# Jackett and OpenVPN, JackettVPN

FROM balenalib/raspberrypi4-64-debian:latest
MAINTAINER b34rd-tek

RUN ["cross-build-start"]

ENV XDG_DATA_HOME="/config" \
XDG_CONFIG_HOME="/config"

WORKDIR /opt

RUN usermod -u 99 nobody

# Make directories
RUN mkdir -p /blackhole /config/Jackett /etc/jackett

#  install required packages
RUN install_packages apt-transport-https\
 wget\
 curl\
 gnupg\
 sed\
 openvpn\
 curl\
 moreutils\
 net-tools\
 dos2unix\
 kmod\
 iptables\
 ipcalc\
 grep\
 libunwind8\
 icu-devtools\
 liblttng-ust0\
 libkrb5-3\
 zlib1g\
 tzdata 

# Cleanup
RUN  apt-get clean \
    && rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/*

# Install Jackett
RUN jackett_latest=$(curl --silent "https://api.github.com/repos/Jackett/Jackett/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') \
    && curl -o /opt/Jackett.Binaries.LinuxARM64.tar.gz -L https://github.com/Jackett/Jackett/releases/download/$jackett_latest/Jackett.Binaries.LinuxARM64.tar.gz \
    && tar -xvzf /opt/Jackett.Binaries.LinuxARM64.tar.gz \
    && rm /opt/Jackett.Binaries.LinuxARM64.tar.gz

VOLUME /blackhole /config

ADD openvpn/ /etc/openvpn/
ADD jackett/ /etc/jackett/

RUN chmod +x /etc/jackett/*.sh /etc/jackett/*.init /etc/openvpn/*.sh /opt/Jackett/jackett

RUN ["cross-build-end"]

EXPOSE 9117
CMD ["/bin/bash", "/etc/openvpn/start.sh"]
