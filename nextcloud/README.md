##Corrección errores

**Fix error 413**

Crear archivo /conf.d/unrestricted_size.conf en local y añadir la siguiente linea:

```
$ sudo nano /mnt/conf.d/unrestricted_size.conf

client_max_body_size 0;

```


