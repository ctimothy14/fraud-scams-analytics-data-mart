with source as (
    select *
    from {{ source('raw', 'raw_products') }}
),

standardised as (
    select
        nullif(upper(trim(prod_cd)), '') as product_code,
        nullif(trim(product_name), '') as product_name,
        nullif(trim(product_category), '') as product_category,
        case
            when upper(trim(product_status)) in ('ACTIVE') then true
            when upper(trim(product_status)) in ('INACTIVE') then false
            else null
        end as is_active,
        cast(effective_start_dt as date) as effective_start_date,
        cast(effective_end_dt as date) as effective_end_date
    from source
),

reference as (
    select *
    from {{ ref('products_reference') }}
),

matched as (
    select s.*,
    case
        when s.product_code = r.product_code
        and upper(s.product_category) = upper(r.product_category)
        and upper(s.product_name) = upper(r.product_name)
            then 1
        else 0
    end as canonical_match

    from standardised s
    left join reference r
    on s.product_code = r.product_code
),

ranked as (
    select *,
    row_number() over (partition by product_code order by canonical_match desc) as rn
    from matched
),

final as (
    select
        product_code,
        product_name,
        product_category,
        is_active,
        effective_start_date,
        effective_end_date
    from ranked
    where rn = 1
)

select *
from final