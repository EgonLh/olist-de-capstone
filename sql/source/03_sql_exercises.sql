with item_revenue as (
    select
        order_id,
        sum(price + freight_value) as revenue
    from raw.order_items oi
    group by order_id
),
payment_total as (
    select
        order_id,
        sum(payment_value) as payment_total
    from raw.order_payments op
    group by order_id
)
select
    ir.order_id,
    revenue,payment_total 
from item_revenue ir
left join payment_total p on ir.order_id  = p.order_id
limit 5;


--seller with no 1 star reviews at all --
select count(1) from raw.sellers s where not exists (
select 1  from raw.order_items oi join order_reviews r on oi.order_id = r.order_id
where oi.seller_id = s.seller_id
and r.review_score = 1
)


--Monthly revenue for delivered orders.--
with delivered_orders as (
    select
        o.order_id,
        date_trunc('month', o.order_purchase_timestamp)::date as order_month
    from raw.orders as o
    where o.order_status = 'delivered'
),
order_revenue as (
    select
        p.order_id,
        sum(p.payment_value) as revenue
    from raw.order_payments as p
    group by p.order_id
)
select
    d.order_month,
    count(*) as delivered_orders,
    round(sum(r.revenue), 2) as revenue
from delivered_orders as d
join order_revenue as r
    on r.order_id = d.order_id
group by d.order_month
order by d.order_month;

--For each month, which product category earned the most delivered revenue?--
WITH monthly AS ( -- step 1: revenue per month + category
SELECT DATE_TRUNC('month', o.order_purchase_timestamp) AS month,
p.product_category_name AS category,
SUM(oi.price) AS revenue
FROM raw.orders o
JOIN raw.order_items oi USING (order_id)
JOIN raw.products p USING (product_id)
WHERE o.order_status = 'delivered'
GROUP BY 1, 2
order by month
),
monthly_max AS ( -- step 2: best revenue per month with category
SELECT month, MAX(revenue) AS top_revenue
FROM monthly
GROUP BY month
order by month
)
SELECT m.month, m.category, m.revenue
FROM monthly m
JOIN monthly_max x
ON x.month = m.month
AND x.top_revenue = m.revenue -- keep only the winner
ORDER BY m.month;

SELECT p.product_category_name
FROM raw.products p
WHERE p.product_category_name NOT IN (
SELECT ct.product_category_name
FROM raw.category_translation ct
)order by p.product_category_name desc ;--13


SELECT p.product_category_name ,p.product_id
FROM raw.products p
WHERE NOT EXISTS (
SELECT 1
FROM raw.category_translation ct
WHERE ct.product_category_name = p.product_category_name
)order by p.product_category_name desc ;--623 610 is null and 13 have value


with delivered_orders as (
    select
        o.order_id,
        date_trunc('month', o.order_purchase_timestamp)::date as order_month
    from raw.orders as o
    where o.order_status = 'delivered'
),
category_revenue as (
    select
        d.order_month,
        p.product_category_name as category,
        sum(oi.price + oi.freight_value) as revenue
    from delivered_orders as d
    join raw.order_items as oi
        on d.order_id = oi.order_id
    join raw.products as p
        on oi.product_id = p.product_id
    group by
        d.order_month,
        p.product_category_name
),
ranked_categories as (
    select
        order_month,
        category,
        revenue,
        rank() over (
            partition by order_month
            order by revenue desc
        ) as rnk
    from category_revenue
)
select
    order_month,
    category,
    round(revenue::numeric, 2) as revenue
from ranked_categories
where rnk = 1
order by order_month;