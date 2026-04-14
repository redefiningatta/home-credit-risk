{{config(
    materialized='view',
    tags=['staging']
)}}

with source as (
    select *
    from {{ source('raw', 'application_train') }}
), 

staged as (
    select
        -- Renaming columns to follow a clear convention
        cast(SK_ID_CURR as INT64) as current_application_id,
        cast(TARGET as INT64) as target_default_status,
        NAME_CONTRACT_TYPE as contract_type,
        CODE_GENDER as gender,
        FLAG_OWN_CAR as owns_car,
        FLAG_OWN_REALTY as owns_realty,
        cast(CNT_CHILDREN as INT64) as children_count,
        cast(AMT_INCOME_TOTAL as FLOAT64) as total_income_amount,
        cast(AMT_CREDIT as FLOAT64) as credit_amount
    from source
)
select *
from staged