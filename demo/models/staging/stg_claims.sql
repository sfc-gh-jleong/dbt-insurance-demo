with source as (
    select * from {{ source('raw', 'raw_claims') }}
),

renamed as (
    select
        claim_id,
        claim_number,
        policy_id,
        customer_id,
        claim_date,
        incident_date,
        incident_description,
        incident_location,
        claim_type,
        claim_amount,
        approved_amount,
        paid_amount,
        claim_status,
        adjuster_id,
        adjuster_notes,
        settlement_date,
        denial_reason,
        created_date,
        updated_date,
        load_timestamp
    from source
)

select * from renamed
