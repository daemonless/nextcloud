ARG BASE_VERSION=15
FROM ghcr.io/daemonless/nginx-base:${BASE_VERSION}

ARG FREEBSD_ARCH=amd64
ARG PACKAGES="nextcloud-php83 php83-pecl-APCu php83-pecl-redis php83-pecl-imagick php83-opcache php83-exif php83-ldap php83-pdo_mysql php83-pdo_pgsql php83-pdo_sqlite php83-sqlite3 php83-sysvsem php83-pcntl ffmpeg"
LABEL org.opencontainers.image.title="Nextcloud" \
    org.opencontainers.image.description="Nextcloud self-hosted cloud on FreeBSD" \
    org.opencontainers.image.source="https://github.com/daemonless/nextcloud" \
    org.opencontainers.image.url="https://nextcloud.com/" \
    org.opencontainers.image.documentation="https://docs.nextcloud.com/" \
    org.opencontainers.image.licenses="AGPL-3.0-only" \
    org.opencontainers.image.vendor="daemonless" \
    org.opencontainers.image.authors="daemonless" \
    io.daemonless.port="80" \
    io.daemonless.arch="${FREEBSD_ARCH}" \
    io.daemonless.pkg-source="containerfile" \
    io.daemonless.base="nginx" \
    io.daemonless.category="Utilities" \
    io.daemonless.upstream-mode="pkg" \
    io.daemonless.packages="${PACKAGES}"

# Install Nextcloud and dependencies
# Using PHP 8.3 as default, includes all recommended extensions
RUN pkg update && \
    pkg install -y \
    ${PACKAGES} \
    && \
    mkdir -p /app && pkg info nextcloud-php83 | sed -n 's/.*Version.*: *//p' > /app/version && \
    pkg clean -ay && \
    rm -rf /var/cache/pkg/* /var/db/pkg/repos/*

# Create nextcloud user (use www for simplicity since nginx runs as www)
# Nextcloud files need to be owned by www user

# Create required directories
RUN mkdir -p /config/www /data /var/log/nextcloud && \
    chown -R bsd:bsd /config /data /var/log/nextcloud

# Copy configuration and service scripts
COPY root/ /

# Make scripts executable
RUN chmod +x /etc/cont-init.d/* /etc/services.d/*/run 2>/dev/null || true

# Set up s6 service links

EXPOSE 80

VOLUME ["/config", "/data"]


