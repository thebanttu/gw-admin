kannel:
  data:
    user: kannel
    group: kannel
    logdir: /var/log/kannel
    piddir: /var/run/kannel
    gwname: centric
    lbhost: lb.centric-prs.net
    gwdir: /opt/gw/kannel
    gwspool: /var/spool/kannel
    al2_pkgs:
      - nmap-ncat
      - libxml2-devel
      - mariadb-devel
      - pcre-devel
      - wget
      - gettext-devel
    pkgs:
      - build-essential
      - netcat-openbsd
      - libxml2-dev
      - libmariadb-dev-compat
      - libmariadbd-dev
      - libpcre3-dev
      - wget
      - gettext
      - m4
      - libtool
    gw_svn_url: https://svn.kannel.org/gateway/trunk
    bison_src_url: https://ftp.gnu.org/gnu/bison/bison-2.7.tar.gz
    mysql:
      username: grandadmin
      password: )TGCJ93DhFSVb,-0eB-M72!Xc$M89f
      host: 127.0.0.1
      db: gw
