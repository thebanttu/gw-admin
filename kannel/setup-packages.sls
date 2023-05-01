{%- set pkgs = salt['pillar.get']('kannel:data:al2_pkgs') -%}

Development Tools:
  pkg.group_installed

gw.packages:
  pkg.installed:
    - pkgs: {{ pkgs }}


