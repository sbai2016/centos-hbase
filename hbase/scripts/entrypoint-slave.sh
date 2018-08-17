#!/bin/bash

/usr/sbin/sshd

su - hbase
bash -c "/opt/hbase/bin/hbase-daemon.sh --config /opt/hbase/conf start regionserver"

hbase shell hbase-create-tables.script


tail -f /dev/null