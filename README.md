# Outpost

Outpost is a lightweight, one-click-deployable outbound VPN node that runs Xray-core in a Docker container.

## Protocols

By default, Outpost listens on:

- One port for **VLESS + TCP + REALITY** connections.
- Another port for **VLESS + gRPC + REALITY** connections.

During setup, it also generates client (or middle-server) outbound configurations.

## Installation

### One-line installation

```bash
sudo bash -c "$(curl -sL https://raw.githubusercontent.com/PBBx0/Outpost/refs/heads/main/outpost.sh)" @ NODE_NAME
```

### Local script

```bash
sudo ./outpost.sh NODE_NAME
```

## Control

Outpost runs as a Docker container named `outpost`.

```bash
sudo docker restart outpost
```

## Usage

### `create_config.sh`

Generates IDs and key pairs, writes them to `/config`, and generates client outbound configurations in a separate file.

### `setup.sh`

- Calls `create_config.sh`
- Creates `docker-compose.yml`
- Starts the container

### `outpost.sh`

Equivalent to `setup.sh`, except the contents of `create_config.sh` are embedded directly into the script. Intended for one-script installation.

### `create_inbounds.sh`

Generates IDs and key pairs and outputs inbound configurations only.

## Structure

The application directory is:

```text
/opt/outpost
```

It contains:

- The active Xray-core configuration
- Generated client (or middle-server) outbound configurations
- Supporting deployment files
