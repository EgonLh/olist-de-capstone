
-- Q1
-- calculate > total revenuess
-- Rank sellers
-- the top 3 ranks
with seller_revenue as (
    select
        s.seller_state,
        s.seller_id,
        SUM(oi.price) AS revenue
    FROM raw.sellers s
    join raw.order_items oi
        ON s.seller_id = oi.seller_id
    group by s.seller_state, s.seller_id
),
ranked_sellers AS (
    SELECT
        seller_state,
        seller_id,
        revenue,
        RANK() OVER (
            PARTITION BY seller_state
            ORDER BY revenue DESC
        ) AS rank
    FROM seller_revenue
)
select
    seller_state,
    seller_id,
    revenue,
    rank
from ranked_sellers
where rank <= 3
order by seller_state, rank;

--Q3
-- each seller's order revenue 
-- one revenue total per seller
-- Add each order's revenue
with seller_order_revenue as (
    select
        oi.seller_id,
        oi.order_id,
        o.order_purchase_timestamp,
        sum(oi.price + oi.freight_value) as order_revenue
    from raw.order_items oi
    join raw.orders o
        on oi.order_id = o.order_id
    group by
        oi.seller_id,
        oi.order_id,
        o.order_purchase_timestamp
)
select
    seller_id,
    order_id,
    order_purchase_timestamp,
    order_revenue,
    sum(order_revenue) over (
        PARTITION BY seller_id
        ORDER BY order_purchase_timestamp, order_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_revenue
FROM seller_order_revenue
ORDER BY seller_id, order_purchase_timestamp, order_id;



--Q4
-- the total money paid
-- divide / grand total -> percentage
select
    payment_type,
    sum(payment_value) AS total_paid,
    round(
        100.0 * sum(payment_value)
        / sum(sum(payment_value)) over (),
        1
    ) as percentage_total 
from raw.order_payments
group by payment_type;

--Q5 : 
-- get price and category
-- avg > each category
-- not null > category
-- round 2 decmi
with item_category_prices as (
    SELECT
        oi.order_id,
        oi.product_id,
        p.product_category_name AS category,
        oi.price,
        avg(oi.price) OVER (
            PARTITION BY p.product_category_name
        ) as category_avg
    from raw.order_items oi
    join raw.products p
        ON oi.product_id = p.product_id
    where p.product_category_name IS NOT NULL
)
select
    order_id,
    product_id,
    category,
    price,
    ROUND(category_avg, 2) as category_avg
from item_category_prices
where price > category_avg
order by category, price desc;

