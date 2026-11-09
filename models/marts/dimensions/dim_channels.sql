with source as (

    select *
    from {{ ref('stg_channels') }}

),

dimension_records as (
    select md5(channel_code) as channel_key,
        channel_code,
        channel_name,
        channel_group,
        channel_type
    from source
),

unknown_member as (

    select
        cast('-1' as varchar) as channel_key,
        'UNK' as channel_code,
        'Unknown' as channel_name,
        'Unknown' as channel_group,
        'Unknown' as channel_type
),

final as (
select * from dimension_records

union all

select * from unknown_member
)

select *
from final