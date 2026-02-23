with agencies as (
    select * from {{ ref('ref_agencies') }}
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['agency_id']) }} as agency_key,
        agency_id,
        agency_name,
        agency_code,
        agency_type,
        full_address,
        city,
        state_code,
        zip_code,
        phone_number,
        email,
        license_number,
        license_expiry_date,
        license_status,
        commission_rate,
        status,
        is_active,
        created_date,
        updated_date
    from agencies
)

select * from final
