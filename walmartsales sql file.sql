-- Create database
CREATE DATABASE IF NOT EXISTS walmartsales;
USE walmartsales;


-- Create table
CREATE TABLE IF NOT EXISTS salestable(
	Invoice_ID VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    productline VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);
select * from salestable;

-- ----------------------------------------------FEATURE ENGINEERING-----------------------------------------------------
-- 1) TIME_OF_DAY:- ADDING to identify when the sales occured morning,afternoon or evening 

select
		time,
	    (case
        when time between "00:00:00" and "12:00:00" then "morning"
        when time between "12:01:00" and "16:00:00" then "afternoon"
        else "evening"
        end) as time_of_day
from salestable;

alter table salestable add column time_of_day varchar(20);

update salestable
set time_of_day = (case
        when time between "00:00:00" and "12:00:00" then "morning"
        when time between "12:01:00" and "16:00:00" then "afternoon"
        else "evening"
        end
);

-- 2)DAY_NAME:- mon,tues,wednesday,etc..

select 
		date,
        dayname(date) as day_name
from salestable;

alter table salestable add column day_name varchar(10);

update salestable 
set day_name = dayname(date);

-- 2)MONTH_NAME:- jan,feb,march,etc..

select 
		date,
        monthname(date) as month_name
from salestable;

alter table salestable add column month_name varchar(10);

update salestable 
set month_name = monthname(date);
-- ----------------------------------------------------------------------------------------------------------------

-- ----------------------------------------------------------------------------------------------------------------
-- ---------------------------------------------General questions-----------------------------------------------------
-- 1)how many unique city does the data have?

select
		distinct city
        from salestable;
        
-- 2)in which city is each branch?

select
		distinct city,branch
        from salestable;
        
-- ------------------------------------Product questions----------------------------------------------------
-- How many unique product lines does the data have?
select 
		count(distinct productline) 
        from salestable;
show columns from salestable;
-- What is the most common payment method?
select
		Payment, count(Payment) as count
        from salestable
        group by payment
        order by count desc 
        limit 1;
        
-- What is the most selling product line?
select
		productline, count(productline) as countprdln
        from salestable
        group by productline
        order by countprdln desc 
        limit 1;
-- What is the total revenue by month?
select
		sum(total) as total_revenue ,month_name
        from salestable
        group by month_name
        order by total_revenue desc;
        
-- What month had the largest COGS?
select
		sum(cogs) as total_cogs,month_name
        from salestable
        group by month_name
        order by total_cogs desc;

-- What product line had the largest revenue?
select
		productline, sum(total) as total_revenue 
        from salestable
        group by productline
        order by total_revenue desc; 

-- What is the city with the largest revenue?
select
		city, sum(total) as total_revenue 
        from salestable
        group by city
        order by total_revenue desc; 

-- What product line had the largest VAT?
select
		productline, avg(VAT) as avg_vat 
        from salestable
        group by productline
        order by avg_vat desc; 
        
-- Fetch each product line and add a column to those product line 
-- showing "Good", "Bad". Good if its greater than average sales

WITH CTESub_Table AS (
						SELECT AVG(Total) Avg_Total_Sales
						FROM salestable
						)


SELECT productline, ROUND(SUM(Total),2) AS Total_Sales,ROUND(AVG(Total),2) AS Avg_Sales, 
CASE
WHEN AVG(Total) > (SELECT * FROM CTESub_Table) THEN 'Good'
ELSE 'Bad'
END AS Status_of_Sales
FROM salestable
GROUP BY productline
ORDER BY 2 DESC;
	
-- Which branch sold more products than average product sold?
select 
		branch,sum(Quantity) as qty
        from salestable
        group by branch
        having sum(Quantity)>(select avg(Quantity) from salestable);
		
-- What is the most common product line by gender?

select
		gender,productline,count(gender) as total_cnt
        from salestable
        group by gender,productline
        order by total_cnt desc;
-- What is the average rating of each product line?

select 
		productline,round(avg(rating),2) as avg_rating
        from salestable
        group by productline
        order by avg_rating desc;

-- ------------------------------------------------------------------------------------------------------------
-- -----------------------------------------Sales Questions----------------------------------------------------

-- Number of sales made in each time of the day per weekday

select
		time_of_day,count(*) No_of_sales
        from salestable
        where day_name like 'monday'
        group by time_of_day
        order by no_of_sales desc;
-- Which of the customer types brings the most revenue?

select 
		customer_type,sum(total) as tot_rev
        from salestable
        group by customer_type
        order by tot_rev desc;
        
-- Which city has the largest tax percent/ VAT (Value Added Tax)?

select 
		city,avg(VAT) as avg_vat 
        from salestable 
        group by city 
        order by avg_vat desc;
        
-- Which customer type pays the most in VAT?

select 
		customer_type,avg(VAT) as avg_vat 
        from salestable 
        group by customer_type 
        order by avg_vat desc;

-- ------------------------------------------------------------------------------------------------------------
-- -------------------------------------Customer Questions---------------------------------------------------

-- How many unique customer types does the data have?
select
	distinct customer_type
from salestable;

-- How many unique payment methods does the data have?

select 
	distinct payment
FROM salestable;

-- What is the most common customer type?
select
	customer_type,
	count(*) as count
FROM salestable
GROUP BY customer_type
ORDER BY count DESC;

-- Which customer type buys the most?
SELECT
	customer_type,
    COUNT(*)
FROM salestable
GROUP BY customer_type;

-- What is the gender of most of the customers?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM salestable
GROUP BY gender
ORDER BY gender_cnt DESC;

-- What is the gender distribution per branch?
SELECT
	gender,
	COUNT(*) as gender_cnt
FROM salestable
WHERE branch = "C"
GROUP BY gender
ORDER BY gender_cnt DESC;

-- Gender per branch is more or less the same hence, I don't think has
-- an effect of the sales per branch and other factors.

-- Which time of the day do customers give most ratings?
SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM salestable
GROUP BY time_of_day
ORDER BY avg_rating DESC;

-- Looks like time of the day does not really affect the rating, its
-- more or less the same rating each time of the day.alter


-- Which time of the day do customers give most ratings per branch?
SELECT
	time_of_day,
	AVG(rating) AS avg_rating
FROM salestable
WHERE branch = "A"
GROUP BY time_of_day
ORDER BY avg_rating DESC;
-- Branch A and C are doing well in ratings, branch B needs to do a 
-- little more to get better ratings.


-- Which day fo the week has the best avg ratings?
SELECT
	day_name,
	AVG(rating) AS avg_rating
FROM salestable
GROUP BY day_name 
ORDER BY avg_rating DESC;
-- Mon, Tue and Friday are the top best days for good ratings



-- Which day of the week has the best average ratings per branch?
SELECT 
	day_name,
	COUNT(day_name) total_sales
FROM salestable
WHERE branch = "C"
GROUP BY day_name
ORDER BY total_sales DESC;
