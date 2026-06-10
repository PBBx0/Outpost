# Outpost
Outpost is a lightweight oneclick-deployable outbound VPN node that runs Xray-core in a docker container.

## Protocols
By default outpost listens on one port for VLESS + TCP + REALITY connections and on the other for VLESS + GRPC + REALITY.
On creation it also writes client (or middleserver) outbounds' configs.

## Usage

`sudo bash -c "$(curl -sL link)" @ NODE_NAME`

or

`sudo ./outpost.sh NODE_NAME`

## Structure
App directory is `/opt/outpost`. It contains the running core configuration as well as the client (or middleserver) outbounds' configs.

