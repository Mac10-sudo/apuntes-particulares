#!/bin/bash

# select username, account_status from dba_users where lock_date is not null | para saber si un usuario esta bloqueado
# ALTER USER account ACCOUNT UNLOCK; | para desbloquear la cuenta

# Script para crear nuevos usuarios de oracle

# Variables de entorno
# Variables de entorno
export ORACLE_SID=zilae
export ORACLE_HOME=/opt/oracle-install
export PATH=$ORACLE_HOME/bin:$PATH


nombre_usuario=$1
contrasena_usuario=$2
pdb="pdzilae"

# comprobar si mete mas parametros de los que deberia
parametos_introducidos=$#

if [ "$parametos_introducidos" -ne 2 ]; then
    echo "Crea un usuario nuevo de oracle, con permisos connect y resource."
    echo "Si el usuario ya existe, lo desbloquea y le cambia la contraseña."
    echo ""
    echo "Uso: nuevo-usuario-oracle.sh <usuario> <contraseña>"
    sleep 10
    exit
fi


comprobar_si_existe_usuario_oracle (){
    local nombre_usuario="$1"
    
    resultado_query=$(sqlplus -s / as sysdba<<EOF
SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF
SELECT COUNT(*) FROM dba_users WHERE USERNAME = UPPER('${nombre_usuario}');
EXIT;
EOF
		   )

    # recortar espacios en blanco
    echo "$resultado_query" | xargs
}

comprobar_si_usuario_bloqueado (){
    resultado_query_block=$(sqlplus -s / as sysdba<<EOF
SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF
SELECT COUNT(*) FROM dba_users WHERE lock_date IS NOT NULL AND USERNAME = UPPER('${nombre_usuario}')
EXIT;
EOF
			 )

    echo "$resultado_query_block" | xargs
}

verificar_pdb(){
    estado_pdb=$(sqlplus -s / as sysdba<<EOF
SET PAGESIZE 0 FEEDBACK OFF VERIFY OFF HEADING OFF ECHO OFF
SELECT OPEN_MODE FROM v\$pdbs WHERE NAME = UPPER('${pdb}');
EXIT;
EOF
	      )
    echo "$estado_pdb" | xargs
}

crear_usuario_dentro_de_oracle (){
    local estado_pdb=$(verificar_pdb)
    if [ "$estado_pdb" != "READ WRITE" ]; then
	sqlplus -s / as sysdba<<EOF
ALTER PLUGGABLE DATABASE ${pdb} OPEN;
EOF
    fi
    sqlplus -s / as sysdba<<EOF
ALTER SESSION SET CONTAINER=${pdb};
CREATE USER ${nombre_usuario} IDENTIFIED BY ${contrasena_usuario};
EXIT;
EOF
}

desbloquea_usu(){
sqlplus -s / as sysdba<<EOF
ALTER USER '${nombre_usuario}' ACCOUNT UNLOCK;
EXIT;
EOF
}

resultado_funcion_comprobar_usuario=$(comprobar_si_existe_usuario_oracle)


if [ "$resultado_funcion_comprobar_usuario" -gt 0 ]; then
    echo "El usuario $nombre_usuario ya existe"

    resultado_funcion_usuario_block=$(comprobar_si_usuario_bloqueado)
    if [ "$resultado_funcion_usuario_block" -eq 1 ]; then
	echo "El usuario $nombre_usuario esta bloqueado"
	echo "Desbloqueando......"
	desbloquea_usu
	echo "El usuario $nombre_usuario ha sido desbloqueado"
    fi
else
    echo "El usuario $nombre_usuario no existe"
    echo "Creando....."
    crear_usuario_dentro_de_oracle
    echo "El usuario $nombre_usuario ha sido creado"
fi
