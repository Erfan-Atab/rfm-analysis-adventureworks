-- Is SalesOrderDetail NULLABLE?
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
-- It's not

-- Orders without a record in salesOrderDetail
SELECT COUNT(*) AS OrdersWithoutDetail
FROM Sales.SalesOrderHeader AS soh
LEFT JOIN Sales.SalesOrderDetail AS sod
			ON soh.SalesOrderID = sod.SalesOrderID 
WHERE sod.SalesOrderDetailID IS NULL

-- Is sum of lineTotal equal to subTotal?
WITH ltotal AS (
	select SalesOrderID,
			SUM(LineTotal) AS GLineTotal
	from Sales.SalesOrderDetail
	GROUP BY SalesOrderID
)
SELECT COUNT(*) AS CountOfUnMatched
FROM ltotal
LEFT JOIN Sales.SalesOrderHeader AS soh ON soh.SalesOrderID = ltotal.SalesOrderID
WHERE ABS(GLineTotal - SubTotal) > 0.01

-- Are key columns NULLABLE?
SELECT COLUMN_NAME,
		IS_NULLABLE,
		DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'Sales'
		AND TABLE_NAME = 'SalesOrderHeader'
ORDER BY COLUMN_NAME
--
SELECT COLUMN_NAME,
		IS_NULLABLE,
		DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'Sales'
		AND TABLE_NAME = 'SalesOrderDetail'
ORDER BY COLUMN_NAME

-- Are lineTotal, OrderQty, UnitPrice less or equal to zero in anr record?
SELECT COUNT(*)
FROM Sales.SalesOrderDetail
WHERE (lineTotal <= 0) OR (OrderQty <= 0) OR  (UnitPrice <= 0)
--0

-- Are customers with very low Monetary real?
SELECT CustomerID,
		SUM(LineTotal) AS Monatery,
		COUNT(*) AS NumberOFiTEMSOrdered,
		COUNT(DISTINCT sod.SalesOrderID) AS NumberOfOrders
		
FROM Sales.SalesOrderDetail AS sod
LEFT JOIN Sales.SalesOrderHeader AS soh ON sod.SalesOrderID = soh.SalesOrderID
GROUP BY CustomerID
HAVING (SUM(LineTotal) < 5)
ORDER BY SUM(LineTotal) ASC

-- Outliers from high end of distribution
SELECT TOP 10 SalesOrderID AS IDOfOrder,
		UnitPrice AS PriceOfUnit,
		OrderQty AS NumberOfItems,
		LineTotal AS TotalLine
FROM Sales.SalesOrderDetail
ORDER BY LineTotal DESC

