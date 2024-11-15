CREATE DATABASE IF NOT EXISTS walmartSales;

CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) NOT NULL PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    tax_pct FLOAT(6) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_pct FLOAT(11),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2)
);

------------------- Feature Engineering -----------------------------
# Time_of_day

SELECT time,
CASE 
	WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
	WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
	ELSE "Evening" 
END AS Time_of_day
FROM sales;

alter table sales
add Time_of_day varchar(50);

SET SQL_SAFE_UPDATES = 0; 

update sales
set Time_of_day =(
CASE 
	WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
	WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
	ELSE "Evening" 
END);

### Add day_name column

SELECT
	date,
	DAYNAME(date)
FROM sales;

ALTER TABLE sales 
ADD COLUMN day_name VARCHAR(10);

UPDATE sales
SET day_name = DAYNAME(date);


### Add month_name column

SELECT
	date,
	MONTHNAME(date)
FROM sales;

ALTER TABLE sales 
ADD COLUMN month_name VARCHAR(10);

UPDATE sales
SET month_name = MONTHNAME(date);


Select * from sales;


#----------------Exploratory Data1 Analysis (EDA)----------------------
#Generic Questions

#1. How many unique cities does the data have?

Select distinct (city)
from sales;

#2. In which city is each branch?

select distinct(branch), city
from sales;

# PRODUCT ANALYSIS
#1. How many unique product lines does the data have?

SELECT COUNT(DISTINCT (product_line)) as unique_product_lines_count
FROM sales;

#2. What is the most common payment method?

SELECT payment, count(payment) as common_pay
FROM sales
group by payment
order by common_pay desc
limit 1;

#3. What is the most selling product line?

select product_line, sum(quantity) as selling 
from sales
group by product_line
order by selling desc
limit 1;

#4. What is the total revenue by month?

select month_name, sum(unit_price * quantity) as total_revenue
from sales
group by month_name
ORDER BY total_revenue DESC;

#5. What month had the largest COGS?

select month_name, sum(cogs) as largest_COGS
from sales
group by month_name
ORDER BY largest_COGS DESC;

#6. What product line had the largest revenue?

select product_line, sum(total) as largest_rev
from sales
group by product_line
ORDER BY largest_rev DESC
limit 1;

#7. What is the city with the largest revenue?

select city, sum(total) as largest_rev_city
from sales
group by city
ORDER BY largest_rev_city DESC
limit 1;

#8. What product line had the largest VAT?

select product_line, sum(0.05* COGS) as vat
from sales
group by product_line
ORDER BY vat DESC
;

#9. Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales

select product_line,
CASE 
	WHEN sum(total) >= (SELECT AVG(total) FROM sales) THEN "Good"
    ELSE "Bad"
END as st1
from sales
group by product_line;

#10. Which branch sold more products than average product sold?

select branch, sum(quantity) as sum1
from sales
group by branch
having sum1> (select (avg(quantity)) from sales)
ORDER BY sum1;


#11. What is the most common product line by gender?

select gender, product_line, count(gender) as common
from sales
group by gender, product_line
order by common desc;

#12. What is the average rating of each product line?
 
select product_line, ROUND(AVG(rating),2) as rating
from sales
group by product_line
;

# SALES ANALYSIS

#1. Number of sales made in each time of the day per weekday

select count(invoice_id) as no_of_sales, Time_of_day , day_name
from sales
group by Time_of_day , day_name
HAVING day_name NOT IN ('Sunday','Saturday')
order by day_name;

#2. Which of the customer types brings the most revenue?

select customer_type, sum( total) as most_rev
from sales
group by customer_type
order by most_rev desc
limit 1;

#3. Which city has the largest tax percent/ VAT (Value Added Tax)?

SELECT city, SUM(tax_pct) AS total_VAT
FROM sales 
GROUP BY city 
ORDER BY total_VAT DESC 
LIMIT 1;

#4. Which customer type pays the most in VAT?

SELECT customer_type, SUM(tax_pct) AS most_VAT
FROM sales 
GROUP BY customer_type 
ORDER BY most_VAT DESC 
;

# CUSTOMER ANALYSIS
#1. How many unique customer types does the data have?

SELECT count(distinct(customer_type)) AS unique1
FROM sales ;

#2. How many unique payment methods does the data have?

SELECT COUNT(DISTINCT (payment)) 
FROM sales;

#3. What is the most common customer type?

SELECT customer_type, COUNT(customer_type) AS common_customer
FROM sales 
GROUP BY customer_type 
ORDER BY common_customer DESC 
;

#4. Which customer type buys the most?

SELECT customer_type, SUM(total) as total_sales
FROM sales 
GROUP BY customer_type 
ORDER BY total_sales 
LIMIT 1;

#5. What is the gender of most of the customers?

SELECT gender, count(gender) as mc
FROM sales 
GROUP BY gender
ORDER BY mc desc
;

#6. What is the gender distribution per branch?

SELECT branch, gender, COUNT(gender) AS gender_distribution
FROM sales 
GROUP BY branch,gender 
ORDER BY branch;

#7. Which time of the day do customers give most ratings?

SELECT Time_of_day, count(rating) as s1
FROM sales 
GROUP BY Time_of_day
ORDER BY s1 desc;

#8. Which time of the day do customers give most ratings per branch?

SELECT Time_of_day, count(rating) as s1
FROM sales 
GROUP BY Time_of_day
ORDER BY s1 desc;


#9. Which day fo the week has the best avg ratings?

SELECT day_name, AVG(rating) AS average_rating
FROM sales 
GROUP BY day_name 
ORDER BY average_rating DESC 
LIMIT 1;

#10. Which day of the week has the best average ratings per branch?

SELECT  branch, day_name, AVG(rating) AS average_rating
FROM sales 
GROUP BY day_name, branch 
ORDER BY average_rating DESC;

