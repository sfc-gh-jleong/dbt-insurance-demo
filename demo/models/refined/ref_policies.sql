with policies as (
    select * from {{ ref('stg_policies') }}
),

enriched as (
    select
        policy_id,
        policy_number,
        customer_id,
        agent_id,
        agency_id,
        policy_type,
        product_code,
        effective_date,
        expiration_date,
        datediff(day, effective_date, expiration_date) as policy_term_days,
        case
            when expiration_date < current_date() then 'Expired'
            when effective_date > current_date() then 'Future'
            when expiration_date < dateadd(day, 30, current_date()) then 'Expiring Soon'
            else 'Active'
        end as policy_period_status,
        premium_amount,
        coverage_amount,
        deductible_amount,
        case
            when coverage_amount > 0 then round(premium_amount / coverage_amount * 100, 4)
            else 0
        end as premium_to_coverage_ratio,
        payment_frequency,
        case payment_frequency
            when 'Monthly' then premium_amount * 12
            when 'Quarterly' then premium_amount * 4
            when 'Semi-Annual' then premium_amount * 2
            when 'Annual' then premium_amount
            else premium_amount
        end as annualized_premium,
        payment_method,
        underwriting_status,
        policy_status,
        cancellation_date,
        cancellation_reason,
        renewal_count,
        case when renewal_count > 0 then true else false end as is_renewal,
        created_date,
        updated_date,
        load_timestamp
    from policies
)

select * from enriched
