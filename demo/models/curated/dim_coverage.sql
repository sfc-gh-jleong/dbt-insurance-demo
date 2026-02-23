with coverages as (
    select * from {{ ref('ref_policy_coverages') }}
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['coverage_id']) }} as coverage_key,
        coverage_id,
        coverage_type,
        coverage_description
    from coverages
    group by coverage_id, coverage_type, coverage_description
)

select * from final
