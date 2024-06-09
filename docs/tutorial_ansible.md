# Tutorial 01

## Atualizando o Inventário

O inventário é o arquivo `hosts` que renomeamos para `inventory.yml` onde estão
as máquinas (no nosso caso containers) que serão alterados. 
Como nossos containers podem mudar de IP criamos um script que faz a verificação do IP 
e automaticamente altera o arquivo `inventroy.yml`

O comando mágico é o `sed` que iremos explicar em detalhes:

### Comando sed
O sed é um editor de fluxo (stream editor) utilizado para realizar transformações 
básicas em textos dentro de um arquivo ou fluxo de dados. É frequentemente usado para buscar e substituir texto em arquivos.

### Comando Completo para o Host 1

```s
sed -i "s/ansible_host1 ansible_host=[^ ]*/ansible_host1 ansible_host=$ip_host1/" $inventory_file
```

Este comando sed realiza uma substituição no arquivo $inventory_file. Vamos quebrar isso em partes:

1. sed -i
sed: Chama o editor de fluxo sed.
-i: Inicia o modo de edição "in-place", que significa que as alterações serão feitas diretamente no arquivo original. 
Sem -i, as alterações seriam exibidas na tela, mas não salvas no arquivo.

2. "s/ansible_host1 ansible_host=[^ ]*/ansible_host1 ansible_host=$ip_host1/"
"s/.../.../": É a estrutura básica do comando de substituição no sed. A letra s indica uma substituição. A estrutura geral é s/padrão/substituição/, onde:
padrão: O que você está procurando no texto.
substituição: O que você quer colocar no lugar do padrão.

3. ansible_host1 ansible_host=[^ ]*
ansible_host1 ansible_host=: Este é o início do padrão que estamos procurando. Estamos procurando por "ansible_host1 ansible_host=" no arquivo.

### Entendendo a expressão regular (Regex)

[^ ]*: Esta é a parte mais complexa, uma expressão regular que significa:
[^ ]: Qualquer caractere que não seja um espaço. Os colchetes [] definem uma classe de caracteres, e o ^ dentro dos colchetes indica negação, ou seja, tudo menos espaço.
*: Zero ou mais ocorrências do caractere anterior (neste caso, qualquer caractere que não seja um espaço). 

`Então, [^ ]* significa "qualquer sequência de caracteres que não contenha espaços".`

4. ansible_host1 ansible_host=$ip_host1
ansible_host1 ansible_host=$ip_host1: Este é o texto de substituição. Substituímos a parte 
encontrada no padrão pelo novo valor ansible_host1 ansible_host=$ip_host1, onde $ip_host1 é a variável que contém o novo endereço IP.

### Resumo da Função sed

Busca: Procura por uma linha que contém "ansible_host1 ansible_host=" seguido por qualquer sequência de caracteres que não contenham espaços.
Substitui: Substitui essa sequência por "ansible_host1 ansible_host=" seguido pelo valor da variável `$ip_host1`.

### Aplicação no Arquivo

O comando faz essa substituição diretamente no arquivo especificado por $inventory_file, garantindo que o arquivo é atualizado com o novo endereço IP.

### Comando Completo para o Host 2

```s
sed -i "s/ansible_host2 ansible_host=[^ ]*/ansible_host2 ansible_host=$ip_host2/" $inventory_file
```

## Criando `ansible.cfg`

Agora que temos o ambiente de testes vamos começar criando o arquivo ansible.cfg é usado 
para configurar opções globais para o Ansible. Ele define o inventário padrão, desativa a verificação 
de chave de host e outras opções de configuração.

## Conteúdo de ansible.cfg
Crie um arquivo chamado ansible.cfg no diretório do projeto com o seguinte conteúdo:

```ini
[defaults]
inventory = hosts
host_key_checking = False
log_path = ./execution.log
```

* inventory: Especifica o arquivo de inventário que o Ansible usará por padrão.
* host_key_checking: Desativa a verificação de chave de host SSH, o que é útil para evitar problemas de primeira conexão com hosts desconhecidos.
* log_path: local do arquivo de log
  

## Criar a Estrutura de Diretórios

Vamos supor que quero executar ações comuns, instalar o nvm, golang  e configurar o ssh nas máquinas.
Para criar a estrutura de diretórios para roles, use o comando ansible-galaxy:

```s
ansible-galaxy init roles/common
ansible-galaxy init roles/nvm
ansible-galaxy init roles/golang
ansible-galaxy init roles/ssh
```

Isso criará a estrutura de diretórios padrão para cada role:

```s
roles/
├── common/
│   ├── tasks/
│   │   └── main.yml
│   ├── files/
│   ├── handlers/
│   │   └── main.yml
│   ├── vars/
│   │   └── main.yml
│   ├── templates/
│   ├── meta/
│   │   └── main.yml
│   └── defaults/
│       └── main.yml
├── nvm/
│   ├── tasks/
│   │   └── main.yml
│   ├── files/
│   ├── handlers/
│   │   └── main.yml
│   ├── vars/
│   │   └── main.yml
│   ├── templates/
│   ├── meta/
│   │   └── main.yml
│   └── defaults/
│       └── main.yml
├── golang/
│   ├── tasks/
│   │   └── main.yml
│   ├── files/
│   ├── handlers/
│   │   └── main.yml
│   ├── vars/
│   │   └── main.yml
│   ├── templates/
│   ├── meta/
│   │   └── main.yml
│   └── defaults/
│       └── main.yml
└── ssh/
    ├── tasks/
    │   └── main.yml
    ├── files/
    ├── handlers/
    │   └── main.yml
    ├── vars/
    │   └── main.yml
    ├── templates/
    ├── meta/
    │   └── main.yml
    └── defaults/
        └── main.yml

```

## Configurar as Roles

### Role common

Esta role instalará pacotes básicos necessários em todos os hosts.

roles/common/tasks/main.yml

```yml
---
- name: Atualizar apt e instalar pacotes básicos
  apt:
    name:
      - curl
      - wget
      - git
    state: present
    update_cache: yes
```
Role nvm
Esta role instalará o NVM (Node Version Manager) e o Node.js.

roles/nvm/tasks/main.yml


```yml
---
- name: Baixar script de instalação do NVM
  shell: curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash

- name: Adicionar NVM ao perfil
  lineinfile:
    dest: ~/.bashrc
    regexp: 'export NVM_DIR="\$HOME/.nvm"'
    line: 'export NVM_DIR="$HOME/.nvm"'
    insertafter: EOF

- name: Carregar NVM e instalar Node.js
  shell: |
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install --lts

```

Role golang
Esta role instalará o Golang.

roles/golang/tasks/main.yml

```yml
---
- name: Baixar e instalar Golang
  get_url:
    url: https://golang.org/dl/go1.16.5.linux-amd64.tar.gz
    dest: /tmp/go1.16.5.linux-amd64.tar.gz

- name: Extrair Golang
  unarchive:
    src: /tmp/go1.16.5.linux-amd64.tar.gz
    dest: /usr/local
    remote_src: yes

- name: Adicionar Golang ao perfil
  lineinfile:
    dest: ~/.bashrc
    regexp: 'export PATH=\$PATH:/usr/local/go/bin'
    line: 'export PATH=$PATH:/usr/local/go/bin'
    insertafter: EOF
```

Role ssh
Esta role gerará chaves SSH, copiará as chaves e o arquivo de configuração SSH.

roles/ssh/tasks/main.yml


```yml
---
- name: Gerar chave SSH se não existir
  command: ssh-keygen -t rsa -b 2048 -f /root/.ssh/id_rsa -q -N ""
  args:
    creates: /root/.ssh/id_rsa

- name: Copiar chave pública
  copy:
    content: "{{ lookup('file', '~/.ssh/id_rsa.pub') }}"
    dest: /root/.ssh/authorized_keys

- name: Copiar chave privada
  copy:
    content: "{{ lookup('file', '~/.ssh/id_rsa') }}"
    dest: /root/.ssh/id_rsa
    mode: '0600'

- name: Copiar arquivo de configuração SSH
  copy:
    content: "{{ lookup('file', '~/config') }}"
    dest: /root/.ssh/config
    mode: '0644'
```

Passo 5: Playbook Principal
Crie o arquivo playbook.yml para incluir as roles e variáveis comuns:

playbook.yml

```yml
---
- name: Configurar servidores
  hosts: servers
  become: yes
  vars:
    ssh_key: "{{ lookup('file', '~/.ssh/id_rsa_ansible') }}"
    ssh_pub_key: "{{ lookup('file', '~/.ssh/id_rsa_ansible.pub') }}"
    ssh_config: "{{ lookup('file', '~/config') }}"
  roles:
    - role: common
    - role: nvm
    - role: golang
    - role: ssh
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

Inicie e Verifique a execução dos serviços de SSH

Para garantir que o serviço SSH está ativo e os containers estão acessíveis, use os seguintes comandos:


```s
docker exec -it ansible_host1 service ssh start
docker exec -it ansible_host2 service ssh start
```

e verifique com:

```s
docker exec -it ansible_host1 service ssh status
docker exec -it ansible_host2 service ssh status
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

Resultado do acesso:

```s
ssh -i ~/.ssh/id_rsa_ansible root@172.25.0.2
```


## Execução do Playbook

Como já indicamos no ansible.cfg que o inventário está em `inventrory.yml` basta executarmos:

```s
ansible-playbook playbook.yml
```