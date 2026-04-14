{{ config(materialized='view') }}

with source as (
    select * from {{ source('raw', 'bureau_balance') }}
),
staged as (
    select
        cast(SK_ID_BUREAU as INT64) as bureau_id,
        cast(MONTHS_BALANCE as INT64) as months_balance,
        STATUS as credit_status
    from source
)
select * from staged
