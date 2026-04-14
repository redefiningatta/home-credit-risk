{{ config(materialized='view') }}

with source as (
    select * from {{ source('raw', 'credit_card_balance') }}
),
staged as (
    select
        cast(SK_ID_PREV as INT64) as previous_application_id,
        cast(SK_ID_CURR as INT64) as current_application_id,
        cast(MONTHS_BALANCE as INT64) as months_balance,
        cast(AMT_BALANCE as FLOAT64) as current_balance,
        cast(AMT_CREDIT_LIMIT_ACTUAL as FLOAT64) as active_credit_limit,
        NAME_CONTRACT_STATUS as contract_status
    from source
)
select * from staged
