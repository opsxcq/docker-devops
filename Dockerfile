FROM debian:9.2

LABEL maintainer "opsxcq@strm.sh"

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    unzip \
    unrar-free \
    curl \
    wget \
    openssl \
    ca-certificates \
    python3 \
    python3-pip \
    python3-dev \
    python3-yaml \
    python3-virtualenv \
    virtualenvwrapper \
    libxml2-dev \
    libxslt-dev \
    libffi-dev \
    libssl-dev \
    ssh \
    rsync \
    git \
    pass \
    gpg \
    qemu-utils \
    sgabios \
    seabios \
    qemu-system\
    qemu-efi\
    qemu-kvm\
    qemu \
    python3-libvirt\
    python3-libqcow\
    libvirt0\
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

############################# RClone
RUN wget http://downloads.rclone.org/rclone-current-linux-amd64.zip && \
    unzip rclone-current-linux-amd64.zip -d /usr/bin && \
    rm *.zip

############################# Packer
ARG PACKER_VERSION=1.5.4
RUN wget https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip && \
  unzip packer_${PACKER_VERSION}_linux_amd64.zip

############################# Ansible
RUN pip3 install --upgrade \
    setuptools
RUN pip3 install --upgrade \
    ansible \
    paramiko \
    PyYAML \
    pycrypto \
    pywinrm \
    ansible-lint
#    Jinja2 \
#    httplib2 \
#    six

# AWS dependencies
RUN pip3 install --upgrade \
    urllib3  python-dateutil jmespath \
    boto boto3 botocore


############################# GCloud cli
ARG CLOUD_SDK_VERSION=223.0.0
ENV CLOUD_SDK_VERSION=$CLOUD_SDK_VERSION

ARG INSTALL_COMPONENTS

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    curl \
    gcc \
    python3-dev \
    python3-setuptools \
    apt-transport-https \
    lsb-release \
    openssh-client \
    git \
    gnupg

RUN pip3 install crcmod && \
    export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
    echo "deb https://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" > /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    google-cloud-sdk=${CLOUD_SDK_VERSION}-0 && \
    gcloud config set core/disable_usage_reporting true && \
    gcloud config set component_manager/disable_update_check true && \
    gcloud config set metrics/environment github_docker_image && \
    gcloud --version

############################# Kubectl

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    kubectl
######################################################################

#### LEGO

WORKDIR /tmp
RUN wget https://github.com/xenolf/lego/releases/download/v2.1.0/lego_v2.1.0_linux_amd64.tar.gz -O lego.tar.gz && \
    tar -zxvf lego.tar.gz && \
    chmod +x lego && \
    mv lego /bin/lego && \
    lego -v

RUN useradd --system --uid 1000 -m --shell /usr/bash devops && \
    mkdir -p /home/devops && \
    chown devops /home/devops

USER devops

RUN pip3 install --upgrade --user awscli
RUN pip3 install boto3 botocore

ENV PATH="/home/devops/.local/bin/:${PATH}"

COPY main.sh /

ENTRYPOINT ["/main.sh"]
CMD ["default"]

