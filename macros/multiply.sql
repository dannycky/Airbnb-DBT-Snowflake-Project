{% macro multiply(x, y, precision=2) %}
  round({{ x }} * {{ y }}, {{ precision }})
{% endmacro %}