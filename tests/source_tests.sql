{{config( severity = "warn", tags = ["source_test"] )}}
SELECT
    1
FROM
    {{source("staging", "bookings")}}
WHERE
    BOOKING_AMOUNT < 0