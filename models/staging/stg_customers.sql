with source as (
    select *
    from {{ source('raw', 'raw_customers') }}
),

standardised AS (
select
    nullif(upper(trim(cust_id)), '') as customer_id,
    initcap(nullif(trim(cust_type), '')) as customer_type,
    case
        when dob > current_date() then null
        when dob > customer_since_dt then null
        else cast(dob as date)
    end as date_of_birth,
    case 
        when upper(trim(state)) in ('NSW', 'NEW SOUTH WALES', 'N.S.W.', 'N S W') THEN 'NSW'
        when upper(trim(state)) in ('VIC', 'VICTORIA', 'V.I.C.') THEN 'VIC'
        when upper(trim(state)) in ('QLD', 'QUEENSLAND', 'Q.L.D.') THEN 'QLD'
        when upper(trim(state)) in ('WA', 'WESTERN AUSTRALIA', 'W.A.', 'WEST AUST', 'WESTERN AUS') THEN 'WA'
        when upper(trim(state)) in ('SA', 'SOUTH AUSTRALIA', 'S.A.', 'SOUTH AUST', 'S AUST') THEN 'SA'
        when upper(trim(state)) in ('TAS', 'TASMANIA', 'TAZMANIA', 'T.A.S.') THEN 'TAS'
        when upper(trim(state)) in ('ACT', 'AUSTRALIAN CAPITAL TERRITORY', 'A.C.T.') THEN 'ACT'
        when upper(trim(state)) in ('NT', 'NORTHERN TERRITORY', 'N.T.') THEN 'NT'
    else UPPER(TRIM(state))
        end as state,
    nullif(trim(postcode), '') as postcode,
    cast(customer_since_dt as date) as customer_since_date,
    initcap(nullif(trim(risk_rating), '')) as risk_rating,
    initcap(nullif(trim(customer_segment), '')) as customer_segment,
    cast(record_created_ts as timestamp_ntz) as record_created_at,
    cast(record_updated_ts as timestamp_ntz) as record_updated_at

from source
),

ranked as (
    select *,
    row_number() over (partition by customer_id order by record_updated_at desc
) as rn
from standardised
),

final as (
    select customer_id,
    customer_type,
    date_of_birth,
    state,
    postcode,
    customer_since_date,
    risk_rating,
    customer_segment,
    record_created_at,
    record_updated_at
    from ranked
    where rn = 1
)

select * 
from final