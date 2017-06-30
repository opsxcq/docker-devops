FROM debian:jessie

MAINTAINER opsxcq <opsxcq@thestorm.com.br>

RUN apt-get update && \
    apt-get upgrade -y && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    unzip \
    unrar-free \
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
    groff-base \ 
    ruby ruby-dev \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

# Docker
RUN curl -fsSL https://get.docker.com/ | sh

# Terraform
ENV TERRAFORM_VERSION=0.8.8
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip -d /usr/bin && \
    rm *.zip

RUN gem install terraforming

# Rclone
RUN wget http://downloads.rclone.org/rclone-current-linux-amd64.zip && \
    unzip rclone-current-linux-amd64.zip -d /usr/bin

# AWS Command line
RUN pip install --upgrade --user awscli

ENV PATH="/root/.local/bin/:${PATH}"

COPY main.sh /
ENTRYPOINT ["/main.sh"]
CMD ["default"]

