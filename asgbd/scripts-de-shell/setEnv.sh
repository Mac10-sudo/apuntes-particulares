#!/bin/bash

# Script para establecer las variables de entorno necesarias
clear
export ORACLE_sid=asir
sqlplus / as sysdba <<EOF
startup;
exit;
EOF
