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
