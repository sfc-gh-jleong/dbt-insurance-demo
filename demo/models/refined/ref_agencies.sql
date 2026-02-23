with agencies as (
    select * from {{ ref('stg_agencies') }}
),

enriched as (
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
        city || ', ' || state_code || ' ' || zip_code as full_address,
        phone_number,
        email,
        license_number,
        license_expiry_date,
        case
            when license_expiry_date < current_date() then 'Expired'
            when license_expiry_date < dateadd(day, 30, current_date()) then 'Expiring Soon'
            else 'Valid'
        end as license_status,
        commission_rate,
        status,
        case when status = 'Active' then true else false end as is_active,
        created_date,
        updated_date,
        load_timestamp
    from agencies
)

select * from enriched
