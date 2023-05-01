{%- set bison_url = salt['pillar.get']('kannel:data:bison_src_url') -%}

bison_download:
  archive.extracted:
    - name: /tmp/
    - source: {{ bison_url }}
    - skip_verify: True
    - archive_format: tar

bison_edit_lib_fseterr:
  file.replace:
    - name: /tmp/bison-2.7/lib/fseterr.c
    - pattern: _IO_ftrylockfile
    - repl: _IO_EOF_SEEN
    - backup: False

bison_configure:
  cmd.run:
    - name: sh ./configure
    - cwd: /tmp/bison-2.7

bison_compile:
  cmd.run:
    - name: make
    - cwd: /tmp/bison-2.7
#    - onchanges:
#      - cmd: bison_configure

bison_install:
  cmd.run:
    - name: make install
    - cwd: /tmp/bison-2.7
#    - onchanges:
#      - cmd: bison_compile

bison_link:
  file.copy:
    - name: /usr/local/bin/bison
    - source: /tmp/bison-2.7/src/bison
    - force: True
#    - onchanges:
#      - cmd: bison_install
