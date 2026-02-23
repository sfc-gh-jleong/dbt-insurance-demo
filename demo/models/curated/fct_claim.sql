with claims as (
    select * from {{ ref('ref_claims') }}
),

customers as (
    select customer_id, customer_key from {{ ref('dim_customer') }}
),

policies as (
    select policy_id, policy_key from {{ ref('dim_policy') }}
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['cl.claim_id']) }} as claim_fact_key,
        cl.claim_id,
        cl.claim_number,
        p.policy_key,
        c.customer_key,
        cl.claim_date,
        cl.incident_date,
        cl.days_to_report,
        cl.incident_description,
        cl.incident_location,
        cl.claim_type,
        cl.claim_amount,
        cl.approved_amount,
        cl.paid_amount,
        cl.outstanding_amount,
        cl.approval_rate_pct,
        cl.payment_rate_pct,
        cl.claim_status,
        cl.claim_resolution_status,
        cl.adjuster_id,
        cl.settlement_date,
        cl.days_to_settle,
        cl.denial_reason,
        cl.created_date,
        cl.updated_date
    from claims cl
    left join customers c on cl.customer_id = c.customer_id
    left join policies p on cl.policy_id = p.policy_id
)

select * from final
