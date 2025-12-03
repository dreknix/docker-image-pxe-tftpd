# syntax=docker/dockerfile:1

# Get Alpine tag from: https://hub.docker.com/_/alpine
FROM alpine:3.23.0 AS builder

ARG HTTP_PORT=8069

# check: https://pkgs.alpinelinux.org/packages?branch=v3.17
RUN apk add --no-cache \
            make=4.3-r1 \
            gcc=12.2.1_git20220924-r4 \
            musl-dev=1.2.3-r5 \
            xz-dev=5.2.9-r0 \
            perl=5.36.0-r2 \
            patch=2.7.6-r9 \
            git=2.38.5-r0

WORKDIR /build/

RUN git clone https://github.com/ipxe/ipxe.git

WORKDIR /build/ipxe/

ADD https://github.com/ipxe/ipxe/pull/612.patch 612.patch

RUN patch -p 1 < 612.patch

WORKDIR /build/ipxe/src/

RUN sed -i '/DOWNLOAD_PROTO_HTTPS/s/#undef/#define/'     config/general.h; \
    sed -i '/PING_CMD/s/\/\/#define/#define/'            config/general.h; \
    sed -i '/CONSOLE_CMD/s/\/\/#define/#define/'         config/general.h; \
    sed -i '/CONSOLE_FRAMEBUFFER/s/\/\/#define/#define/' config/console.h; \
    sed -i '/KEYBOARD_MAP/s/us/de/'                      config/console.h

COPY embedded.ipxe .

RUN \
    sed -i "s/HTTP_PORT/${HTTP_PORT}/g" embedded.ipxe;    \
    make bin-x86_64-pcbios/ipxe.pxe EMBED=embedded.ipxe;  \
    make bin-x86_64-efi/ipxe.efi    EMBED=embedded.ipxe

# Get Alpine tag from: https://hub.docker.com/_/alpine
FROM alpine:3.23.0

ARG ROOT_DIR=/tftpboot
ARG LISTEN_ADDR
ARG PORT=69
ARG DEBUG
ARG BLOCK_SIZE=1468

LABEL org.opencontainers.image.authors='dreknix <dreknix@proton.me>' \
      org.opencontainers.image.base.name='alpine:3.71.1' \
      org.opencontainers.image.licenses='MIT' \
      org.opencontainers.image.source='https://github.com/dreknix/docker-image-pxe-tftpd.git' \
      org.opencontainers.image.title='Docker image for TFTP server in PXE' \
      org.opencontainers.image.url='https://github.com/dreknix/docker-image-pxe-tftpd'

# check: https://pkgs.alpinelinux.org/packages?branch=v3.17
RUN apk add --no-cache \
            tftp-hpa=5.2-r5

WORKDIR /

COPY --from=builder /build/ipxe/src/bin-x86_64-pcbios/ipxe.pxe /
COPY --from=builder /build/ipxe/src/bin-x86_64-efi/ipxe.efi    /

COPY entrypoint.sh /

EXPOSE ${PORT}/udp

VOLUME ${ROOT_DIR}

ENV ROOT_DIR=${ROOT_DIR}
ENV LISTEN_ADDR=${LISTEN_ADDR}
ENV PORT=${PORT}
ENV DEBUG=${DEBUG}
ENV BLOCK_SIZE=${BLOCK_SIZE}

ENTRYPOINT [ "sh", "-c", "/entrypoint.sh" ]
