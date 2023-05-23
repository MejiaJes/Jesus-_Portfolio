--Question 1: Which Products Should We order More of or Less of?--
--Write a query to compute the low stock for each product using a correlated subquery.--
--In SQLite, REAL is the datatype for FLOAT.
WITH low AS(SELECT o.productCode, ROUND(SUM(CAST(quantityOrdered AS REAL))/quantityInStock,2) as lowstock
FROM orderdetails o
JOIN products 
ON o.productCode = p.productCode
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10)

SELECT l.productCode, sum(quantityOrdered*priceEach) as productperf
FROM orderdetails o
JOIN low l
on o.productCode = l.productCode
group by 1
order by 2 DESC
limit 10;
--Question 2: How Should We Match Marketing and Communication Strategies to Customer Behavior?
--2a.Before we begin, let's compute how much profit each customer generates.
select customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS profit
from orderdetails od
join products p
on od.productCode = p.productCode
join orders o
ON od.orderNumber = o.orderNumber
GROUP BY customerNumber;
--Question 3:Finding the VIP and Less Engaged Customers
--3a.Write a query to find the top five VIP customers.
SELECT customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS profit
from orderdetails od
join products p
on od.productCode = p.productCode
join orders o
ON od.orderNumber = o.orderNumber
GROUP BY customerNumber
ORDER BY 	profit DESC
LIMIT 5
--3b.Similar to the previous query, write a query to find the top five least-engaged customers.
-- Use the query from the previous screen as a CTE.
-- Select the following columns: contactLastName, contactFirstName, city, and country from the customers table and the profit from the CTE.
SELECT customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS profit
from orderdetails od
join products p
on od.productCode = p.productCode
join orders o
ON od.orderNumber = o.orderNumber
GROUP BY customerNumber
ORDER BY 	profit 
LIMIT 5

--4.Write a query to find the top five VIP customers.
--Use the query from the previous screen as a CTE.
--Select the following columns: contactLastName, contactFirstName, city, and country from the customers table and the profit from the CTE.
WITH target_customers AS (SELECT customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS profit
from orderdetails od
join products p
on od.productCode = p.productCode
join orders o
ON od.orderNumber = o.orderNumber
GROUP BY customerNumber)

SELECT contactLastName, contactFirstName, city, country, profit
FROM target_customers t
JOIN customers c
ON t.customerNumber = c.customerNumber
ORDER BY profit DESC
LIMIT 5;

SELECT contactLastName, contactFirstName, city, country, profit
FROM target_customers t
JOIN customers c
ON t.customerNumber = c.customerNumber
ORDER BY profit
LIMIT 5
--5. compute the average of customer profits using the CTE on the previous screen.
WITH target_customers AS (SELECT customerNumber, SUM(quantityOrdered * (priceEach - buyPrice)) AS profit
from orderdetails od
join products p
on od.productCode = p.productCode
join orders o
ON od.orderNumber = o.orderNumber
GROUP BY customerNumber)

SELECT ROUND(avg(profit) ,2) AS  Customer_LTV
FROM target_customers