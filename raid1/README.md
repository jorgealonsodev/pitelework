# RAID1 en raspberry

Instalamos el controlador de raid por software

```
$ sudo apt-get install mdadm
```
Comprobamos cuales son los discos con los que vamos a hacer el RAID1

```
$ lsblk
```
![lsblk](https://imgur.com/ISbrmDO.png)

En este caso son sda1 y sdb2 . Y el comando para crear un solo disco de tipo RAID 0 es:

$ sudo mdadm --create --verbose /dev/md0 --level=mirror --raid-devices=2 /dev/sda1 /dev/sdd1

Esto significa:

sudo mdadm --create >> crear un disco RAID

/dev/md0 >> será el nombre del disco RAID

--level=mirror  >> esto indica que es un RAID de nivel 1

--raid-devices=2 >> esto indica que vamos a usar 2 discos

/dev/sdb /dev/sdc >> estos son los nombre de los discos a incluir en el RAID

Comprobamos que están correctamente montados

```
$ lsblk
```


Comprobamos que el raid esta activo

```
$ cat /proc/mdstat
```
![lsblk](https://imgur.com/QqnC8WL.png)


Creamos el sistema de ficheros para el disco RAID1 y lo montamos

```
$ sudo mkfs.ext4 -v -m .1 -b 4096 -E stride=32,stripe-width=64 /dev/md0
$ sudo mount /dev/md0 /mnt
```
Averiguamos su  UUID

```
$ sudo blkid
```


Modificamos el fstab para que se automonte al iniciar
```
$ sudo cp /etc/fstab /etc/fstab.bak (hacemos una backup)
$ sudo nano /etc/fstab
```
Y editamos el fstab con esta linea

```
UUID=ec1e6c6e-24bc-429a-8e5e-5e7494d9e1b6 /mnt ext4 defaults 0 0
```

## Comprobacion de correcto funcionamiento

Generar error en disco /dev/sdb 

#Comprobamos los discos que estan en RAID
```
$ cat /proc/mdstat
```
#Elegimos un disco y generamos un error
```
mdadm --manage /dev/md0 --fail /dev/sdb1
```
#Así será su estado después de marcar como fallido el RAID.

```
$cat /proc/mdstat 
Personalities : [raid1] 
md0 : active raid1 sda1[0] sdb1[1](F)
      19904512 blocks super 1.2 [2/1] [U_]


#Expulsamos el disco que esta en fail
mdadm --manage /dev/md0 --remove /dev/sdb1

#Comprobamos los discos que estan en RAID
$ cat /proc/mdstat 
Personalities : [raid1] 
md0 : active raid1 sda1[0]
      19904512 blocks super 1.2 [2/1] [U_]
# Apagar y meter disco nuevo
```

Añadir un nuevo disco al RAID

Comprobamos cual es el disco a añadir al RAID

```
$ lsblk 
NAME        MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda           8:0    1   29G  0 disk  
└─sda1        8:1    1   29G  0 part  
sdb           8:16   1 28.7G  0 disk  
└─sdb1        8:17   1 28.7G  0 part  
  └─md0       9:0    0 28.6G  0 raid1 /mnt/hd
mmcblk0     179:0    0 59.5G  0 disk  
├─mmcblk0p1 179:1    0  256M  0 part  /boot
└─mmcblk0p2 179:2    0 59.2G  0 part  /
```
Copiamos la tabla de particiones del disco en producción al nuevo disco.

```
$ sudo su
# sfdisk -d /dev/sdb | sfdisk --force /dev/sda
```
Añadimos el disco al RAID
```
# mdadm --manage /dev/md0 --add /dev/sdb1
```
Ya podemos comprobar como el disco esta siendo restaurado

```
$ cat /proc/mdstat
Personalities : [raid1] 
md0 : active raid1 sda1[3] sdb1[2]
      30013440 blocks super 1.2 [2/1] [_U]
      [=>...................]  recovery =  7.2% (2185792/30013440) finish=14.4min speed=32046K/sec
```

Instalación de MTA para enviar mails con errores del sistema y avisos.

Para eso instalamos un MTA(Mail Transfer Agent), en nuestro caso instalaremos mstmp

```
$ sudo apt install msmtp msmtp-mta
```
Y luego lo configuramos 


```
$ sudo nano /etc/msmtprc

# Valores por defecto                      
defaults
auth           on
tls            on
tls_starttls   on
tls_trust_file /etc/ssl/certs/ca-certificates.crt
logfile        /var/log/msmtp.log

# Configuración smtp          
account        gmail
auth           plain
host           smtp.gmail.com
port           587
from           jorgealonsodev@gmail.com
user           jorgealonsodev
password       (metemos nuestra contraseña de aplicación)

# Establecer la cuenta predeterminada
account default : gmail
```
Probamos si envía los emails correctamente con

```
echo "hello there username." | msmtp -a default tuemail@gmail.com
```
Ejemplo de mail de error que se envía al correo si falla uno de los discos RAID1

![Fail email](https://imgur.com/P8HiGw1.png)