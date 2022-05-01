FROM debian:bullseye

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
    jq \
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
    libncursesw5 \
    gcc \
    python3-setuptools \
    apt-transport-https \
    lsb-release \
    openssh-client \
    gnupg \
    emacs \
    netcat socat kafkacat\
    tmux \
    && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

###############
#### RClone
###############
RUN wget http://downloads.rclone.org/rclone-current-linux-amd64.zip && \
    unzip rclone-current-linux-amd64.zip -d /usr/bin && \
    rm *.zip


###############
#### Packer
###############
ARG PACKER_VERSION=1.5.4

RUN wget https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip && \
    unzip packer_${PACKER_VERSION}_linux_amd64.zip && \
    chmod +x packer && \
    mv packer /usr/bin && \
    rm *.zip

###############
#### Terraform
###############
ARG TERRAFORM_VERSION=1.1.9
RUN wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
    chmod +x terraform && \
    mv terraform /usr/bin && \
    rm *.zip

###############
#### AWS
###############
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm *.zip

###############
#### File Formats
###############
RUN wget https://github.com/mikefarah/yq/releases/download/v4.2.0/yq_linux_amd64 -O /usr/bin/yq &&\
    chmod +x /usr/bin/yq

###############
#### Ansible
###############
RUN pip3 install --upgrade \
    setuptools \
    ansible \
    paramiko \
    PyYAML \
    pycrypto \
    pywinrm \
    poetry \
    ansible-lint \
    urllib3  \
    python-dateutil \
    jmespath \
    boto \
    boto3 \
    botocore \
    diagrams

###############
#### Digital certificates
###############
RUN wget https://github.com/xenolf/lego/releases/download/v2.1.0/lego_v2.1.0_linux_amd64.tar.gz -O lego.tar.gz && \
    tar -zxvf lego.tar.gz && \
    chmod +x lego && \
    mv lego /bin/lego && \
    rm *.tar.gz

###############
#### VMWare
###############
COPY VMware-ovftool-4.3.0-13981069-lin.x86_64.bundle /tmp/ovftool
RUN sh /tmp/ovftool -p /usr/local --console --eulas-agreed --required && \
    rm /tmp/ovftool

###############
#### Kubernetes
###############
RUN curl -Lo kubectl "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv ./kubectl /usr/local/bin/ && \
    curl -Lo skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64 && \
    chmod +x skaffold && \
    mv ./skaffold /usr/local/bin/

###############
#### Finance & Machine learning
###############

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    gfortran \
    libfreetype6-dev \
    libhdf5-dev \
    liblapack-dev \
    libopenblas-dev \
    libpng-dev && \
    mkdir -p /tmp/talib && \
    cd /tmp/talib && \
    curl -fsSL http://prdownloads.sourceforge.net/ta-lib/ta-lib-0.4.0-src.tar.gz | tar xvz --strip-components 1 && \
    ./configure --prefix=/usr && \
    make && \
    make install && \
    apt clean && \
    rm -Rf /tmp/*

###############
#### Slack integration
###############
RUN curl https://raw.githubusercontent.com/rockymadden/slack-cli/46d22741e82d749180ae91512515132a9380ad57/src/slack > /usr/local/bin/slack && \
    chmod +x /usr/local/bin/slack

###############
#### User setup
###############
RUN useradd --system --uid 1000 -m --shell /usr/bash devops && \
    mkdir -p /home/devops && \
    chown devops /home/devops

USER devops

ENV PATH="/home/devops/.local/bin/:${PATH}"

RUN git clone https://github.com/syl20bnr/spacemacs ~/.emacs.d

COPY main.sh /

ENTRYPOINT ["/main.sh"]
CMD ["default"]
