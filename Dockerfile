FROM ubuntu:latest

# Instalação do servidor SSH e outras dependências
RUN apt-get update && \
    apt-get install -y openssh-server sudo && \
    mkdir /var/run/sshd && \
    echo 'root:root' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd && \
    echo "root ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/dont-prompt-root-for-sudo-password

# Adicionando chave pública ao container
COPY id_rsa_ansible.pub /root/.ssh/authorized_keys

# Expondo a porta 22 para o SSH
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]
