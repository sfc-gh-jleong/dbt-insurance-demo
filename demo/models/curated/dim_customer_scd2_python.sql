{#
    Example: Using Python UDF for SCD Processing
    
    This model demonstrates how to use the Python UDF approach for more complex
    SCD logic. The Python function can be customized for specific business rules.
    
    Workflow:
    1. First run the macro to create the UDF: {{ create_scd_python_udf() }}
    2. Then this model uses the UDF to process records
    
    Benefits of Python approach:
    - Complex business logic is easier to express
    - Can use Python libraries (pandas, numpy)
    - Custom collapse/merge logic per dimension
    - Easier unit testing of the Python function
#}

{{
    config(
        materialized='table',
        pre_hook="{{ create_scd_python_udf() }}"
    )
}}

with source_records as (
    select
        customer_id as business_key,
        first_name,
        last_name,
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
        date_of_birth,
        ssn_last_four,
        created_date,
        updated_date as effective_date
    from {{ ref('stg_customers') }}
),

aggregated as (
    select
        array_agg(
            object_construct(
                'business_key', business_key,
                'first_name', first_name,
                'last_name', last_name,
                'email', email,
                'phone_number', phone_number,
                'address_line1', address_line1,
                'address_line2', address_line2,
                'city', city,
                'state_code', state_code,
                'zip_code', zip_code,
                'customer_type', customer_type,
                'credit_score', credit_score,
                'risk_category', risk_category,
                'status', status,
                'date_of_birth', date_of_birth,
                'ssn_last_four', ssn_last_four,
                'created_date', created_date,
                'effective_date', to_varchar(effective_date, 'YYYY-MM-DD')
            )
        ) within group (order by business_key, effective_date) as records
    from source_records
),

processed as (
    select
        value:business_key::number as customer_id,
        value:first_name::varchar as first_name,
        value:last_name::varchar as last_name,
        value:email::varchar as email,
        value:phone_number::varchar as phone_number,
        value:address_line1::varchar as address_line1,
        value:address_line2::varchar as address_line2,
        value:city::varchar as city,
        value:state_code::varchar as state_code,
        value:zip_code::varchar as zip_code,
        value:customer_type::varchar as customer_type,
        value:credit_score::number as credit_score,
        value:risk_category::varchar as risk_category,
        value:status::varchar as status,
        value:date_of_birth::date as date_of_birth,
        value:ssn_last_four::varchar as ssn_last_four,
        value:created_date::timestamp as created_date,
        value:effective_date::date as effective_date,
        value:expiration_date::date as expiration_date,
        value:is_current::boolean as is_current
    from aggregated,
    lateral flatten(input => {{ target.database }}.{{ target.schema }}.process_scd_records(records))
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['customer_id', 'effective_date']) }} as surrogate_key,
        *
    from processed
)

select * from final
