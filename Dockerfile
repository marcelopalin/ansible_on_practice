FROM ubuntu:latest

# Instalação do servidor SSH e outras dependências
RUN apt-get update && \
    apt-get install -y openssh-server sudo iptables iptables-persistent docker.io && \
    mkdir /var/run/sshd && \
    echo 'root:root' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd && \
    echo "root ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/dont-prompt-root-for-sudo-password

# Instalação do Docker
RUN apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release && \
    mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin && \
    usermod -aG docker ubuntu

# Configurar para usar iptables-legacy
RUN update-alternatives --set iptables /usr/sbin/iptables-legacy && \
    update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy

# Criação do usuário ubuntu e configuração SSH
RUN useradd -m -s /bin/bash ubuntu || true && \
    echo 'ubuntu:ubuntu' | chpasswd && \
    usermod -aG sudo ubuntu && \
    mkdir -p /home/ubuntu/.ssh && \
    chown -R ubuntu:ubuntu /home/ubuntu/.ssh && \
    chmod 700 /home/ubuntu/.ssh && \
    echo "ubuntu ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/ubuntu

# Adicionando chave pública ao usuário ubuntu
COPY id_rsa_ansible.pub /home/ubuntu/.ssh/authorized_keys
RUN chown ubuntu:ubuntu /home/ubuntu/.ssh/authorized_keys && chmod 600 /home/ubuntu/.ssh/authorized_keys

# Expondo a porta 22 para o SSH
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
