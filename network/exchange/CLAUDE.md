# CLAUDE.md

Peer-to-peer local network chat library for Lean 4.

## Status

Early development - core structure exists but implementation is placeholder. See ROADMAP.md for implementation plan.

## Build & Test

```bash
lake build
lake test
```

## Dependencies

- `crucible` - Testing framework
- `jack` - Socket library (planned, for TCP connections)

## Architecture

Exchange enables zero-configuration P2P chat on local networks:

- **mDNS/Bonjour** for peer discovery (no central server)
- **TCP** for reliable message delivery
- **JSON** message format
- **Event-driven** API

### Core Types (Planned)

| Type | Purpose |
|------|---------|
| `Peer` | Network node (name, address) |
| `Room` | Conversation channel |
| `Message` | Text with sender/timestamp metadata |
| `ExchangeEvent` | Events: peerJoined, peerLeft, message, roomCreated |
| `Host` | Creates/manages chat sessions |
| `Client` | Connects to hosted sessions |

### Intended Usage

```lean
-- Host a session
let host <- Exchange.Host.create "MySession"
host.onEvent fun event => ...
host.start

-- Connect as client
let peers <- Exchange.discover
let client <- Exchange.Client.connect peers[0]!
client.send "Hello!"
```

## File Structure

```
Exchange.lean       -- Root import
Exchange/
  Main.lean         -- Core implementation (placeholder)
Tests/
  Main.lean         -- Test suite using crucible
```

## Implementation Phases

1. **Core Networking** - Socket abstraction via jack, TCP connections
2. **Message Protocol** - JSON serialization, length-prefixed framing
3. **Peer Discovery** - mDNS FFI (dns_sd.h on macOS)
4. **Host/Client API** - High-level session management
5. **Rooms & Presence** - Multi-channel, user status
6. **Reliability** - Reconnection, heartbeat, graceful shutdown
