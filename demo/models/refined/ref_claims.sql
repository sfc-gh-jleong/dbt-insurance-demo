with claims as (
    select * from {{ ref('stg_claims') }}
),

enriched as (
    select
        claim_id,
        claim_number,
        policy_id,
        customer_id,
        claim_date,
        incident_date,
        datediff(day, incident_date, claim_date) as days_to_report,
        incident_description,
        incident_location,
        claim_type,
        claim_amount,
        approved_amount,
        paid_amount,
        case
            when claim_amount > 0 then round(approved_amount / claim_amount * 100, 2)
            else 0
        end as approval_rate_pct,
        case
            when approved_amount > 0 then round(paid_amount / approved_amount * 100, 2)
            else 0
        end as payment_rate_pct,
        claim_amount - coalesce(paid_amount, 0) as outstanding_amount,
        claim_status,
        case claim_status
            when 'Closed' then 'Resolved'
            when 'Denied' then 'Resolved'
            when 'Paid' then 'Resolved'
            else 'Open'
        end as claim_resolution_status,
        adjuster_id,
        adjuster_notes,
        settlement_date,
        case
            when settlement_date is not null then datediff(day, claim_date, settlement_date)
            else null
        end as days_to_settle,
        denial_reason,
        created_date,
        updated_date,
        load_timestamp
    from claims
)

select * from enriched
