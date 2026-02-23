with source as (
    select * from {{ source('raw', 'raw_policy_coverages') }}
),

renamed as (
    select
        coverage_id,
        policy_id,
        coverage_type,
        coverage_description,
        coverage_limit,
        deductible,
        premium_portion,
        effective_date,
        end_date,
        status,
        created_date,
        updated_date,
        load_timestamp
    from source
)

select * from renamed
