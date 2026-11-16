with source as (

    select *
    from {{ ref('stg_customers') }}

),

dim_records as (
    select
        md5(customer_id) as customer_key,
        customer_id,
        customer_type,
        date_of_birth,
        state,
        postcode,
        customer_since_date,
        risk_rating,
        customer_segment,
        record_created_at,
        record_updated_at
    from source
        
),

unknown_members as (
    select 
        cast('-1' as varchar) as customer_key,
        'UNK' as customer_id,
        'Unknown' as customer_type,
        cast(null as date) as date_of_birth,
        'Unknown' as state,
        'Unknown' as postcode,
        cast('1900-01-01' as date) as customer_since_date,
        'Unknown' as risk_rating,
        'Unknown' as customer_segment,
        cast('1900-01-01 00:00:00' as timestamp_ntz) as record_created_at,
        cast('1900-01-01 00:00:00' as timestamp_ntz) as record_updated_at     
        
),

final as (
    select * from dim_records

    union all

    select * from unknown_members
)

select *
from final