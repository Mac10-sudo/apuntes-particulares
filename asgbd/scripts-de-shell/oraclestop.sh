#!/bin/bash
# variables de entorno
export ORACLE_SID=asir
export ORACLE_HOME=/opt/oracle-install
export PATH=$ORACLE_HOME/bin:$PATH

# Parar oracle
sqlplus / as sysdba <<EOF
shutdown inmediante;
exit;
EOF

# Parar el listener
lsnrctl stop
