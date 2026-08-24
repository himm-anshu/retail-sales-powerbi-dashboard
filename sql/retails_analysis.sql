-- =====================================================================
-- Retail Sales Analysis — SQL Validation & Business Queries
-- =====================================================================
-- Data note: source is a practice/synthetic dataset (retail_sales_practice.csv).
-- Profit margins here (~50%+) are far above real-world retail norms and should
-- not be presented as a genuine business finding without that caveat.
--
-- Margin formula standardized across every query in this file:
--     SUM(Profit) / SUM(Sales)      (revenue-weighted)
-- NOT AVG(Profit/Sales)             (unweighted — over-weights small orders)
-- This matches the Power BI measure: Profit Margin = DIVIDE([Total Profit], [Total Revenue])
-- =====================================================================

CREATE DATABASE IF NOT EXISTS retail_project;
USE retail_project;

DROP TABLE IF EXISTS retail_sales;

CREATE TABLE retail_sales (
    Order_ID       INT PRIMARY KEY,
    Order_Date     DATE,
    Customer_ID    VARCHAR(20),
    City           VARCHAR(50),
    Product        VARCHAR(50),
    Category       VARCHAR(50),
    Quantity       INT,
    Sales          DECIMAL(10,2),
    Discount       DECIMAL(5,4),
    Profit         DECIMAL(10,2),
    Year           INT,
    Month          INT,
    Profit_Margin  DECIMAL(6,4)
);

-- =====================================================================
-- 1. Load cleaned data
-- =====================================================================
-- Requires local_infile enabled on the client/server:
--   SET GLOBAL local_infile = 1;
-- Update the file path below to match your local repo location before running.

LOAD DATA LOCAL INFILE 'data/cleaned_retail_sales.csv'
INTO TABLE retail_sales
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Order_ID, Order_Date, Customer_ID, City, Product, Category, Quantity,
 Sales, Discount, Profit, Year, Month, Profit_Margin);

-- =====================================================================
-- 2. Data validation
-- =====================================================================

-- Row count sanity check — should match the cleaned CSV's row count (348)
SELECT COUNT(*) AS Row_Count FROM retail_sales;

SELECT * FROM retail_sales LIMIT 5;

-- Confirm no zero-Sales rows exist (would break every Profit/Sales division below)
SELECT COUNT(*) AS Zero_Sales_Rows FROM retail_sales WHERE Sales = 0;

-- Confirm no duplicate Order_IDs (PRIMARY KEY should already enforce this on load,
-- this is a belt-and-suspenders check on the source data itself)
SELECT Order_ID, COUNT(*) AS cnt
FROM retail_sales
GROUP BY Order_ID
HAVING COUNT(*) > 1;

-- Category is single-valued after cleaning (Electronics only) — confirm that's still true
SELECT DISTINCT Category FROM retail_sales;

-- =====================================================================
-- 3. Overall KPIs
-- =====================================================================

SELECT ROUND(SUM(Sales), 2) AS Total_Revenue
FROM retail_sales;

SELECT ROUND(SUM(Profit), 2) AS Total_Profit
FROM retail_sales;

SELECT
    ROUND(SUM(Profit) / SUM(Sales), 4) AS Overall_Profit_Margin
FROM retail_sales;

SELECT
    ROUND(SUM(Sales) / COUNT(Order_ID), 2) AS Avg_Order_Value
FROM retail_sales;

-- =====================================================================
-- 4. City-level breakdown
-- =====================================================================

SELECT
    City,
    ROUND(SUM(Sales), 2) AS Total_Revenue
FROM retail_sales
GROUP BY City
ORDER BY Total_Revenue DESC;

SELECT
    City,
    ROUND(SUM(Profit), 2) AS Total_Profit
FROM retail_sales
GROUP BY City
ORDER BY Total_Profit DESC;

SELECT
    City,
    ROUND(SUM(Profit) / SUM(Sales), 4) AS Profit_Margin
FROM retail_sales
GROUP BY City
ORDER BY Profit_Margin DESC;

SELECT
    City,
    ROUND(AVG(Discount), 4) AS Avg_Discount
FROM retail_sales
GROUP BY City
ORDER BY Avg_Discount DESC;

-- =====================================================================
-- 5. Product-level breakdown
-- =====================================================================
-- Replaces the old City x Category breakdown: Category is single-valued
-- (Electronics only) after cleaning, so a Category split has nothing to compare.
-- Product is the meaningful dimension here.

SELECT
    City,
    Product,
    ROUND(SUM(Sales), 2) AS Revenue
FROM retail_sales
GROUP BY City, Product
ORDER BY City, Revenue DESC;

SELECT
    Product,
    ROUND(SUM(Sales), 2) AS Revenue,
    ROUND(SUM(Profit), 2) AS Profit,
    ROUND(SUM(Profit) / SUM(Sales), 4) AS Margin
FROM retail_sales
GROUP BY Product
ORDER BY Revenue DESC;

-- =====================================================================
-- 6. Drill-downs
-- =====================================================================

-- Kolkata product performance, weakest margin first
SELECT
    Product,
    ROUND(SUM(Profit) / SUM(Sales), 4) AS Margin
FROM retail_sales
WHERE City = 'Kolkata'
GROUP BY Product
ORDER BY Margin ASC;

SELECT
    Product,
    SUM(Sales) AS Revenue,
    SUM(Profit) AS Profit,
    ROUND(SUM(Profit) / SUM(Sales), 4) AS Margin
FROM retail_sales
WHERE City = 'Kolkata'
GROUP BY Product
ORDER BY Revenue DESC;

-- Tablet performance across cities
SELECT
    City,
    ROUND(AVG(Discount), 4) AS Avg_Discount,
    ROUND(SUM(Sales), 2) AS Revenue,
    ROUND(SUM(Profit) / SUM(Sales), 4) AS Margin
FROM retail_sales
WHERE Product = 'Tablet'
GROUP BY City
ORDER BY Avg_Discount DESC;

-- =====================================================================
-- 7. Monthly trend
-- =====================================================================
-- Ordered chronologically by Month (1-12), NOT by revenue value — this is the
-- fix for the equivalent bug found in the Power BI line chart, which had been
-- sorted by Total Revenue descending instead of Month ascending.

SELECT
    Month,
    ROUND(SUM(Sales), 2) AS Total_Revenue,
    ROUND(SUM(Profit), 2) AS Total_Profit,
    ROUND(SUM(Profit) / SUM(Sales), 4) AS Profit_Margin
FROM retail_sales
GROUP BY Month
ORDER BY Month ASC;