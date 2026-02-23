with policies as (
    select * from {{ ref('ref_policies') }}
),

customers as (
    select customer_id, customer_key from {{ ref('dim_customer') }}
),

agents as (
    select agent_id, agent_key from {{ ref('dim_agent') }}
),

agencies as (
    select agency_id, agency_key from {{ ref('dim_agency') }}
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['p.policy_id', 'p.effective_date']) }} as policy_fact_key,
        p.policy_id,
        p.policy_number,
        c.customer_key,
        a.agent_key,
        ag.agency_key,
        p.effective_date,
        p.expiration_date,
        p.policy_term_days,
        p.policy_period_status,
        p.policy_type,
        p.product_code,
        p.premium_amount,
        p.annualized_premium,
        p.coverage_amount,
        p.deductible_amount,
        p.premium_to_coverage_ratio,
        p.payment_frequency,
        p.payment_method,
        p.underwriting_status,
        p.policy_status,
        p.cancellation_date,
        p.cancellation_reason,
        p.renewal_count,
        p.is_renewal,
        p.created_date,
        p.updated_date
    from policies p
    left join customers c on p.customer_id = c.customer_id
    left join agents a on p.agent_id = a.agent_id
    left join agencies ag on p.agency_id = ag.agency_id
)

select * from final
