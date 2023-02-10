#!/bin/sh

if [ ! -d "${ROOT_DIR}/" ]
then
  echo "root dir '${ROOT_DIR}/' is not existing"
  exit 1
fi

cp -u /ipxe.efi "${ROOT_DIR}/"
cp -u /ipxe.pxe "${ROOT_DIR}/"

busybox syslogd -n -O /dev/stdout &

if [ "${DEBUG}" = "true" ]
then
  VERBOSE_FLAGS="-vvv"
else
  VERBOSE_FLAGS="-v"
fi

/usr/sbin/in.tftpd \
  --foreground  \
  --address "${LISTEN_ADDR}:${PORT}" \
  --secure \
  --user ftp \
  --blocksize "${BLOCK_SIZE}" \
  "${VERBOSE_FLAGS}" \
  "${ROOT_DIR}"
