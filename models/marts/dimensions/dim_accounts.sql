with source as (

    select *
    from {{ ref('stg_accounts') }}

),

dim_records as (
    select 
        md5(account_id) as account_key,
        account_id,
        customer_id,
        product_code,
        account_type,
        account_status,
        is_joint_account,
        account_open_date,
        account_close_date,
        record_updated_at
    from source
        
),

unknown_members as (
    select
        cast('-1' as varchar) as account_key,
        'UNK' as account_id,
        'UNK' as customer_id,
        'UNK' as product_code,
        'Unknown' as account_type,
        'Unknown' as account_status,
        cast(null as boolean) as is_joint_account,
        cast('1900-01-01' as date) as account_open_date,
        cast('1900-01-01' as date) as account_close_date,
        cast('1900-01-01' as timestamp_ntz) as record_updated_at
        
),

final as (
    select * from dim_records

    union all

    select * from unknown_members
)

select *
from final