-- Walmart Project Queries - MySQL

use walmart_db;

select * from walmart;

-- Count total records
select count(*) from walmart;

-- Count payment methods and number of transactions by payment method
SELECT 
    payment_method,
    COUNT(*) AS no_payments
FROM walmart
GROUP BY payment_method;

-- Count distinct branches
SELECT COUNT(DISTINCT branch) FROM walmart;

-- Find the minimum quantity sold
SELECT MIN(quantity) FROM walmart;

-- Business Problem Q1: Find different payment methods, number of transactions, and quantity sold by payment method
SELECT 
    payment_method,
    COUNT(*) AS no_payments,
    SUM(quantity) AS no_qty_sold
FROM walmart
GROUP BY payment_method;

-- Project Question #2: Identify the highest-rated category in each branch
-- Display the branch, category, and avg rating
select * 
from 
(
	select 
		branch, 
		category, 
		avg(rating) as avg_rating, 
		rank() over(partition by branch order by avg(rating) desc) as `rank`
	from walmart 
	group by 1,2
) as rank_data
where `rank` = 1;

-- Q3: Identify the busiest day for each branch based on the number of transactions
select * 
from 
(
	select 
		branch,
		DATE_FORMAT(str_to_date(date,'%d/%m/%Y'), '%W') as day_name,
		count(*) as no_transaction,
		rank() over(partition by branch order by count(*) desc) as `rank`
	from walmart
	group by branch, day_name
) as rank_data
where `rank` = 1;

-- Q4: Calculate the total quantity of items sold per payment method
SELECT 
    payment_method,
    SUM(quantity) AS no_qty_sold
FROM walmart
GROUP BY payment_method;

-- Q5: Determine the average, minimum, and maximum rating of categories for each city

select
	city,
    category,
    min(rating) as min_rating,
    max(rating)as max_rating,
    avg(rating)as avg_rating
from walmart
group by 1,2
order by 1;

-- Q6: Calculate the total profit for each category
select
	category,
    sum(total) as total_revenue,
    sum(total * profit_margin) as profit
from walmart
group by 1
order by 3 desc;

-- Q7: Determine the most common payment method for each branch
select * 
from 
(
	select 
		branch,
		payment_method,
		count(*) as no_transaction,
		rank() over(partition by branch order by count(*) desc) as `rank`
	from walmart
	group by 1,2
) as rank_data
where `rank` = 1;

-- Q8: Categorize sales into Morning, Afternoon, and Evening shifts
select
	branch,
	case 
		when extract(hour from time(time)) < 12 then 'Morning'
        when extract(hour from time(time)) between 12 and 17 then 'Afternoon'
        else 'Evening'
	end date_time,
    count(*) as  no_transaction
from walmart
group by 1,2
order by 1, 3 desc;



-- Q9: Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)
with revenue_2022
as
(
	select 
		branch,
		sum(total) as revenue
	from walmart
	where DATE_FORMAT(str_to_date(date,'%d/%m/%Y'), '%Y')=2022
	group by 1
),
revenue_2023
as
(
	select 
		branch,
		sum(total) as revenue
	from walmart
	where DATE_FORMAT(str_to_date(date,'%d/%m/%Y'), '%Y')=2023
	group by 1
)
select 
	ls.branch,
    ls.revenue as last_year_revenue,
    cs.revenue as ce_year_revenue,
    round((ls.revenue - cs.revenue)/ls.revenue *100,2) as rev_dec_ratio
from revenue_2022 as ls 
join
revenue_2023 as cs
on ls.branch = cs.branch
where ls.revenue > cs.revenue
order by 4 desc
limit 5;