#!/bin/sh
set -e
webdis_config="/etc/webdis.json"

write_config() {
  ACL_DISABLED=${ACL_DISABLED:-\"DEBUG\", \"FLUSHDB\", \"FLUSHALL\"}
  ACL_HTTP_BASIC_AUTH_ENABLED=${ACL_HTTP_BASIC_AUTH_ENABLED:-\"DEBUG\"}
  [ -n "$REDIS_PORT" ] && REDIS_PORT=${REDIS_PORT##*:}
  cat - <<EOF
{
  "redis_host": "${REDIS_HOST:-redis}",
  "redis_port": ${REDIS_PORT:-6379},
  "redis_auth": ${REDIS_AUTH:-null},
  "http_host": "${HTTP_HOST:-0.0.0.0}",
  "http_port": ${HTTP_PORT:-6380},
  "threads": ${THREADS:-4},
  "pool_size": ${POOL_SIZE:-16},
  "daemonize": false,
  "websockets": ${WEBSOCKETS:-false},
  "database": ${DATABASE:-0},
  "acl": [
    {
      "disabled": [${ACL_DISABLED}]
    },
    {
      "http_basic_auth": "${ACL_HTTP_BASIC_AUTH:-user:password}",
      "enabled":  [${ACL_HTTP_BASIC_AUTH_ENABLED}]
    }
  ],
  "verbosity": ${VERBOSITY:-99},
  "logfile": "${LOGFILE:-/dev/stdout}"
}
EOF
}

if [ $# -eq 0 ]; then
  echo "writing config.." >&2
  write_config >${webdis_config}

  echo "starting webdis.." >&2
  webdis ${webdis_config}
fi

exec "$@"
