# Original credit:
# - https://github.com/gkweb76/dnscrypt-proxy
FROM alpine:latest
LABEL maintainer="Elrod <elrod@thomaselrod.com>"


# Install dnscrypt-proxy
RUN apk add --update --no-cache dnscrypt-proxy bash && \
    rm -rf /tmp/* /var/tmp/* /var/cache/apk/* /var/cache/distfiles/*

# add entrypoint
COPY entrypoint.sh /
RUN chmod 755 /entrypoint.sh

# Healtcheck
HEALTHCHECK --start-period=5s --interval=30s --timeout=3s --retries=3 CMD nslookup icann.org 127.0.0.1 || exit 1

# Environnement variables
ENV LOCAL_IP 0.0.0.0
ENV LOCAL_PORT 53

# Port for DNS
EXPOSE $LOCAL_PORT/udp

# Start dnscrypt-proxy daemon based on ENV variables
WORKDIR /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/usr/bin/dnscrypt-proxy", "--config", "/tmp/dnscrypt-proxy.toml"]
