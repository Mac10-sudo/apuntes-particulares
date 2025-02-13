#!/bin/bash
# Envía un correo periódicamente
# Enviar a alvaro@alvarogonzalez.no-ip.biz

# Variables de entorno
export ORACLE_SID=zilae
export ORACLE_HOME=/opt/oracle-install
export PATH=$ORACLE_HOME/bin:$PATH

sacar_informacion(){
    info=$(sqlplus -s / as sysdba<<EOF
set colsep ,        -- Separate columns with a comma
set pagesize 0      -- No headers, continuous output
set trimspool on    -- Remove trailing blanks
set headsep off     -- Ensure no additional header separation
set linesize 1000   -- Adjust as needed for long lines
set numwidth 15     -- Ensure numbers don’t use scientific notation

spool myfile.csv    

SELECT
	sistema, avg(tamano), avg(usado), montado
FROM
	DF
GROUP BY
      sistema, montado;

EOF
    )

# echo "$info" | xargs | sed 's/\s+,/,/' myfile.csv 
}

sacar_informacion

comprobacion_postfix(){
    comando=$(rpm -qa | grep postfix | wc -l)

    if [ "$comando" -ge 1 ]; then
	echo "POSTFIX esta instalado"
    else
	echo "POSTFIX NO esta instalado"
	echo "Instalando....."
	dnf install -y postfix mailx
	echo "Se ha instalado POSTFIX"
    fi
}

comprobacion_postfix

programar_tarea(){
    cron_schedule="* * * * * /home/oracle/Documents/practica-scripts/enviar-correo.sh"

    echo "$cron_schedule" >> /etc/crontab
}

programar_tarea

enviar_correo(){
fichero_csv="/home/oracle/Documents/practica-scripts/myfile.csv"
echo "Informe de la tabla DF" | mail -s "Ismael Macareno Chouikh" -a "$fichero_csv" alvaro@alvarogonzalez.no-ip.biz
}

enviar_correo

