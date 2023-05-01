{%- set gwname = salt['pillar.get']('kannel:data:gwname') -%}
{%- set gwcfg = "/etc/kannel/" ~ salt['pillar.get']('kannel:data:gwname') -%}
{%- set boxes = ['bearerbox','smsbox','sqlbox','smppbox'] -%}
{%- set target_configs = {
    'logrotate':{'target':'/etc/logrotate.d/kannel','source':'logrotate/kannel'},
    'dbconfig':{'target':'/usr/local/scripts/conf/mysql/site_db.cnf','source':'conf/mysql/site_db.cnf'},
    'admin_scripts':{'target':'/usr/local/scripts/gateway/admin','source':'admin'},
    'gw_services':{'target':'/lib/systemd/system','source':'systemd/services'}
  } -%}
{%- set gw_modified = "/root/gw_admin/.modified" -%}

# extract gateway cfg tarball:
#   archive.extracted:
#     - name: {{ gwcfg }}
#     - source: salt://kannel/files/gw_config.tar.gz
#     - skip_verify: True
#     - archive_format: tar
#     - options: "--strip-components=1"
#     - enforce_toplevel: False

Copy gw configs to config dir:
  file.recurse:
    - name: {{ gwcfg }}
    - source: "salt://kannel/files/gw_config"
    - makedirs: True
    - exclude_pat:
        - '*.sw?'
    - template: jinja

Copy gw scripts and files to gw_admin:
  file.recurse:
    - name: "/root/gw_admin"
    - source: "salt://kannel/files/gw_admin"
    - makedirs: True
    - exclude_pat:
        - '*.sw?'
        - 'box_admin'
    - template: jinja

/root/gw_admin/box_admin:
  file.managed:
    - source: salt://kannel/files/gw_admin/box_admin

{%- for key in ['admin_scripts', 'gw_services'] %}
Copy {{ target_configs[key].source }} to {{ target_configs[key].target }}:
  file.recurse:
    - name: {{ target_configs[key].target }}
    - source: salt://kannel/files/gw_admin/{{ target_configs[key].source }}
    {% if key == "admin_scripts" %}
    - file_mode: 755
    {% endif %}
    - replace: True
    - makedirs: True
{%- endfor %}

# Enable gateway services
{%- for box in boxes %}
Enable systemd service for {{ box }}:
  service.enabled:
    - name: {{ box }}
{%- endfor %}


# Setup logrotate
Copy the logrotate config to system dir:
  file.managed:
    - name: {{ target_configs['logrotate']['target'] }}
    - source: salt://kannel/files/gw_admin/{{ target_configs['logrotate']['source'] }}
    - makedirs: True

# Setup db config
Copy the db config to system dir:
  file.managed:
    - name: {{ target_configs['dbconfig']['target'] }}
    - source: salt://kannel/files/gw_admin/{{ target_configs['dbconfig']['source'] }}
    - makedirs: True

Infect bashrc with the gateway goodies:
  cmd.script:
    - name: salt://kannel/files/gw_admin/scripts/infect_bashrc.sh
    - source: salt://kannel/files/gw_admin/scripts/infect_bashrc.sh
    - cwd: /root/gw_admin

Touch gw_modified when the configs are changed:
  file.touch:
    - name: {{ gw_modified }}
    - watch:
      - file: "Copy gw configs to config dir"
