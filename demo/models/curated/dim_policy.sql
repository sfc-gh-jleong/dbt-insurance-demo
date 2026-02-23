with policies as (
    select * from {{ ref('ref_policies') }}
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['policy_id']) }} as policy_key,
        policy_id,
        policy_number,
        policy_type,
        product_code,
        payment_frequency,
        payment_method,
        underwriting_status,
        policy_status,
        is_renewal
    from policies
)

select * from final
