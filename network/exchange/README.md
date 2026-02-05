# Exchange

Peer-to-peer local network chat library for Lean 4.

## Features

- mDNS/Bonjour peer discovery
- Direct P2P connections (no central server)
- Rooms/channels for group chat
- Presence status (online/away/offline)
- Event-driven message handling
- (Planned) End-to-end encryption

## Quick Start

```lean
import Exchange

-- Host a chat session
def hostExample : IO Unit := do
  let host <- Exchange.Host.create "MySession"
  host.onEvent fun event => do
    match event with
    | .peerJoined peer => IO.println s!"Welcome {peer.name}!"
    | .message msg => IO.println s!"[{msg.sender}]: {msg.text}"
    | _ => pure ()
  host.start

-- Connect as a client
def clientExample : IO Unit := do
  let peers <- Exchange.discover
  if let some host := peers[0]? then
    let client <- Exchange.Client.connect host
    client.send "Hello everyone!"
```

## Core Concepts

- **Peer**: A node on the network identified by name and address
- **Room**: A conversation channel that peers can join
- **Message**: Text content with sender metadata and timestamp
- **ExchangeEvent**: Incoming events (peerJoined, peerLeft, message, roomCreated)

## Architecture

Exchange uses mDNS (multicast DNS) for zero-configuration peer discovery on local networks. When a host starts a session, it advertises via Bonjour/mDNS. Clients discover available sessions and connect directly via TCP for reliable message delivery.

Key design decisions:
- No central server required - fully decentralized
- TCP for message reliability
- JSON message format for simplicity
- Event-driven API for reactive programming

## Build

```bash
lake build
```

## Test

```bash
lake test
```
