# Exchange Roadmap

A peer-to-peer local network chat library for Lean 4.

## Phase 1: Core Networking

Foundation for TCP communication.

- [ ] **Socket abstraction** - FFI bindings for BSD sockets (connect, bind, listen, accept, send, recv)
- [ ] **Connection** - Managed TCP connection with read/write operations
- [ ] **Server** - Accept incoming connections on a port
- [ ] **Error handling** - Network error types (ConnectionRefused, Timeout, etc.)

**Milestone:** Can establish TCP connections between two processes.

## Phase 2: Message Protocol

Wire format for communication.

- [ ] **Message types** - Define `Message` structure (type, sender, payload, timestamp)
- [ ] **Serialization** - JSON encoding/decoding for messages
- [ ] **Framing** - Length-prefixed message framing over TCP
- [ ] **Protocol version** - Version negotiation on connect

**Milestone:** Can send and receive structured messages.

## Phase 3: Peer Discovery

Zero-config local network discovery using mDNS.

- [ ] **mDNS FFI** - Bindings to dns_sd.h (macOS) or Avahi (Linux)
- [ ] **Service registration** - Advertise `_exchange._tcp.local`
- [ ] **Service browsing** - Discover other Exchange peers
- [ ] **Peer record** - Name, address, port, metadata

**Milestone:** Peers automatically discover each other on LAN.

## Phase 4: Host/Client API

High-level API for chat sessions.

- [ ] **Host** - Create and manage a chat session
  - [ ] Start/stop session
  - [ ] Accept peer connections
  - [ ] Broadcast messages to all peers
- [ ] **Client** - Connect to a hosted session
  - [ ] Connect/disconnect
  - [ ] Send messages
  - [ ] Receive messages
- [ ] **ExchangeEvent** - Event types (PeerJoined, PeerLeft, Message, Error)
- [ ] **Event callbacks** - Register handlers for events

**Milestone:** Working chat between host and multiple clients.

## Phase 5: Rooms & Presence

Multi-channel and status features.

- [ ] **Room** - Named conversation channels
  - [ ] Create/join/leave rooms
  - [ ] Room-scoped messages
  - [ ] Room membership list
- [ ] **Presence** - User status
  - [ ] Status enum (Online, Away, Busy, Offline)
  - [ ] Status change notifications
  - [ ] Idle detection (optional)

**Milestone:** Multi-room chat with presence indicators.

## Phase 6: Reliability & Polish

Production readiness.

- [ ] **Reconnection** - Auto-reconnect on disconnect
- [ ] **Heartbeat** - Connection health monitoring
- [ ] **Message history** - In-memory recent message buffer
- [ ] **Graceful shutdown** - Clean disconnect notifications
- [ ] **Comprehensive tests** - Unit and integration tests

**Milestone:** Reliable for real-world use.

## Future / Optional

- [ ] **End-to-end encryption** - Diffie-Hellman key exchange + AES
- [ ] **File transfer** - Send files between peers
- [ ] **Typing indicators** - "User is typing..." notifications
- [ ] **Message reactions** - Emoji reactions to messages
- [ ] **Persistence** - Optional message logging to disk

## Dependencies to Consider

| Dependency | Purpose |
|------------|---------|
| `wisp` | Could provide HTTP client patterns (if needed) |
| `chronicle` | Logging |
| `totem` | Config file parsing |
| `chronos` | Timestamps |

## Getting Started

Start with Phase 1. A minimal first PR could implement:

1. Basic socket FFI (`Exchange/FFI/Socket.lean` + `ffi/socket.c`)
2. Simple `Connection` type with `send`/`recv`
3. Echo server test demonstrating bidirectional communication
