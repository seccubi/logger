FROM debian:latest AS builder

RUN apt-get update && apt-get install -y curl unzip procps

FROM fluent/fluent-bit:latest AS logger

#core
COPY --from=builder /bin/sleep /bin/sleep
COPY --from=builder /bin/cat /bin/cat
COPY --from=builder /bin/sh /bin/sh
COPY --from=builder /bin/rm /bin/rm
COPY --from=builder /bin/ps /bin/ps
COPY --from=builder /bin/chmod /bin/chmod
COPY --from=builder /usr/bin/curl /usr/bin/curl
COPY --from=builder /usr/bin/unzip /usr/bin/unzip
#curl dependencies
COPY --from=builder /usr/lib/x86_64-linux-gnu/libcurl.so.4 /usr/lib/x86_64-linux-gnu/libcurl.so.4
COPY --from=builder /usr/lib/x86_64-linux-gnu/libnghttp2.so.14 /usr/lib/x86_64-linux-gnu/libnghttp2.so.14
COPY --from=builder /usr/lib/x86_64-linux-gnu/librtmp.so.1 /usr/lib/x86_64-linux-gnu/librtmp.so.1
COPY --from=builder /usr/lib/x86_64-linux-gnu/libssh2.so.1 /usr/lib/x86_64-linux-gnu/libssh2.so.1
COPY --from=builder /usr/lib/x86_64-linux-gnu/libpsl.so.5 /usr/lib/x86_64-linux-gnu/libpsl.so.5

#unzip dependencies
COPY --from=builder /lib/x86_64-linux-gnu/libbz2.so.1.0 /lib/x86_64-linux-gnu/libbz2.so.1.0

COPY src/entrypoint.sh /fluent-bit/bin/entrypoint.sh
COPY src/health.sh /fluent-bit/bin/health.sh
RUN /bin/chmod +x /fluent-bit/bin/entrypoint.sh
RUN chmod +x /fluent-bit/bin/health.sh

ARG REACT_APP_API_ENTRYPOINT=https://api.seccubi.com
ENV REACT_APP_API_ENTRYPOINT=$REACT_APP_API_ENTRYPOINT

HEALTHCHECK --interval=30s --timeout=5s --start-period=45s \
   CMD /bin/sh /fluent-bit/bin/health.sh


#ENTRYPOINT ["/bin/sleep"]
#CMD ["300"]

ENTRYPOINT ["/bin/sh", "/fluent-bit/bin/entrypoint.sh"]


