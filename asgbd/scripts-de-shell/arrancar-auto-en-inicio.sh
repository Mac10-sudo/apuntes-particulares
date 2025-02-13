#!/bin/bash

# por si acaso, deshabilitamos SELinux para que no moleste
# modificar /etc/selinux/config para hacerlo permanente
setenforce 0

# ORACLE_HOME del sistema
valor_oracle_home=$(env | grep ORACLE_HOME | cut -d "=" -f 2)

# miro en oratab
valor_oracle_home_en_oratab=$(cat /etc/oratab | grep $valor_oracle_home | cut -d ":" -f 3)


# Habra que crear el fichero de logs si no existe
directorio_de_logs="/home/alumno/logs"
fichero_de_logs="/home/alumno/logs/oracle.log"
mkdir -p "$directorio_de_logs"


# tenia la fecha formateada con el echo normal, pero me apetece meter funciones
#    date "+%Y-%m-%d-%H:%M:%S" formato de fecha para "$fichero_de_logs"
fechaformateada (){
    date "+%Y-%m-%d-%H:%M:%S"
}


if [ -n "$valor_oracle_home_en_oratab" ] && [ $valor_oracle_home_en_oratab = "Y" ]; then
    echo "$(fechaformteada) Solicitud de arrancar Oracle" | tee -a "$fichero_de_logs"
    echo "$(fechaformteada) Oracle arrancado porque /etc/oratab indica Y" | tee -a "$fichero_de_logs"
    sqlplus / as sysdba <<EOF
startup;
EOF
    echo "$(fechaformteada) Oracle arrancado" | tee -a "$fichero_de_logs"
else
    echo "$(fechaformteada) Solicitud de arrancar Oracle" | tee -a "$fichero_de_logs"
    echo "$(fechaformteada) Oracle arrancado porque /etc/oratab indica N" | tee -a "$fichero_de_logs"
    echo "$(fechaformteada) Solicitud de parar Oracle" | tee -a "$fichero_de_logs"
    sqlplus / as sysdba <<EOF
shutdown inmediate;
EOF
    echo "$(fechaformteada) Oracle parado" | tee -a "$fichero_de_logs"    
fi
