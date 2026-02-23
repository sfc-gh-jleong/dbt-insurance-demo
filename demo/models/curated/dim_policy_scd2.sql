{{
    config(
        materialized='incremental',
        unique_key='surrogate_key',
        on_schema_change='sync_all_columns'
    )
}}

{#
    Example SCD Type 2 Policy Dimension using the reusable scd_type2 macro
    
    Demonstrates reusability - same macro, different dimension dataset
#}

{{ scd_type2(
    source_model='stg_policies',
    unique_key='policy_id',
    tracked_columns=[
        'policy_number',
        'customer_id',
        'agent_id',
        'agency_id',
        'policy_type',
        'product_code',
        'premium_amount',
        'coverage_amount',
        'deductible_amount',
        'payment_frequency',
        'payment_method',
        'underwriting_status',
        'policy_status',
        'cancellation_date',
        'cancellation_reason',
        'renewal_count'
    ],
    effective_date_col='updated_date',
    additional_columns=['created_date', 'effective_date', 'expiration_date']
) }}
