#!/bin/bash

sudo apt update -y >/dev/null 2&>/dev/null
sudo apt install uuid -y >/dev/null 2&>/dev/null
sudo apt install docker -y >/dev/null 2&>/dev/null

sudo docker pull ghcr.io/xtls/xray-core:latest

APP_DIR="/opt/outpost"


if [ -z "$NODE_NAME" ]; then
    NODE_NAME="$1"
fi

if [ -z "$NODE_NAME" ]; then
    NODE_NAME="Node Name"
fi

mkdir -p $APP_DIR/config && cd $APP_DIR


function set_parameters {
    port1=$(($RANDOM + 10000))
    port2=$(($port1 + 1))
    long_id1=$(uuid)
    long_id2=$(uuid)
    short_id1=$(openssl rand -hex 8)
    short_id2=$(openssl rand -hex 8)
    
    output="$(sudo docker run --rm ghcr.io/xtls/xray-core:latest x25519)"
    privkey1=$(sed -n "s/^PrivateKey: //p" <<< "$output" | tr -d '\r')
    pubkey1=$(sed -n "s/^Password (PublicKey): //p" <<< "$output" | tr -d '\r')
    output="$(sudo docker run --rm ghcr.io/xtls/xray-core:latest x25519)"
    privkey2=$(sed -n "s/^PrivateKey: //p" <<< "$output" | tr -d '\r')
    pubkey2=$(sed -n "s/^Password (PublicKey): //p" <<< "$output" | tr -d '\r')

    my_ip=$(hostname -I | cut -d' ' -f1)
}


function set_config_log {
    echo "
    {
        \"log\": {
            \"loglevel\": \"warning\"
        }
    }
	"
}

function set_config_dns {
    echo "
    {
        \"dns\": {
            \"servers\": [
                \"https+local://1.1.1.1/dns-query\",
                \"localhost\"
            ]
        }
    }
    "
}


function set_config_routing {
    echo "
    {
        \"routing\": {
            \"domainStrategy\": \"IPOnDemand\",
            \"rules\": [
                {
                    \"ip\": [
                        \"geoip:private\"
                    ],
                    \"outboundTag\": \"BLOCK\"
                },
                {
                    \"domain\": [
                        \"geosite:private\"
                    ],
                    \"outboundTag\": \"BLOCK\"
                },
                {
                    \"domain\": [
                        \"geosite:category-ads-all\"
                    ],
                    \"outboundTag\": \"BLOCK\"
                },
                {
                    \"protocol\": [
                        \"bittorrent\"
                    ],
                    \"outboundTag\": \"BLOCK\"
                }
            ]
        }
    }
    "
}

function set_config_inbounds {
    echo "
    {
        \"inbounds\": [
            {
                \"tag\": \"VLESS TCP REALITY\",
                \"listen\": \"0.0.0.0\",
                \"port\": $port1,
                \"protocol\": \"vless\",
                \"settings\": {
                    \"clients\": [
                        {
                            \"id\": \"$long_id1\"
                        }
                    ],
                    \"decryption\": \"none\"
                },
                \"streamSettings\": {
                    \"network\": \"tcp\",
                    \"security\": \"reality\",
                    \"realitySettings\": {
                        \"show\": false,
                        \"dest\": \"ya.ru:443\",
                        \"xver\": 0,
                        \"serverNames\": [
                            \"vk.com\",
                            \"ya.ru\"
                        ],
                        \"privateKey\": \"$privkey1\",
                        \"publicKey\": \"$pubkey1\",
                        \"shortIds\": [
                            \"$short_id1\"
                        ]
                    }
                }
            },
            {
                \"tag\": \"VLESS GRPC REALITY\",
                \"listen\": \"0.0.0.0\",
                \"port\": $port2,
                \"protocol\": \"vless\",
                \"settings\": {
                    \"clients\": [
                        {
                            \"id\": \"$long_id2\"
                        }
                    ],
                    \"decryption\": \"none\"
                },
                \"streamSettings\": {
                    \"network\": \"grpc\",
                    \"grpcSettings\": {
                        \"serviceName\": \"xyz\"
                    },
                    \"security\": \"reality\",
                    \"realitySettings\": {
                        \"show\": false,
                        \"dest\": \"ya.ru:443\",
                        \"xver\": 0,
                        \"serverNames\": [
                            \"vk.com\",
                            \"ya.ru\"
                        ],
                        \"privateKey\": \"$privkey2\",
                        \"publicKey\": \"$pubkey2\",
                        \"shortIds\": [
                            \"$short_id2\"
                        ]
                    }
                }
            }
        ]
    }
    "
}

function set_config_outbounds {
    echo "
    {
        \"outbounds\": [
            {
                \"protocol\": \"freedom\", // DEFAULT
                \"tag\": \"DIRECT\"
            },
            {
                \"protocol\": \"blackhole\",
                \"tag\": \"BLOCK\"
            }
        ]
    }
    "
}


function print_client_outbounds_config {
    echo "
    {
        \"tag\": \"VLESS TCP PROXY $NODE_NAME\",
        \"protocol\": \"vless\",
        \"settings\": {
            \"vnext\": [
                {
                    \"address\": \"$my_ip\",
                    \"port\": $port1,
                    \"users\": [
                        {
                            \"id\": \"$long_id1\",
                            \"encryption\": \"none\"
                        }
                    ]
                }
            ]
        },
        \"streamSettings\": {
            \"network\": \"tcp\",
            \"security\": \"reality\",
            \"realitySettings\": {
            	\"show\": false,
                \"fingerprint\": \"chrome\",
                \"serverName\": \"vk.com\",
                \"publicKey\": \"$pubkey1\",
                \"shortId\": \"$short_id1\",
                \"spiderX\": \"\"
            }
        }
    },
    {
        \"tag\": \"VLESS GRPC PROXY $NODE_NAME\",
        \"protocol\": \"vless\",
        \"settings\": {
            \"vnext\": [
                {
                    \"address\": \"$my_ip\",
                    \"port\": $port2,
                    \"users\": [
                        {
                            \"id\": \"$long_id2\",
                            \"encryption\": \"none\"
                        }
                    ]
                }
            ]
        },
        \"streamSettings\": {
            \"network\": \"grpc\",
            \"grpcSettings\": {
                \"serviceName\": \"xyz\"
            },
            \"security\": \"reality\",
            \"realitySettings\": {
                \"show\": false,
                \"fingerprint\": \"chrome\",
                \"serverName\": \"vk.com\",
                \"publicKey\": \"$pubkey2\",
                \"shortId\": \"$short_id2\",
                \"spiderX\": \"\"
            }
        }
    },
    "
}

set_parameters

set_config_log > config/00_log.json
set_config_dns > config/02_dns.json
set_config_routing > config/03_routing.json
set_config_inbounds > config/05_inbounds.json
set_config_outbounds > config/06_outbounds.json

print_client_outbounds_config > client_outbounds.json



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
