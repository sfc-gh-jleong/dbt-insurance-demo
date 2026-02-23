with source as (
    select * from {{ source('raw', 'raw_agents') }}
),

renamed as (
    select
        agent_id,
        agency_id,
        first_name,
        last_name,
        email,
        phone_number,
        license_number,
        license_state,
        license_expiry_date,
        hire_date,
        termination_date,
        status,
        created_date,
        updated_date,
        load_timestamp
    from source
)

select * from renamed
