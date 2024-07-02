#!/bin/bash
# Verificar si se pasaron los parámetros necesarios

if [ "$#" -ne 8 ]; then
  echo "Uso: $0 <nombre_corto_inst> <C> <ST> <L> <O> <OU> <CN> <email>"
  echo "Ejemplo: sh init_script.sh  'RedIRIS' 'ES' 'Madrid' 'Madrid' 'RedIRIS' 'Middleware' 'rediris.idpnube.rediris.es' 'admin@rediris.es'"
  exit 1
fi

# Asignar parámetros a variables
SHORT_INST=$1
C=$2
ST=$3
L=$4
O=$5
OU=$6
CN=$7
EMAIL=$8

# Ruta del directorio de certificados
CERT_DIR="./config_files/simpleSAMLphp/certificados_firma" 
CRT_FILE="${CERT_DIR}/${SHORT_INST}.crt"
PEM_FILE="${CERT_DIR}/${SHORT_INST}.pem"

echo "Proceso de generación de certificados de firma para el IdP en proceso..."

# Comprobar si el directorio existe
if [ ! -d "$CERT_DIR" ]; then
  echo "El directorio $CERT_DIR no existe. Creándolo para poder almacenar los certificados de firma."
  mkdir -p "$CERT_DIR"
  echo "Directorio creado exitosamente."
  echo "Generando certificados de firma..."
  # Comando OpenSSL para generar los certificados de forma no interactiva
  openssl req -newkey rsa:3072 -new -x509 -days 3652 -nodes -out ./config_files/simpleSAMLphp/certificados_firma/${SHORT_INST}.crt -keyout ./config_files/simpleSAMLphp/certificados_firma/${SHORT_INST}.pem -subj "/C=${C}/ST=${ST}/L=${L}/O=${O}/OU=${OU}/CN=${CN}/emailAddress=${EMAIL}"
else
  if [ -f "$CRT_FILE" ]; then
    expiry_date=$(openssl x509 -enddate -noout -in "$CRT_FILE" | cut -d= -f2)
    echo "El certificado $CRT_FILE expira el $expiry_date."
    echo "Recuerda que la actualización de los certificados de firma implica una renovación de los metadatos y una propagacion de los mismos a todo slos servicios que lo esten usando."
    read -p "¿Desea renovar los certificados? (sí/no): " RENEW_CERT
    if [[ "$RENEW_CERT" != "si" && "$RENEW_CERT" != "s" ]]; then
      echo "No se renovarán los certificados. Saliendo..."
    else
      echo "Generando certificados de firma..."
      openssl req -newkey rsa:3072 -new -x509 -days 3652 -nodes -out ./config_files/simpleSAMLphp/certificados_firma/${SHORT_INST}.crt -keyout ./config_files/simpleSAMLphp/certificados_firma/${SHORT_INST}.pem -subj "/C=${C}/ST=${ST}/L=${L}/O=${O}/OU=${OU}/CN=${CN}/emailAddress=${EMAIL}"
    fi
  else
    echo "No se encontró un certificado existente en $CERT_DIR"
    echo "Generando certificados de firma..."
    openssl req -newkey rsa:3072 -new -x509 -days 3652 -nodes -out ./config_files/simpleSAMLphp/certificados_firma/${SHORT_INST}.crt -keyout ./config_files/simpleSAMLphp/certificados_firma/${SHORT_INST}.pem -subj "/C=${C}/ST=${ST}/L=${L}/O=${O}/OU=${OU}/CN=${CN}/emailAddress=${EMAIL}"
  fi
fi


echo "Asignando permisos a los certificados generados..."

chmod 644 ./config_files/simpleSAMLphp/certificados_firma/${SHORT_INST}.crt
chmod 644 ./config_files/simpleSAMLphp/certificados_firma/${SHORT_INST}.pem

# Verificar si el comando se ejecutó correctamente
if [ $? -eq 0 ]; then
  echo "Certificados existentes:"
  echo "- Archivo CRT: ${SHORT_INST}.crt"
  echo "- Archivo PEM: ${SHORT_INST}.pem"
else
  echo "Error al generar los certificados."
  exit 1
fi

echo "Deplegando proveedor de identidad ..."

# Comprobar si docker-compose está corriendo
if docker compose ps | grep 'Up'; then
  echo "docker-compose ya está corriendo. Reiniciando..."
  docker compose down
  docker compose up -d
else
  echo "docker-compose no está corriendo. Iniciando..."
  docker compose up -d
fi
