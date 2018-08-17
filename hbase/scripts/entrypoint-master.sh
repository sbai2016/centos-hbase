#!/bin/bash

/usr/sbin/sshd

SLEEP_WAIT=30
echo "ATTENTE ${SLEEP_WAIT} secondes pour l'arrivée de HADOOP"
sleep $SLEEP_WAIT

source .bashrc
bash -c "/opt/hbase/bin/hbase-daemon.sh --config /opt/hbase/conf start master"
bash -c "/opt/hbase/bin/hbase-daemon.sh --config /opt/hbase/conf start regionserver"

echo "ATTENTE ${SLEEP_WAIT} secondes pour de demarrage d'hbase"
sleep $SLEEP_WAIT

bash -c "hbase shell ./hbase-create-tables.script"

tail -f /dev/null
