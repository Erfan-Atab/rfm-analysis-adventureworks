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
