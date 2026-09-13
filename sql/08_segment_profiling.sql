-- CTE has been completely copied from 06_rfm_scoring.sql & 07_customer_segmentation.sql . If needed all three must be changed
--
WITH Percentiles AS(
SELECT CustomerID,
		CustomerType,
		Recency,
		Frequency,
		Monetary,
		PERCENT_RANK()
		OVER (PARTITION BY CustomerType ORDER BY Recency DESC) AS RPercentile,
		PERCENT_RANK() 
		OVER (PARTITION BY CustomerType ORDER BY Frequency ASC) AS FPercentile,
		PERCENT_RANK() 
		OVER (PARTITION BY CustomerType ORDER BY Monetary ASC) AS MPercentile
FROM rfm.vw_CustomerRFM
),
Scores AS (
SELECT CustomerID,
		CustomerType,
		Recency,
		Frequency,
		Monetary,
		RPercentile,
		CASE 
			WHEN RPercentile <= 0.2 THEN 1
			WHEN RPercentile <= 0.4 THEN 2
			WHEN RPercentile <= 0.6 THEN 3
			WHEN RPercentile <= 0.8 THEN 4
			WHEN RPercentile <= 1 THEN 5
		END AS RScore,
		CASE 
			WHEN FPercentile <= 0.2 THEN 1
			WHEN FPercentile <= 0.4 THEN 2
			WHEN FPercentile <= 0.6 THEN 3
			WHEN FPercentile <= 0.8 THEN 4
			WHEN FPercentile <= 1 THEN 5
		END AS FScore,
		CASE 
			WHEN MPercentile <= 0.2 THEN 1
			WHEN MPercentile <= 0.4 THEN 2
			WHEN MPercentile <= 0.6 THEN 3
			WHEN MPercentile <= 0.8 THEN 4
			WHEN MPercentile <= 1 THEN 5
		END AS MScore
FROM Percentiles
),
Segments AS (
SELECT CustomerID,
		CustomerType,
		Recency,
		Frequency,
		Monetary,
		RScore, 
		FScore,
		MScore,
		CASE
			WHEN RScore IN (4,5) AND FScore IN (4,5) AND MScore IN (4,5) THEN 'High Value'
			WHEN RScore IN (1,2) AND FScore IN (4,5) AND MScore IN (4,5) THEN 'Churn Risk'
			WHEN RScore IN (1,2) AND FScore = 1 AND MScore IN (4,5) THEN 'High Value Lapsed'
			WHEN RScore IN (4,5) AND FScore = 1 THEN 'New Customer'
			WHEN FScore IN (4,5) AND MScore IN (1,2) THEN 'Loyal Small Spender'
			WHEN RScore IN (3,4,5) AND MScore = 3 THEN 'Medium Value'
			WHEN RScore IN (1,2) AND FScore = 1 AND MScore = 1 THEN 'Low Value'
			ELSE 'Mid Recency Active'
			END AS Segment
FROM Scores
)
-- checking the distribution of scores in Unclassified wighch made me change the name to  Mid Recency Active
-----------------------------
/*
SELECT CustomerType,
		RScore,
		FScore,
		MScore,
		COUNT(*) AS CustomerCount
FROM Segments
WHERE Segment = 'Mid Recency Active'
GROUP BY CustomerType, RScore, FScore, MScore
ORDER BY CustomerCount DESC
*/
-----------------------------
,
Medians AS (
SELECT Segment,
		CustomerType,
		Recency,
		Frequency,
		Monetary,
		PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Recency ASC) OVER(PARTITION BY Segment, CustomerType) AS MedianRecency,
		PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Frequency ASC) OVER(PARTITION BY Segment, CustomerType) AS MedianFrequency,
		PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Monetary ASC) OVER(PARTITION BY Segment, CustomerType) AS MedianMonetary
FROM Segments
)
--, Profiling AS (
SELECT Segment,
		CustomerType,
		COUNT(*) AS CustomerCount,
		CAST(SUM(Recency) / CAST(COUNT(*) AS decimal(10,2))AS decimal(10,2)) AS AvgRecency,
		CAST(SUM(Frequency) / CAST(COUNT(*) AS decimal(10,2))AS decimal(10,2)) AS AvgFrequency,
		CAST(SUM(Monetary) / CAST(COUNT(*) AS decimal(10,2))AS decimal(10,2)) AS AvgMonetary,
		MIN(MedianRecency) AS MedianRecency,
		MIN(MedianFrequency) AS MedianFrequency,
		CAST(MIN(MedianMonetary) AS decimal(10,2)) AS MedianMonetary,
		CAST(SUM(Monetary) AS decimal(10,2)) AS TotalRevenue,
		CAST((CAST(COUNT(*) AS decimal(10,2)) / CAST( SUM(COUNT(*)) OVER(PARTITION BY CustomerType) AS decimal(10,2))) * 100 AS decimal(5,2)) AS PopulationSharePct,
		CAST((SUM(Monetary) / CAST(SUM(SUM(Monetary)) OVER(PARTITION BY CustomerType) AS decimal(10,2))) * 100 AS decimal(5,2)) AS RevenueSharePct
FROM Medians
GROUP BY Segment, CustomerType

-- checking data integrity
-------------------
/*
)
SELECT SUM(CustomerCount) AS TotalCustomers,
		SUM(TotalRevenue) AS TotalGrandRevenue
FROM Profiling
*/
-------------------
-- is sum of percentges 100?
/*
)
SELECT CustomerType,
		SUM(PopulationSharePct) AS SumPopulationPct,
		SUM(RevenueSharePct) AS SumRevenuePct
FROM Profiling
GROUP BY CustomerType
*/
-------------------
-- do the names match the data?
/*
)
SELECT CustomerType,
		MAX(CASE WHEN Segment = 'High Value' THEN AvgMonetary END) AS AvgMonetaryHighValue,
		MAX(CASE WHEN Segment = 'Low Value' THEN AvgMonetary END) AS AvgMonetaryLowValue
FROM Profiling
GROUP BY CustomerType
*/

