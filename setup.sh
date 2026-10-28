#!/bin/bash

if (( EUID != 0 )); then
    echo "Run this script as root" >&2
    exit 1
fi

apt update -y >/dev/null 2>/dev/null
apt install uuid docker -y >/dev/null 2>/dev/null

docker pull ghcr.io/xtls/xray-core:latest

APP_DIR="/opt/outpost"
NODE_NAME="${1:-NODE_NAME}"

./create_config.sh "$NODE_NAME"


echo "
services:
  outpost:
    image: ghcr.io/xtls/xray-core:latest
    container_name: outpost
    restart: always
    network_mode: host
    volumes:
      - $APP_DIR/config:/usr/local/etc/xray:ro
" > "$APP_DIR/docker-compose.yml"

cd "$APP_DIR"
docker compose up -d
