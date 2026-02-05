# CLAUDE.md - Crypt

Cryptographic primitives library for Lean 4 using libsodium FFI.

## Build Commands

```bash
lake build           # Build library
lake test            # Run tests
./build.sh           # Check libsodium + build
```

**Requires:** `brew install libsodium`

## Architecture

### Modules

| Module | Purpose |
|--------|---------|
| `Crypt.Core` | Initialization, CryptError type |
| `Crypt.Random` | Secure random bytes (randombytes_buf) |
| `Crypt.Hash` | BLAKE2b hashing (single-shot + streaming) |
| `Crypt.Password` | Argon2id password hashing |
| `Crypt.Auth` | HMAC authentication (crypto_auth) |
| `Crypt.SecretBox` | XChaCha20-Poly1305 symmetric encryption |

### Key Types

- `CryptError` - Error type for crypto operations
- `AuthKey` - Opaque HMAC key (32 bytes, secure finalization)
- `SecretKey` - Opaque encryption key (32 bytes, secure finalization)
- `HashState` - Streaming hash state

### FFI

Uses libsodium via C FFI:
- External classes with secure finalizers (sodium_memzero)
- ByteArray interop via lean_sarray_*
- Except returns for error handling

### File Structure

```
Crypt/
├── Core.lean       # CryptError, init
├── Random.lean     # bytes, uint32
├── Hash.lean       # blake2b, streaming
├── Password.lean   # hash, hashStr, verify
├── Auth.lean       # AuthKey, auth, verify
└── SecretBox.lean  # SecretKey, encrypt, decrypt
ffi/
└── crypt_ffi.c     # libsodium bindings
```

## Dependencies

- **crucible** - Test framework
- **libsodium** - System library (brew install libsodium)

## Usage Examples

```lean
import Crypt

-- Initialize (once)
let _ ← Crypt.init

-- Random bytes
let bytes ← Crypt.Random.bytes 32

-- Hash data
match ← Crypt.Hash.blake2b data with
| .ok hash => ...

-- Password hashing
match ← Crypt.Password.hashStr password with
| .ok stored => ...
let valid ← Crypt.Password.verify password stored

-- Symmetric encryption
let key ← Crypt.SecretBox.SecretKey.generate
match ← Crypt.SecretBox.encryptEasy plaintext key with
| .ok encrypted => ...
```
