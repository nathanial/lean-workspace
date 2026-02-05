/-
  Crypt - Cryptographic primitives for Lean 4

  Provides libsodium bindings for common cryptographic operations:
  - Secure random number generation
  - BLAKE2b hashing
  - Argon2id password hashing
  - HMAC authentication
  - XChaCha20-Poly1305 symmetric encryption

  ## Quick Start

  ```lean
  import Crypt

  def main : IO Unit := do
    -- Initialize libsodium (required once)
    let _ ← Crypt.init

    -- Generate random bytes
    let randomBytes ← Crypt.Random.bytes 32

    -- Hash data
    let data := "Hello, World!".toUTF8
    match ← Crypt.Hash.blake2b data with
    | .ok hash => IO.println s!"Hash size: {hash.size}"
    | .error e => IO.println s!"Error: {e}"

    -- Password hashing
    match ← Crypt.Password.hashStr "mypassword" with
    | .ok stored =>
      let valid ← Crypt.Password.verify "mypassword" stored
      IO.println s!"Password valid: {valid}"
    | .error e => IO.println s!"Error: {e}"

    -- Symmetric encryption
    let key ← Crypt.SecretBox.SecretKey.generate
    let plaintext := "Secret message".toUTF8
    match ← Crypt.SecretBox.encryptEasy plaintext key with
    | .ok encrypted =>
      match ← Crypt.SecretBox.decryptEasy encrypted key with
      | .ok decrypted => IO.println "Roundtrip successful!"
      | .error e => IO.println s!"Decrypt error: {e}"
    | .error e => IO.println s!"Encrypt error: {e}"
  ```
-/

import Crypt.Core
import Crypt.Random
import Crypt.Hash
import Crypt.Password
import Crypt.Auth
import Crypt.SecretBox

-- Types and functions are already exported in Crypt namespace from submodules
