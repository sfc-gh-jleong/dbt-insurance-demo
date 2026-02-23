{{
    config(
        materialized='incremental',
        unique_key='surrogate_key',
        on_schema_change='sync_all_columns'
    )
}}

{#
    Example SCD Type 2 Dimension using the reusable scd_type2 macro
    
    This model demonstrates Kent's requirement:
    - Process source records with effective dates
    - Automatically expire old records when new versions arrive
    - Collapse multiple unchanged records into single records with appropriate effective/expiration dates
    
    The macro is reusable across different dimensional datasets - just change:
    - source_model: The staging/refined model to source from
    - unique_key: The business key
    - tracked_columns: Columns that trigger new versions when changed
    - effective_date_col: The date column representing when changes occurred
    - additional_columns: Extra columns to include (not tracked for changes)
#}

{{ scd_type2(
    source_model='stg_customers',
    unique_key='customer_id',
    tracked_columns=[
        'first_name',
        'last_name',
        'email',
        'phone_number',
        'address_line1',
        'address_line2',
        'city',
        'state_code',
        'zip_code',
        'customer_type',
        'credit_score',
        'risk_category',
        'status'
    ],
    effective_date_col='updated_date',
    additional_columns=['created_date', 'date_of_birth', 'ssn_last_four']
) }}
