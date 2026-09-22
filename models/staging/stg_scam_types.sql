with source as (
    select * 
    from {{ source('raw', 'raw_scam_types') }}
),


standardised as (
    select
        nullif(upper(trim(scam_type_cd)), '') as scam_type_code,
        nullif(trim(scam_type_name), '') as scam_type_name,
        nullif(trim(scam_category), '') as scam_category,
        nullif(trim(scam_description), '') as scam_description,
        -- standardise and clean boolean
        case
            when upper(trim(active_flag)) in ('TRUE', 'T', 'YES', 'Y', '1') then true
            when upper(trim(active_flag)) in ('FALSE', 'F', 'NO', 'N', '0') then false
            else null
        end as active_flag

    from source
),

reference as (
    select * 
    from {{ ref('scam_type_reference') }}
),

matched as (
    select s.*,
    case
        when s.scam_type_code = r.scam_type_code
        and upper(s.scam_category) = upper(r.scam_category)
        and upper(s.scam_type_name) = upper(r.scam_type_name)
            then 1
        else 0
    end as canonical_match

    from standardised s
    left join reference r
    on s.scam_type_code = r.scam_type_code
),

ranked as (
    select *,
    row_number() over (partition by scam_type_code order by canonical_match desc) as rn
    from matched
),


final as (
    select
        scam_type_code,
        scam_type_name,
        scam_category,
        scam_description,
        active_flag
            

    from ranked
    where rn = 1
)

select *
from final