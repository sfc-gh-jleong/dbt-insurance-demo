with agents as (
    select * from {{ ref('stg_agents') }}
),

agencies as (
    select * from {{ ref('ref_agencies') }}
),

enriched as (
    select
        a.agent_id,
        a.agency_id,
        ag.agency_name,
        a.first_name,
        a.last_name,
        a.first_name || ' ' || a.last_name as full_name,
        a.email,
        a.phone_number,
        a.license_number,
        a.license_state,
        a.license_expiry_date,
        case
            when a.license_expiry_date < current_date() then 'Expired'
            when a.license_expiry_date < dateadd(day, 30, current_date()) then 'Expiring Soon'
            else 'Valid'
        end as license_status,
        a.hire_date,
        a.termination_date,
        datediff(day, a.hire_date, coalesce(a.termination_date, current_date())) as tenure_days,
        case
            when a.termination_date is not null then 'Terminated'
            else a.status
        end as employment_status,
        case when a.status = 'Active' and a.termination_date is null then true else false end as is_active,
        a.created_date,
        a.updated_date,
        a.load_timestamp
    from agents a
    left join agencies ag on a.agency_id = ag.agency_id
)

select * from enriched
