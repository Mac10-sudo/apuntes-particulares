#!/bin/bash

# Variables de entorno
export ORACLE_SID=asir
export ORACLE_HOME=/opt/oracle-install
export PATH=$ORACLE_HOME/bin:$PATH

# Iniciar el listener
lsnrctl start

# Arrancar oracle
sqlplus / as sysdba <<EOF
startup;
exit;
EOF
