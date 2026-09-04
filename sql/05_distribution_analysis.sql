-- Summary statistics by customer type
SELECT CustomerType,
		COUNT(*) AS CustomerCount,
		MAX(Recency) AS MaxRecency,
		MIN(Recency) AS MinRecency,
		SUM(Frequency) AS TotalOrders,
		CAST(AVG(CAST(Frequency AS decimal(10,2))) AS decimal(10,2)) AS AvgFrequency,
		MAX(Frequency) AS MaxFrequency,
		MIN(Frequency) AS MinFrequency,
		SUM(Monetary) AS TotalRevenue,
		AVG(Monetary) AS AvgMonetary,
		MAX(Monetary) AS MaxMonetary,
		MIN(Monetary) AS MinMonetary
FROM rfm.vw_CustomerRFM
GROUP BY CustomerType
ORDER BY CustomerCount DESC;

--
WITH FrequencyDistribution AS (
SELECT CustomerType,
       Frequency,
       COUNT(*) AS CustomerCount
FROM rfm.vw_CustomerRFM
GROUP BY CustomerType, Frequency
)
SELECT CustomerType,
       Frequency,
       CustomerCount,
       CAST((CAST(CustomerCount AS decimal(10,5)) / CAST(SUM(CustomerCount) OVER (PARTITION BY CustomerType) AS decimal(10,5)) * 100) AS decimal(5,2)) AS ShareOfGroupPct,
       CAST((CAST(SUM(CAST(CustomerCount AS decimal(10,5))) OVER (PARTITION BY CustomerType ORDER BY Frequency ASC) /
                    SUM(CAST(CustomerCount AS decimal(10,5))) OVER (PARTITION BY CustomerType) AS decimal(10,5)) * 100) AS decimal(5,2)) AS CumulativeSharePct
FROM FrequencyDistribution
ORDER BY CustomerType, Frequency;

--
WITH RecencyCount AS (
	SELECT CustomerType,
			Recency,
			COUNT(*) AS CustomerCount
	FROM rfm.vw_CustomerRFM
	GROUP BY CustomerType, Recency
),
RankedRecency AS ( 
	SELECT CustomerType,
			Recency,
			CustomerCount,
			COUNT(*) OVER (PARTITION BY CustomerType) AS DistinctValueCount,
			CAST((CustomerCount /
								(SUM(CAST(CustomerCount AS decimal(10,5))) OVER (PARTITION BY CustomerType)) * 100) AS decimal(5,2)) AS TopValueSharePct,
			RANK() OVER (PARTITION BY CustomerType ORDER BY CustomerCount DESC) AS CountRank
	FROM RecencyCount
),
MonetaryCount AS (
	SELECT CustomerType,
			Monetary,
			COUNT(*) AS CustomerCount
	FROM rfm.vw_CustomerRFM
	GROUP BY CustomerType, Monetary
),
RankedMonetary AS ( 
	SELECT CustomerType,
			Monetary,
			CustomerCount,
			COUNT(Monetary) OVER (PARTITION BY CustomerType) AS DistinctValueCount,
			CAST((CustomerCount /
								(SUM(CAST(CustomerCount AS decimal(10,5))) OVER (PARTITION BY CustomerType)) * 100) AS decimal(5,2)) AS TopValueSharePct,
			RANK() OVER (PARTITION BY CustomerType ORDER BY CustomerCount DESC) AS CountRank
	FROM MonetaryCount
)
SELECT CustomerType,
		'Recency' AS "Metric",
		Recency AS TopValue,
		CustomerCount,
		CountRank,
		DistinctValueCount,
		TopValueSharePct
FROM RankedRecency
WHERE CountRank = 1

UNION ALL

SELECT CustomerType,
		'Monetary' AS "Metric",
		Monetary AS TopValue,
		CustomerCount,
		CountRank,
		DistinctValueCount,
		TopValueSharePct
FROM RankedMonetary
WHERE CountRank = 1
ORDER BY CustomerType, "Metric";

----------------------------------------------------------
SELECT DISTINCT CustomerType,
		CAST(PERCENTILE_CONT(0.1)
			WITHIN GROUP( ORDER BY Monetary)
			OVER(PARTITION BY CustomerType) AS decimal(10,2)) AS P10,
		CAST(PERCENTILE_CONT(0.25)
			WITHIN GROUP( ORDER BY Monetary)
			OVER(PARTITION BY CustomerType) AS decimal(10,2)) AS P25,
		CAST(PERCENTILE_CONT(0.5)
			WITHIN GROUP( ORDER BY Monetary)
			OVER(PARTITION BY CustomerType) AS decimal(10,2)) AS P50,
		CAST(PERCENTILE_CONT(0.75)
			WITHIN GROUP( ORDER BY Monetary)
			OVER(PARTITION BY CustomerType) AS decimal(10,2)) AS P75,
		CAST(PERCENTILE_CONT(0.9)
			WITHIN GROUP( ORDER BY Monetary)
			OVER(PARTITION BY CustomerType) AS decimal(10,2)) AS P90,
		CAST(PERCENTILE_CONT(0.99)
			WITHIN GROUP( ORDER BY Monetary)
			OVER(PARTITION BY CustomerType) AS decimal(10,2)) AS P99,
		CAST(AVG(Monetary) OVER(PARTITION BY CustomerType) AS decimal(18,2)) AS AvgMonetary
FROM rfm.vw_CustomerRFM
ORDER BY CustomerType;
	