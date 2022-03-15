# Jackett and OpenVPN, JackettVPN

FROM raspbian/stretch
MAINTAINER gjeanmart

ENV DEBIAN_FRONTEND noninteractive
ENV XDG_DATA_HOME="/config" \
XDG_CONFIG_HOME="/config"

WORKDIR /opt

RUN usermod -u 99 nobody

# Make directories
RUN mkdir -p /blackhole /config/Jackett /etc/jackett

# Update and upgrade
RUN apt update && apt -y upgrade

#  install required packages
RUN apt -y install \
    apt-transport-https \
    wget \
    curl \
    gnupg \
    sed \
    openvpn \
    curl \
    moreutils \
    net-tools \
    dos2unix \
    kmod \
    iptables \
    ipcalc\
    grep \
    libunwind8 \
    icu-devtools \
    #libcurl4 \
    liblttng-ust0 \
    #libssl1.0.0 \
    libkrb5-3 \
    zlib1g \
    tzdata \
    && apt-get clean \
    && rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/*


# Install Jackett
RUN jackett_latest=$(curl --silent "https://api.github.com/repos/Jackett/Jackett/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/') \
    && curl -o /opt/Jackett.Binaries.LinuxARM32.tar.gz -L https://github.com/Jackett/Jackett/releases/download/$jackett_latest/Jackett.Binaries.LinuxARM64.tar.gz \
    && tar -xvzf /opt/Jackett.Binaries.LinuxARM32.tar.gz \
    && rm /opt/Jackett.Binaries.LinuxARM32.tar.gz

VOLUME /blackhole /config

ADD openvpn/ /etc/openvpn/
ADD jackett/ /etc/jackett/

RUN chmod +x /etc/jackett/*.sh /etc/jackett/*.init /etc/openvpn/*.sh /opt/Jackett/jackett

EXPOSE 9117
CMD ["/bin/bash", "/etc/openvpn/start.sh"]
