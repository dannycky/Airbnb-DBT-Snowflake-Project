{{ config(materialized= 'incremental', unique_key = 'BOOKING_ID') }}
SELECT
    BOOKING_ID,
    LISTING_ID,
    BOOKING_DATE,
    {{ multiply('NIGHTS_BOOKED', 'BOOKING_AMOUNT', 2) }} + CLEANING_FEE + SERVICE_FEE AS TOTAL_BOOKING_AMOUNT,
    BOOKING_STATUS,
    CREATED_AT,
FROM {{ ref('bronze_bookings') }}

