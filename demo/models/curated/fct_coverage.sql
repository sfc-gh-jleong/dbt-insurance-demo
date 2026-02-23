with coverages as (
    select * from {{ ref('ref_policy_coverages') }}
),

policies as (
    select policy_id, policy_key from {{ ref('dim_policy') }}
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['c.coverage_id', 'c.effective_date']) }} as coverage_fact_key,
        c.coverage_id,
        p.policy_key,
        c.coverage_type,
        c.coverage_limit,
        c.deductible,
        c.premium_portion,
        c.premium_to_limit_ratio,
        c.effective_date,
        c.end_date,
        c.coverage_duration_days,
        c.coverage_status_derived,
        c.status,
        c.created_date,
        c.updated_date
    from coverages c
    left join policies p on c.policy_id = p.policy_id
)

select * from final
