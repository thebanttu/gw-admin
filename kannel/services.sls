{%- set boxes = ['bearerbox','smsbox','sqlbox','smppbox'] -%}
{%- set gw_modified = "/root/gw_admin/.modified" -%}

# Start gateway services
{%- for box in boxes %}
Start systemd service for {{ box }}:
  service.running:
    - name: {{ box }}
    - watch:
      - file: {{ gw_modified }}
{%- endfor %}

