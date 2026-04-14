{{ config(materialized='view') }}

with source as (
    select * from {{ source('raw', 'pos_cash_balance') }}
),
staged as (
    select
        cast(SK_ID_PREV as INT64) as previous_application_id,
        cast(SK_ID_CURR as INT64) as current_application_id,
        cast(MONTHS_BALANCE as INT64) as months_balance,
        cast(CNT_INSTALMENT as FLOAT64) as installment_term_count,
        cast(CNT_INSTALMENT_FUTURE as FLOAT64) as installments_remaining,
        NAME_CONTRACT_STATUS as contract_status,
        cast(SK_DPD as INT64) as days_past_due,
        cast(SK_DPD_DEF as INT64) as days_past_due_with_tolerance
    from source
)
select * from staged
