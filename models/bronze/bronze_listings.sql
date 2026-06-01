{{config(materialized= 'incremental')}}

SELECT * FROM {{source('staging', 'listings')}}

{% if is_incremental() %}
    WHERE CREATED_AT > (SELECT COALESCE(MAX(CREATED_AT), '1900-01-01') FROM {{ this }})
{% endif %}

