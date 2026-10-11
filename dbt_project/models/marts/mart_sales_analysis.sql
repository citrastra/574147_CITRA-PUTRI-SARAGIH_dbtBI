with transactions as (

    select *
    from {{ ref('stg_transactions') }}

),

products as (

    select *
    from {{ ref('stg_products') }}

),

enriched as (

    select
        cast(date_trunc('month', t.transaction_datetime) as date)
            as order_month,
        p.category,
        t.sales_channel,
        t.city,
        t.transaction_id,
        t.quantity,
        t.unit_price,
        t.discount_pct,
        coalesce(t.shipping_cost, 0) as shipping_cost,
        t.order_status,
        t.rating,

        t.quantity * t.unit_price as gross_amount,

        t.quantity * t.unit_price
            * t.discount_pct / 100.0 as discount_amount,

        case
            when t.order_status in ('Completed', 'Shipped')
            then t.quantity * t.unit_price
                 * (1 - t.discount_pct / 100.0)
            else 0
        end as net_sales

    from transactions t
    inner join products p
        on t.product_id = p.product_id

)

select
    order_month,
    category,
    sales_channel,
    city,
    count(distinct transaction_id) as transaction_count,
    sum(quantity) as total_quantity,
    sum(gross_amount) as gross_sales,
    sum(discount_amount) as discount_amount,
    sum(shipping_cost) as total_shipping_cost,
    sum(net_sales) as total_net_sales,
    avg(rating) as average_rating

from enriched
group by
    order_month,
    category,
    sales_channel,
    city
