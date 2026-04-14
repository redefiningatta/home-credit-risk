{{ config(materialized='view') }}

with source as (
    select * from {{ source('raw', 'installments_payments') }}
),
staged as (
    select
        cast(SK_ID_PREV as INT64) as previous_application_id,
        cast(SK_ID_CURR as INT64) as current_application_id,
        cast(NUM_INSTALMENT_VERSION as FLOAT64) as installment_version,
        cast(NUM_INSTALMENT_NUMBER as INT64) as installment_number,
        cast(DAYS_INSTALMENT as FLOAT64) as days_since_installment_due,
        cast(DAYS_ENTRY_PAYMENT as FLOAT64) as days_since_installment_paid,
        cast(AMT_INSTALMENT as FLOAT64) as scheduled_payment_amount,
        cast(AMT_PAYMENT as FLOAT64) as actual_payment_amount
    from source
)
select * from staged
