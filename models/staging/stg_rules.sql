with source as (
    select *
    from {{ source('raw', 'raw_rules') }}
),

standardised as (
    select 
        upper(trim(rule_id)) as rule_id,
        initcap(trim(rule_name)) as rule_name,
        initcap(trim(rule_category)) as rule_category,
        initcap(trim(rule_description)) as rule_description,
        upper(trim(rule_version)) as rule_version,

        -- standardized boolean flag
        case 
            when upper(trim(rule_active_flag)) in ('Y', 'YES', 'ACTIVE', '1') then true
            when upper(trim(rule_active_flag)) in ('N', 'NO', 'INACTIVE', '0') then false
            else null 
        end as is_active,

        -- timestamps
        cast(rule_start_dt as date) as rule_start_date,
        cast(rule_end_dt as date) as rule_end_date,
        cast(last_updated_ts as timestamp_ntz) as rule_last_updated

    from source
),

ranked as (
    select 
        *,
        row_number() over (
            partition by rule_id 
            order by rule_last_updated desc, rule_version desc
        ) as rn
    from standardised
),

final as (
    select 
    rule_id,
    rule_name,
    rule_category,
    rule_description,
    rule_version,
    is_active,
    rule_start_date,
    rule_end_date,
    rule_last_updated
from ranked
where rn = 1
)

select *
from final

