#!/bin/bash

# Autor: Marcelo Facio Palin
# Data de criação: 09/06/2024
# Descrição: Este script inspeciona e imprime os 
# endereços IP dos containers Docker ansible_host1 e ansible_host2.
# Em seguida, atualiza o arquivo inventory.yml com os novos IPs.

# Requisitos:
# Containers Docker ansible_host1 e ansible_host2 devem estar em execução.

# Execução:
# chmod +x s_inspeciona_ips_hosts.sh
# ./s_inspeciona_ips_hosts.sh

# Função para verificar se um container está rodando
check_container_running() {
    container_name=$1
    if [ "$(docker ps -q -f name=$container_name)" ]; then
        return 0  # Container está rodando
    else
        return 1  # Container não está rodando
    fi
}

# Verificando se os containers estão rodando
if ! check_container_running ansible_host1; then
    echo "O container ansible_host1 não está rodando. Execute 'docker-compose up -d' para iniciar os containers."
    exit 1
fi

if ! check_container_running ansible_host2; then
    echo "O container ansible_host2 não está rodando. Execute 'docker-compose up -d' para iniciar os containers."
    exit 1
fi

# Inspecionando o IP do Host1
echo "Inspecionando o IP do Host1"
ip_host1=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ansible_host1)
echo "IP do Host1: $ip_host1"

# Inspecionando o IP do Host2
echo "Inspecionando o IP do Host2"
ip_host2=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ansible_host2)
echo "IP do Host2: $ip_host2"

# Caminho para o arquivo inventory.yml
inventory_file="inventory.yml"

# Atualizando os IPs no arquivo inventory.yml
echo "Atualizando o arquivo $inventory_file com os novos IPs"

sed -i "s/ansible_host1 ansible_host=[^ ]*/ansible_host1 ansible_host=$ip_host1/" $inventory_file
sed -i "s/ansible_host2 ansible_host=[^ ]*/ansible_host2 ansible_host=$ip_host2/" $inventory_file

echo "Arquivo $inventory_file atualizado com sucesso"
