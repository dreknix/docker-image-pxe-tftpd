# syntax=docker/dockerfile:1

# Get Alpine tag from: https://hub.docker.com/_/alpine
FROM alpine:3.17.1 AS builder

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

COPY scripts/embedded.ipxe .

RUN make bin-x86_64-pcbios/ipxe.pxe EMBED=embedded.ipxe
RUN make bin-x86_64-efi/ipxe.efi    EMBED=embedded.ipxe


# Get Alpine tag from: https://hub.docker.com/_/alpine
FROM alpine:3.17.1

# install tftp
RUN apk add --no-cache tftp-hpa

COPY --from=builder /build/ipxe/src/bin-x86_64-pcbios/ipxe.pxe /ipxe-base/
COPY --from=builder /build/ipxe/src/bin-x86_64-efi/ipxe.efi    /ipxe-base/

COPY scripts/entrypoint.sh      /

EXPOSE 69/udp

VOLUME /ipxe

ENTRYPOINT [ "sh", "-c", "/entrypoint.sh" ]
