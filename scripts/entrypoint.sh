#!/bin/sh

busybox syslogd -n -O /dev/stdout &

cp /ipxe-base/ipxe.efi           /ipxe/
cp /ipxe-base/ipxe.pxe           /ipxe/

if [ ! -d /ipxe/boot ]
then
  mkdir /ipxe/boot
fi

cp /ipxe-base/boot.ipxe         /ipxe/boot/
cp /ipxe-base/boot.ipxe.cfg.j2  /ipxe/boot/

/usr/sbin/in.tftpd \
  --foreground  \
  --address :6969 \
  --secure \
  --user ftp \
  --blocksize 1468 \
  -vvv \
  /ipxe
