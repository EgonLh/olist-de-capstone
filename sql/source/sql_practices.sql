-- understand steps by steps logics , and keywords such as total->sum , desc + limit > top nums
-- not too overwhelmed

-- How many customers are there in each state? Show the top 5 states.--
-- limit 5 > count > order desc > grounp
select customer_state, COUNT(*) as customer
from customers
group by customer_state
order by customer desc
limit 5;

-- How many distinct real customers (customer_unique_id) are there? --
-- unique > distinct > count > customer
select count(distinct customer_unique_id) as unique_customers
from customers;

--  Which payment_type is used most, and what is its total payment_value?--
-- total , ground by payments , sum-> used most , order by total,count
select payment_type, count(*) as total_transactions, sum(payment_value) as total_payment_value
from  order_payments
group by payment_type
order by total_transactions desc
limit 1;

-- 4. Count reviews for each score (1-5) and find the average score. --
-- (1-5)>between , count , avg, 
select review_score, count(*) as total_reviews, (avg(review_score)) as average_rev_score
from order_reviews
where review_score between 1 and 5
group by review_score
order by review_score;

--5. Find seller states with more than 50 sellers.--
-- count -> having >50 -> order 
select seller_state,count(*) as total_sellers from sellers
group by seller_state 
having count(*) > 50
order by total_sellers desc;

--6. Calculate the average price and freight per item, rounded to 2 decimals--
--  avg 
select round(avg(price),2) as avg_price, round(avg(freight_value),2) as avg_freight from order_items;

