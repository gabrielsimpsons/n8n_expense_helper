#!/bin/bash
apt-get update -y
apt-get install -y docker.io

systemctl start docker
systemctl enable docker

docker network create helpers-network
docker volume create helpers_data 

if [ "$(docker ps -aq -f name=helpers)" ]; then
    docker stop helpers
    docker rm helpers
fi


docker run -d -p 5678:5678 \
    --name workflows \
    -v helpers_data:/home/node/.n8n \
    -e WEBHOOK_URL=${webhook_url} \
    -e N8N_BASIC_AUTH_ACTIVE=true \
    -e N8N_BASIC_AUTH_USER=admin \
    -e N8N_BASIC_AUTH_PASSWORD=${helpers_root_password} \
    -e N8N_HOST=${n8n_host} \
    -e N8N_PORT=5678 \
    -e N8N_PROTOCOL=https \
    -e N8N_TRUSTED_PROXIES=${trusted_proxies} \
    n8nio/n8n

