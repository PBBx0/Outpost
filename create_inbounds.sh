#!/bin/bash


function set_parameters {
    port1=$(($RANDOM + 10000))
    port2=$(($port1 + 1))
    long_id1=$(uuid)
    long_id2=$(uuid)
    short_id1=$(openssl rand -hex 8)
    short_id2=$(openssl rand -hex 8)
    
    output="$(sudo docker exec -it outpost x25519)"
    privkey1=$(sed -n "s/^PrivateKey: //p" <<< "$output" | tr -d '\r')
    pubkey1=$(sed -n "s/^Password (PublicKey): //p" <<< "$output" | tr -d '\r')
    output="$(sudo docker exec -it outpost x25519)"
    privkey2=$(sed -n "s/^PrivateKey: //p" <<< "$output" | tr -d '\r')
    pubkey2=$(sed -n "s/^Password (PublicKey): //p" <<< "$output" | tr -d '\r')
}


function create_inbounds {
    echo "
    {
        \"inbounds\": [
            {
                \"tag\": \"VLESS TCP $INBOUND_NAME\",
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
                \"tag\": \"VLESS GRPC $INBOUND_NAME\",
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


INBOUND_NAME=$1
if [ -z "$INBOUND_NAME" ]; then
 INBOUND_NAME="INBOUND_NAME"
fi

set_parameters
create_inbounds
