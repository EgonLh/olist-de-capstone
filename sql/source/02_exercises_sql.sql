--Q1.Revenue (SUM of price) by customer_state for delivered orders. Top 10 states.
select * from raw.customers c ;    --customer_state
select * from raw.order_items oi ; --price
select * from raw.orders o;        --delivered : main

select c.customer_state as customer_state, SUM(oi.price) as revenue from raw.orders o 
inner join raw.customers c on o.customer_id = c.customer_id 
inner join raw.order_items oi on o.order_id = oi.order_id   
where o.order_status = 'delivered'
group by customer_state
order by revenue desc limit 10;

--Q.2 How many orders have no review at all? (anti-join)
select count(distinct o.order_id ) as order_without_rev
from raw.orders o 
left join raw.order_reviews t 
on o.order_id  = t.order_id 
where t.order_id is null;


--Q.3: Top 10 product categories in English by items sold. Why LEFT JOIN to the translation?

select * from raw.category_translation ct ;
select *  from raw.products;
select * from raw.order_items oi ;

select
    tr.product_category_name_english,
    count(*) as items_sold
from raw.order_items oi
inner join raw.products p on oi.product_id = p.product_id
left join raw.category_translation tr on p.product_category_name = tr.product_category_name
group by tr.product_category_name_english
order by items_sold desc
limit 10;

--4. What share of order items were sold by a seller in the same state as the customer?

select SUM(case when s.seller_state = c.customer_state
	then 1 else 0 end) as same_state , count(*) as total_items,
	round(100.0 * sum(case when s.seller_state = c.customer_state then 1 else 0 end)/count(*),1)share
from raw.order_items i
join raw.sellers s
    on i.seller_id = s.seller_id -- get seller state
join raw.orders o
    on i.order_id = o.order_id -- connect items to orders
join raw.customers c
    on o.customer_id = c.customer_id; -- get customer state
    
    
--5. For 5 orders, show item revenue and payment total side by side — without fan-out.
select o.order_id,
    o.item_revenue,
    p.payment_total
from (select order_id, sum(price + freight_value) as item_revenue -- total item price + freight per order
    from raw.order_items ot
    group by order_id) o
join (select order_id, sum(payment_value) as payment_total  --  total payments per order
    from raw.order_payments 	
    group by order_id
) p on o.order_id = p.order_id
limit 5;

--6. Find orders where payments differ from price + freight by more than 1.00.
select
    i.order_id,
    round(i.item_total::numeric, 2) as item_total,
    round(p.payment_total::numeric, 2) as payment_total,
    round(abs(i.item_total - p.payment_total)::numeric, 2) as difference
from (--price + freight per order
    select order_id, sum(price + freight_value) as item_total --include fregi
    from raw.order_items
    group by order_id
) i
join ( -- payments per order
    select order_id, sum(payment_value) as payment_total
    from raw.order_payments
    group by order_id
) p on i.order_id = p.order_id
where abs(i.item_total - p.payment_total) > 1.00
order by difference desc;