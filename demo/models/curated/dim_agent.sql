with agents as (
    select * from {{ ref('ref_agents') }}
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['agent_id']) }} as agent_key,
        agent_id,
        agency_id,
        agency_name,
        full_name,
        first_name,
        last_name,
        email,
        phone_number,
        license_number,
        license_state,
        license_expiry_date,
        license_status,
        hire_date,
        termination_date,
        tenure_days,
        employment_status,
        is_active,
        created_date,
        updated_date
    from agents
)

select * from final
