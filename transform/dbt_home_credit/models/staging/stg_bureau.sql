{{ config(materialized='view') }}

with source as (
    select * from {{ source('raw', 'bureau') }}
),

staged as (
    select
        cast(SK_ID_CURR as INT64) as current_application_id,
        cast(SK_ID_BUREAU as INT64) as bureau_id,
        CREDIT_ACTIVE as credit_status,
        CREDIT_CURRENCY as credit_currency,
        cast(DAYS_CREDIT as INT64) as days_since_credit_applied,
        cast(AMT_CREDIT_SUM as FLOAT64) as total_credit_amount
    from source
)

select * from staged
