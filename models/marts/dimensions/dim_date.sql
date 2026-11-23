with date_spine as (

    select
        dateadd(
            day,
            seq4(),
            cast('2020-01-01' as date)
        ) as full_date
    from table(generator(rowcount => 4018))

),

date_attributes as (

    select
        to_number(to_char(full_date, 'YYYYMMDD')) as date_key,
        full_date,
        day(full_date) as day_of_month,
        dayname(full_date) as day_name,
        dayofweekiso(full_date) as day_of_week,
        weekofyear(full_date) as week_of_year,
        month(full_date) as month_number,
        monthname(full_date) as month_name,
        date_trunc('month', full_date) as month_date,
        to_char(full_date, 'MM/YYYY') as month_year,
        to_number(to_char(full_date, 'YYYYMM')) as year_month_key,
        quarter(full_date) as quarter_number,
        year(full_date) as year,
        case
            when dayofweekiso(full_date) in (6, 7) then true
            else false
        end as is_weekend

    from date_spine

),

unknown_member as (

    select
        -1 as date_key,
        cast('1900-01-01' as date) as full_date,
        -1 as day_of_month,
        'Unknown' as day_name,
        -1 as day_of_week,
        -1 as week_of_year,
        -1 as month_number,
        'Unknown' as month_name,
        cast('1900-01-01' as date) as month_date,
        'Unknown' as month_year,
        -1 as year_month_key,
        -1 as quarter_number,
        -1 as year,
        false as is_weekend

),

final as (

    select *
    from date_attributes

    union all

    select *
    from unknown_member

)

select *
from final