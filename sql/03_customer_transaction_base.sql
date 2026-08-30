-- Evaluating Order-Level Data
WITH OrderLevelRevenue AS (
	SELECT SalesOrderID,
			SUM(LineTotal) AS OrderRevenue
	FROM Sales.SalesOrderDetail
	GROUP BY SalesOrderID
)
SELECT SUM(OrderRevenue) AS TotalRevenue,
		MIN(OrderRevenue) AS MinOrderRevenue,
		COUNT(*) AS OrderCount
FROM OrderLevelRevenue;

-- Customer Count, Total orders and Grand total revenue
WITH OrderLevelRevenue AS (
	SELECT SalesOrderID,
			SUM(LineTotal) AS OrderRevenue
	FROM Sales.SalesOrderDetail
	GROUP BY SalesOrderID
),
OrderWithCustomer AS (
	SELECT OrderLevelRevenue.SalesOrderID,
			OrderRevenue,
			OrderDate,
			CustomerID
	FROM OrderLevelRevenue
	INNER JOIN Sales.SalesOrderHeader AS soh ON OrderLevelRevenue.SalesOrderID = soh.SalesOrderID
),
CustomerDetail AS (
	SELECT OrderWithCustomer.CustomerID,
			COUNT(*) AS OrderCount,
			SUM(OrderWithCustomer.OrderRevenue) AS TotalRevenue,
			MIN(OrderWithCustomer.OrderDate) AS FirstOrderDate,
			MAX(OrderWithCustomer.OrderDate) AS LastOrderDate
	FROM OrderWithCustomer
	GROUP BY CustomerID
),
CustomerData AS (
	SELECT CustomerDetail.CustomerID,
			OrderCount,
			TotalRevenue,
			FirstOrderDate,
			LastOrderDate,
			CASE 
					WHEN StoreID IS NULL THEN 'Individual'
					WHEN PersonID IS NULL THEN 'Store without rep'
					ELSE 'Store with rep'
				END AS CustomerType
	FROM CustomerDetail
	INNER JOIN Sales.Customer AS c ON CustomerDetail.CustomerID = c.CustomerID
)
SELECT COUNT(*) AS CustomerCount,
		SUM(OrderCount) AS TotalOrders,
		SUM(TotalRevenue) AS GrandTotalRevenue,
		SUM(CASE WHEN FirstOrderDate = LastOrderDate THEN 1 ELSE 0 END) AS OneTimeBuyer
FROM CustomerData;

-- Verification
WITH OrderLevelRevenue AS (
	SELECT SalesOrderID,
			SUM(LineTotal) AS OrderRevenue
	FROM Sales.SalesOrderDetail
	GROUP BY SalesOrderID
),
OrderWithCustomer AS (
	SELECT OrderLevelRevenue.SalesOrderID,
			OrderRevenue,
			OrderDate,
			CustomerID
	FROM OrderLevelRevenue
	INNER JOIN Sales.SalesOrderHeader AS soh ON OrderLevelRevenue.SalesOrderID = soh.SalesOrderID
),
CustomerDetail AS (
	SELECT OrderWithCustomer.CustomerID,
			COUNT(*) AS OrderCount,
			SUM(OrderWithCustomer.OrderRevenue) AS TotalRevenue,
			MIN(OrderWithCustomer.OrderDate) AS FirstOrderDate,
			MAX(OrderWithCustomer.OrderDate) AS LastOrderDate
	FROM OrderWithCustomer
	GROUP BY CustomerID
),
CustomerData AS (
	SELECT CustomerDetail.CustomerID,
			OrderCount,
			TotalRevenue,
			FirstOrderDate,
			LastOrderDate,
			CASE 
					WHEN StoreID IS NULL THEN 'Individual'
					WHEN PersonID IS NULL THEN 'Store without rep'
					ELSE 'Store with rep'
				END AS CustomerType
	FROM CustomerDetail
	INNER JOIN Sales.Customer AS c ON CustomerDetail.CustomerID = c.CustomerID
)
SELECT CustomerID,
		OrderCount,
		FirstOrderDate,
		LastOrderDate
FROM CustomerData
WHERE (FirstOrderDate = LastOrderDate) AND (OrderCount > 1);

-- Finding
WITH OrderLevelRevenue AS (
	SELECT SalesOrderID,
			SUM(LineTotal) AS OrderRevenue
	FROM Sales.SalesOrderDetail
	GROUP BY SalesOrderID
),
OrderWithCustomer AS (
	SELECT OrderLevelRevenue.SalesOrderID,
			OrderRevenue,
			OrderDate,
			CustomerID
	FROM OrderLevelRevenue
	INNER JOIN Sales.SalesOrderHeader AS soh ON OrderLevelRevenue.SalesOrderID = soh.SalesOrderID
),
CustomerDetail AS (
	SELECT OrderWithCustomer.CustomerID,
			COUNT(*) AS OrderCount,
			SUM(OrderWithCustomer.OrderRevenue) AS TotalRevenue,
			MIN(OrderWithCustomer.OrderDate) AS FirstOrderDate,
			MAX(OrderWithCustomer.OrderDate) AS LastOrderDate
	FROM OrderWithCustomer
	GROUP BY CustomerID
),
CustomerData AS (
	SELECT CustomerDetail.CustomerID,
			OrderCount,
			TotalRevenue,
			FirstOrderDate,
			LastOrderDate,
			CASE 
					WHEN StoreID IS NULL THEN 'Individual'
					WHEN PersonID IS NULL THEN 'Store without rep'
					ELSE 'Store with rep'
				END AS CustomerType
	FROM CustomerDetail
	INNER JOIN Sales.Customer AS c ON CustomerDetail.CustomerID = c.CustomerID
)
SELECT CustomerType,
		COUNT(*) AS CustomerCount
FROM CustomerData
GROUP BY CustomerType
ORDER BY COUNT(*) DESC


