#!/bin/bash
# Almacena información periódicamente en la base de datos

# Variables de entorno para que chute sqlplus
export ORACLE_SID=zilae
export ORACLE_HOME=/opt/oracle-install
export PATH=$ORACLE_HOME/bin:$PATH

# Creacion de tablas
# Quiero comprobar si existe o no la tabla
crear_tablas(){
    # Si se quita el SET HEADING OFF da fallo diciendo que no existe la tabla DF
    tabla_existe=$(sqlplus -s / as sysdba<<EOF
SET HEADING OFF
SELECT COUNT(*) FROM all_tables WHERE table_name = 'DF';
EXIT;
EOF
		)
    if [ "$tabla_existe" -eq 0 ]; then
sqlplus -s / as sysdba<<EOF
create table DF(
hora varchar(40),
sistema varchar(40),
tamano varchar(40),
usado varchar(40),
montado varchar(40)
);
EXIT;
EOF

    else
	echo "Ya existe la tabla DF"
    fi
}

hora_actual=$(date '+%T')

crear_tablas

df -k | awk '{print $1, $2, $3, $6}' | tail -n +2 | while read -r sistema tamano usado montado; do
    insertar="INSERT INTO DF(hora, sistema, tamano, usado, montado) VALUES(
    '$hora_actual', '$sistema', '$tamano', '$usado', '$montado');"

    sqlplus -s / as sysdba<<EOF
$insertar
EOF
done

# df -k | awk '{print $1}' | tail -n +2
# df -k | awk '{print $2}' | tail -n +2
# df -k | awk '{print $3}' | tail -n +2
# df -k | awk '{print $6}' | tail -n +2

