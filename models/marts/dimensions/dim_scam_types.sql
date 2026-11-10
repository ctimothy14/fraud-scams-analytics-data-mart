with source as (

    select *
    from {{ ref('stg_scam_types') }}

),

dimension_records as (
    select 
        md5(scam_type_code) as scam_type_key,
        scam_type_code, 
        scam_type_name,
        scam_category,
        scam_description,
        active_flag,
    from source
),

unknown_members as (
    select
        cast('-1' as varchar) as scam_type_key,
        'UNK' as scam_type_code,
        'Unknown' as scam_type_name,
        'Unknown' as scam_category,
        'Unknown' as scam_description,
        false as active_flag
),

final as (
    select * from dimension_records

    union all

    select * from unknown_members
)

select *
from final