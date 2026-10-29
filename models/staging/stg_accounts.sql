with source as (

    select *
    from {{ source('raw', 'raw_accounts') }}

),

standardised as (
    select
        nullif(upper(trim(acct_id)), '') as account_id,
        nullif(upper(trim(cust_id)), '') as customer_id,
        nullif(upper(trim(prod_cd)), '') as product_code,
        initcap(nullif(trim(account_type), '')) as account_type,
        initcap(nullif(trim(account_status), '')) as account_status,
        case
            when upper(trim(joint_account_flag)) in ('TRUE', 'T', 'YES', 'Y', '1') then true
            when upper(trim(joint_account_flag)) in ('FALSE', 'F', 'NO', 'N', '0') then false
            else null
        end as is_joint_account,
        case
            when account_open_dt > current_date() then null
            else cast(account_open_dt as date)
        end as account_open_date,
        case
            when account_close_dt is not null
            and account_close_dt < account_open_dt then null
        else cast(account_close_dt as date)
            end as account_close_date,
        case
            when record_updated_ts > current_timestamp() then null
            else cast(record_updated_ts as timestamp_ntz)
        end as record_updated_at


    from source
),

ranked as (
    select
        *,
        row_number() over (
            partition by account_id
            order by record_updated_at desc nulls last
        ) as rn
    from standardised
),

final as (
    select account_id,
        customer_id,
        product_code,
        account_type,
        account_status,
        is_joint_account,
        account_open_date,
        account_close_date,
        record_updated_at
    from ranked
    where rn = 1

)

select * 
from final