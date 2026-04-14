{{ config(materialized='view') }}

with source as (
    select * from {{ source('raw', 'home_credit_columns_description') }}
),

staged as (
    select
        cast(int64_field_0 as INT64) as column_entry_id,
        string_field_1 as table_name,
        string_field_2 as column_name,
        string_field_3 as column_description,
        string_field_4 as special_notes
    from source
    -- Optional: Filter out the header row if it was ingested as data
    where string_field_1 != 'Table' 
)

select * from staged