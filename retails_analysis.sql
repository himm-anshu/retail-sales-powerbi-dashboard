CREATE DATABASE retail_project;
USE retail_project;
CREATE TABLE retail_sales (
    Order_ID INT,
    Order_Date DATE,
    Customer_ID VARCHAR(20),
    City VARCHAR(50),
    Product VARCHAR(50),
    Category VARCHAR(50),
    Quantity INT,
    Sales FLOAT,
    Discount FLOAT,
    Profit FLOAT,
    Year INT,
    Month INT,
    Profit_Margin FLOAT
);
SELECT COUNT(*) FROM retail_sales;
SELECT * FROM retail_sales
LIMIT 5;
SELECT ROUND(SUM(Sales), 2) AS Total_Revenue
FROM retail_sales;
SELECT 
ROUND(SUM(Sales) / COUNT(Order_ID), 2) AS Avg_Order_Value
FROM retail_sales;
SELECT ROUND(SUM(Profit), 2) AS Total_Profit
FROM retail_sales;
SELECT 
ROUND(SUM(Profit) / SUM(Sales), 4) AS Overall_Profit_Margin
FROM retail_sales;
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
SELECT 
    City,
    Category,
    ROUND(SUM(Sales),2) AS Revenue
FROM retail_sales
GROUP BY City, Category
ORDER BY City, Revenue DESC;
SELECT 
    City,
    Category,
    ROUND(AVG(Profit / Sales),4) AS Avg_Margin
FROM retail_sales
GROUP BY City, Category
ORDER BY City;
SELECT 
    Product,
    ROUND(AVG(Profit/Sales),4) AS Avg_Margin
FROM retail_sales
WHERE City = 'Kolkata'
GROUP BY Product
ORDER BY Avg_Margin ASC;
SELECT 
    Product,
    SUM(Sales) AS Revenue,
    SUM(Profit) AS Profit,
    ROUND(AVG(Profit/Sales),4) AS Margin
FROM retail_sales
WHERE City = 'Kolkata'
GROUP BY Product
ORDER BY Revenue DESC;
SELECT 
    City,
    ROUND(AVG(Discount),4) AS Avg_Discount,
    ROUND(SUM(Sales),2) AS Revenue,
    ROUND(AVG(Profit/Sales),4) AS Margin
FROM retail_sales
WHERE Product = 'Tablet'
GROUP BY City
ORDER BY Avg_Discount DESC;
SELECT 
    Month,
    ROUND(SUM(Sales),2) AS Total_Revenue,
    ROUND(SUM(Profit),2) AS Total_Profit,
    ROUND(SUM(Profit)/SUM(Sales),4) AS Profit_Margin
FROM retail_sales
GROUP BY Month
ORDER BY Month;