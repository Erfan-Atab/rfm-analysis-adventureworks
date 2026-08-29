--
WITH OrderLevelRevenue AS (
	SELECT SalesOrderID,
			SUM(LineTotal) AS OrderRevenue
	FROM Sales.SalesOrderDetail
	GROUP BY SalesOrderID
)
SELECT SUM(OrderRevenue) AS TotalRevenue,
		MIN(OrderRevenue) AS MinOrderRevenue,
		COUNT(*) AS OrderCount
FROM OrderLevelRevenue
