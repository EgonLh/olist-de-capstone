-- Q1. NULL audit: count NULLs in product_category_name and product_weight_g. --
select 
	count(*) as total_data,
	count(*) - count(p.product_category_name) as null_category,
	count(*) - count(p.product_weight_g) as null_weight 
from products p ;

-- Q2. For each month of purchase, what is the average delivery time, and how many orders (and what percentage) were delivered within 30 days of purchase?
with delivery_stats as (
    select
        date_trunc('month', o.order_purchase_timestamp)::date as order_month,
        o.order_id,
        extract(epoch from (
            o.order_delivered_customer_date - o.order_purchase_timestamp
        )) / 86400.0 as delivery_days --86400 sec
    from raw.orders as o
    where o.order_status = 'delivered'
      and o.order_purchase_timestamp is not null
      and o.order_delivered_customer_date is not null
)
select
    order_month,
    round(avg(delivery_days)::numeric, 2) as avg_delivery_days,
    count(*) as delivered_orders,
    count(*) filter (
        where delivery_days <= 30
    ) as within_30_days,
    round(
        100.0 * count(*) filter (
            where delivery_days <= 30
        ) / count(*),
        2
    ) as within_30_days_pct
from delivery_stats
group by order_month
order by order_month;

--Q3 >> On which day of the week do customers place the most orders? Show each weekday’s name and number, and the total orders for that day, sorted from busiest to quietest.
-- > weekdays, weekdays_nums > count > group> orders
select
    to_char(order_purchase_timestamp, 'Day') as weekday_name,
    extract(isodow from order_purchase_timestamp)::int as weekday_number,
    count(*) as total_orders
from raw.orders
where order_purchase_timestamp is not null
group by
    to_char(order_purchase_timestamp, 'Day'),
    extract(isodow from order_purchase_timestamp)
order by total_orders desc;

--Q4 : Q.4 What is the total revenue for each product category, shown with its English name? If a category has no English translation, show the original Portuguese name instead. If the product has no category at all, show it as ‘unknown’.
-- get order items > categories
-- eng_cat > if
-- if translation ! 'unknown'
-- total revenue for each category
-- group by sort from highest to lowest 
select
    coalesce(
        t.product_category_name_english,
        p.product_category_name,
        'unknown'
    ) as category,
    round(sum(oi.price + oi.freight_value)::numeric, 2) as revenue
from raw.order_items as oi
join raw.products as p
    on oi.product_id = p.product_id
left join raw.category_translation as t
    on p.product_category_name = t.product_category_name
group by
    coalesce(
        t.product_category_name_english,
        p.product_category_name,
        'unknown'
    )
order by revenue desc;

--Q5 : Group delivered orders by delivery speed:
with delivery_days as (
    select
        o.order_id,
        extract(epoch from (
            o.order_delivered_customer_date - o.order_purchase_timestamp
        )) / 86400.0 as days
    from raw.orders as o
    where o.order_status = 'delivered'
      and o.order_purchase_timestamp is not null
      and o.order_delivered_customer_date is not null
),
delivery_groups as (
    select
        order_id,
        case
            when days <= 7 then 'Fast'
            when days <= 14 then 'Normal'
            when days <= 30 then 'Slow'
            when days > 30 then 'Very slow'
        end as delivery_speed
    from delivery_days
    where days >= 0
)
select
    delivery_speed,
    count(*) as total_orders,
    round(
        100.0 * count(*) / sum(count(*)) over (),
        2
    ) as percentage
from delivery_groups
where delivery_speed is not null
group by delivery_speed
order by
    case delivery_speed
        when 'Fast' then 1
        when 'Normal' then 2
        when 'Slow' then 3
        when 'Very slow' then 4
    end;