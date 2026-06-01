{{ config(materialized='incremental', unique_key='LISTING_ID') }}

SELECT
    LISTING_ID,
    HOST_ID,
    CAST(PROPERTY_TYPE AS STRING) AS PROPERTY_TYPE,
    ROOM_TYPE,
    CITY,
    COUNTRY,
    ACCOMMODATES,
    BATHROOMS,
    BEDROOMS,
    PRICE_PER_NIGHT,
    {{ tag('CAST(PRICE_PER_NIGHT AS INT)') }} AS PRICE_PER_NIGHT_TAG,
    CREATED_AT
FROM {{ ref('bronze_listings') }}