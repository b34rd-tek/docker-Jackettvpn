# Jackett and OpenVPN, JackettVPN

FROM alpine:latest

LABEL org.opencontainers.image.authors="b34rd_tek <el_barbado@b34rd.tech>" \
      org.opencontainers.image.documentation="https://github.com/${PACKAGE}/README.md" \
      org.opencontainers.image.description="${DESCRIPTION}" \
      org.opencontainers.image.licenses="GPLv3" \
      org.opencontainers.image.source="https://github.com/${PACKAGE}" \
      org.opencontainers.image.url="https://hub.docker.com/r/${PACKAGE}/"

ENV XDG_DATA_HOME="/config" \
XDG_CONFIG_HOME="/config"

WORKDIR /opt

#  install required packages
RUN apk update && apk add wget\
 openrc\
 bash\
 curl\
 gnupg\
 sed\
 openvpn\
 moreutils\
 net-tools\
 dos2unix\
 kmod\
 iptables\
 ipcalc\
 grep\
 libunwind\
 icu-dev\
 lttng-ust\
 krb5-libs\
 zlib\
 tzdata

# Make directories
RUN mkdir -p /blackhole /config/Jackett /etc/jackett /lib/lsb /lib/init

ARG TARGETARCH
ENV JACKETT_ARCH=LinuxAMDx64

# Install Jackett
RUN case ${TARGETARCH} in \
         "amd64")  JACKETT_ARCH=LinuxAMDx64  ;; \
         "arm64")  JACKETT_ARCH=LinuxARM64  ;; \
         "arm") JACKETT_ARCH=LinuxARM32  ;; \
    esac \
    && jackett_latest=$(curl --silent "https://api.github.com/repos/Jackett/Jackett/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') \
    && curl -o /opt/Jackett.Binaries.${JACKETT_ARCH}.tar.gz -L https://github.com/Jackett/Jackett/releases/download/$jackett_latest/Jackett.Binaries.${JACKETT_ARCH}.tar.gz \
    && tar -xvzf /opt/Jackett.Binaries.${JACKETT_ARCH}.tar.gz \
    && rm /opt/Jackett.Binaries.${JACKETT_ARCH}.tar.gz

VOLUME /blackhole /config

ADD openvpn/ /etc/openvpn/
ADD jackett/ /etc/jackett/

RUN chmod +x /etc/jackett/*.sh /etc/jackett/*.init /etc/openvpn/*.sh /opt/Jackett/jackett

EXPOSE 9117
CMD ["/bin/sh", "/etc/openvpn/start.sh"]
