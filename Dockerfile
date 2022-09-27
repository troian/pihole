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

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG='C.UTF-8' LANGUAGE='C.UTF-8' LC_ALL='C.UTF-8'
ENV DOTE_OPTS="-s 127.0.0.1:5053"

RUN apt update \
 && apt install --no-install-recommends -y \
        openssh-server \
        tzdata \
 && rm -rf /var/cache/apt/archives /var/lib/apt/lists/*

COPY etc/ /etc/
COPY --from=builder /workdir/DoTe/build/dote /opt/dote
