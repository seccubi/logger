FROM fluent/fluent-bit:latest AS builder

FROM debian:latest AS logger

COPY --from=builder /usr/lib/x86_64-linux-gnu/*sasl* /usr/lib/x86_64-linux-gnu/
COPY --from=builder /usr/lib/x86_64-linux-gnu/libz* /usr/lib/x86_64-linux-gnu/
COPY --from=builder /lib/x86_64-linux-gnu/libz* /lib/x86_64-linux-gnu/
COPY --from=builder /usr/lib/x86_64-linux-gnu/libssl.so* /usr/lib/x86_64-linux-gnu/
COPY --from=builder /usr/lib/x86_64-linux-gnu/libcrypto.so* /usr/lib/x86_64-linux-gnu/

# These below are all needed for systemd
COPY --from=builder /lib/x86_64-linux-gnu/libsystemd* /lib/x86_64-linux-gnu/
COPY --from=builder /lib/x86_64-linux-gnu/libselinux.so* /lib/x86_64-linux-gnu/
COPY --from=builder /lib/x86_64-linux-gnu/liblzma.so* /lib/x86_64-linux-gnu/
COPY --from=builder /usr/lib/x86_64-linux-gnu/liblz4.so* /usr/lib/x86_64-linux-gnu/
COPY --from=builder /lib/x86_64-linux-gnu/libgcrypt.so* /lib/x86_64-linux-gnu/
COPY --from=builder /lib/x86_64-linux-gnu/libpcre.so* /lib/x86_64-linux-gnu/
COPY --from=builder /lib/x86_64-linux-gnu/libgpg-error.so* /lib/x86_64-linux-gnu/


# PostgreSQL output plugin
COPY --from=builder /usr/lib/x86_64-linux-gnu/libpq.so* /usr/lib/x86_64-linux-gnu/
COPY --from=builder /usr/lib/x86_64-linux-gnu/libgssapi* /usr/lib/x86_64-linux-gnu/
COPY --from=builder /usr/lib/x86_64-linux-gnu/libldap* /usr/lib/x86_64-linux-gnu/
COPY --from=builder /usr/lib/x86_64-linux-gnu/libkrb* /usr/lib/x86_64-linux-gnu/
COPY --from=builder /usr/lib/x86_64-linux-gnu/libk5crypto* /usr/lib/x86_64-linux-gnu/
COPY --from=builder /usr/lib/x86_64-linux-gnu/liblber* /usr/lib/x86_64-linux-gnu/
COPY --from=builder /usr/lib/x86_64-linux-gnu/libgnutls* /usr/lib/x86_64-linux-gnu/
COPY --from=builder /usr/lib/x86_64-linux-gnu/libp11-kit* /usr/lib/x86_64-linux-gnu/
COPY --from=builder /usr/lib/x86_64-linux-gnu/libidn2* /usr/lib/x86_64-linux-gnu/
COPY --from=builder /usr/lib/x86_64-linux-gnu/libunistring* /usr/lib/x86_64-linux-gnu/
COPY --from=builder /usr/lib/x86_64-linux-gnu/libtasn1* /usr/lib/x86_64-linux-gnu/
COPY --from=builder /usr/lib/x86_64-linux-gnu/libnettle* /usr/lib/x86_64-linux-gnu/
COPY --from=builder /usr/lib/x86_64-linux-gnu/libhogweed* /usr/lib/x86_64-linux-gnu/
COPY --from=builder /usr/lib/x86_64-linux-gnu/libgmp* /usr/lib/x86_64-linux-gnu/
COPY --from=builder /usr/lib/x86_64-linux-gnu/libffi* /usr/lib/x86_64-linux-gnu/
COPY --from=builder /lib/x86_64-linux-gnu/libcom_err* /lib/x86_64-linux-gnu/
COPY --from=builder /lib/x86_64-linux-gnu/libkeyutils* /lib/x86_64-linux-gnu/

#COPY resources/cert.pem /fluent-bit/etc/cert.pem
#COPY resources/key.pem /fluent-bit/etc/key.pem
#COPY resources/myCA.pem /fluent-bit/etc/myCA.pem

COPY src/entrypoint.sh /fluent-bit/bin/entrypoint.sh
COPY src/health.sh /fluent-bit/bin/health.sh
RUN chmod +x /fluent-bit/bin/entrypoint.sh
RUN chmod +x /fluent-bit/bin/health.sh

COPY --from=builder /fluent-bit /fluent-bit
#
EXPOSE 2020

RUN apt-get update && apt-get install -y curl unzip

ARG REACT_APP_API_ENTRYPOINT=api
ENV REACT_APP_API_ENTRYPOINT=$REACT_APP_API_ENTRYPOINT

HEALTHCHECK --interval=30s --timeout=5s --start-period=45s \
   CMD /fluent-bit/bin/health.sh


ENTRYPOINT ["/fluent-bit/bin/entrypoint.sh"]
