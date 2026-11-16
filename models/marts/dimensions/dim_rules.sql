with source as (

    select *
    from {{ ref('stg_rules') }}

),

dim_records as (
    select
        md5(rule_id) as rule_key,
        rule_id,
        rule_name,
        rule_category,
        rule_description,
        rule_version,
        is_active,
        rule_start_date,
        rule_end_date,
        rule_last_updated
    from source
),

unknown_members as (
    select
        cast('-1' as varchar) as rule_key,
        'UNK' as rule_id,
        'Unknown Rule' as rule_name,
        'Unknown' as rule_category,
        'Unknown' as rule_description,
        'Unknown' as rule_version,
        false as is_active,
        cast('1900-01-01' as date) as rule_start_date,
        cast('1900-01-01' as date) as rule_end_date,
        cast('1900-01-01 00:00:00' as timestamp_ntz) as rule_last_updated
        
        
        

),

no_rule_triggered_member as (

    select
        md5('NO_RULE') as rule_key,
        'NO_RULE' as rule_id,
        'No Rule Triggered' as rule_name,
        'Manual' as rule_category,
        'Valid manual/customer-reported case' as rule_description,
        'N/A' as rule_version,
        false as is_active,
        cast('1900-01-01' as date) as rule_start_date,
        cast('1900-01-01' as date) as rule_end_date,
        cast('1900-01-01 00:00:00' as timestamp_ntz) as rule_last_updated

),
          


final as (

    select * from dim_records

    union all

    select * from unknown_members

    union all

    select * from no_rule_triggered_member
)

select *
from final