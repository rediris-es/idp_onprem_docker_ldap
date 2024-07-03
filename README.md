Requisitos del sistema: 
    - Min 4 CPUs
    - 16 GB RAM

Directorios y ficheros del proyecto: 
    - config_files -> Ficheros de configuración de arranque. Tambien se encuentran los directorios donde se almacenan las imagenes, los logos y el favicon de la interfaz del proveedor 
    - sp-remote-xml -> Directorio donde se pueden almacenar los diferentes metadatos en formato XML de los servicios a los que se quiera unir el IdP 
    - init-scrip.sh -> script de automatización de despliegue 
    - docker-compose.yaml -> configuración de los contenedores a desplegar
    

PASOS PARA DESPLEGAR EL PROVEEDOR DE IDENtIDAD:

1- Descargar repositorio de github. existen varias opciones

    - git clone https://github.com/rediris-es/IdPnube_onprem_docker_ldap.git

    - Descargar el zip del proyecto

2- Rellenar los fichero config_files/config_back.env y config_files/config_front.env con los datos de configuración necesarios

3- Ejecutar el script init_script para el despliegue de la instancía de docker. se necesita pasar esos parametros para la posible generación de certificados de firma
    Se neceita pasar los siguientes parámetros: <nombre_corto_inst> <C> <ST> <L> <O> <OU> <CN> <email>
    Ejemplo: sh init_script.sh  'RedIRIS' 'ES' 'Madrid' 'Madrid' 'RedIRIS' 'Middleware' 'rediris.idpnube.rediris.es' 'admin@rediris.es'

4- Configurar apache/nginx para que redireccione a los contenedores de docker. Se muestran ejemplos en la documentación.

Ejemplos de configuración para nginx y apache. Los proxysPass son los correctos. El resto de la configuración a modificar según se necesite

Configuración apache

```plain
<VirtualHost *:443>
    ServerName 
    CustomLog /log/apache/access.log combined
    ErrorLog /log/apache/error.log

    SSLEngine               on
    SSLCertificateFile      
    SSLCertificateKeyFile   
    SSLProtocol             all -SSLv2 -SSLv3
    SSLCipherSuite          ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-AES128-SHA256:ECDHE-RSA-AES128-SHA256:ECDHE-ECDSA-AES128-SHA:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA:ECDHE-ECDSA-AES256-SHA384:ECDHE-ECDSA-AES256-SHA:ECDHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA256:DHE-RSA-AES128-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES256-SHA:ECDHE-ECDSA-DES-CBC3-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES128-GCM-SHA256:AES256-GCM-SHA384:AES128-SHA256:AES256-SHA256:AES128-SHA:AES256-SHA:DES-CBC3-SHA:!DSS
    SSLHonorCipherOrder     on
    SSLProxyEngine on

    ProxyPreserveHost On

    ProxyPass / http://127.0.01:8052/
    ProxyPassReverse / http://127.0.0.1:8052/

</VirtualHost>
```


Configuración nginx: 

```plain

client_max_body_size 0;
server {
  listen 80;
  server_name nombreDelServicio;
  return 301 https://$host$request_uri;
}

server {
  listen 443 ssl;
  server_name nombreDelServicio;

  ssl_certificate /ruta/al/certificado;
  ssl_certificate_key /ruta/a/la/clavePrivafa;
  ssl_trusted_certificate /ruta/al/certificado/de/la/CA;
  access_log            /ruta/access/logs;
  error_log             /ruta/error/logs;

location / {

      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
      proxy_set_header Host $http_host;
      proxy_set_header X-NginX-Proxy true;

      proxy_redirect off;
      proxy_pass http://127.0.0.1:8052;

 }

}

```
