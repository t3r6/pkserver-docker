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

# Painkiller server is a 32-bit binary, so we enable 32-bit architecture in OS.
RUN dpkg --add-architecture i386

# Uncomment if you need to install debugging tools in a container.
# RUN apt-get update && \
#     apt-get install -y python3 zip unzip curl wget git file binutils iproute2 \
#                        iputils-ping net-tools dnsutils nmap netcat-traditional iptables \
#                        traceroute tcpdump lsof telnet procps \
#     apt-get clean && \
#     rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Required packages for 32-bit 'pkserver' zlib1g:i386 libncurses5:i386 libstdc++5:i386
# bbe is required for binary hacking
RUN apt-get update && \
    apt-get install --no-install-recommends -y bbe vim zlib1g:i386 libncurses5:i386 libstdc++5:i386 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY --chmod=765 scripts/* /usr/local/bin/

COPY pkserver/ ${PKS_DIR}/

RUN chown -R ${PKS_USER}:${PKS_USER} ${PKS_DIR}/

WORKDIR ${PKS_DIR}/

USER ${PKS_USER}

# Uncomment if you are planning to use volumes.
# VOLUME ${PKS_DIR}

# EXPOSE is not required but left for documenting purposes. 3578 is for LAN Discovery.
EXPOSE 3455/udp 3578/udp

ENTRYPOINT ["entrypoint.sh"]
