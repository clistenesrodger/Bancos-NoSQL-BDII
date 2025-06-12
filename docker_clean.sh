#!/bin/bash

echo "=== Parando todos os containers em execução ==="
docker stop $(docker ps -q)

echo "=== Removendo todos os containers ==="
docker rm $(docker ps -aq)

echo "=== Removendo todas as imagens ==="
docker rmi -f $(docker images -q)

echo "=== Removendo todos os volumes ==="
docker volume rm $(docker volume ls -q)

echo "=== Removendo todas as redes não utilizadas ==="
docker network prune -f

echo "=== Fazendo limpeza geral do sistema Docker ==="
docker system prune -a --volumes -f

echo "=== Limpeza concluída com sucesso! ==="
docker system df
