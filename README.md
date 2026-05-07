# VaultPeer Signaling Server

A lightweight, robust WebRTC signaling server built with Node.js and `ws`. This server manages WebRTC peer connections using a room-based architecture and includes several production-ready safeguards.

## Features
- **Room-based Signaling:** Peers can join specific rooms. The server automatically routes WebRTC offers, answers, and ICE candidates to all other peers in the same room.
- **Connection Health (Heartbeat):** Implements a standard WebSocket ping/pong interval (every 30 seconds) to detect and terminate dead connections, preventing memory leaks.
- **Payload Limits:** Strict 50KB payload limits on incoming messages to protect against memory exhaustion and DDoS attacks.
- **Graceful Shutdown:** Handles `SIGTERM` and `SIGINT` signals to cleanly shut down active connections before exiting.
- **Docker Ready:** Includes a `Dockerfile` and `docker-compose.yml` for effortless deployment to any server.

## Installation & Running Locally

### Prerequisites
- Node.js 20+

### Setup
```bash
# Clone the repository
git clone https://github.com/mHamzaIqbal1998/VaultPeer-Phonebook.git
cd VaultPeer-Phonebook

# Install dependencies
npm install

# Start the server (defaults to port 8080)
npm start
```
The server will start on `ws://0.0.0.0:8080`.

## Running with Docker (Recommended for Production)

The easiest way to deploy the signaling server is using Docker Compose.

```bash
# Start the container in detached mode
docker compose up -d --build

# View real-time logs
docker compose logs -f
```

## Client Protocol

All WebSocket messages should be sent as JSON strings.

### 1. Joining a Room
To join a room, send a message with `type: 'join'` and a `roomId`.
```json
{
  "type": "join",
  "roomId": "your-room-id"
}
```
The server will acknowledge the join by responding with:
```json
{
  "type": "joined",
  "roomId": "your-room-id",
  "clientId": "abc123",
  "peerCount": 1
}
```

### 2. Heartbeat (Pong)
The server will send a `{"type": "ping"}` payload to every client every 30 seconds. To keep the connection alive, the client **must** respond with:
```json
{
  "type": "pong"
}
```

### 3. WebRTC Signaling
Once joined, any other message sent will be broadcasted to **all other peers** in the same room. For example:
```json
{
  "type": "offer",
  "data": { ...sdp }
}
```

## License

This project is licensed under the [Apache License 2.0](LICENSE).
