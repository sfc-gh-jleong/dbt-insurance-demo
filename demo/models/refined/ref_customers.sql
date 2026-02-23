with customers as (
    select * from {{ ref('stg_customers') }}
),

enriched as (
    select
        customer_id,
        first_name,
        last_name,
        first_name || ' ' || last_name as full_name,
        date_of_birth,
        datediff(year, date_of_birth, current_date()) as age,
        ssn_last_four,
        email,
        phone_number,
        address_line1,
        address_line2,
        city,
        state_code,
        zip_code,
        city || ', ' || state_code || ' ' || zip_code as full_address,
        customer_type,
        credit_score,
        case
            when credit_score >= 750 then 'Excellent'
            when credit_score >= 700 then 'Good'
            when credit_score >= 650 then 'Fair'
            when credit_score >= 600 then 'Poor'
            else 'Very Poor'
        end as credit_tier,
        risk_category,
        status,
        case when status = 'Active' then true else false end as is_active,
        created_date,
        updated_date,
        load_timestamp
    from customers
)

select * from enriched
