/*Question1: 
Show each country's sales by customer age group.
Used CASE statements to categorized age groups.
Created a cte with joined tables to extract country and age information.*/
WITH cte1 AS(Select 
    t3.EnglishCountryRegionName AS country,
    DATEDIFF(MONTH, BirthDate, OrderDate)/12 AS age,
    SalesOrderNumber
FROM FactInternetSales t1
JOIN DimCustomer t2
ON t1.CustomerKey = t2.CustomerKey
JOIN DimGeography t3
ON t2.GeographyKey = t3.GeographyKey)
--Lastly, query country, age groups, and total sales by country and age group.--
SELECT country,
    CASE WHEN age < 30 THEN 'a.Under 30'
    WHEN age BETWEEN 30 and 40 THEN 'b.30-40'
    WHEN age BETWEEN 40 and 50 THEN 'c.40-50'
    WHEN age BETWEEN 50 and 60 THEN 'd.50-60'
    ELSE 'e.Over 60' END AS age_group,
    COUNT(SalesOrderNumber) as sales
FROM cte1
GROUP BY country, CASE WHEN age < 30 THEN 'a.Under 30'
    WHEN age BETWEEN 30 and 40 THEN 'b.30-40'
    WHEN age BETWEEN 40 and 50 THEN 'c.40-50'
    WHEN age BETWEEN 50 and 60 THEN 'd.50-60'
    ELSE 'e.Over 60' END
ORDER BY country, age_group

--Question 2:
----Show each Product sales by age group.--
--Need to join DimProduct and ProductSubcategoryKey tables to the previous CTE.
WITH cte1 AS(Select 
    t5.EnglishProductSubcategoryName AS product,
    DATEDIFF(MONTH, BirthDate, OrderDate)/12 AS age,
    SalesOrderNumber
FROM FactInternetSales t1
JOIN DimCustomer t2
ON t1.CustomerKey = t2.CustomerKey
JOIN DimGeography t3
ON t2.GeographyKey = t3.GeographyKey
JOIN DimProduct t4
ON t1.ProductKey = t4.ProductKey
JOIN DimProductSubcategory t5
ON t4.ProductSubcategoryKey = t5.ProductSubcategoryKey)

--Query product, age groups, and total sales.
SELECT product,
    CASE WHEN age < 30 THEN 'a.Under 30'
    WHEN age BETWEEN 30 and 40 THEN 'b.30-40'
    WHEN age BETWEEN 40 and 50 THEN 'c.40-50'
    WHEN age BETWEEN 50 and 60 THEN 'd.50-60'
    ELSE 'e.Over 60' END AS age_group,
    COUNT(SalesOrderNumber) as sales
FROM cte1
GROUP BY product, CASE WHEN age < 30 THEN 'a.Under 30'
    WHEN age BETWEEN 30 and 40 THEN 'b.30-40'
    WHEN age BETWEEN 40 and 50 THEN 'c.40-50'
    WHEN age BETWEEN 50 and 60 THEN 'd.50-60'
    ELSE 'e.Over 60' END
ORDER BY product, age_group;

--Question3:
--Show monthly sales for Australia and USA compared for the year 2012--
SELECT 
    substring(cast([OrderDateKey] as char),1,6) as Month, 
    SalesOrderNumber, 
    OrderDate, 
    t.SalesTerritoryCountry
FROM DimSalesTerritory t
JOIN FactInternetSales s
ON t.SalesTerritoryKey = s.SalesTerritoryKey
WHERE SalesTerritoryCountry IN('Australia', 'United States')
    AND substring(cast([OrderDateKey] as char),1,4) = '2012'

--Question 4:
--Display each product's first reorder date
WITH cte1 AS(select EnglishProductName AS product, 
    OrderDateKey,
    SafetyStockLevel,
    ReorderPoint,
    sum(s.OrderQuantity) AS Sales
FROM DimProduct AS p
JOIN FactInternetSales AS s
ON p.ProductKey = s.ProductKey
GROUP BY EnglishProductName, OrderDateKey, SafetyStockLevel, ReorderPoint),
--Used a subquery in the FROM clause to extract 'Running_Total_Sales' using a Window function.
--In the outer query, I used CASE statement to filter 'ReorderPoint' threshold.
ReorderDate AS(SELECT *, 
    CASE WHEN SafetyStockLevel - Running_Total_Sales <= ReorderPoint THEN 1 ELSE 0 END AS reorder_flag
FROM
    (SELECT *, SUM(Sales) OVER(PARTITION BY product ORDER BY OrderDateKey) AS Running_Total_Sales
FROM cte1
GROUP BY product, 
    OrderDateKey,
    SafetyStockLevel, ReorderPoint, Sales) AB)
--Lastly, query the minimum date of reorder date.
SELECT product, MIN(OrderDateKey) AS First_ReorderDate
FROM ReorderDate
WHERE reorder_flag = 1
GROUP BY product