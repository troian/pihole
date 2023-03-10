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
ARG S6_OVERLAY_VERSION=v3.1.3.0
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG='C.UTF-8'
ENV LANGUAGE='C.UTF-8'
ENV LC_ALL='C.UTF-8'
ENV DOTE_OPTS="-s 127.0.0.1:5053"
ENV GS_DOCKER=1

COPY updatelists /tmp/updatelists/

RUN \
    apt update \
 && apt install --no-install-recommends -y \
        openssh-server \
        tzdata \
        rsync \
        wget \
        php-cli \
        php-sqlite3 \
        php-intl \
        php-curl \
 && curl -L -s "https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/syslogd-overlay-noarch.tar.xz" | tar Jxpf - -C / \
 && curl -sOL https://cronitor.io/dl/linux_$TARGETARCH.tar.gz \
 && tar xvf linux_$TARGETARCH.tar.gz -C /usr/bin/ \
 && rm linux_$TARGETARCH.tar.gz \
 && curl -sSL https://gravity.vmstan.com | bash \
 && rm -rf /var/cache/apt/archives /var/lib/apt/lists/* \
 && chmod +x /tmp/updatelists/install.sh \
 && bash /tmp/updatelists/install.sh docker \
 && rm -fr /tmp/updatelists

COPY etc/ /etc/

COPY --from=builder /workdir/DoTe/build/dote /opt/dote
