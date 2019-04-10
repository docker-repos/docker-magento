#!/bin/sh
set -e

service apache2 start
service ssh start

exec "$@"