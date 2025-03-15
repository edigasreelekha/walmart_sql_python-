create database walmart_db

use walmart_db

select * from walmart;

-- counting total records
select count(*) from walmart;

-- Count payment methods and number of transactions by payment methods
select 
payment_method,
count(*) as total_payments
from walmart
group by payment_method;

-- count distinct branches 
select count(distinct branch) from walmart;

-- Find the minimum quantity sold
select min(quantity) from walmart;

-- Find different payment methods, number of transactions, and quantity sold by payment method 
select
	payment_method,
    count(*) as no_payments,
    sum(quantity) as no_qty_sold
from walmart
group by payment_method;

-- Identify the highest_rated category in each branch 
-- Display the branch, category, and average rating

SELECT branch, category, avg_rating
FROM (
    SELECT
        branch,
        category,
        AVG(rating) AS avg_rating,
        ROW_NUMBER() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS row_num
    FROM walmart
    GROUP BY branch, category
) AS ranked
WHERE row_num = 1;

--  Identify the busiest day for each branch based on the number of transactions
SELECT branch, day_name, no_transactions
FROM (
    SELECT
        branch,
        DAYNAME(STR_TO_DATE(date, '%d-%m-%y')) AS day_name,
        COUNT(*) AS no_transactions,
        RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS rnk
    FROM walmart
    GROUP BY branch, DAYNAME(STR_TO_DATE(date, '%d-%m-%y'))
) AS ranked
WHERE rnk = 1;
-- Calculate the total quantity of items sold per payment method
select payment_method,
sum(quantity) as no_qty_sold
from walmart
group by payment_method;

--  Determine the average, minimum, and maximum rating of categories for each city
select city, category,
min(rating) as min_rating,
max(rating) as max_rating,
avg(rating) as avg_rating
from walmart 
group by city, category ;

--  Calculate the total profit for each category
select category,
sum(unit_price * quantity * profit_margin) as total_profit
from walmart
group by category
order by total_profit desc; 

-- Determine the most common payment method for each branch
WITH cte AS (
    SELECT 
        branch,
        payment_method,
        COUNT(*) AS total_trans,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rnk
    FROM walmart
    GROUP BY branch, payment_method
)
SELECT branch, payment_method AS preferred_payment_method
FROM cte
WHERE rnk = 1;

-- Categorize sales into Morning, Afternoon, and Evening shifts
select 
	branch,
    CASE 
        WHEN HOUR(TIME(time)) < 12 THEN 'Morning'
        WHEN HOUR(TIME(time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS num_invoices
FROM walmart
GROUP BY branch, shift
ORDER BY branch, num_invoices DESC;

--  Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)
WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%Y')) = 2023
    GROUP BY branch
)
SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;
	