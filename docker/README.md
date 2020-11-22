## OpenVPN con  docker


Descargamos el contenido del repositorio https://github.com/kylemanna/docker-openvpn.git

```
$ git clone https://github.com/kylemanna/docker-openvpn.git
```
Entramos en la carpeta descargada de github y creamos el contenedor

```
$ cd docker-openvpn
$ docker build -t mivpn .
```
Creamos el directorio donde guardaremos las llaves públicas, privadas y ficheros de configuración.

```
$ mkdir ~/datos-vpn
```
Generando el fichero de configuración de OpenVPN
Ahora generamos un contenedor efímero, cuya misión va ser la de generar el primer fichero de configuración que vamos a guardar en la carpeta datos-vpn. Añadimos la ip publica y el puerto por el que vamos a acceder al vpn.

```
$ docker run -v ~/datos-vpn:/etc/openvpn --rm mivpn ovpn_genconfig -u udp://dirección.ip.publica:3000
```
Generando el CA y el PKI
Tenemos que generar las llaves y el certificado de autenticación, para esto ejecutaremos otro contenedor efímero que generar, la llave privada, la llave pública y un certificado.

```
$ docker run -v ~/datos-vpn:/etc/openvpn --rm -it mivpn ovpn_initpki
```
Iniciamos el contenedor OpenVPN
Ahora vamos a poner en funcionamiento el contenedor que hará de servidor OpenVPN.

```
$ docker run --name mivpn -v ~/datos-vpn:/etc/openvpn -d --restart always -p 3000:1194/udp --cap-add=NET_ADMIN mivpn
```
Añadir usuarios
Ya podemos añadir los usuarios que se conectaran al VPN, y lo haremos mediante la creación de un archivo .ovpn  que contendrá la llave, el certificado y el usuario. Si el usuario está en posesión de este archivo podrá conectarse automáticamente sin contraseña.

Para crear el archivo .ovpn del usuario usaremos 2 contenedores efímeros, que se borran cuando terminen su cometido.

```
$ docker run -v ~/datos-vpn:/etc/openvpn --rm -it mivpn easyrsa build-client-full user1 nopass
$ docker run -v ~/datos-vpn:/etc/openvpn --rm mivpn ovpn_getclient USUARIO > ~/datos-vpn/user1.ovpn
```
Y con esto el servidor OpenVPN ya estaría funcionando, solo tenemos que entregarle el archivo .ovpn que le corresponde a cada usuario y este desde un cliente OpenVPN, importando el archivo, se conectaran de forma segura por VPN al servidor y a la red de la empresa.

No podemos olvidar que tenemos que abrir el router el puerto udp 3000 hacia el exterior e indicarle la ip interna donde se encuentra el  servidor con el puerto udp 3000.

![router port open](https://imgur.com/yzmlCh8.png)

*** Conexión desde un móvil Android con la aplicación OpenVPN, importando user1.ovpn

![<img src="openVPN" width="250"/>](https://imgur.com/MRNwEyb.png)

