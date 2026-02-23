{#
    Process SCD Type 2 Records - Python UDF Approach
    
    This macro demonstrates using a Python UDF to perform SCD Type 2 logic.
    It provides the same functionality as the SQL macro but uses Python for
    more complex transformations that may be easier to express in Python.
    
    This approach is useful when:
    - You need complex business logic that's cleaner in Python
    - You want to reuse existing Python libraries
    - You have custom collapse/merge logic requirements
    
    The Python code can be customized per dataset while the UDF wrapper remains consistent.
#}

{% macro create_scd_python_udf() %}

create or replace function {{ target.database }}.{{ target.schema }}.process_scd_records(
    records array
)
returns array
language python
runtime_version = '3.11'
packages = ('pandas')
handler = 'process_scd'
as
$$
import pandas as pd
from datetime import datetime, timedelta

def process_scd(records: list) -> list:
    """
    Process SCD Type 2 records with change detection and date collapsing.
    
    This function:
    1. Detects actual changes in tracked columns
    2. Collapses unchanged consecutive records
    3. Sets appropriate effective and expiration dates
    
    Args:
        records: List of dictionaries containing dimension records
                 Each record must have 'business_key', 'effective_date', and tracked columns
    
    Returns:
        List of processed SCD Type 2 records with effective/expiration dates
    """
    if not records:
        return []
    
    df = pd.DataFrame(records)
    
    if df.empty:
        return []
    
    df['effective_date'] = pd.to_datetime(df['effective_date'])
    df = df.sort_values(['business_key', 'effective_date'])
    
    tracked_cols = [col for col in df.columns if col not in ['business_key', 'effective_date', 'expiration_date', 'is_current']]
    df['row_hash'] = df[tracked_cols].astype(str).agg('|'.join, axis=1)
    
    df['prev_hash'] = df.groupby('business_key')['row_hash'].shift(1)
    df['is_change'] = (df['row_hash'] != df['prev_hash']) | (df['prev_hash'].isna())
    
    result_df = df[df['is_change']].copy()
    
    result_df['next_effective'] = result_df.groupby('business_key')['effective_date'].shift(-1)
    result_df['expiration_date'] = result_df['next_effective'].apply(
        lambda x: (x - timedelta(days=1)) if pd.notna(x) else datetime(9999, 12, 31)
    )
    result_df['is_current'] = result_df['next_effective'].isna()
    
    output_cols = ['business_key'] + tracked_cols + ['effective_date', 'expiration_date', 'is_current']
    result_df = result_df[[col for col in output_cols if col in result_df.columns]]
    
    result_df['effective_date'] = result_df['effective_date'].dt.strftime('%Y-%m-%d')
    result_df['expiration_date'] = result_df['expiration_date'].dt.strftime('%Y-%m-%d')
    
    return result_df.to_dict('records')
$$;

{% endmacro %}
