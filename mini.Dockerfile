# Debian has all the necessary 32-bit packages in repositories and good support for multi-platform builds.
FROM debian:12

ARG PKS_LSCRIPTS
ARG PKS_CFG
ARG PKS_BINARY="pkserver"
ARG PKS_DIR="/opt/pkserver"
ARG PKS_USER="painkiller"

ENV PKS_LSCRIPTS=${PKS_LSCRIPTS}
ENV PKS_CFG=${PKS_CFG}
ENV PKS_BINARY=${PKS_BINARY}
ENV PKS_DIR=${PKS_DIR}

RUN useradd -m -s /bin/bash ${PKS_USER}

# Painkiller server is a 32-bit binary
RUN dpkg --add-architecture i386

# Required packages for 32-bit 'pkserver' zlib1g:i386 libncurses5:i386 libstdc++5:i386
# bbe is required for binary hacking
RUN apt-get update && \
    apt-get install --no-install-recommends -y bbe zlib1g:i386 libncurses5:i386 libstdc++5:i386 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --chmod=755 scripts/* /usr/local/bin/

WORKDIR ${PKS_DIR}/

USER ${PKS_USER}

EXPOSE 3455/udp 3578/udp

ENTRYPOINT ["entrypoint.sh"]
