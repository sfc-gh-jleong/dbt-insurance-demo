with source as (
    select * from {{ source('raw', 'raw_customers') }}
),

renamed as (
    select
        customer_id,
        first_name,
        last_name,
        date_of_birth,
        ssn_last_four,
        email,
        phone_number,
        address_line1,
        address_line2,
        city,
        state_code,
        zip_code,
        customer_type,
        credit_score,
        risk_category,
        status,
        created_date,
        updated_date,
        load_timestamp
    from source
)

select * from renamed
