{{ config(materialized='view') }}

with source as (
    select * from {{ source('raw', 'previous_application') }}
),

staged as (
    select
        cast(SK_ID_PREV as INT64) as previous_application_id,
        cast(SK_ID_CURR as INT64) as current_application_id,
        NAME_CONTRACT_TYPE as contract_type,
        cast(AMT_ANNUITY as FLOAT64) as annuity_amount,
        NAME_CONTRACT_STATUS as contract_status,
        CODE_REJECT_REASON as reject_reason
    from source
)

select * from staged
