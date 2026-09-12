
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
)
-- Order Of CASEs are intentional
SELECT CustomerType,
		SUM(CASE WHEN RScore IN (4,5) AND FScore IN (4,5) AND MScore IN (4,5) THEN 1 ELSE 0 END) AS HighValue,
		SUM(CASE WHEN RScore IN (1,2) AND FScore IN (4,5) AND MScore IN (4,5) THEN 1 ELSE 0 END) AS ChurnRisk,
		SUM(CASE WHEN RScore IN (1,2) AND FScore = 1 AND MScore IN (4,5) THEN 1 ELSE 0 END) AS HighValueOneTimeCustomer,
		SUM(CASE WHEN RScore IN (4,5) AND FScore = 1 THEN 1 ELSE 0 END) AS NewCustomer,
		SUM(CASE WHEN FScore IN (4,5) AND MScore IN (1,2) THEN 1 ELSE 0 END) AS LoyalSmallCustomer,
		SUM(CASE WHEN RScore IN (3,4,5) AND MScore = 3 THEN 1 ELSE 0 END) AS MediumValue,
		SUM(CASE WHEN RScore IN (1,2) AND FScore = 1 AND MScore = 1 THEN 1 ELSE 0 END) AS LowValue,
		COUNT(*) AS CustomerCount
FROM Scores
GROUP BY CustomerType
ORDER BY CustomerType;

-- Part of this part is the exact copy of the quary above. Any changes should effect both parts.
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
)
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
			WHEN RScore IN (1,2) AND FScore = 1 AND MScore IN (4,5) THEN 'High Value One-Time'
			WHEN RScore IN (4,5) AND FScore = 1 THEN 'New Customer'
			WHEN FScore IN (4,5) AND MScore IN (1,2) THEN 'Loyal Small Spender'
			WHEN RScore IN (3,4,5) AND MScore = 3 THEN 'Medium Value'
			WHEN RScore IN (1,2) AND FScore = 1 AND MScore = 1 THEN 'Low Value'
			ELSE 'Unclassified'
			END AS Segment
FROM Scores
ORDER BY CustomerType, Segment;

-- Segments distribution
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
			WHEN RScore IN (1,2) AND FScore = 1 AND MScore IN (4,5) THEN 'High Value One-Time'
			WHEN RScore IN (4,5) AND FScore = 1 THEN 'New Customer'
			WHEN FScore IN (4,5) AND MScore IN (1,2) THEN 'Loyal Small Spender'
			WHEN RScore IN (3,4,5) AND MScore = 3 THEN 'Medium Value'
			WHEN RScore IN (1,2) AND FScore = 1 AND MScore = 1 THEN 'Low Value'
			ELSE 'Unclassified'
			END AS Segment
FROM Scores
)
SELECT Segment,
		CustomerType,
		COUNT(*) AS CustomerCount
FROM Segments
GROUP BY Segment, CustomerType;

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
			WHEN RScore IN (1,2) AND FScore = 1 AND MScore IN (4,5) THEN 'High Value One-Time'
			WHEN RScore IN (4,5) AND FScore = 1 THEN 'New Customer'
			WHEN FScore IN (4,5) AND MScore IN (1,2) THEN 'Loyal Small Spender'
			WHEN RScore IN (3,4,5) AND MScore = 3 THEN 'Medium Value'
			WHEN RScore IN (1,2) AND FScore = 1 AND MScore = 1 THEN 'Low Value'
			ELSE 'Unclassified'
			END AS Segment
FROM Scores
)
SELECT COUNT(*) AS CustomerCount,
        SUM(CASE WHEN Segment IS NULL THEN 1 ELSE 0 END) AS NullSegmentCount
FROM Segments;

 -- checking conflict bitween New Customer & Medium Value
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
)
SELECT CustomerType,
		SUM(CASE WHEN RScore IN (4,5) AND FScore = 1 AND MScore = 3 THEN 1 ELSE 0 END) AS CustomerCount
FROM Scores
GROUP BY CustomerType
ORDER BY CustomerType;