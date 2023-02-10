# Docker image for TFTP server in PXE

This Docker image provides a TFTP server with iPXE as network bootstrap program
(NBP). It is part of the Docker compose
[PXE service](https://github.com/dreknix/docker-compose-pxe)

## Testing

```console
$ sudo netstat -tulpn | grep tftp
```

```console
$ curl tftp://localhost/ipxe.efi
```

## License

[MIT](https://github.com/dreknix/docker-image-pxe-tftpd/blob/main/LICENSE)
