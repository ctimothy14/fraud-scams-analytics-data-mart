with source as (
    select * 
    from {{ source('raw', 'raw_scam_cases') }}
),

standardised as (
    select 
        nullif(upper(trim(case_id)), '') as case_id,
        nullif(upper(trim(cust_id)), '') as customer_id,
        nullif(upper(trim(acct_id)), '') as account_id,
        nullif(upper(trim(prod_cd)), '') as product_code,
        nullif(upper(trim(channel_cd)), '') as channel_code,
        nullif(upper(trim(scam_type_cd)), '') as scam_type_code,
        nullif(upper(trim(rule_id)), '') as rule_id,
        initcap(nullif(trim(case_status), '')) as case_status,
        initcap(nullif(trim(case_outcome), '')) as case_outcome,
        initcap(nullif(trim(case_priority), '')) as case_priority,
        initcap(nullif(trim(source_system), '')) as source_system,
        cast(case_opened_ts as timestamp_ntz) as case_opened_at,
        case when case_closed_ts is not null
            and case_closed_ts < case_opened_ts
            then null
            else cast(case_closed_ts as timestamp_ntz)
        end as case_closed_at,
        cast(loss_occurred_ts as timestamp_ntz) as loss_occurred_at,
        alert_cnt as alert_count,
        txn_cnt as transaction_count,
        abs(try_to_decimal(nullif(regexp_replace(trim(gross_loss_amt), '[$,]', ''), ''),18,2)) as gross_loss_amount,
        try_to_decimal(nullif(regexp_replace(trim(prevented_amt), '[$,]', ''), ''), 18, 2) as prevented_amount,
        try_to_decimal(nullif(regexp_replace(trim(recovered_amt), '[$,]', ''), ''), 18, 2) as recovered_amount,
        try_to_decimal(nullif(regexp_replace(trim(reimbursed_amt), '[$,]', ''), ''), 18, 2) as reimbursed_amount,
        created_by,
        cast(last_updated_ts as timestamp_ntz) as last_updated_at
    from source
),

ranked as (
    select *,
    row_number() over (partition by case_id order by last_updated_at desc nulls last) as rn
    from standardised
),

final as (
    select case_id,
    customer_id,
    account_id,
    product_code,
    channel_code,
    scam_type_code,
    rule_id,
    case_status,
    case_outcome,
    case_priority,
    source_system,
    case_opened_at,
    case_closed_at,
    loss_occurred_at,
    alert_count,
    transaction_count,
    gross_loss_amount,
    prevented_amount,
    recovered_amount,
    reimbursed_amount,
    created_by,
    last_updated_at
    from ranked
    where rn = 1
)

select * 
from final