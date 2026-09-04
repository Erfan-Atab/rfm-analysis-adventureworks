/*
Purpose:  Build the customer-level RFM base view.
Creates:  rfm.vw_CustomerRFM  (schema rfm)
*/

--
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'rfm')
    EXEC('CREATE SCHEMA rfm');
GO
--
DROP VIEW IF EXISTS rfm.vw_CustomerRFM;
GO
--
CREATE VIEW rfm.vw_CustomerRFM AS
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
		GROUP BY OrderWithCustomer.CustomerID
	),
	CustomerData AS (
		SELECT CustomerDetail.CustomerID,
				OrderCount,
				TotalRevenue,
				FirstOrderDate,
				LastOrderDate,
				CASE 
						WHEN c.StoreID IS NULL THEN 'Individual'
						WHEN c.PersonID IS NULL THEN 'Store without rep'
						ELSE 'Store with rep'
					END AS CustomerType
		FROM CustomerDetail
		INNER JOIN Sales.Customer AS c ON CustomerDetail.CustomerID = c.CustomerID
	)
	SELECT CustomerID,
			CustomerType,
			-- '2014-07-01' comes from last order of database + 1
			DATEDIFF(DAY,LastOrderDate,'2014-07-01') AS Recency,
			OrderCount AS Frequency,
			TotalRevenue AS Monetary,
			FirstOrderDate,
			LastOrderDate
	FROM CustomerData;
GO

--
SELECT COUNT(*) AS CustomerCount,
		MIN(Recency) AS MinRecency,
		MAX(Recency) AS MaxRecency,
		SUM(CASE WHEN Recency < 1 THEN 1 ELSE 0 END) AS NegativeRecencyCount,
		SUM(Frequency) AS TotalOrder,
		SUM(Monetary) AS GrandTotalRevenue
FROM rfm.vw_CustomerRFM