ARG PIHOLE_DOCKER_TAG=latest

FROM pihole/pihole:${PIHOLE_DOCKER_TAG} as builder
RUN apt update \
 && apt install --no-install-recommends -y \
        cmake \
        build-essential \
        libssl-dev \
        g++ \
        git

RUN mkdir /workdir \
 && cd /workdir \
 && git clone https://github.com/chrisstaite/DoTe.git \
 && cd DoTe \
 && mkdir build

WORKDIR /workdir/DoTe/build
RUN cmake -DCMAKE_BUILD_TYPE=Release ..
RUN make -j$(nproc)

FROM pihole/pihole:${PIHOLE_DOCKER_TAG}
ARG TARGETARCH
ARG S6_OVERLAY_VERSION=v3.1.1.2
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG='C.UTF-8'
ENV LANGUAGE='C.UTF-8'
ENV LC_ALL='C.UTF-8'
ENV DOTE_OPTS="-s 127.0.0.1:5053"
ENV GS_DOCKER=1

RUN \
    export distro_name=$(cat /etc/*-release | grep VERSION_CODENAME |  cut -d '=' -f 2) \
 && curl -fsSL https://pkgs.tailscale.com/stable/debian/${distro_name}.noarmor.gpg | sudo tee /usr/share/keyrings/tailscale-archive-keyring.gpg >/dev/null \
 && curl -fsSL https://pkgs.tailscale.com/stable/debian/${distro_name}.tailscale-keyring.list | sudo tee /etc/apt/sources.list.d/tailscale.list \
 && apt update \
 && apt install --no-install-recommends -y \
        openssh-server \
        tzdata \
        rsync \
        git \
        vim \
        tailscale \
        iptables \
        libip4tc2 \
        libip6tc2 \
        libjansson4 \
        libnetfilter-conntrack3 \
        libnfnetlink0 \
        libnftables1 \
        libnftnl11 \
        netbase \
        nftables \
 && curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/syslogd-overlay-noarch.tar.xz" | tar Jxpf - -C / \
 && curl -sOL https://cronitor.io/dl/linux_$TARGETARCH.tar.gz \
 && tar xvf linux_$TARGETARCH.tar.gz -C /usr/bin/ \
 && rm linux_$TARGETARCH.tar.gz \
 && curl -sSL https://gravity.vmstan.com | bash \
 && rm -rf /var/cache/apt/archives /var/lib/apt/lists/*

COPY etc/ /etc/

COPY --from=builder /workdir/DoTe/build/dote /opt/dote
