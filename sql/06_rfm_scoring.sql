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
--ORDER BY CustomerType, RScore DESC, FScore DESC, MScore DESC
)
---------
/*
SELECT COUNT(*) AS RecordCount,
		SUM(CASE WHEN RScore < 1 OR RScore > 5 THEN 1 ELSE 0 END) AS RInvalidCount,
		SUM(CASE WHEN FScore < 1 OR FScore > 5 THEN 1 ELSE 0 END) AS FInvalidCount,
		SUM(CASE WHEN MScore < 1 OR MScore > 5 THEN 1 ELSE 0 END) AS MInvalidCount,
		SUM(CASE WHEN RScore IS NULL THEN 1 ELSE 0 END) AS RNullCount,
		SUM(CASE WHEN FScore IS NULL THEN 1 ELSE 0 END) AS FNullCount,
		SUM(CASE WHEN MScore IS NULL THEN 1 ELSE 0 END) AS MNullCount,
		SUM(Frequency) AS OrderCount,
		SUM(Monetary) AS TotalRevenue
FROM Scores;
*/
---------
/*
SELECT CustomerType,
		MAX(CASE WHEN RScore = 5 THEN Recency END) AS MaxRecencyAtScore5,
		MIN(CASE WHEN RScore = 1 THEN Recency END) AS MinRecencyAtScore1
FROM Scores
GROUP BY CustomerType;
*/
,
ScoreCeiling AS (
SELECT CustomerType,
		Recency,
		RScore,
		MAX(RScore) OVER(PARTITION BY CustomerType) AS MaxRScoreInType
FROM Scores
)
SELECT CustomerType,
		MAX(MaxRScoreInType) AS MaxScoreInType,
		MAX(CASE WHEN RScore = MaxRScoreInType THEN Recency END) AS MaxRecencyAtTopScore,
		MIN(CASE WHEN RScore = 1 THEN Recency END) AS MinRecencyAtScore1
FROM ScoreCeiling
GROUP BY CustomerType
ORDER BY CustomerType;


---------
/*
SELECT CustomerType,
		'Recency' AS Metric,
		RScore AS Score,
		COUNT(*) AS CustomerCount
FROM Scores
GROUP BY CustomerType,RScore


UNION ALL

SELECT CustomerType,
		'Frequency' AS Metric,
		FScore AS Score,
		COUNT(*) AS CustomerCount
FROM Scores
GROUP BY CustomerType,FScore


UNION ALL

SELECT CustomerType,
		'Monetary' AS Metric,
		MScore AS Score,
		COUNT(*) AS CustomerCount
FROM Scores
GROUP BY CustomerType,MScore
ORDER BY CustomerType,Metric, Score;
*/
---------
/*
SELECT CustomerType,
		Recency,
		RScore,
		RPercentile,
		COUNT(*) AS CustomerCount
FROM Scores
WHERE CustomerType = 'Store with rep'
GROUP BY CustomerType, Recency, RScore, RPercentile
ORDER BY Recency ASC
*/
--------

