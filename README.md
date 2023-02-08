# Docker container for TFTP and iPXE

```
docker build . -t ipxe
docker run --rm -d -p 69:6969/udp --network host --name ipxe-tftpd ipxe

docker exec -it ipxe-tftpd sh

docker logs -f ipxe-tftpd
```

```
sudo netstat -tulpn | grep tftp
```

```
tftp -4 localhost 69 -c get xxx
```
