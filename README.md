# Ansible Tutorial

Este projeto fornece um ambiente de testes para aprender Ansible utilizando Docker. Subiremos dois servidores Ubuntu em containers Docker para que possamos aplicar nossos playbooks e aprender a gerenciar infraestrutura de forma automatizada.

## Requisitos

Para executar este tutorial, você precisará dos seguintes itens instalados em sua máquina:

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)
- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)


## O que é Docker?

Docker é uma plataforma que permite criar, executar e gerenciar containers. Containers são unidades leves e portáteis que incluem tudo o que você precisa para executar um software, incluindo o código, runtime, bibliotecas e dependências.

### Por que usar Docker?

- **Portabilidade**: Containers podem ser executados em qualquer lugar, desde que o Docker esteja instalado.
- **Isolamento**: Cada container é isolado dos outros, o que ajuda a evitar conflitos de dependências.
- **Facilidade de uso**: Docker simplifica a configuração e a distribuição de ambientes de desenvolvimento.

## Instalação do Docker

### Ubuntu/Debian

A instalação oficial é descrita em https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository

No momento que consultei era:

```s
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

Depois instalar:

```s
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

## Verificação da Instalação
Para verificar se o Docker foi instalado corretamente, execute:

```s
docker --version
```

Você deve ver a versão do Docker instalada.

Para verificar a instalação você precisa ter uma conta no site do dockerhub.com
configurar seu linux para ter permissão e então executar:

```s
sudo docker run hello-world
```

## O que é Docker Compose?

Docker Compose é uma ferramenta para definir e gerenciar multi-containers Docker. Com ele, você pode definir serviços, redes e volumes em um arquivo YAML.

## Instalação do Docker Compose

A maioria das instalações do Docker Desktop já inclui o Docker Compose. Para verificar se o Docker Compose está instalado, execute:

```s
docker-compose --version
```

Se o Docker Compose não estiver instalado, siga as instruções no site oficial.

## Entendendo o arquivo docker-compose.yml

Aqui está o arquivo docker-compose.yml que utilizaremos:

```yml
version: '3'

services:
  ansible_host1:
    image: ubuntu:latest
    container_name: ansible_host1
    networks:
      - ansible_net
    tty: true
    restart: always

  ansible_host2:
    image: ubuntu:latest
    container_name: ansible_host2
    networks:
      - ansible_net
    tty: true
    restart: always

networks:
  ansible_net:
    driver: bridge
```

## Explicação das Seções do docker-compose.yml

* version: '3': Especifica a versão do Docker Compose.
* services: Define os serviços que serão executados. Cada serviço é um container.
ansible_host1: Nome do primeiro serviço/container.

* image: ubuntu
: A imagem Docker que será usada. Neste caso, estamos usando a última versão do Ubuntu.
* container_name: ansible_host1: Nome do container.
* networks: Define as redes nas quais o container estará conectado.
* tty: true: Mantém o terminal ativo, necessário para alguns comandos interativos.
* ansible_host2: Nome do segundo serviço/container, com as mesmas configurações do primeiro.
* networks: Define as redes que serão usadas pelos serviços.
* ansible_net: Nome da rede.
driver: bridge: Tipo de driver de rede, que neste caso é o padrão 'bridge'.


## Executando este tutorial

### 1. Clonar o repositório

Primeiro, clone este repositório para sua máquina local:

```bash
git clone https://github.com/seu-usuario/seu-repositorio.git
cd seu-repositorio
```


### 2. Subir os containers

Use o Docker Compose para subir os containers com os servidores Ubuntu:

```s
docker-compose up -d
```

### Configurar o acesso SSH

Para permitir que o Ansible se conecte aos containers via SSH, precisamos configurar o acesso SSH sem senha.

Verifique se já possui o diretório `~/.ssh` e se dentro já existem os arquivos
- id_rsa
- id_rsa.pub

Mesmo que existirem, vamos gerar uma chave SSH específica para o Ansible:

```s
ssh-keygen -t rsa -b 2048 -f ~/.ssh/id_rsa_ansible -q -N ""
```

Copie a chave pública para os containers:

```s
docker exec -it ansible_host1 bash -c "apt update && apt install -y openssh-server && mkdir -p /root/.ssh && echo '$(cat ~/.ssh/id_rsa_ansible.pub)' >> /root/.ssh/authorized_keys"
docker exec -it ansible_host2 bash -c "apt update && apt install -y openssh-server && mkdir -p /root/.ssh && echo '$(cat ~/.ssh/id_rsa_ansible.pub)' >> /root/.ssh/authorized_keys"
```

Atenção: você será perguntado para responder os códigos abaixo.

```s
Please select the geographic area in which you live. Subsequent configuration questions will narrow this down by presenting
a list of cities, representing the time zones in which they are located.

  1. Africa   3. Antarctica  5. Asia      7. Australia  9. Indian    11. Etc
  2. America  4. Arctic      6. Atlantic  8. Europe     10. Pacific
Geographic area: 2
```

```s
Please select the city or region corresponding to your time zone.

  1. Adak                     40. Coral_Harbour         79. Juneau                   118. Port-au-Prince
  2. Anchorage                41. Costa_Rica            80. Kentucky/Louisville      119. Port_of_Spain
  3. Anguilla                 42. Creston               81. Kentucky/Monticello      120. Porto_Acre
  4. Antigua                  43. Cuiaba                82. Kralendijk               121. Porto_Velho
  5. Araguaina                44. Curacao               83. La_Paz                   122. Puerto_Rico
  6. Argentina/Buenos_Aires   45. Danmarkshavn          84. Lima                     123. Punta_Arenas
  7. Argentina/Catamarca      46. Dawson                85. Los_Angeles              124. Rainy_River
  8. Argentina/Cordoba        47. Dawson_Creek          86. Lower_Princes            125. Rankin_Inlet
  9. Argentina/Jujuy          48. Denver                87. Maceio                   126. Recife
  10. Argentina/La_Rioja      49. Detroit               88. Managua                  127. Regina
  11. Argentina/Mendoza       50. Dominica              89. Manaus                   128. Resolute
  12. Argentina/Rio_Gallegos  51. Edmonton              90. Marigot                  129. Rio_Branco
  13. Argentina/Salta         52. Eirunepe              91. Martinique               130. Santa_Isabel
  14. Argentina/San_Juan      53. El_Salvador           92. Matamoros                131. Santarem
  15. Argentina/San_Luis      54. Ensenada              93. Mazatlan                 132. Santiago
  16. Argentina/Tucuman       55. Fort_Nelson           94. Menominee                133. Santo_Domingo
  17. Argentina/Ushuaia       56. Fortaleza             95. Merida                   134. Sao_Paulo
  
Time zone: 134
```

Use os endereços IP dos containers para acessar via SSH. Primeiro, obtenha os endereços IP dos containers:

```s
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ansible_host1
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ansible_host2

172.25.0.2
172.25.0.3
```

### Verificando se o servidor é acessível via SSH:

```s
ssh -i ~/.ssh/id_rsa_ansible root@172.25.0.2
ssh -i ~/.ssh/id_rsa_ansible root@172.25.0.3
```

Resultado de um acesso bem sucedido:

```s
ssh -i ~/.ssh/id_rsa_ansible root@172.25.0.2

The authenticity of host '172.25.0.2 (172.25.0.2)' can't be established.
ECDSA key fingerprint is SHA256:djXOhSN588MagdrhSAh5yn8lVEh9DhS1W0q8gwoFiLg.
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
Warning: Permanently added '172.25.0.2' (ECDSA) to the list of known hosts.
Welcome to Ubuntu 24.04 LTS (GNU/Linux 5.15.146.1-microsoft-standard-WSL2 x86_64)

 * Documentation:  https://help.ubuntu.com
 * Management:     https://landscape.canonical.com
 * Support:        https://ubuntu.com/pro

This system has been minimized by removing packages and content that are
not required on a system that users do not log into.

To restore this content, you can run the 'unminimize' command.

The programs included with the Ubuntu system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Ubuntu comes with ABSOLUTELY NO WARRANTY, to the extent permitted by
applicable law.

root@a66163424b2f:~#
```

### Certifique-se de que a chave pública está nos containers:

Execute os comandos abaixo para garantir que a chave pública está nos containers:

```s
docker exec -it ansible_host1 bash -c "mkdir -p /root/.ssh && echo '$(cat ~/.ssh/id_rsa_ansible.pub)' >> /root/.ssh/authorized_keys"
docker exec -it ansible_host2 bash -c "mkdir -p /root/.ssh && echo '$(cat ~/.ssh/id_rsa_ansible.pub)' >> /root/.ssh/authorized_keys"
```

Verifique a execução dos serviços:
Para garantir que o serviço SSH está ativo e os containers estão acessíveis, use os seguintes comandos:

```s
docker exec -it ansible_host1 service ssh status
docker exec -it ansible_host2 service ssh status
```

a resposta deve ser `sshd is running`.


### 3. Acessar os containers

Você pode acessar os containers usando o comando docker exec. Por exemplo:

```s
docker exec -it ansible_host1 bash
docker exec -it ansible_host2 bash

```

### 4. Instalar o Ansible na máquina host (sua máquina)

Para gerenciar os containers com Ansible, você precisará instalar o Ansible na máquina host (ou seja, sua máquina local). Siga as instruções abaixo para instalar o Ansible:

### Ubuntu/Debian usando PIP

Primeiro, vamos remover qualquer instalação existente do Ansible para evitar conflitos:

```s
sudo apt remove ansible -y
```

Em seguida, vamos usar pip para garantir que Ansible e todas as suas dependências sejam instalados corretamente:

Atualize os pacotes do sistema e instale python3-pip:

```s
sudo apt update
sudo apt install python3-pip -y
```

Instale Ansible usando pip:

```s
pip3 install --user ansible
```

Adicione o diretório de pacotes de usuário ao PATH, se ainda não estiver:

```s
echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

use o comando `echo $SHELL` se tiver o zsh faça:

```s
echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.zshrc
source ~/.zshrc
```


Verifique se a instalação foi bem-sucedida:

```s
ansible --version
```


### 5. Configurar o Inventário do Ansible




Primeiro, obtenha os endereços IP dos containers:

```s
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ansible_host1
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ansible_host2

172.25.0.2
172.25.0.3
```


Crie um arquivo chamado `hosts` no diretório do projeto com o seguinte conteúdo:

```s
[servers]
ansible_host1 ansible_host=172.25.0.2 ansible_user=root ansible_ssh_private_key_file=~/.ssh/id_rsa_ansible
ansible_host2 ansible_host=172.25.0.3 ansible_user=root ansible_ssh_private_key_file=~/.ssh/id_rsa_ansible

[all:vars]
ansible_python_interpreter=/usr/bin/python3

```

### 6. Escrever um Playbook Simples

Crie um arquivo chamado `playbook.yml` no diretório do projeto com o seguinte conteúdo:

```yml
---
- name: Testar Ansible no Docker
  hosts: servers
  tasks:
    - name: Instalar pacote 'tree'
      apt:
        name: tree
        state: present

```



### 7. Executar o Playbook

Execute o playbook usando o comando abaixo:

```s
ansible-playbook -i hosts playbook.yml
```

Saída com sucesso!
Observação: se você pulou o passo de acesso ao servidor através destes comandos:

```s
ssh -i ~/.ssh/id_rsa_ansible root@172.25.0.2
ssh -i ~/.ssh/id_rsa_ansible root@172.25.0.3
```

Você deverá receber esta pergunta no meio da execução do playbook:

Are you sure you want to continue connecting (yes/no/[fingerprint])? ok: [ansible_host1]
Are you sure you want to continue connecting (yes/no/[fingerprint])? ok: [ansible_host2]

Mais ou menos assim:

```s
PLAY [Testar Ansible no Docker] **********************************************************************

TASK [Gathering Facts] *******************************************************************************
The authenticity of host '172.25.0.3 (172.25.0.3)' can't be established.
ECDSA key fingerprint is SHA256:8kAZ9MNNX93qo8IllhI1+w6I6gfkxn1WWu2lflSJ/yk.
Are you sure you want to continue connecting (yes/no/[fingerprint])? ok: [ansible_host1]
yes
ok: [ansible_host2]

TASK [Instalar pacote 'tree'] ************************************************************************
changed: [ansible_host2]
changed: [ansible_host1]

PLAY RECAP *******************************************************************************************
ansible_host1              : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ansible_host2              : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

Senão a execução será limpa, o mesmo vale se executar o comando `ansible-playbook -i hosts playbook.yml` novamente:


```yml
 ansible-playbook -i hosts playbook.yml

PLAY [Testar Ansible no Docker] **********************************************************************

TASK [Gathering Facts] *******************************************************************************
ok: [ansible_host2]
ok: [ansible_host1]

TASK [Instalar pacote 'tree'] ************************************************************************
ok: [ansible_host2]
ok: [ansible_host1]

PLAY RECAP *******************************************************************************************
ansible_host1              : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
ansible_host2              : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```


Exemplo de verificação no container ansible_host1:

```s
ssh -i ~/.ssh/id_rsa_ansible root@172.25.0.2
root@a66163424b2f:~# tree -L 1 /usr
/usr
├── bin
├── games
├── include
├── lib
├── lib64
├── libexec
├── local
├── sbin
├── share
└── src
```

Pronto, aprendemos como configurar o ambiente Ansible, e testá-lo rapidamente.


## Conclusão

Agora você tem um ambiente de testes configurado com dois servidores Ubuntu, prontos para serem gerenciados pelo Ansible. Sinta-se à vontade para experimentar e modificar os playbooks para aprender mais sobre Ansible e suas capacidades.

Recursos Adicionais

Para mais informações sobre Ansible, consulte a documentação oficial do Ansible.

- Vou iniciar um Tutorial sobre ansible na pasta `docs`