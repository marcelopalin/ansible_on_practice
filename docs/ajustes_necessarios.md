# Docker Compose

Para evitar este problema ao tentarmos acessar o servidor via ssh

```s
ssh -i ~/.ssh/id_rsa_ansible root@172.25.0.3
```

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
Someone could be eavesdropping on you right now (man-in-the-middle attack)!
It is also possible that a host key has just been changed.
The fingerprint for the ECDSA key sent by the remote host is
SHA256:xKC6dpz8ePmJNCo1pfmuX5InHMYBw4HYSSOGQePeuL4.
Please contact your system administrator.
Add correct host key in /home/mpi/.ssh/known_hosts to get rid of this message.
Offending ECDSA key in /home/mpi/.ssh/known_hosts:16
  remove with:
  ssh-keygen -f "/home/mpi/.ssh/known_hosts" -R "172.25.0.3"
ECDSA host key for 172.25.0.3 has changed and you have requested strict checking.
Host key verification failed.

Esse problema ocorre porque o SSH armazena a chave de host dos servidores aos quais você 
se conecta no arquivo `known_hosts`. Quando o endereço IP dos containers muda, o SSH detecta 
que a chave de host para esse IP mudou, o que pode indicar um ataque de man-in-the-middle.

Para resolver esse problema, podemos fazer duas coisas:

Configurar IPs fixos para os containers: Isso evitará que os endereços IP mudem a cada reinicialização.
Automatizar a remoção de entradas de known_hosts no playbook: Isso limpará automaticamente as entradas antigas quando necessário.

Vamos atualizar o `docker-compose.yml` para garantir que os containers 
sejam reiniciados automaticamente e que o servidor SSH seja instalado e iniciado quando os containers forem criados.
Adicionaremos uma configuração para reiniciar os containers sempre e incluiremos comandos para instalar e iniciar o servidor SSH.

docker-compose.yml

```yml
services:
  ansible_host1:
    image: ubuntu:latest
    container_name: ansible_host1
    networks:
      ansible_net:
        ipv4_address: 172.18.0.2
    tty: true
    restart: always
    command: /bin/bash -c "apt-get update && apt-get install -y openssh-server && service ssh start && tail -f /dev/null"

  ansible_host2:
    image: ubuntu:latest
    container_name: ansible_host2
    networks:
      ansible_net:
        ipv4_address: 172.18.0.3
    tty: true
    restart: always
    command: /bin/bash -c "apt-get update && apt-get install -y openssh-server && service ssh start && tail -f /dev/null"

networks:
  ansible_net:
    driver: bridge
    ipam:
      config:
        - subnet: 172.18.0.0/16


```


## Criando .dockerignore

Explicação

Dockerfile e .dockerignore: Ignora o Dockerfile e o próprio arquivo .dockerignore, pois eles não são necessários dentro da imagem.
ansible.cfg, hosts, playbook.yml, roles/: Ignora os arquivos e diretórios específicos do Ansible, pois eles não são necessários dentro da imagem Docker.

.*: Ignora todos os arquivos e diretórios ocultos.

!.ssh/: Inclui o diretório .ssh para garantir que as chaves SSH sejam copiadas para a imagem, se necessário.

Temporários: Ignora arquivos temporários gerados por editores de texto e sistemas operacionais.

Com este .dockerignore, você garante que apenas os arquivos necessários sejam incluídos na imagem Docker, mantendo-a mais leve e eficiente.


## Erro 


```s
Offending ECDSA key in /home/mpi/.ssh/known_hosts:17
  remove with:
  ssh-keygen -f "/home/mpi/.ssh/known_hosts" -R "172.32.0.2"
ECDSA host key for 172.32.0.2 has changed and you have requested strict checking.
Host key verification failed.
```

Essa mensagem indica que a chave de host no arquivo known_hosts mudou. Isso pode acontecer quando você recria os containers, pois novas chaves de host são geradas. Para resolver isso, podemos remover a entrada existente no arquivo known_hosts para esses IPs.


Vamos automatizar a remoção das entradas antigas do known_hosts para evitar este problema. Você pode adicionar os comandos necessários ao playbook Ansible para garantir que as entradas antigas sejam removidas automaticamente antes de tentar a conexão SSH.

Passo 1: Remover Manualmente as Entradas Antigas
Remova as entradas antigas manualmente:


```s
ssh-keygen -f "/home/mpi/.ssh/known_hosts" -R "172.32.0.2"
ssh-keygen -f "/home/mpi/.ssh/known_hosts" -R "172.32.0.3"
```

Verifique a conexão ssh:

```s
ssh -i ~/.ssh/id_rsa_ansible root@172.32.0.2
ssh -i ~/.ssh/id_rsa_ansible root@172.32.0.3
```

Então execute o Ansible

```

```
