#!/bin/bash

# Define variables
DOMAIN="midominio.com"
ZONE_FILE="/etc/named/zones/db.$DOMAIN"
REV_ZONE_FILE="/etc/named/zones/db.$(echo $DOMAIN | awk -F. '{print $3"."$2"."$1}').rev"
NS_IP="192.168.1.10"  # Cambia esto por la dirección IP del servidor DNS primario
HOST_IP="192.168.1.20"  # Cambia esto por la dirección IP del host que deseas asignar al dominio

# Verificar si los archivos de zona existen, si no, crearlos
if [ ! -f $ZONE_FILE ]; then
    touch $ZONE_FILE
fi

if [ ! -f $REV_ZONE_FILE ]; then
    touch $REV_ZONE_FILE
fi

# Crear zona directa si el archivo está vacío
if [ ! -s $ZONE_FILE ]; then
    echo "\$TTL 86400" > $ZONE_FILE
    echo "@   IN  SOA     ns.$DOMAIN. root.$DOMAIN. (" >> $ZONE_FILE
    echo "        2017010101  ; Serial" >> $ZONE_FILE
    echo "        3600        ; Refresh" >> $ZONE_FILE
    echo "        1800        ; Retry" >> $ZONE_FILE
    echo "        604800      ; Expire" >> $ZONE_FILE
    echo "        86400 )     ; Minimum TTL" >> $ZONE_FILE
    echo "" >> $ZONE_FILE
    echo "@               IN  NS          ns.$DOMAIN." >> $ZONE_FILE
    echo "ns              IN  A           $NS_IP" >> $ZONE_FILE
    echo "www             IN  A           $HOST_IP" >> $ZONE_FILE
fi

# Crear zona inversa si el archivo está vacío
if [ ! -s $REV_ZONE_FILE ]; then
    echo "\$TTL 86400" > $REV_ZONE_FILE
    echo "@   IN  SOA     ns.$DOMAIN. root.$DOMAIN. (" >> $REV_ZONE_FILE
    echo "        2017010101  ; Serial" >> $REV_ZONE_FILE
    echo "        3600        ; Refresh" >> $REV_ZONE_FILE
    echo "        1800        ; Retry" >> $REV_ZONE_FILE
    echo "        604800      ; Expire" >> $REV_ZONE_FILE
    echo "        86400 )     ; Minimum TTL" >> $REV_ZONE_FILE
    echo "" >> $REV_ZONE_FILE
    echo "@               IN  NS          ns.$DOMAIN." >> $REV_ZONE_FILE
    echo "$HOST_IP     IN  PTR         www.$DOMAIN." >> $REV_ZONE_FILE
fi

# Reiniciar Bind
systemctl restart named

echo "Dominio $DOMAIN configurado correctamente."
