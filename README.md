1- Descargar repositorio de github. existen varias opciones

    - git clone https://github.com/rediris-es/IdPnube_onprem_docker_ldap.git

    - Descargar el zip del proyecto

2- Rellenar los fichero config_files/config_back.env y config_files/config_front.env con los datos de configuración necesarios

3- Ejecutar el script init_script para el despliegue de la instancía de docker. se necesita pasar esos parametros para la posible generación de certificados de firma
    Se neceita pasar los siguientes parámetros: <nombre_corto_inst> <C> <ST> <L> <O> <OU> <CN> <email>
    Ejemplo: sh init_script.sh  'RedIRIS' 'ES' 'Madrid' 'Madrid' 'RedIRIS' 'Middleware' 'rediris.idpnube.rediris.es' 'admin@rediris.es'

4- Configurar apache/nginx para que redireccione a los contenedores de docker. Se muestran ejemplos en la documentación.

```plain
dasdsad
```


```plain
fsdfdsf
```

