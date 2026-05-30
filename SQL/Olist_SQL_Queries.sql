-- =========================================================
-- OLIST E-COMMERCE BUSINESS ANALYTICS SQL PROJECT
-- Author: Kotha Sai Srinath
-- Tools Used: MySQL
-- =========================================================

-- =========================================================
-- BASIC BUSINESS ANALYSIS QUERIES
-- =========================================================

-- 1. Total Number of Orders
SELECT COUNT(*) AS Total_Orders
FROM orders;

-- 2. Total Revenue Generated
SELECT ROUND(SUM(payment_value),2) AS Total_Revenue
FROM order_payments;

-- 3. Total Unique Customers
SELECT COUNT(DISTINCT customer_unique_id) AS Total_Customers
FROM customers;

-- 4. Most Used Payment Type
select payment_type, count(*)  
total_usuage from order_payments group by payment_type;

-- 5. Average Review Score
SELECT ROUND(AVG(review_score),2) AS Avg_Review_Score
FROM order_reviews;

-- =========================================================
-- SELLER ANALYSIS --
-- =========================================================

-- 6. Top Revenue Generating Sellers
select s.seller_id,Sum(ori.price) as 'Total Revenue'
from sellers s
join order_items ori on ori.seller_id=s.seller_id
group by s.seller_id
order by sum(ori.price) desc
limit 10;

-- =========================================================
-- DELIVERY ANALYSIS
-- =========================================================

-- 7. Average Delivery Delay by Customer State
select ROUND(avg(DATEDIFF(ord.order_delivered_customer_date ,ord.order_estimated_delivery_date)),2), 
cus.customer_state
from orders ord
join customers cus on ord.customer_id = cus.customer_id
group by cus.customer_state
limit 10;

-- 8. Late Delivery Percentage
-- late delivery means >0 if <0 it is deliveried early
select 
SUM(
	case
		when 
				datediff(order_delivered_customer_date ,order_estimated_delivery_date) >0 
                then 1 
                else 0
    end
    )*100.0 /count(*) AS late_delivery_percentage
from orders;

-- 9. Review Score Comparison:
-- Late vs On-Time Deliveries
SELECT 
    CASE
        WHEN DATEDIFF(
            ord.order_delivered_customer_date,
            ord.order_estimated_delivery_date
        ) > 0
        THEN 'Late'
        ELSE 'On Time'
    END AS delivery_status,
    ROUND(AVG(rev.review_score),2) AS avg_review_score
FROM orders ord
JOIN order_reviews rev
ON ord.order_id = rev.order_id
GROUP BY delivery_status;

-- =========================================================
-- REVENUE ANALYSIS
-- =========================================================

-- 10. Calculate monthly revenue growth.
select date_format(ord.order_approved_at,'%Y-%m') as 'Order_month',Sum(payment_value) as monthly_revenue
from order_payments orp
join orders ord on ord.order_id =orp.order_id
group by Order_month
order by Order_month;


-- =========================================================
-- CUSTOMER ANALYSIS
-- =========================================================

-- 11. Top 5 Customers by Spending
select  cus.customer_id,sum(orp.payment_value) as total_spending
from customers cus
join orders ord on ord.customer_id = cus.customer_id
join order_payments orp on orp.order_id = ord.order_id
group by cus.customer_id
order by total_spending desc
limit 5;


-- 12.Which customers placed more than one order?
select cus.customer_unique_id,count(order_id) AS total_orders
from customers cus
join orders ord on ord.customer_id = cus.customer_id
group by cus.customer_unique_id 
having count(order_id)>1;

-- =========================================================
-- WINDOW FUNCTION ANALYSIS
-- =========================================================

-- 13. Running Total Revenue
select order_month , Monthly_revenue,
SUM(Monthly_revenue) 
over(order by order_month ) as Running_revenue
from (
select date_format(order_approved_at, '%Y-%m') as order_month,
sum(payment_value) as Monthly_revenue
from orders ord
join order_payments orp on orp.order_id= ord.order_id
group  by order_month) t;
-- NOTE: EVERY TABLE MUST HAVE A UNIQUE ALIAS NAME. AS t in above table.

-- =========================================================
-- END OF PROJECT
-- =========================================================
