-- CTE has been completely copied from 06_rfm_scoring.sql , 07_customer_segmentation.sql & 08_segment_profiling . If needed all three must be changed

-- Is `New Customer` realy new?
WITH Percentiles AS(
	SELECT CustomerID,
			CustomerType,
			Recency,
			Frequency,
			Monetary,
			-- carried through for tenure calculation
			FirstOrderDate,
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
			-- carried through for tenure calculation
			FirstOrderDate,
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
			-- carried through for tenure calculation
			FirstOrderDate,
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
),
	Tenure AS (
	SELECT CustomerID,
			CustomerType,
			Segment,
			FirstOrderDate,
			DATEDIFF(DAY,FirstOrderDate,'2014-07-01') AS TenureDays,
			CASE
				WHEN CustomerType = 'Individual' THEN 336
				WHEN CustomerType = 'Store with rep' THEN 91
			END AS CycleThresholdDays
	FROM Segments
)
SELECT CustomerType,
		COUNT(*) AS CustomerCount,
		SUM(CASE WHEN TenureDays < CycleThresholdDays THEN 1 ELSE 0 END) AS TenureWithinCycleCount,
		CAST(CAST(SUM(CASE WHEN TenureDays < CycleThresholdDays THEN 1 ELSE 0 END) AS decimal(10,2)) / CAST(COUNT(*) AS decimal(10,2)) * 100 AS decimal(5,2)) AS TenureWithinCyclePct
FROM Tenure
WHERE Segment = 'New Customer'
GROUP BY CustomerType
ORDER BY CustomerCount;

-- comparing the view with SalesOrderHeader, and the TenureDays query versus Recency
WITH Percentiles AS(
	SELECT CustomerID,
			CustomerType,
			Recency,
			Frequency,
			Monetary,
			-- carried through for tenure calculation
			FirstOrderDate,
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
			-- carried through for tenure calculation
			FirstOrderDate,
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
			-- carried through for tenure calculation
			FirstOrderDate,
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
	SELECT CustomerID,
			CustomerType,
			DATEDIFF(DAY,FirstOrderDate,'2014-07-01') AS TenureDays,
			Recency
	FROM Segments
	WHERE CustomerType = 'Store with rep' AND Segment = 'New Customer';

	-- Are stores buying in a specific cycle
	WITH OrderGaps AS (
	SELECT soh.CustomerID,
			CustomerType,
			OrderDate,
			LAG(OrderDate) OVER(PARTITION BY soh.CustomerID ORDER BY OrderDate) AS PreviousOrderDate
	FROM Sales.SalesOrderHeader AS soh
	INNER JOIN rfm.vw_CustomerRFM AS vw ON soh.CustomerID = vw.CustomerID
WHERE CustomerType = 'Store with rep'
),
Gaps AS (
SELECT CustomerID,
		CustomerType,
		PreviousOrderDate,
		OrderDate,
		DATEDIFF(DAY,PreviousOrderDate,OrderDate) AS DaysBetweenOrders
FROM OrderGaps
)
SELECT DaysBetweenOrders,
		COUNT(*) AS OccurrenceCount
FROM Gaps
WHERE PreviousOrderDate IS NOT NULL
GROUP BY DaysBetweenOrders
ORDER BY OccurrenceCount DESC;

---------------
WITH LapsedStores AS (
    SELECT CustomerID,
           Recency,
           Monetary
    FROM rfm.vw_CustomerRFM
	-- 273 comes from queries above which determined any store that wasn't active three cycles, is Lapsed.
    WHERE CustomerType = 'Store with rep' AND Recency > 273
),
WithMedian AS (
    SELECT Recency,
           Monetary,
           PERCENTILE_CONT(0.5) 
				WITHIN GROUP (ORDER BY Recency)
				OVER () AS MedianRecencyDays
    FROM LapsedStores
)
SELECT COUNT(*) AS LapsedStoreCount,
		SUM(Monetary) AS HistoricalRevenue,
		MIN(MedianRecencyDays) AS MedianRecencyDays,
		MIN(Recency) AS MinRecencyDays,
		MAX(Recency) AS MaxRecencyDays
FROM WithMedian;

-- finding valuable segments from Lapsed Stores
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
),
	WithMedian AS (
		SELECT Recency,
			   Monetary,
			   Segment,
			   PERCENTILE_CONT(0.5) 
					WITHIN GROUP (ORDER BY Recency)
					OVER (PARTITION BY Segment) AS MedianRecencyDays
		FROM Segments
		WHERE CustomerType = 'Store with rep' AND Recency > 273
)
SELECT Segment,
		COUNT(*) AS LapsedStoreCount,
		SUM(Monetary) AS HistoricalRevenue,
		CAST((SUM(Monetary) / SUM(SUM(Monetary)) OVER()) * 100 AS decimal(5,2)) AS RevenueSharePct,
		MIN(MedianRecencyDays) AS MedianRecencyDays,
		MIN(Recency) AS MinRecencyDays,
		MAX(Recency) AS MaxRecencyDays
FROM WithMedian
GROUP BY Segment
ORDER BY HistoricalRevenue DESC;


-- Monetary share of each CustomerType & segment from the Grand Total Renvenue
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
SELECT CustomerType,
		Segment,
		SUM(Monetary) AS SegmentRevenue,
		CAST((SUM(Monetary) / SUM(SUM(Monetary)) OVER()) * 100 AS decimal(5,2)) AS ProjectRevenueSharePct
FROM Segments
GROUP BY CustomerType, Segment
ORDER BY SegmentRevenue DESC;
