#!/bin/bash

mkdir ~/datos-vpn

echo '*** Introduzca la Url (ejemplo.es) o Ip pública del servidor VPN ***'

read server_name

docker run -v ~/datos-vpn:/etc/openvpn --rm darathor/openvpn ovpn_genconfig -u udp://$server_name:3000

docker run -v ~/datos-vpn:/etc/openvpn --rm -it darathor/openvpn ovpn_initpki

echo '*** Introduzca nombre de usuario ***'

read user

echo '*** Introduzca la ruta donde quiere que se almacene el archivo de configuración del cliente ***'

read ruta

docker run -v ~/datos-vpn:/etc/openvpn --rm -it darathor/openvpn easyrsa build-client-full $user nopass

docker run -v ~/datos-vpn:/etc/openvpn --rm darathor/openvpn ovpn_getclient $user >$ruta/$user.ovpn
