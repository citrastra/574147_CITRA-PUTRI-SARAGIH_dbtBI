with source_data as (
    select
        nullif(trim(cast(transaction_id as varchar)), '') as transaction_id,
        try_cast(transaction_datetime as timestamp) as transaction_datetime,
        nullif(trim(cast(customer_id as varchar)), '') as customer_id,
        nullif(trim(cast(product_id as varchar)), '') as product_id,
        try_cast(quantity as integer) as quantity,
        try_cast(unit_price as decimal(18, 2)) as unit_price,
        try_cast(discount_pct as decimal(5, 2)) as discount_pct,
        nullif(trim(cast(payment_method as varchar)), '') as payment_method,
        nullif(trim(cast(sales_channel as varchar)), '') as sales_channel,
        nullif(trim(cast(city as varchar)), '') as city,
        nullif(trim(cast(customer_type as varchar)), '') as customer_type,
        try_cast(shipping_cost as decimal(18, 2)) as shipping_cost,
        nullif(trim(cast(order_status as varchar)), '') as order_status,
        nullif(trim(cast(rating as varchar)), '') as rating_text,
        try_cast(nullif(trim(cast(rating as varchar)), '') as integer) as rating
    from {{ source('raw', 'transactions') }}
),

deduplicated as (
    select
        *,
        row_number() over (
            partition by transaction_id
            order by transaction_datetime desc nulls last
        ) as row_num
    from source_data
),

cleaned as (
    select
        d.transaction_id,
        d.transaction_datetime,
        d.customer_id,
        d.product_id,
        d.quantity,
        d.unit_price,
        coalesce(d.discount_pct, 0) as discount_pct,
        d.payment_method,
        d.sales_channel,
        d.city,
        d.customer_type,
        d.shipping_cost,
        d.order_status,
        d.rating
    from deduplicated d
    where d.row_num = 1
      and d.transaction_id is not null
      and d.transaction_datetime is not null
      and d.customer_id is not null
      and d.product_id is not null
      and d.quantity > 0
      and d.unit_price is not null
      and d.unit_price >= 0
      and (
          d.rating_text is null
          or d.rating between 1 and 5
      )
      and exists (
          select 1
          from {{ source('raw', 'products') }} p
          where trim(cast(p.product_id as varchar)) = d.product_id
      )
)

select *
from cleaned
