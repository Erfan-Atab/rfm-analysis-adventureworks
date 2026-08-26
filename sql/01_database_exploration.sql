-- Taking a look in sales.SalesOrderHeader & SalesOrderDetail
SELECT *
FROM sales.SalesOrderHeader

SELECT *
FROM sales.SalesOrderDetail

-- Number of records in SalesOrderHeader
SELECT COUNT(*)
FROM sales.SalesOrderHeader
--31465

-- Number of records in SalesOrderDetail
SELECT COUNT(*)
FROM Sales.SalesOrderDetail
--121317

-- Number of customers that have put in an order
SELECT COUNT(DISTINCT CustomerID)
FROM Sales.SalesOrderHeader
--19119

-- Numcer of all customers
SELECt COUNT(*)
FROM sales.Customer
--19820

-- Last day of sales
SELECT MAX(OrderDate) AS MaximumDate
FROM Sales.SalesOrderHeader
--2014-06-30 00:00:00.000

-- First day of sales
SELECT MIN(OrderDate) AS MinimumDate
FROM Sales.SalesOrderHeader
--2011-05-31 00:00:00.000

-- Orders per year
SELECT DATEPART(YYYY,OrderDate) AS Year,
		SUM(TotalDue) AS SellAmount,
		COUNT(TotalDue) AS SellCount
FROM Sales.SalesOrderHeader
GROUP BY DATEPART(YYYY,OrderDate)
ORDER BY Year ASC

-- Count of online and offline orders
SELECT OnlineOrderFlag,
		COUNT(*) AS "Count"
FROM Sales.SalesOrderHeader
GROUP BY OnlineOrderFlag

-- Checking Sales.Customer
SELECT * 
FROM Sales.Customer

-- Count of each kind of customers
SELECT
	SUM(CASE WHEN PersonID IS NOT NULL AND StoreID IS NULL THEN 1 ELSE 0 END) AS Person,
	SUM(CASE WHEN StoreID IS NOT NULL AND PersonID IS NULL THEN 1 ELSE 0 END) AS "Store without rep",
	SUM(CASE WHEN StoreID IS NOT NULL AND PersonID IS NOT NULL THEN 1 ELSE 0 END) AS "Store with rep"
FROM Sales.Customer

-- Count of each kind of customers
SELECT  
		CASE 
			WHEN StoreID IS NULL THEN 'Individual'
			WHEN PersonID IS NULL THEN 'Store without rep'
			ELSE 'Store with rep'
		END AS TypeOfCustomer
		,COUNT(*) AS "Count"
FROM Sales.Customer
GROUP BY
		CASE 
			WHEN StoreID IS NULL THEN 'Individual'
			WHEN PersonID IS NULL THEN 'Store without rep'
			ELSE 'Store with rep'
		END

-- Count of customers for each group in SalesOrderHeader
SELECT 
	CASE 
			WHEN StoreID IS NULL THEN 'Individual'
			WHEN PersonID IS NULL THEN 'Store without rep'
			ELSE 'Store with rep'
		END AS TypeOfCustomer,
		COUNT(DISTINCT c.CustomerID)
FROM Sales.Customer AS c
	INNER JOIN Sales.SalesOrderHeader AS soh
	ON soh.CustomerID = c.CustomerID
GROUP BY
		CASE 
			WHEN StoreID IS NULL THEN 'Individual'
			WHEN PersonID IS NULL THEN 'Store without rep'
			ELSE 'Store with rep'
		END

-- Count of orders in each status
SELECT COUNT(*)
FROM Sales.SalesOrderHeader
GROUP BY Status;

-- Count of order distribution for each customer
WITH cte_freq AS (
	SELECT CustomerID,COUNT(*) AS NumberOfOrders
	FROM Sales.SalesOrderHeader
	GROUP BY CustomerID
),
typed AS (
	SELECT cte_freq.CustomerID,
			cte_freq.NumberOfOrders,
			CASE 
				WHEN StoreID IS NULL THEN 'Individual'
				WHEN PersonID IS NULL THEN 'Store without rep'
				ELSE 'Store with rep'
			END AS TypeOfCustomer
	FROM cte_freq
	JOIN Sales.Customer AS c ON cte_freq.CustomerID = c.CustomerID
)

SELECT TypeOfCustomer,
		COUNT(*) AS CustomerCount,
		SUM(NumberOfOrders) AS TotalOrders,
		AVG(NumberOfOrders * 1.0) AS AvgOrderPerCustomer
FROM typed
GROUP BY TypeOfCustomer
ORDER BY CustomerCount DESC;

-- Total Purchase for each customer
WITH total AS (
	SELECT CustomerID,SUM(LineTotal) AS TotalAmountOfOrders
	FROM Sales.SalesOrderHeader AS soh
	JOIN Sales.SalesOrderDetail AS sod ON soh.SalesOrderID = sod.SalesOrderID
	GROUP BY CustomerID
),
typed AS (
	SELECT total.CustomerID,
			total.TotalAmountOfOrders,
			CASE 
				WHEN StoreID IS NULL THEN 'Individual'
				WHEN PersonID IS NULL THEN 'Store without rep'
				ELSE 'Store with rep'
			END AS TypeOfCustomer
	FROM total
	JOIN Sales.Customer AS c ON total.CustomerID = c.CustomerID
)

SELECT TypeOfCustomer,
		COUNT(*) AS CustomerCount,
		SUM(TotalAmountOfOrders) AS TotalRevenue,
		MAX(TotalAmountOfOrders) AS MaximummAmount,
		MIN(TotalAmountOfOrders) AS MinimummAmount,
		AVG(TotalAmountOfOrders) AS AvgRevenuePerCustomer
FROM typed
GROUP BY TypeOfCustomer
ORDER BY CustomerCount DESC;


