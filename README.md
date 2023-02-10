# Docker image for TFTP server in PXE

This Docker image provides a
[TFTP server](https://linux.die.net/man/8/in.tftpd)
with
[iPXE](https://ipxe.org/)
as network bootstrap program
(NBP). It is part of the Docker compose
[PXE service](https://github.com/dreknix/docker-compose-pxe)

The image is also available from
[Docker Hub](https://hub.docker.com/r/dreknix/pxe-tftpd):

```console
$ docker pull dreknix/pxe-tftpd
```

## Configure iPXE

The iPXE software is configured as follows:

* enable `DOWNLOAD_PROTO_HTTPS`
* enable `PING_CMD`
* enable `CONSOLE_CMD`
* enable `CONSOLE_FRAMEBUFFER`
* change `KEYBOARD_MAP` to `de`

In order to boot from local disk in UEFI mode a
[patch](https://github.com/ipxe/ipxe/pull/612)
is used, which is currently not part of the main branch of iPXE.

In `ipxe.pxe` and `ipxe.efi` the script [embedded.ipxe](embedded.ipxe) is
embedded. The boot menu is loaded via:

```
chain http://${next-server}:8069/boot/boot.ipxe
```

The port can be configured by creating a `.env_local` file and build the image.

## Configure DHCP server

The DHCP server must be configured, so that the right file will be loaded via
TFTP. An example can be found in the
[iPXE documentation](https://ipxe.org/howto/dhcpd).

```
option architecture-type code 93 = unsigned integer 16;

subnet 192.168.1.0 netmask 255.255.255.0 {

  interface eth0;

  # speeding up DHCP with iPXE
  option ipxe.no-pxedhcp 1;

  class "pxeclients" {

    match if substring (option vendor-class-identifier, 0, 9) = "PXEClient";

    next-server 192.168.1.69;  # pxe.example.org

    if exists user-class and option user-class = "iPXE" {
      filename "http://pxe.example.org:8069/boot/boot.ipxe";
    } elsif option architecture-type = 00:00 {
      filename "ipxe.pxe";
    } else {
      filename "ipxe.efi";
    }

  }

    ...
}
```

In this example the network, interface, next-server and filename url must be
adjusted to the current network settings.

## Testing

Show which ports are used:

```console
$ sudo netstat -tulpn | grep tftp
```

Try to download a file:

```console
$ curl tftp://localhost/ipxe.efi
```

## License

[MIT](https://github.com/dreknix/docker-image-pxe-tftpd/blob/main/LICENSE)
