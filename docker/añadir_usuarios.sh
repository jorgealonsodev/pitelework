#!/bin/bash

echo '*** Introduzca nombre de usuario ***'

read user

echo '*** Introduzca la ruta donde quiere que se almacene el archivo de configuración del cliente ***'

read ruta

docker run -v ~/datos-vpn:/etc/openvpn --rm -it openvpn easyrsa build-client-full $user nopass

docker run -v ~/datos-vpn:/etc/openvpn --rm openvpn ovpn_getclient $user > $ruta/$user.ovpn
