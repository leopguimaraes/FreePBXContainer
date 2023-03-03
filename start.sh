#!/bin/bash
#Script que vislumbra a instalação do freepbx onde precisa ter os serviços asterisk e mysqld ativos
#para proceder com a instalação.
#Responsável: Leonardo Guimaraes
#Email: leonardo.guimaraes@serpro.gov.br
# SERVICO FEDERAL DE PROCESSAMENTO DE DADOS - SERPRO
# Março de 2023
set -ex

#Subindo asterisk
echo "Subindo o serviço asterisk"
#/usr/sbin/asterisk -g -f -U asterisk > /dev/null
service asterisk start
sleep 5
echo "Asterisk inicializado"

#Permitindo que o serviço mysqld seja ativo
MARIADB_MYSQL_SOCKET_DIRECTORY='/var/run/mysqld'
mkdir -p $MARIADB_MYSQL_SOCKET_DIRECTORY && \
    chown root:mysql $MARIADB_MYSQL_SOCKET_DIRECTORY && \
    chmod 774 $MARIADB_MYSQL_SOCKET_DIRECTORY

echo "Iniciando serviço Mysql"
/usr/bin/mysqld_safe &
sleep 5
echo "Mysql inicializado"

#Instalando o freepbx
echo "Iniciando a instalação do Freepbx"
/usr/src/freepbx/install -n
sleep 5
echo "FreePBX Instalado"

#Instalando os módulos do FreePBX
echo "Instalando módulos para o FreePBX"
fwconsole moduleadmin listonline
cat /usr/src/freepbx/modules.txt |xargs fwconsole moduleadmin downloadinstall

