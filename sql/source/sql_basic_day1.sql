--Limit Usasge--
select * from orders limit 5; 

--Get specific columns and renamed from a table--
select order_id, order_status as Status from orders limit 10;

--Get Distinct Order Status From Orders--
select distinct order_status from orders

--Where : filtering rows--

-- order status => delivered --
select order_id,order_status as Status from orders 
where order_status = 'delivered'

-- order status != canceled  --
select distinct order_status as status
from orders
where order_status <>'canceled'

select distinct customer_state from customers 

-- Arranged Selection with Where operator --
select customer_id,customer_city  from customers 
where customer_state in ('ES','TO','PI')

-- Select Between two values ---
select * from order_items
where price between 20 and 30

-- Like operator --
select * from customers 
where customer_city like '%sao';

select * from customers 
where customer_city like 'sao%';

--Order By--
select order_id,product_id,price,freight_value from raw.order_items 
order by price desc  limit 10

--sort by two keys; alias is allowed here
select * from order_items 
order by price,order_id limit 10

-- order by two columns
select price+freight_value as total_paid,order_id 
from order_items
order by total_paid,order_id  desc limit 10

-- Aggregate Func-- 
select count(*) from customers ; --99441
select count(*) from order_items; --112,650

--Order Status Count by Orders--
--Combination with GroupBy
select count(*),order_status from orders 
group by order_status

--Where and Group by
select count(*),customer_state from customers  
where customer_state <> 'SP'
group by customer_state

--Where + Group By + Having--
select seller_id ,Count(*) as items_sold
from order_items 
group by seller_id
having count(*) > 100


