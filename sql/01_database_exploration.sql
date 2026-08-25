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
SELECT COUNT(DISTINCT(CustomerID))
FROM Sales.SalesOrderHeader
--19119

-- Numcer of all customers
SELECt COUNT(*)
FROM sales.Customer
--19820

-- Last day of sales
SELECT MAX(OrderDate) AS MaximumDate
FROM Sales.SalesOrderHeader

-- First day of sales
SELECT MIN(OrderDate) AS MinimumDate
FROM Sales.SalesOrderHeader
--2011-05-31 00:00:00.000

-- Orders per year
SELECT DATEPART(YYYY,OrderDate) AS Year,
		SUM(TotalDue) AS SellAmount
FROM Sales.SalesOrderHeader
GROUP BY DATEPART(YYYY,OrderDate)
ORDER BY Year ASC

-- Count of online and offline orders
SELECT OnlineOrderFlag,
		COUNT(OnlineOrderFlag) AS "Count"
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

-- Count of customers in SalesOrderHeader
SELECT COUNT(DISTINCT(CustomerID))
FROM Sales.SalesOrderHeader
--19119
