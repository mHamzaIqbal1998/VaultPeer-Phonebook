<p align="center">
  <img src="assets/icon.png" alt="VaultPeer logo" width="96" height="96" />
</p>

# VaultPeer Phonebook

> The WebRTC signaling server for VaultPeer — an open-source, privacy-first KeePass-compatible password manager with live multi-device sync over peer-to-peer connections.

---

## Table of Contents

- [Introduction](#introduction)
- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
- [Client Protocol](#client-protocol)
- [Docker Deployment](#docker-deployment)
- [Configuration](#configuration)
- [Dependencies](#dependencies)
- [Related Projects](#related-projects)
- [Contributing](#contributing)
- [License](#license)

---

## Introduction

VaultPeer is an open-source, privacy-first password manager that gives you full control over your credentials. It stores vaults in the standard **KDBX** format used by KeePass and KeePassXC, encrypts everything at rest, and keeps your data on your device.

Unlike cloud-first password managers, VaultPeer syncs encrypted `.kdbx` vault files directly between your devices over **WebRTC data channels**. **Phonebook** (this repository) is the central signaling server that makes that possible. Every **node** — [desktop](https://github.com/mHamzaIqbal1998/VaultPeer-Desktop), [mobile](https://github.com/mHamzaIqbal1998/VaultPeer-Mobile), or the headless [server node](https://github.com/mHamzaIqbal1998/VaultPeer-ServerNode) — connects to Phonebook, joins a room, discovers the other live nodes, and then establishes direct peer-to-peer connections to sync the vault.

Phonebook is a **facilitator only**. It relays WebRTC connection metadata (offers, answers, ICE candidates) inside rooms. It never sees your decrypted vault contents, master password, or KDBX file data. After nodes discover each other through Phonebook, all vault sync traffic flows directly between peers.

> **Note:** The [server node](https://github.com/mHamzaIqbal1998/VaultPeer-ServerNode) is **not** a signaling server. It is a headless sync node with no UI — it holds the vault file and relays push/pull sync with other nodes. **Only Phonebook handles signaling.**

---

## Features

- **Room-based signaling** — Nodes join a shared room ID to discover other live peers on the same vault.
- **Opaque message relay** — Forwards WebRTC offers, answers, and ICE candidates to all other peers in the room without parsing SDP or vault data.
- **Connection health** — 30-second WebSocket heartbeat (`ping` / `pong`) detects and terminates dead connections.
- **Payload limits** — 50 KB maximum message size protects against memory exhaustion.
- **Graceful shutdown** — Handles `SIGTERM` and `SIGINT` to notify clients and close connections cleanly.
- **Docker ready** — Includes a `Dockerfile` and `docker-compose.yml` for production deployment.
- **No vault storage** — Phonebook does not store passwords, KDBX files, or any user credentials.

---

## Installation

### Prerequisites

- **Node.js 20+** — verify with:

```bash
node --version
```

### Steps

```bash
# 1. Clone the repository
git clone https://github.com/mHamzaIqbal1998/VaultPeer-Phonebook.git

# 2. Go to the cloned directory
cd VaultPeer-Phonebook

# 3. Install dependencies
npm install

# 4. Start the server (defaults to port 8080)
npm start
```

The server listens on `ws://0.0.0.0:8080` by default.

For development with auto-reload:

```bash
npm run dev
```

---

## Usage

1. Deploy Phonebook on a server reachable by all your VaultPeer nodes (locally or on the internet).
2. In each VaultPeer node (desktop, mobile, or server node), open **Settings → Sync** and enter:
   - **Signaling server URL** — e.g. `ws://your-server:8080` or `wss://your-server` behind TLS
   - **Room ID** — a shared identifier for the vault you want to sync (all nodes must use the same room ID and vault filename)
3. Nodes connect to Phonebook, join the room, discover each other, and establish direct WebRTC connections to sync the encrypted KDBX vault.

Phonebook must stay running while nodes are syncing. It does not need to be on the same machine as any node.

---

## Client Protocol

All messages are JSON strings sent over WebSocket.

### Join a room

```json
{
  "type": "join",
  "roomId": "your-room-id"
}
```

Server response:

```json
{
  "type": "joined",
  "roomId": "your-room-id",
  "clientId": "abc123",
  "peerCount": 1
}
```

`peerCount` is the number of **other** peers already in the room.

### Heartbeat

The server sends `{"type": "ping"}` every 30 seconds. Clients must reply:

```json
{
  "type": "pong"
}
```

### WebRTC signaling

After joining, any other message is broadcast to all other peers in the same room:

```json
{
  "type": "offer",
  "data": { }
}
```

Supported signaling types are defined by the VaultPeer node clients. Phonebook forwards them transparently.

### Leave a room

```json
{
  "type": "leave"
}
```

### Peer disconnect notification

When a peer leaves, others receive:

```json
{
  "type": "peer_left",
  "roomId": "your-room-id",
  "clientId": "abc123"
}
```

---

## Docker Deployment

Recommended for production:

```bash
# Build and start in detached mode
docker compose up -d --build

# View logs
docker compose logs -f
```

By default, Docker Compose maps host port **9000** to container port **8080**. Connect nodes to `ws://your-host:9000`.

---

## Configuration

| Variable | Default | Description |
| -------- | ------- | ----------- |
| `PORT`   | `8080`  | WebSocket listen port |

Example:

```bash
PORT=3000 npm start
```

For TLS (`wss://`), terminate TLS at a reverse proxy (e.g. nginx, Caddy) and forward to Phonebook.

---

## Dependencies

- [Node.js](https://nodejs.org/) 20+
- [`ws`](https://github.com/websockets/ws) — WebSocket server

---

## Related Projects

| Project | Description |
| ------- | ----------- |
| [`VaultPeer-Desktop`](https://github.com/mHamzaIqbal1998/VaultPeer-Desktop) | Windows desktop node with UI |
| [`VaultPeer-Mobile`](https://github.com/mHamzaIqbal1998/VaultPeer-Mobile) | Mobile node with UI |
| [`VaultPeer-ServerNode`](https://github.com/mHamzaIqbal1998/VaultPeer-ServerNode) | Headless sync node — no UI; holds the vault and relays push/pull to other nodes |
| [`VaultPeer-Phonebook`](https://github.com/mHamzaIqbal1998/VaultPeer-Phonebook) | WebRTC signaling server for room join and peer discovery (this repository) |

All nodes share the same sync protocol and KDBX vault format. Only Phonebook handles signaling; every other component is a peer node.

---

## Contributing

We welcome contributions. See [`CONTRIBUTING.md`](./CONTRIBUTING.md) for the development workflow.

---

## License

This project is licensed under the Apache License, Version 2.0. See the [LICENSE](./LICENSE) file for details.
