with coverages as (
    select * from {{ ref('stg_policy_coverages') }}
),

enriched as (
    select
        coverage_id,
        policy_id,
        coverage_type,
        coverage_description,
        coverage_limit,
        deductible,
        premium_portion,
        case
            when coverage_limit > 0 then round(premium_portion / coverage_limit * 100, 4)
            else 0
        end as premium_to_limit_ratio,
        effective_date,
        end_date,
        datediff(day, effective_date, coalesce(end_date, current_date())) as coverage_duration_days,
        case
            when end_date is null or end_date >= current_date() then 'Active'
            else 'Expired'
        end as coverage_status_derived,
        status,
        created_date,
        updated_date,
        load_timestamp
    from coverages
)

select * from enriched
