FROM golang

ARG SOPS_VERSION=3.11.0
ARG TENV_VERSION=v4.9.0
ARG NVM_VERSION=0.40.3
ENV TENV_AUTO_INSTALL=true
ENV HISTFILE=/root/bash_history/.bash_history

# Update our image
RUN <<EOF
    # Have the script fail if any command fails
    set -Eeuo pipefail

    echo "Updating base container"
    apt-get -y update
    apt-get -y install zip python3 python3-pip vim jq lsb-release
    apt-get -y upgrade
    pip install awscli --break-system-packages
    apt-get clean all
    echo "Installing node version manager"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh | bash
    echo "Installing tenv"
    DKPG_VERSION=$(dpkg --print-architecture)
    curl -O -L "https://github.com/tofuutils/tenv/releases/latest/download/tenv_${TENV_VERSION}_${DKPG_VERSION}.deb"
    dpkg -i "tenv_${TENV_VERSION}_${DKPG_VERSION}.deb"
    echo "Installing SOPS"
    go install github.com/getsops/sops/v3/cmd/sops@v$SOPS_VERSION
    echo "Installing packer"
    wget -O - https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
    apt update && apt install packer
    bash -c "source ~/.bashrc && nvm install 20"
    echo 'alias tf="tofu"' >> ~/.bashrc
    echo 'alias tfi="tofu init"' >> ~/.bashrc
    echo 'alias tfp="tofu plan"' >> ~/.bashrc
    echo 'alias tfa="tofu apply"' >> ~/.bashrc
    echo 'alias tfd="tofu destroy"' >> ~/.bashrc
    echo 'alias tg="terragrunt"' >> ~/.bashrc
    echo 'alias tgi="terragrunt init"' >> ~/.bashrc
    echo 'alias tgp="terragrunt plan"' >> ~/.bashrc
    echo 'alias tga="terragrunt apply"' >> ~/.bashrc
    echo 'alias tgd="terragrunt destroy"' >> ~/.bashrc
    echo 'alias ll="ls -alh"' >> ~/.bashrc
EOF

VOLUME /root/.tenv
VOLUME /root/bash_history

WORKDIR /root/repo