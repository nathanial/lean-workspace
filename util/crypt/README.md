# Crypt

Cryptographic primitives library for Lean 4, providing libsodium bindings.

## Features

- **Secure Random** - Cryptographically secure random bytes
- **Hashing** - BLAKE2b (16-64 byte output, optional keyed hashing)
- **Password Hashing** - Argon2id with configurable memory/CPU cost
- **HMAC** - Message authentication codes
- **Symmetric Encryption** - XChaCha20-Poly1305 authenticated encryption

## Requirements

- Lean 4.26.0
- libsodium (`brew install libsodium` on macOS)

## Installation

Add to your `lakefile.lean`:

```lean
require crypt from git "https://github.com/nathanial/crypt" @ "v0.0.1"
```

## Quick Start

```lean
import Crypt

def main : IO Unit := do
  -- Initialize libsodium (required once)
  let _ ← Crypt.init

  -- Generate random bytes
  let randomBytes ← Crypt.Random.bytes 32
  IO.println s!"Generated {randomBytes.size} random bytes"

  -- Hash data
  let data := "Hello, World!".toUTF8
  match ← Crypt.Hash.blake2b data with
  | .ok hash => IO.println s!"Hash: {hash.size} bytes"
  | .error e => IO.println s!"Error: {e}"

  -- Password hashing (for user authentication)
  let password := "my-secure-password"
  match ← Crypt.Password.hashStr password with
  | .ok storedHash =>
    -- Store `storedHash` in database
    let isValid ← Crypt.Password.verify password storedHash
    IO.println s!"Password valid: {isValid}"
  | .error e => IO.println s!"Error: {e}"

  -- Symmetric encryption
  let key ← Crypt.SecretBox.SecretKey.generate
  let plaintext := "Secret message".toUTF8
  match ← Crypt.SecretBox.encryptEasy plaintext key with
  | .ok encrypted =>
    match ← Crypt.SecretBox.decryptEasy encrypted key with
    | .ok decrypted => IO.println "Encryption roundtrip successful!"
    | .error _ => IO.println "Decryption failed"
  | .error e => IO.println s!"Encryption error: {e}"
```

## API Reference

### Crypt.Random

```lean
Crypt.Random.bytes (n : Nat) : IO ByteArray
Crypt.Random.uint32 : IO UInt32
Crypt.Random.uint32Uniform (upperBound : UInt32) : IO UInt32
```

### Crypt.Hash

```lean
Crypt.Hash.blake2b (data : ByteArray) (outLen : Nat := 32)
                   (key : Option ByteArray := none) : IO (Except CryptError ByteArray)
Crypt.Hash.hash256 (data : ByteArray) : IO (Except CryptError ByteArray)
Crypt.Hash.hash512 (data : ByteArray) : IO (Except CryptError ByteArray)

-- Streaming API
Crypt.Hash.HashState.init (outLen : Nat := 32) : IO (Except CryptError HashState)
HashState.update (data : ByteArray) : IO (Except CryptError Unit)
HashState.final : IO (Except CryptError ByteArray)
```

### Crypt.Password

```lean
-- For storage (includes algorithm parameters)
Crypt.Password.hashStr (password : String) : IO (Except CryptError String)
Crypt.Password.verify (password : String) (storedHash : String) : IO Bool

-- Raw hash with explicit salt
Crypt.Password.hash (password : String) (salt : ByteArray) : IO (Except CryptError ByteArray)
```

### Crypt.Auth

```lean
Crypt.Auth.AuthKey.generate : IO AuthKey
Crypt.Auth.auth (message : ByteArray) (key : AuthKey) : IO ByteArray
Crypt.Auth.verify (tag : ByteArray) (message : ByteArray) (key : AuthKey) : IO Bool
```

### Crypt.SecretBox

```lean
Crypt.SecretBox.SecretKey.generate : IO SecretKey
Crypt.SecretBox.generateNonce : IO ByteArray

-- Manual nonce management
Crypt.SecretBox.encrypt (plaintext nonce : ByteArray) (key : SecretKey) : IO (Except CryptError ByteArray)
Crypt.SecretBox.decrypt (ciphertext nonce : ByteArray) (key : SecretKey) : IO (Except CryptError ByteArray)

-- Automatic nonce (prepended to ciphertext)
Crypt.SecretBox.encryptEasy (plaintext : ByteArray) (key : SecretKey) : IO (Except CryptError ByteArray)
Crypt.SecretBox.decryptEasy (combined : ByteArray) (key : SecretKey) : IO (Except CryptError ByteArray)
```

## Security Notes

- Keys are securely wiped from memory when finalized (sodium_memzero)
- Password hashing uses Argon2id with safe defaults
- Encryption uses XChaCha20-Poly1305 (authenticated encryption)
- All random generation uses libsodium's secure RNG

## License

MIT License
