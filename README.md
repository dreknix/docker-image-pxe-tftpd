# Docker container for TFTP and iPXE

## Testing

```console
$ sudo netstat -tulpn | grep tftp
```

```console
$ curl tftp://localhost/ipxe.efi
```
