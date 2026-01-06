
-- DATA CLEANING & DATA PREPARATION (SQL)

-- 1. Database Creation & Selection
CREATE DATABASE Inventory;
USE Inventory;


-- 2. Initial Data Type Inspection
DESCRIBE Categories;
DESCRIBE Customers;
DESCRIBE Inventory;
DESCRIBE order_details;
DESCRIBE products;
DESCRIBE Warehouses;


-- 3. Standardizing ID Columns (Data Type Alignment)
ALTER TABLE categories
MODIFY categoryid VARCHAR(20);

ALTER TABLE customers
MODIFY customerid VARCHAR(20);

ALTER TABLE inventory
MODIFY productid VARCHAR(20);

ALTER TABLE order_details
MODIFY productid VARCHAR(20);

ALTER TABLE order_details
MODIFY orderid VARCHAR(20);

ALTER TABLE order_details
MODIFY customerid VARCHAR(20);

ALTER TABLE products
MODIFY productid VARCHAR(20);

ALTER TABLE products
MODIFY categoryid VARCHAR(20);


-- 4. Cleaning Customer Contact Information

ALTER TABLE customers
MODIFY phone TEXT;


-- 5. Price Column Standardization
ALTER TABLE order_details
MODIFY price DECIMAL(10,2);

ALTER TABLE products
MODIFY price DECIMAL(10,2);

-- 6. Order Date Cleaning & Formatting
SET sql_safe_updates = 0;
UPDATE order_details 
SET orderdate = CASE
    WHEN orderdate LIKE '%-%' THEN STR_TO_DATE(orderdate, '%d-%m-%Y')
    WHEN orderdate LIKE '%/%' THEN STR_TO_DATE(orderdate, '%m/%d/%Y')
END;

ALTER TABLE order_details
MODIFY orderdate DATE;


-- 7. Email Domain Profiling (Data Validation)
SELECT DISTINCT SUBSTRING_INDEX(email, '@', -1)
FROM customers;


-- 8. Handling Missing Values
UPDATE customers
SET phone = 'Not Available'
WHERE phone IS NULL;

UPDATE customers
SET phone = 'Not Available'
WHERE email IS NULL;


-- 9. Data Quality Validation Checks
-- Inventory with zero or negative stock
SELECT *
FROM inventory
WHERE quantityavailable <= 0;

-- Orders with invalid quantity
SELECT *
FROM order_details
WHERE quantityordered <= 0;

-- Orders with invalid price
SELECT *
FROM order_details
WHERE price <= 0;

-- Products with invalid price
SELECT *
FROM products
WHERE price <= 0;


-- 10. Final Data Review
SELECT * FROM categories;
SELECT * FROM customers;
SELECT * FROM inventory;
SELECT * FROM order_details;
SELECT * FROM products;
SELECT * FROM warehouses;




-- Inventory Management Analytics Project - SQL
/* Description: End-to-end analysis covering inventory,
   sales, customer behavior, warehouses, and categories. */


/* ---------------------------
   Q1: Products with inventory below reorder level
---------------------------- */
SELECT 
    p.ProductID,
    p.ProductName,
    p.ReorderLevel,
    i.QuantityAvailable
FROM
    Products p
        JOIN
    Inventory i ON p.ProductID = i.ProductID
WHERE
    i.QuantityAvailable < p.ReorderLevel;


/* ---------------------------
   Q2: Products out of stock in at least one warehouse
---------------------------- */
SELECT 
    p.ProductID, p.ProductName, i.WarehouseID
FROM
    Products p
        JOIN
    Inventory i ON p.ProductID = i.ProductID
WHERE
    i.QuantityAvailable = 0;


/* ---------------------------
   Q3: Total available inventory per product across all warehouses
---------------------------- */
SELECT 
    p.ProductID,
    p.ProductName,
    SUM(i.QuantityAvailable) AS TotalInventory
FROM
    Products p
        JOIN
    Inventory i ON p.ProductID = i.ProductID
GROUP BY p.ProductID , p.ProductName
ORDER BY TotalInventory DESC;


/* ---------------------------
   Q4 : Identify overstocked products with high inventory but low order demand
---------------------------- */

/* ---------------------------
   Q5: Products that are stocked but never ordered
---------------------------- */
SELECT 
    p.ProductID,
    p.ProductName,
    SUM(i.QuantityAvailable) AS TotalStock
FROM
    Products p
        JOIN
    Inventory i ON p.ProductID = i.ProductID
        LEFT JOIN
    Order_Details od ON p.ProductID = od.ProductID
GROUP BY p.ProductID , p.ProductName
HAVING SUM(i.QuantityAvailable) > 0
    AND COUNT(od.OrderID) = 0;

/* ---------------------------
    Q6: Detect products where ordered quantity exceeded available stock
---------------------------- */


/* ---------------------------
   Q7: Product with highest inventory value (Price × Quantity)
---------------------------- */
SELECT 
    p.ProductID,
    p.ProductName,
    SUM(i.QuantityAvailable * p.Price) AS InventoryValue
FROM
    Products p
        JOIN
    Inventory i ON p.ProductID = i.ProductID
GROUP BY p.ProductID , p.ProductName
ORDER BY InventoryValue DESC
LIMIT 1;


/* ---------------------------
   Q8: Products that frequently trigger reorder alerts
---------------------------- */
SELECT 
    p.ProductID, p.ProductName, COUNT(*) AS Alerts
FROM
    Products p
        JOIN
    Inventory i ON p.ProductID = i.ProductID
WHERE
    i.QuantityAvailable <= p.ReorderLevel
GROUP BY p.ProductID , p.ProductName
HAVING COUNT(*) > 1;


/* ---------------------------
    Q9: Average time gap between consecutive orders per product
---------------------------*/


/* ---------------------------
   Q10: Suggest products where reorder level should be increased based on sales
---------------------------- */
WITH Total_Demand AS (
    SELECT 
        ProductID,
        SUM(QuantityOrdered) AS TotalOrdered
    FROM Order_Details
    GROUP BY ProductID
)
SELECT 
    p.ProductID,
    p.ProductName,
    p.ReorderLevel,
    d.TotalOrdered,
    CASE
        WHEN d.TotalOrdered > p.ReorderLevel THEN 'Increase your ReorderLevel'
        ELSE 'ReorderLevel Ok'
    END AS Suggestion
FROM Products p
JOIN Total_Demand d 
    ON p.ProductID = d.ProductID;


/* ---------------------------
   Q11: Identify products with unnecessarily high reorder levels
---------------------------- */
WITH Total_Demand AS (
    SELECT 
        ProductID,
        SUM(QuantityOrdered) AS TotalOrdered
    FROM Order_Details
    GROUP BY ProductID
)
SELECT 
    p.ProductID,
    p.ProductName,
    p.ReorderLevel,
    d.TotalOrdered,
    CASE
        WHEN p.ReorderLevel > d.TotalOrdered THEN 'Unnecessary High ReorderLevel'
        ELSE 'ReorderLevel Ok'
    END AS Suggestion
FROM Products p
JOIN Total_Demand d 
    ON p.ProductID = d.ProductID;


/* ---------------------------
   Q12: Total revenue generated per product
---------------------------- */
SELECT 
    p.ProductID,
    p.ProductName,
    SUM(od.QuantityOrdered * od.Price) AS OverallSale
FROM
    Products p
        JOIN
    Order_Details od ON p.ProductID = od.ProductID
GROUP BY p.ProductID , p.ProductName;


/* ---------------------------
   Q13: Top 5 best-selling products by order quantity
---------------------------- */
SELECT 
    p.ProductID,
    p.ProductName,
    SUM(od.QuantityOrdered) AS TotalOrder
FROM
    Products p
        JOIN
    Order_Details od ON p.ProductID = od.ProductID
GROUP BY p.ProductID , p.ProductName
ORDER BY TotalOrder DESC
LIMIT 5;


/* ---------------------------
   Q14: Bottom 5 slow-moving products by sales volume
---------------------------- */
SELECT 
    p.ProductID,
    p.ProductName,
    SUM(od.QuantityOrdered) AS TotalOrder
FROM
    Products p
        JOIN
    Order_Details od ON p.ProductID = od.ProductID
GROUP BY p.ProductID , p.ProductName
ORDER BY TotalOrder ASC
LIMIT 5;


/* ---------------------------
   Q15: Month with peak order volumes
---------------------------- */
SELECT 
    MONTHNAME(OrderDate) AS PeakMonth,
    SUM(QuantityOrdered) AS OrderVolume
FROM
    Order_Details
GROUP BY MONTHNAME(OrderDate)
ORDER BY OrderVolume DESC
LIMIT 1;


/* ---------------------------
   Q16: Top 10 customers by total order value
---------------------------- */
SELECT 
    c.CustomerID,
    c.CustomerName,
    SUM(od.QuantityOrdered * od.Price) AS OrderValue
FROM
    Customers c
        JOIN
    Order_Details od ON c.CustomerID = od.CustomerID
GROUP BY c.CustomerID , c.CustomerName
ORDER BY OrderValue DESC
LIMIT 10;

/* ---------------------------
   Q17 : Detect orders where order price differs from master product price
---------------------------- */


/* ---------------------------
   Q18: Classify customers into One-Time vs Repeat buyers
---------------------------- */
SELECT 
    c.CustomerID,
    c.CustomerName,
    COUNT(DISTINCT od.OrderID) AS TotalOrders,
    CASE
        WHEN COUNT(DISTINCT od.OrderID) = 1 THEN 'One-Time Customer'
        WHEN COUNT(DISTINCT od.OrderID) > 1 THEN 'Repeat Customer'
        ELSE 'No Orders'
    END AS CustomerType
FROM
    Customers c
        LEFT JOIN
    Order_Details od ON c.CustomerID = od.CustomerID
GROUP BY c.CustomerID , c.CustomerName
ORDER BY TotalOrders DESC;


/* ---------------------------
   Q19: Average order value per customer
---------------------------- */
WITH OrderValue AS (
    SELECT 
        OrderID,
        CustomerID,
        SUM(QuantityOrdered * Price) AS OrderTotal
    FROM Order_Details
    GROUP BY OrderID, CustomerID
)
SELECT 
    CustomerID,
    ROUND(AVG(OrderTotal), 2) AS AvgPrice
FROM OrderValue
GROUP BY CustomerID;


/* ---------------------------
   Q20: Customers who frequently place bulk orders (Min 50)
---------------------------- */
SELECT 
    c.CustomerID,
    c.CustomerName,
    COALESCE(COUNT(DISTINCT od.OrderID), 0) AS TotalOrders
FROM
    Customers c
        LEFT JOIN
    Order_Details od ON c.CustomerID = od.CustomerID
WHERE
    od.QuantityOrdered >= 50
GROUP BY c.CustomerID , c.CustomerName
ORDER BY TotalOrders DESC;


/* ---------------------------
   Q21: Total inventory stored per warehouse
---------------------------- */
SELECT 
    w.WarehouseID,
    w.WarehouseName,
    SUM(i.QuantityAvailable) AS InventoryStored
FROM
    Inventory i
        JOIN
    Warehouses w ON i.WarehouseID = w.WarehouseID
GROUP BY w.WarehouseID , w.WarehouseName;


/* ---------------------------
   Q22: Warehouses with high demand but low inventory (Risk Number)
---------------------------- */
WITH ProductDemand AS (
    SELECT 
        ProductID,
        SUM(QuantityOrdered) AS TotalDemand
    FROM Order_Details
    GROUP BY ProductID
),
WarehouseInventory AS (
    SELECT 
        WarehouseID,
        ProductID,
        SUM(QuantityAvailable) AS TotalInventory
    FROM Inventory
    GROUP BY WarehouseID, ProductID
)
SELECT 
    w.WarehouseID,
    w.WarehouseName,
    SUM(pd.TotalDemand) AS TotalDemand,
    SUM(wi.TotalInventory) AS TotalInventory,
    SUM(pd.TotalDemand) - SUM(wi.TotalInventory) AS RiskNumber
FROM Warehouses w
JOIN WarehouseInventory wi 
    ON w.WarehouseID = wi.WarehouseID
JOIN ProductDemand pd 
    ON wi.ProductID = pd.ProductID
GROUP BY w.WarehouseID, w.WarehouseName
HAVING SUM(pd.TotalDemand) > SUM(wi.TotalInventory)
ORDER BY RiskNumber DESC;


/* ---------------------------
   Q23: Revenue contribution by product category
---------------------------- */
SELECT 
    c.CategoryID,
    c.CategoryName,
    SUM(od.QuantityOrdered * od.Price) AS TotalRevenue
FROM
    Order_Details od
        JOIN
    Products p ON od.ProductID = p.ProductID
        JOIN
    Categories c ON p.CategoryID = c.CategoryID
GROUP BY c.CategoryID , c.CategoryName
ORDER BY TotalRevenue DESC;


/* ---------------------------
   Q24: Slow-moving product categories with high inventory cost
---------------------------- */
SELECT 
    c.CategoryName,
    COALESCE(SUM(od.QuantityOrdered), 0) AS TotalSales,
    SUM(i.QuantityAvailable * p.Price) AS InventoryCost
FROM
    Categories c
        JOIN
    Products p ON c.CategoryID = p.CategoryID
        JOIN
    Inventory i ON p.ProductID = i.ProductID
        LEFT JOIN
    Order_Details od ON p.ProductID = od.ProductID
GROUP BY c.CategoryName
ORDER BY TotalSales ASC , InventoryCost DESC;

