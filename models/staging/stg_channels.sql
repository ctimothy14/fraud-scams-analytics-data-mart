with source as (

    select *
    from {{ source('raw', 'raw_channels') }}

),

standardised as (

    select
        nullif(upper(trim(channel_cd)), '') as channel_code,
        nullif(trim(channel_name), '') as channel_name,
        initcap(nullif(trim(channel_group), '')) as channel_group,
        initcap(nullif(trim(channel_type), '')) as channel_type

    from source

),

scored as (

    select
        channel_code,
        channel_name,
        channel_group,
        channel_type,

        (case when channel_name is not null then 1 else 0 end) +
        (case when channel_group is not null then 1 else 0 end) +
        (case when channel_type is not null then 1 else 0 end)
            as completeness_score

    from standardised

),

ranked_channel as (

    select
        channel_code,
        channel_name,
        channel_group,
        channel_type,

        row_number() over (
            partition by channel_code
            order by completeness_score desc
        ) as rn

    from scored

),

final as (

    select
        channel_code,
        channel_name,
        channel_group,
        channel_type

    from ranked_channel

    where rn = 1

)

select *
from final