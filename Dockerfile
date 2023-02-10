# syntax=docker/dockerfile:1

# Get Alpine tag from: https://hub.docker.com/_/alpine
FROM alpine:3.17.1 AS builder

ARG HTTP_PORT=8080

RUN apk add --no-cache make gcc musl-dev xz-dev perl patch git

WORKDIR /build/

RUN git clone https://github.com/ipxe/ipxe.git

WORKDIR /build/ipxe/

ADD https://github.com/ipxe/ipxe/pull/612.patch 612.patch

RUN patch -p 1 < 612.patch

WORKDIR /build/ipxe/src/

RUN sed -i '/DOWNLOAD_PROTO_HTTPS/s/#undef/#define/'     config/general.h
RUN sed -i '/PING_CMD/s/\/\/#define/#define/'            config/general.h
RUN sed -i '/CONSOLE_CMD/s/\/\/#define/#define/'         config/general.h

RUN sed -i '/CONSOLE_FRAMEBUFFER/s/\/\/#define/#define/' config/console.h
RUN sed -i '/KEYBOARD_MAP/s/us/de/'                      config/console.h

COPY embedded.ipxe .

RUN \
    sed -i "s/HTTP_PORT/${HTTP_PORT}/g" embedded.ipxe;    \
    make bin-x86_64-pcbios/ipxe.pxe EMBED=embedded.ipxe;  \
    make bin-x86_64-efi/ipxe.efi    EMBED=embedded.ipxe

# Get Alpine tag from: https://hub.docker.com/_/alpine
FROM alpine:3.17.1

ARG ROOT_DIR=/tftpboot
ARG LISTEN_ADDR
ARG PORT=69
ARG DEBUG
ARG BLOCK_SIZE=1468

# install tftp
RUN apk add --no-cache tftp-hpa

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
