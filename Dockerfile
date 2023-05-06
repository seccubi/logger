FROM debian:bullseye-slim as builder

RUN apt-get update && apt-get install -y curl unzip procps

RUN mkdir /root/lib
RUN find -name libcurl.so.4 -exec cp {} /root/lib/ \;
RUN find -name libbz2.so.1.0 -exec cp {} /root/lib/ \;
RUN find -name libnghttp2.so.14 -exec cp {} /root/lib/ \;
RUN find -name librtmp.so.1 -exec cp {} /root/lib/ \;
RUN find -name libssh2.so.1 -exec cp {} /root/lib/ \;
RUN find -name libpsl.so.5 -exec cp {} /root/lib/ \;
RUN find -name libbrotlidec.so.1 -exec cp {} /root/lib/ \;
RUN find -name libbrotlicommon.so.1 -exec cp {} /root/lib/ \;
RUN find -name libhogweed.so.4 -exec cp {} /root/lib/ \;
RUN find -name libnettle.so.6 -exec cp {} /root/lib/ \;
RUN find -name libnghttp2.so* -exec cp {} /root/lib/ \;
RUN find -name librtmp.so.1 -exec cp {} /root/lib/ \;
RUN find -name libprocps.so.8 -exec cp {} /root/lib/ \;
RUN find -name libpcre.so.3 -exec cp {} /root/lib/ \;

FROM fluent/fluent-bit:2.1.2 as client

COPY --from=builder /usr/bin/curl /usr/bin/curl
COPY --from=builder /usr/bin/unzip /usr/bin/unzip
COPY --from=builder /bin/sh /bin/sh
COPY --from=builder /bin/bash /bin/bash
COPY --from=builder /bin/chmod /bin/chmod
COPY --from=builder /bin/rm /bin/rm
COPY --from=builder /bin/sleep /bin/sleep
COPY --from=builder /usr/bin/awk /usr/bin/awk
COPY --from=builder /bin/ps /bin/ps
COPY --from=builder /bin/grep /bin/grep
COPY --from=builder /usr/bin/killall /usr/bin/killall

COPY --from=builder /root/lib/* /usr/lib/x86_64-linux-gnu/
COPY --from=builder /root/lib/* /usr/lib/aarch64-linux-gnu/
COPY --from=builder /root/lib/* /usr/lib/arm-linux-gnueabihf/

COPY src/entrypoint.sh /fluent-bit/bin/entrypoint.sh
COPY src/version.info /fluent-bit/bin/version.info

RUN /bin/chmod +x /fluent-bit/bin/entrypoint.sh

ARG REACT_APP_API_ENTRYPOINT=https://api.seccubi.com
ENV REACT_APP_API_ENTRYPOINT=$REACT_APP_API_ENTRYPOINT

ARG FLAGS=""
ENV FLAGS=$FLAGS

HEALTHCHECK --interval=60s --timeout=5s --start-period=120s \
   CMD curl -s http://127.0.0.1:2020/api/v1/health | grep "ok" || exit 1

ENTRYPOINT ["/bin/sh", "/fluent-bit/bin/entrypoint.sh"]


