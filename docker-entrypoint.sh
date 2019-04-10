#!/bin/sh
set -e

# rm -rf /etc/ssh/ssh_host_* && dpkg-reconfigure openssh-server

service ssh start

exec "$@"