with source as (
    select * from {{ source('raw', 'raw_agencies') }}
),

renamed as (
    select
        agency_id,
        agency_name,
        agency_code,
        agency_type,
        address_line1,
        address_line2,
        city,
        state_code,
        zip_code,
        phone_number,
        email,
        license_number,
        license_expiry_date,
        commission_rate,
        status,
        created_date,
        updated_date,
        load_timestamp
    from source
)

select * from renamed
