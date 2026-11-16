with source as (

    select *
    from {{ ref('stg_scam_types') }}

),

dimension_records as (
    select 
        case
            when scam_type_code = 'UNK'
                then cast('-1' as varchar)
            else md5(scam_type_code)
        end as scam_type_key,
        scam_type_code, 
        scam_type_name,
        scam_category,
        scam_description,
        case
            when scam_type_code = 'UNK'
                then false
            else active_flag
        end as active_flag
    from source
),

final as (
    select 
        scam_type_key,
        scam_type_code, 
        scam_type_name,
        scam_category,
        scam_description,
        active_flag
    from dimension_records
)

select *
from final