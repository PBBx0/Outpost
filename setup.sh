#!/bin/bash

sudo apt update -y >/dev/null 2>/dev/null
sudo apt install uuid docker -y >/dev/null 2>/dev/null

sudo docker pull ghcr.io/xtls/xray-core:latest

APP_DIR="/opt/outpost"

sudo ./create_config.sh $1


echo "
services:
  outpost:
    image: ghcr.io/xtls/xray-core:latest
    container_name: outpost
    restart: always
    network_mode: host
    volumes:
      - $APP_DIR/config:/usr/local/etc/xray:ro
" > $APP_DIR/docker-compose.yml

cd $APP_DIR
sudo docker compose up -d
