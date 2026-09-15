-- ============================================================
-- Superstore Sales Data Analysis using SQL Server
-- Database: SuperstoreSalesDB
-- ============================================================

-- Create Database
CREATE DATABASE SuperstoreSalesDB;
GO

USE SuperstoreSalesDB;
GO

-- ============================================================
-- 1. Create Tables
-- ============================================================

CREATE TABLE Customers (
    CustomerID VARCHAR(20) PRIMARY KEY,
    CustomerName VARCHAR(100),
    Segment VARCHAR(50)
);

CREATE TABLE Products (
    ProductID VARCHAR(20) PRIMARY KEY,
    ProductName VARCHAR(255),
    Category VARCHAR(50),
    SubCategory VARCHAR(50)
);

CREATE TABLE Locations (
    PostalCode VARCHAR(20) PRIMARY KEY,
    City VARCHAR(100),
    State VARCHAR(100),
    Country VARCHAR(100),
    Region VARCHAR(50)
);

CREATE TABLE Orders (
    OrderID VARCHAR(20) PRIMARY KEY,
    OrderDate DATE,
    ShipDate DATE,
    ShipMode VARCHAR(50),
    CustomerID VARCHAR(20),
    PostalCode VARCHAR(20),

    CONSTRAINT FK_Orders_Customers
        FOREIGN KEY (CustomerID)
        REFERENCES Customers(CustomerID),

    CONSTRAINT FK_Orders_Locations
        FOREIGN KEY (PostalCode)
        REFERENCES Locations(PostalCode)
);

CREATE TABLE OrderDetails (
    OrderDetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID VARCHAR(20),
    ProductID VARCHAR(20),
    Sales DECIMAL(18,2),
    Quantity INT,
    Discount DECIMAL(5,2),
    Profit DECIMAL(18,2),

    CONSTRAINT FK_OrderDetails_Orders
        FOREIGN KEY (OrderID)
        REFERENCES Orders(OrderID),

    CONSTRAINT FK_OrderDetails_Products
        FOREIGN KEY (ProductID)
        REFERENCES Products(ProductID)
);
GO

-- ============================================================
-- 2. Staging Table
-- ============================================================

CREATE TABLE Staging_Superstore (
    OrderID VARCHAR(20),
    OrderDate DATE,
    ShipDate DATE,
    ShipMode VARCHAR(50),
    CustomerID VARCHAR(20),
    CustomerName VARCHAR(100),
    Segment VARCHAR(50),
    City VARCHAR(100),
    State VARCHAR(100),
    PostalCode VARCHAR(20),
    Region VARCHAR(50),
    ProductID VARCHAR(20),
    Category VARCHAR(50),
    SubCategory VARCHAR(50),
    ProductName VARCHAR(255),
    Sales DECIMAL(18,2),
    Quantity INT,
    Discount DECIMAL(5,2),
    Profit DECIMAL(18,2)
);
GO

-- ============================================================
-- 3. Load Customers
-- ============================================================

INSERT INTO dbo.Customers
(
    CustomerID,
    CustomerName,
    Segment
)
SELECT DISTINCT
    Customer_ID,
    Customer_Name,
    Segment
FROM dbo.samplesuperstore
WHERE Customer_ID IS NOT NULL;
GO

-- ============================================================
-- 4. Load Products
-- Handles duplicate Product IDs using ROW_NUMBER()
-- ============================================================

;WITH ProductData AS
(
    SELECT
        Product_ID,
        Product_Name,
        Category,
        Sub_Category,

        ROW_NUMBER() OVER
        (
            PARTITION BY Product_ID
            ORDER BY Product_Name
        ) AS rn

    FROM dbo.samplesuperstore
    WHERE Product_ID IS NOT NULL
)
INSERT INTO dbo.Products
(
    ProductID,
    ProductName,
    Category,
    SubCategory
)
SELECT
    Product_ID,
    Product_Name,
    Category,
    Sub_Category
FROM ProductData
WHERE rn = 1;
GO

-- ============================================================
-- 5. Load Locations
-- ============================================================

;WITH LocationData AS
(
    SELECT
        Postal_Code,
        City,
        State_Province,
        Country_Region,
        Region,

        ROW_NUMBER() OVER
        (
            PARTITION BY Postal_Code
            ORDER BY City
        ) AS rn

    FROM dbo.samplesuperstore
    WHERE Postal_Code IS NOT NULL
)
INSERT INTO dbo.Locations
(
    PostalCode,
    City,
    State,
    Country,
    Region
)
SELECT
    Postal_Code,
    City,
    State_Province,
    Country_Region,
    Region
FROM LocationData
WHERE rn = 1;
GO

-- ============================================================
-- 6. Load Orders
-- ============================================================

;WITH OrderData AS
(
    SELECT
        Order_ID,
        Order_Date,
        Ship_Date,
        Ship_Mode,
        Customer_ID,
        Postal_Code,

        ROW_NUMBER() OVER
        (
            PARTITION BY Order_ID
            ORDER BY Order_Date
        ) AS rn

    FROM dbo.samplesuperstore
    WHERE Order_ID IS NOT NULL
)
INSERT INTO dbo.Orders
(
    OrderID,
    OrderDate,
    ShipDate,
    ShipMode,
    CustomerID,
    PostalCode
)
SELECT
    Order_ID,
    Order_Date,
    Ship_Date,
    Ship_Mode,
    Customer_ID,
    Postal_Code
FROM OrderData
WHERE rn = 1;
GO

-- ============================================================
-- 7. Load Order Details
-- ============================================================

INSERT INTO dbo.OrderDetails
(
    OrderID,
    ProductID,
    Sales,
    Quantity,
    Discount,
    Profit
)
SELECT
    Order_ID,
    Product_ID,
    Sales,
    Quantity,
    Discount,
    Profit
FROM dbo.samplesuperstore
WHERE Order_ID IS NOT NULL
  AND Product_ID IS NOT NULL;
GO

-- ============================================================
-- 8. Data Validation
-- ============================================================

SELECT COUNT(*) AS MissingOrders
FROM dbo.OrderDetails od
LEFT JOIN dbo.Orders o
    ON od.OrderID = o.OrderID
WHERE o.OrderID IS NULL;

SELECT COUNT(*) AS MissingProducts
FROM dbo.OrderDetails od
LEFT JOIN dbo.Products p
    ON od.ProductID = p.ProductID
WHERE p.ProductID IS NULL;

SELECT COUNT(*) AS MissingCustomers
FROM dbo.Orders o
LEFT JOIN dbo.Customers c
    ON o.CustomerID = c.CustomerID
WHERE c.CustomerID IS NULL;

SELECT COUNT(*) AS MissingLocations
FROM dbo.Orders o
LEFT JOIN dbo.Locations l
    ON o.PostalCode = l.PostalCode
WHERE o.PostalCode IS NOT NULL
  AND l.PostalCode IS NULL;
GO

-- ============================================================
-- 9. Sales and Profit by Category
-- ============================================================

SELECT
    p.Category,
    SUM(od.Sales) AS TotalSales,
    SUM(od.Profit) AS TotalProfit,
    SUM(od.Quantity) AS TotalQuantity
FROM dbo.OrderDetails od
INNER JOIN dbo.Products p
    ON od.ProductID = p.ProductID
GROUP BY
    p.Category
ORDER BY
    TotalSales DESC;
GO

-- ============================================================
-- 10. Sales and Profit by Region
-- ============================================================

SELECT
    l.Region,
    SUM(od.Sales) AS TotalSales,
    SUM(od.Profit) AS TotalProfit,
    SUM(od.Quantity) AS TotalQuantity
FROM dbo.OrderDetails od
INNER JOIN dbo.Orders o
    ON od.OrderID = o.OrderID
INNER JOIN dbo.Locations l
    ON o.PostalCode = l.PostalCode
GROUP BY
    l.Region
ORDER BY
    TotalSales DESC;
GO

-- ============================================================
-- 11. Top 10 Products by Sales
-- ============================================================

SELECT TOP 10
    p.ProductID,
    p.ProductName,
    p.Category,
    SUM(od.Sales) AS TotalSales,
    SUM(od.Profit) AS TotalProfit
FROM dbo.OrderDetails od
INNER JOIN dbo.Products p
    ON od.ProductID = p.ProductID
GROUP BY
    p.ProductID,
    p.ProductName,
    p.Category
ORDER BY
    TotalSales DESC;
GO

-- ============================================================
-- 12. Product Sales Ranking using CTE and RANK()
-- ============================================================

WITH ProductSales AS
(
    SELECT
        p.ProductID,
        p.ProductName,
        p.Category,
        SUM(od.Sales) AS TotalSales

    FROM dbo.OrderDetails od
    INNER JOIN dbo.Products p
        ON od.ProductID = p.ProductID

    GROUP BY
        p.ProductID,
        p.ProductName,
        p.Category
)
SELECT
    ProductID,
    ProductName,
    Category,
    TotalSales,

    RANK() OVER
    (
        ORDER BY TotalSales DESC
    ) AS SalesRank

FROM ProductSales
ORDER BY SalesRank;
GO

-- ============================================================
-- 13. Monthly Sales Comparison using LAG()
-- ============================================================

WITH MonthlySales AS
(
    SELECT
        YEAR(o.OrderDate) AS SalesYear,
        MONTH(o.OrderDate) AS SalesMonth,
        SUM(od.Sales) AS TotalSales

    FROM dbo.OrderDetails od
    INNER JOIN dbo.Orders o
        ON od.OrderID = o.OrderID

    GROUP BY
        YEAR(o.OrderDate),
        MONTH(o.OrderDate)
)
SELECT
    SalesYear,
    SalesMonth,
    TotalSales,

    LAG(TotalSales) OVER
    (
        ORDER BY SalesYear, SalesMonth
    ) AS PreviousMonthSales,

    TotalSales -
    LAG(TotalSales) OVER
    (
        ORDER BY SalesYear, SalesMonth
    ) AS SalesDifference

FROM MonthlySales
ORDER BY
    SalesYear,
    SalesMonth;
GO

-- ============================================================
-- 14. Stored Procedure - Regional Sales Report
-- ============================================================

CREATE OR ALTER PROCEDURE dbo.GetRegionalSalesReport
    @Region VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        l.Region,
        p.Category,
        SUM(od.Sales) AS TotalSales,
        SUM(od.Profit) AS TotalProfit,
        SUM(od.Quantity) AS TotalQuantity

    FROM dbo.OrderDetails od

    INNER JOIN dbo.Orders o
        ON od.OrderID = o.OrderID

    INNER JOIN dbo.Products p
        ON od.ProductID = p.ProductID

    INNER JOIN dbo.Locations l
        ON o.PostalCode = l.PostalCode

    WHERE l.Region = @Region

    GROUP BY
        l.Region,
        p.Category

    ORDER BY
        TotalSales DESC;
END;
GO

-- Test Stored Procedure
EXEC dbo.GetRegionalSalesReport
    @Region = 'West';
GO

-- ============================================================
-- 15. Indexing for Performance Optimization
-- ============================================================

CREATE INDEX IX_OrderDetails_ProductID
ON dbo.OrderDetails(ProductID);

CREATE INDEX IX_OrderDetails_OrderID
ON dbo.OrderDetails(OrderID);

CREATE INDEX IX_Orders_CustomerID
ON dbo.Orders(CustomerID);

CREATE INDEX IX_Orders_PostalCode
ON dbo.Orders(PostalCode);
GO

-- ============================================================
-- 16. Customer Sales Performance Query
-- ============================================================

SELECT
    o.CustomerID,
    SUM(od.Sales) AS TotalSales,
    SUM(od.Profit) AS TotalProfit

FROM dbo.Orders o

INNER JOIN dbo.OrderDetails od
    ON o.OrderID = od.OrderID

GROUP BY
    o.CustomerID

ORDER BY
    TotalSales DESC;
GO

-- ============================================================
-- 17. Final Project Validation
-- ============================================================

SELECT
    COUNT(DISTINCT o.OrderID) AS TotalOrders,
    COUNT(DISTINCT o.CustomerID) AS TotalCustomers,
    COUNT(DISTINCT od.ProductID) AS TotalProducts,
    SUM(od.Sales) AS TotalSales,
    SUM(od.Profit) AS TotalProfit,
    SUM(od.Quantity) AS TotalQuantity

FROM dbo.Orders o

INNER JOIN dbo.OrderDetails od
    ON o.OrderID = od.OrderID;
GO
