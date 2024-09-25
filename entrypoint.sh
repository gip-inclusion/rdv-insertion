#!/bin/sh -l
set -ex

if [ -f /app/tmp/pids/server.pid ]; then
  rm /app/tmp/pids/server.pid
fi

bin/rails db:prepare

exec "$@"
