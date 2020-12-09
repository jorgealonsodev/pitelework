#!/bin/bash

echo '*** Introduzca nombre de usuario ***'

read usuario

docker run -v ~/datos-vpn:/etc/openvpn --rm -it darathor/openvpn easyrsa build-client-full $usuario nopass

docker run -v ~/datos-vpn:/etc/openvpn --rm darathor/openvpn ovpn_getclient $usuario > ~/$usuario.ovpn

echo '*** El archivo de configuración se encuentra en /home/'$USER'/'$usuario'.ovpn ***'
