FROM debian:latest AS builder

RUN apt-get update && apt-get install -y curl unzip

FROM fluent/fluent-bit:latest AS logger

COPY --from=builder /bin/sh /bin/sh
COPY --from=builder /bin/chmod /bin/chmod
COPY --from=builder /usr/bin/curl /usr/bin/curl
COPY --from=builder /usr/bin/unzip /usr/bin/unzip

COPY src/entrypoint.sh /fluent-bit/bin/entrypoint.sh
COPY src/health.sh /fluent-bit/bin/health.sh
RUN /bin/chmod +x /fluent-bit/bin/entrypoint.sh
RUN chmod +x /fluent-bit/bin/health.sh

ARG REACT_APP_API_ENTRYPOINT=https://api.seccubi.com
ENV REACT_APP_API_ENTRYPOINT=$REACT_APP_API_ENTRYPOINT

HEALTHCHECK --interval=30s --timeout=5s --start-period=45s \
   CMD /fluent-bit/bin/health.sh


ENTRYPOINT ["/fluent-bit/bin/entrypoint.sh"]
