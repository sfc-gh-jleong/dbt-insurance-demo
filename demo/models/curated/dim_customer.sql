with customers as (
    select * from {{ ref('ref_customers') }}
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['customer_id']) }} as customer_key,
        customer_id,
        full_name,
        first_name,
        last_name,
        date_of_birth,
        age,
        email,
        phone_number,
        full_address,
        city,
        state_code,
        zip_code,
        customer_type,
        credit_score,
        credit_tier,
        risk_category,
        status,
        is_active,
        created_date,
        updated_date
    from customers
)

select * from final
