{%- set gw_user = salt['pillar.get']('kannel:data:mysql:username') -%}
{%- set gw_pass = salt['pillar.get']('kannel:data:mysql:password') -%}
{%- set gw_host = salt['pillar.get']('kannel:data:mysql:host') -%}
{%- set dir = "/etc/kannel/" ~ salt['pillar.get']('kannel:data:gwname') ~ '/connections' -%}
{%- set gw_db_configs = salt['file.find'](dir,maxdepth=1,mindepth=1,type='f') -%}

{%- for f in gw_db_configs %}
Change username for {{ f }}:
  file.replace:
    - name: {{ f }}
    - pattern: '^(username\s*=\s*).*'
    - repl: '\1{{ gw_user }}'
    - backup: False
{%- endfor %}

{%- for f in gw_db_configs %}
Change password for {{ f }}:
  file.replace:
    - name: {{ f }}
    - pattern: '^(password\s*=\s*).*'
    - repl: '\1{{ gw_pass }}'
    - backup: False
{%- endfor %}

{%- for f in gw_db_configs %}
Change host for {{ f }}:
  file.replace:
    - name: {{ f }}
    - pattern: '^(host\s*=\s*).*'
    - repl: '\1{{ gw_host }}'
    - backup: False
{%- endfor %}

restart sqlbox after editting credentials:
  service.running:
    - name: sqlbox
