FROM debian:jessie

MAINTAINER opsxcq <opsxcq@thestorm.com.br>

RUN apt-get update && \
    apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    curl \
    wget \
    openssl \
    ca-certificates \
    python \
    python-pip \
    ssh \
    rsync \
    git \
    ansible \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Docker
RUN curl -fsSL https://get.docker.com/ | sh

COPY main.sh /
ENTRYPOINT ["/main.sh"]
CMD ["default"]

