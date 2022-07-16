FROM debian:buster-slim as client

RUN apt-get update && apt-get install -y curl unzip supervisor
COPY --from=fluent/fluent-bit:1.9.0 /fluent-bit /fluent-bit
COPY --from=fluent/fluent-bit:1.9.0 /usr/lib/x86_64-linux-gnu/libpq.so.5 /usr/lib/x86_64-linux-gnu/libpq.so.5
COPY --from=fluent/fluent-bit:1.9.0 /usr/lib/x86_64-linux-gnu/libyaml-0.so.2 /usr/lib/x86_64-linux-gnu/libyaml-0.so.2
COPY --from=fluent/fluent-bit:1.9.0 /lib/x86_64-linux-gnu/libm.so.6 /lib/x86_64-linux-gnu/libm.so.6

COPY src/health.sh /fluent-bit/bin/health.sh
COPY src/entrypoint.sh /fluent-bit/bin/entrypoint.sh
COPY src/version.info /fluent-bit/bin/version.info
COPY src/fluent-bit.conf /etc/supervisor/conf.d/fluent-bit.conf

RUN /bin/chmod +x /fluent-bit/bin/entrypoint.sh
RUN chmod +x /fluent-bit/bin/health.sh

ARG REACT_APP_API_ENTRYPOINT=https://api.seccubi.com
ENV REACT_APP_API_ENTRYPOINT=$REACT_APP_API_ENTRYPOINT

ARG FLAGS=""
ENV FLAGS=$FLAGS

HEALTHCHECK --interval=60s --timeout=5s --start-period=120s \
   CMD /bin/sh curl -s http://127.0.0.1:2020/api/v1/health | grep "ok" || exit 1

ENTRYPOINT ["/bin/bash", "/fluent-bit/bin/entrypoint.sh"]


