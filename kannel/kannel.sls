{%- set user = salt['pillar.get']('kannel:data:user') -%}
{%- set group = salt['pillar.get']('kannel:data:group') -%}
{%- set logdir = salt['pillar.get']('kannel:data:logdir') ~ "/" ~ salt['pillar.get']('kannel:data:gwname') -%}
{%- set piddir = salt['pillar.get']('kannel:data:piddir') -%}
{%- set gwdir = salt['pillar.get']('kannel:data:gwdir') -%}
{%- set gwspool = salt['pillar.get']('kannel:data:gwspool') -%}
{%- set gw_svn_url = salt['pillar.get']('kannel:data:gw_svn_url') -%}
{%- set gw_tmp = "/tmp/gateway" -%}
{%- set sqlbox_tmp = gw_tmp ~ "/addons/sqlbox" -%}
{%- set smppbox_tmp = gw_tmp ~ "/addons/opensmppbox" -%}
{%- set log_sub_dirs = [ 'access', 'sqlbox', 'smppbox', 'smscs' ] -%}

{{ user }}:
  user.present:
    - shell: /bin/nologin

{{ logdir }}:
  file.directory:
    - user: {{ user }}
    - group: {{ group }}
    - mode: 755
    - makedirs: True

{%- for dir in log_sub_dirs %}
Create log sub directory {{ logdir }}/{{ dir }}:
  file.directory:
    - name: {{ logdir }}/{{ dir }}
    - user: {{ user }}
    - group: {{ group }}
    - mode: 755
    - makedirs: True
{%- endfor %}
  
{{ piddir }}:
  file.directory:
    - user: {{ user }}
    - group: {{ group }}
    - mode: 755
    - makedirs: True
  
{{ gwdir }}:
  file.directory:
    - user: {{ user }}
    - group: {{ group }}
    - mode: 755
    - makedirs: True
  
{{ gwspool }}:
  file.directory:
    - user: {{ user }}
    - group: {{ group }}
    - mode: 755
    - makedirs: True

subversion:
  pkg.installed

fetch_gw_src_from_svn:
  svn.latest:
    - name: {{ gw_svn_url }}
    - target: {{ gw_tmp }}
    - trust: True
    - creates:
      - {{ gw_tmp }}

run_bootstrap:
  cmd.run:
    - name: sh ./bootstrap.sh
    - cwd: {{ gw_tmp }}
    - onchanges:
      - svn: fetch_gw_src_from_svn

gw_configure:
  cmd.run:
    - name: |-
        sh ./configure \
          --prefix={{ gwdir }} \
          --enable-pcre \
          --enable-start-stop-daemon \
          --with-mysql
    - cwd: {{ gw_tmp }}
    - onchanges:
      - cmd: run_bootstrap

gw_sort_out_depend:
  cmd.run:
    - name: "[ -f .depend ] || touch .depend"
    - cwd: {{ gw_tmp }}
    - onchanges:
      - cmd: gw_configure

# This was important when I was using the non-svn version of the gateway.
# make_depend:
#   cmd.run:
#     - name: make depend
#     - cwd: {{ gw_tmp }}
#     - onchanges:
#       - cmd: gw_sort_out_depend

make_gateway:
  cmd.run:
    - name: "make && make install"
    - cwd: {{ gw_tmp }}
    - onchanges:
      - cmd: gw_sort_out_depend

sqlbox_configure:
  cmd.run:
    - name: |-
        sh ./configure \
          --prefix={{ gwdir }} \
          --with-kannel-dir={{ gwdir }}
    - cwd: {{ sqlbox_tmp }}

make_sqlbox:
  cmd.run:
    - name: "make && make install"
    - cwd: {{ sqlbox_tmp }}
    - onchanges:
      - cmd: sqlbox_configure

smppbox_configure:
  cmd.run:
    - name: |-
        sh ./configure \
          --prefix={{ gwdir }} \
          --with-kannel-dir={{ gwdir }}
    - cwd: {{ smppbox_tmp }}

make_smppbox:
  cmd.run:
    - name: "make && make install"
    - cwd: {{ smppbox_tmp }}
    - onchanges:
      - cmd: smppbox_configure

