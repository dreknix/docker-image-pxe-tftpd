#!/bin/sh

cp -u /ipxe-base/ipxe.efi           /ipxe/
cp -u /ipxe-base/ipxe.pxe           /ipxe/

busybox syslogd -n -O /dev/stdout &

/usr/sbin/in.tftpd \
  --foreground  \
  --address :69 \
  --secure \
  --user ftp \
  --blocksize 1468 \
  -vvv \
  /ipxe
