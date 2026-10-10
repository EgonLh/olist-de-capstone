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