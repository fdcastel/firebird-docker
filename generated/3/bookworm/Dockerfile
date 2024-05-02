#
# This file was generated. Do not edit. See /src.
#

# Best practices for Dockerfile instructions
#   https://docs.docker.com/develop/develop-images/instructions/

FROM debian:bookworm-slim

ENV FIREBIRD_RELEASE_URL=https://github.com/FirebirdSQL/firebird/releases/download/v3.0.11/Firebird-3.0.11.33703-0.amd64.tar.gz
ENV FIREBIRD_RELEASE_SHA256=713757e09b40b2631d800dacd9b80179b7eb75693a72089136055a7154413a3e
ENV FIREBIRD_VERSION=3.0.11
ENV FIREBIRD_MAJOR=3

# https://linuxcommand.org/lc3_man_pages/seth.html
#   -e  Exit immediately if a command exits with a non-zero status.
#   -u  Treat unset variables as an error when substituting
#   -x  Print commands and their arguments as they are executed.

# Prerequisites
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        libatomic1 \
        libicu72 \
        libncurses6 \
        libtomcrypt1 \
        libtommath1 \
        netbase \
        procps; \
    rm -rf /var/lib/apt/lists/*

# Download
ADD --checksum="sha256:$FIREBIRD_RELEASE_SHA256" \
    --chown=root:root \
    --chmod=777 \
    $FIREBIRD_RELEASE_URL \
    /tmp/firebird-bundle.tar.gz

# Extract, install, clean
RUN set -eux; \
    cd /tmp; \
    tar --extract --file=firebird-bundle.tar.gz --gunzip --verbose --strip-components=1; \
    ./install.sh -silent; \
    rm *.tar.gz *.sh *.txt \
    # Remove unnecessary files
    rm -rf /opt/firebird/doc \
           /opt/firebird/examples \
           /opt/firebird/help \
           /opt/firebird/include; \
    # Remove 'employee' sample database from 'databases.conf'
    sed -i '/^employee/d' /opt/firebird/databases.conf

# System path
ENV PATH=/opt/firebird/bin:$PATH

# Data directory
ENV FIREBIRD_DATA /run/firebird/data
RUN set -eux; \
    mkdir -p "$FIREBIRD_DATA"; \
    chown -R firebird:firebird "$FIREBIRD_DATA"; \
    chmod 644 "$FIREBIRD_DATA"
VOLUME $FIREBIRD_DATA

# Entrypoint
COPY entrypoint.sh /usr/local/bin/
RUN set -eux; \
    chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]

EXPOSE 3050/tcp

# Fix terminfo location
ENV TERMINFO=/lib/terminfo/

CMD ["firebird"]

