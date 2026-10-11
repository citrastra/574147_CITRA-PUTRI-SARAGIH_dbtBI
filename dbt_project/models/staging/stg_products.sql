with source_data as (
    select
        nullif(trim(cast(product_id as varchar)), '') as product_id,
        nullif(trim(cast(product_name as varchar)), '') as product_name,
        nullif(trim(cast(brand as varchar)), '') as brand,
        nullif(trim(cast(category as varchar)), '') as category,
        nullif(trim(cast(subcategory as varchar)), '') as subcategory,
        try_cast(unit_price as decimal(18, 2)) as unit_price,
        try_cast(stock as integer) as stock,
        nullif(trim(cast(supplier as varchar)), '') as supplier,
        case try_cast(is_active as integer)
            when 1 then true
            when 0 then false
            else null
        end as is_active
    from {{ source('raw', 'products') }}
),

deduplicated as (
    select
        *,
        row_number() over (
            partition by product_id
            order by product_id
        ) as row_num
    from source_data
)

select
    product_id,
    product_name,
    brand,
    category,
    subcategory,
    unit_price,
    stock,
    supplier,
    is_active
from deduplicated
where row_num = 1
  and product_id is not null
  and product_name is not null
  and unit_price is not null
  and unit_price >= 0
