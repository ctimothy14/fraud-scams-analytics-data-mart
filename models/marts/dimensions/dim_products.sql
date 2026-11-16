with source as (

    select *
    from {{ ref('stg_products') }}

),

dim_records as (
    select 
        md5(product_code) as product_key,
        product_code,
        product_name,
        product_category,
        is_active,
        effective_start_date,
        effective_end_date
    from source
),

unknown_members as (
    select 
        cast('-1' as varchar) as product_key,
        'UNK' as product_code,
        'Unknown Product' as product_name,
        'Unknown' as product_category,
        false as is_active,
        cast('1900-01-01' as date) as effective_start_date,
        cast('1900-01-01' as date) as effective_end_date
        
),

final as (
    select * from dim_records

    union all

    select * from unknown_members
)

select *
from final