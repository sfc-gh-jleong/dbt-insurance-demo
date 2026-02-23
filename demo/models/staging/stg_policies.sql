with source as (
    select * from {{ source('raw', 'raw_policies') }}
),

renamed as (
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
        premium_amount,
        coverage_amount,
        deductible_amount,
        payment_frequency,
        payment_method,
        underwriting_status,
        policy_status,
        cancellation_date,
        cancellation_reason,
        renewal_count,
        created_date,
        updated_date,
        load_timestamp
    from source
)

select * from renamed
