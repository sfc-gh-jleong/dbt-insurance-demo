{#
    SCD Type 2 Macro - Reusable dimensional logic with effective/expiration date management
    
    This macro implements SCD Type 2 logic that:
    1. Tracks historical changes to dimension records
    2. Collapses multiple unchanged records into a single record with appropriate effective/expiration dates
    3. Manages record expiration when new records arrive
    4. Is reusable across different dimensional data sets
    
    Parameters:
        source_model: The source model/CTE name containing the new records
        unique_key: The business key column(s) that identify a dimension record
        tracked_columns: List of columns to track for changes (changes trigger new version)
        effective_date_col: Column containing the effective date of the record
        additional_columns: List of additional columns to include (not tracked for changes)
        
    Usage Example:
        {{ scd_type2(
            source_model='stg_customers',
            unique_key='customer_id',
            tracked_columns=['first_name', 'last_name', 'address', 'credit_score'],
            effective_date_col='updated_date',
            additional_columns=['created_date']
        ) }}
#}

{% macro scd_type2(source_model, unique_key, tracked_columns, effective_date_col, additional_columns=[]) %}

with source_data as (
    select * from {{ ref(source_model) }}
),

existing_data as (
    {% if is_incremental() %}
    select * from {{ this }}
    {% else %}
    select * from source_data where 1=0
    {% endif %}
),

change_hash as (
    select
        {{ unique_key }},
        {{ effective_date_col }} as effective_date,
        {% for col in tracked_columns %}
        {{ col }},
        {% endfor %}
        {% for col in additional_columns %}
        {{ col }},
        {% endfor %}
        {{ dbt_utils.generate_surrogate_key(tracked_columns) }} as row_hash
    from source_data
),

ranked_source as (
    select
        *,
        lag(row_hash) over (partition by {{ unique_key }} order by effective_date) as prev_hash,
        lead(effective_date) over (partition by {{ unique_key }} order by effective_date) as next_effective_date
    from change_hash
),

detect_changes as (
    select
        *,
        case
            when prev_hash is null then true
            when row_hash != prev_hash then true
            else false
        end as is_change
    from ranked_source
),

filtered_changes as (
    select
        {{ unique_key }},
        effective_date,
        {% for col in tracked_columns %}
        {{ col }},
        {% endfor %}
        {% for col in additional_columns %}
        {{ col }},
        {% endfor %}
        row_hash
    from detect_changes
    where is_change = true
),

with_expiration as (
    select
        {{ dbt_utils.generate_surrogate_key([unique_key, 'effective_date']) }} as surrogate_key,
        {{ unique_key }},
        {% for col in tracked_columns %}
        {{ col }},
        {% endfor %}
        {% for col in additional_columns %}
        {{ col }},
        {% endfor %}
        effective_date,
        coalesce(
            dateadd(day, -1, lead(effective_date) over (partition by {{ unique_key }} order by effective_date)),
            '9999-12-31'::date
        ) as expiration_date,
        case
            when lead(effective_date) over (partition by {{ unique_key }} order by effective_date) is null then true
            else false
        end as is_current,
        row_hash
    from filtered_changes
)

select * from with_expiration

{% endmacro %}
