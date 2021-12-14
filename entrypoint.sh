#!/bin/bash

cat <<EOF>/tmp/dnscrypt-proxy.toml
listen_addresses = ['$LOCAL_IP:$LOCAL_PORT']
ipv4_servers = ${DNSCRYPT_IPV4:-true}
ipv6_servers = ${DNSCRYPT_IPV6:-false}
dnscrypt_servers = ${DNSCRYPT_DNSCRYPT:-true}
doh_servers = ${DNSCRYPT_DOH:-true}
#odoh_servers = ${DNSCRYPT_ODOH:-false}
require_dnssec = ${DNSCRYPT_DNSSEC:-false}
require_nolog = ${DNSCRYPT_NOLOG:-true}
require_nofilter = ${DNSCRYPT_NOFILTER:-true}
force_tcp = ${DNSCRYPT_FORCE_TCP:-false}
EOF

if [ -n "$SERVERS" ]; then
SERVER_LIST=$(echo $SERVERS | awk -F, '{for(i=1;i<=NF;i++){printf "'\''%s'\''", $i; if(i<NF) printf ", "}}')
cat <<EOF>>/tmp/dnscrypt-proxy.toml
server_names = [$SERVER_LIST]
EOF
fi

if [ -z "$SOURCES" ]; then
    SOURCES='https://download.dnscrypt.info/resolvers-list/v3/public-resolvers.md'
fi
SOURCE_LIST=$(echo $SOURCES | awk -F, '{for(i=1;i<=NF;i++){printf "'\''%s'\''", $i; if(i<NF) printf ", "}}')

cat <<EOF>>/tmp/dnscrypt-proxy.toml
[query_log]
  file = '/dev/null'

[nx_log]
  file = '/dev/null'

[sources]
  [sources.'public-resolvers']
    urls = [$SOURCE_LIST]
    cache_file = '/tmp/public-resolvers.md'
    minisign_key = 'RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3'
    refresh_delay = 72
    prefix = ''
EOF

exec $@
