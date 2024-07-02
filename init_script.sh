#!/bin/bash
# Verificar si se pasaron los parámetros necesarios

if [ "$#" -ne 8 ]; then
  echo "Uso: $0 <nombre_corto_inst> <C> <ST> <L> <O> <OU> <CN> <email>"
  echo "Ejemplo: sh init_script.sh  'RedIRIS' 'ES' 'Madrid' 'Madrid' 'RedIRIS' 'Middleware' 'rediris.idpnube.rediris.es' 'admin@rediris.es'"
  exit 1
fi

echo "Proceso de generación de certificados de firma para el IdP en proceso..."

# Asignar parámetros a variables
SHORT_INST=$1
C=$2
ST=$3
L=$4
O=$5
OU=$6
CN=$7
EMAIL=$8

# Comando OpenSSL para generar los certificados de forma no interactiva
openssl req -newkey rsa:3072 -new -x509 -days 3652 -nodes -out ./config_files/simpleSAMLphp/certificados_firma/${SHORT_INST}.crt -keyout ./config_files/simpleSAMLphp/certificados_firma/${SHORT_INST}.pem -subj "/C=${C}/ST=${ST}/L=${L}/O=${O}/OU=${OU}/CN=${CN}/emailAddress=${EMAIL}"

chmod 644 ./config_files/simpleSAMLphp/certificados_firma/${SHORT_INST}.crt
chmod 644 ./config_files/simpleSAMLphp/certificados_firma/${SHORT_INST}.pem

# Verificar si el comando se ejecutó correctamente
if [ $? -eq 0 ]; then
  echo "Certificados generados exitosamente:"
  echo "- Archivo CRT: ${SHORT_INST}.crt"
  echo "- Archivo PEM: ${SHORT_INST}.pem"
else
  echo "Error al generar los certificados."
  exit 1
fi

docker compose up -d
