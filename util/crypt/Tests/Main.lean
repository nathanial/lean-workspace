/-
  Crypt Tests - Comprehensive test suite for cryptographic operations
-/

import Crypt
import Crucible

open Crucible
open Crypt

-- ============================================================================
-- Initialization Tests
-- ============================================================================

testSuite "Crypt.Init"

test "init succeeds" := do
  match ← Crypt.init with
  | .ok _ => pure ()
  | .error e => throw (IO.userError s!"Init failed: {e}")

test "isInitialized returns true after init" := do
  let _ ← Crypt.init
  let initialized ← Crypt.isInitialized
  shouldSatisfy initialized "isInitialized should be true"



-- ============================================================================
-- Random Tests
-- ============================================================================

namespace RandomTests

testSuite "Crypt.Random"

test "bytes generates correct length" := do
  let _ ← Crypt.init
  let bytes ← Crypt.Random.bytes 32
  bytes.size ≡ 32

test "bytes generates different values" := do
  let _ ← Crypt.init
  let a ← Crypt.Random.bytes 32
  let b ← Crypt.Random.bytes 32
  shouldSatisfy (a != b) "Random bytes should differ"

test "uint32Uniform stays in range" := do
  let _ ← Crypt.init
  for _ in [:100] do
    let val ← Crypt.Random.uint32Uniform 100
    shouldSatisfy (val < 100) "Value should be < 100"



end RandomTests

-- ============================================================================
-- Hash Tests
-- ============================================================================

namespace HashTests

testSuite "Crypt.Hash"

test "blake2b produces 32-byte hash by default" := do
  let _ ← Crypt.init
  let data := "Hello, World!".toUTF8
  match ← Crypt.Hash.blake2b data with
  | .ok hash => hash.size ≡ 32
  | .error e => throw (IO.userError s!"Hash failed: {e}")

test "blake2b is deterministic" := do
  let _ ← Crypt.init
  let data := "Test data".toUTF8
  match ← Crypt.Hash.blake2b data, ← Crypt.Hash.blake2b data with
  | .ok h1, .ok h2 => shouldSatisfy (h1 == h2) "Hashes should be equal"
  | _, _ => throw (IO.userError "Hash failed")

test "blake2b different inputs produce different hashes" := do
  let _ ← Crypt.init
  match ← Crypt.Hash.blake2b "a".toUTF8, ← Crypt.Hash.blake2b "b".toUTF8 with
  | .ok h1, .ok h2 => shouldSatisfy (h1 != h2) "Hashes should differ"
  | _, _ => throw (IO.userError "Hash failed")

test "blake2b custom length" := do
  let _ ← Crypt.init
  match ← Crypt.Hash.blake2b "data".toUTF8 64 with
  | .ok hash => hash.size ≡ 64
  | .error e => throw (IO.userError s!"Hash failed: {e}")

test "streaming hash matches single-shot" := do
  let _ ← Crypt.init
  let data := "Hello, streaming world!".toUTF8
  match ← Crypt.Hash.blake2b data with
  | .ok expected =>
    match ← Crypt.Hash.HashState.init with
    | .ok state =>
      match ← state.update data with
      | .ok _ =>
        match ← state.final with
        | .ok streamed => shouldSatisfy (streamed == expected) "Streaming hash should match single-shot"
        | .error e => throw (IO.userError s!"Final failed: {e}")
      | .error e => throw (IO.userError s!"Update failed: {e}")
    | .error e => throw (IO.userError s!"Init failed: {e}")
  | .error e => throw (IO.userError s!"Hash failed: {e}")



end HashTests

-- ============================================================================
-- Password Tests
-- ============================================================================

namespace PasswordTests

testSuite "Crypt.Password"

test "hashStr and verify roundtrip" := do
  let _ ← Crypt.init
  let password := "my-secure-password-123!"
  match ← Crypt.Password.hashStr password with
  | .ok stored =>
    let valid ← Crypt.Password.verify password stored
    shouldSatisfy valid "Password should verify"
  | .error e => throw (IO.userError s!"Hash failed: {e}")

test "verify rejects wrong password" := do
  let _ ← Crypt.init
  match ← Crypt.Password.hashStr "correct-password" with
  | .ok stored =>
    let valid ← Crypt.Password.verify "wrong-password" stored
    shouldSatisfy (!valid) "Wrong password should not verify"
  | .error e => throw (IO.userError s!"Hash failed: {e}")

test "hash with explicit salt" := do
  let _ ← Crypt.init
  let salt ← Crypt.Random.bytes 16
  match ← Crypt.Password.hash "password" salt with
  | .ok hash => hash.size ≡ 32
  | .error e => throw (IO.userError s!"Hash failed: {e}")



end PasswordTests

-- ============================================================================
-- Auth Tests
-- ============================================================================

namespace AuthTests

testSuite "Crypt.Auth"

test "auth and verify roundtrip" := do
  let _ ← Crypt.init
  let key ← Crypt.Auth.AuthKey.generate
  let message := "Authenticate this message".toUTF8
  let tag ← Crypt.Auth.auth message key
  let valid ← Crypt.Auth.verify tag message key
  shouldSatisfy valid "Tag should verify"

test "verify rejects modified message" := do
  let _ ← Crypt.init
  let key ← Crypt.Auth.AuthKey.generate
  let message := "Original message".toUTF8
  let tag ← Crypt.Auth.auth message key
  let modified := "Modified message".toUTF8
  let valid ← Crypt.Auth.verify tag modified key
  shouldSatisfy (!valid) "Modified message should not verify"

test "verify rejects wrong key" := do
  let _ ← Crypt.init
  let key1 ← Crypt.Auth.AuthKey.generate
  let key2 ← Crypt.Auth.AuthKey.generate
  let message := "Test message".toUTF8
  let tag ← Crypt.Auth.auth message key1
  let valid ← Crypt.Auth.verify tag message key2
  shouldSatisfy (!valid) "Wrong key should not verify"

test "key roundtrip" := do
  let _ ← Crypt.init
  let key ← Crypt.Auth.AuthKey.generate
  let bytes ← key.toBytes
  match ← Crypt.Auth.AuthKey.fromBytes bytes with
  | .ok key2 =>
    let message := "Test".toUTF8
    let tag1 ← Crypt.Auth.auth message key
    let valid ← Crypt.Auth.verify tag1 message key2
    shouldSatisfy valid "Restored key should work"
  | .error e => throw (IO.userError s!"Key restore failed: {e}")



end AuthTests

-- ============================================================================
-- SecretBox Tests
-- ============================================================================

namespace SecretBoxTests

testSuite "Crypt.SecretBox"

test "encrypt/decrypt roundtrip" := do
  let _ ← Crypt.init
  let key ← Crypt.SecretBox.SecretKey.generate
  let nonce ← Crypt.SecretBox.generateNonce
  let plaintext := "Secret message for encryption".toUTF8
  match ← Crypt.SecretBox.encrypt plaintext nonce key with
  | .ok ciphertext =>
    match ← Crypt.SecretBox.decrypt ciphertext nonce key with
    | .ok decrypted => shouldSatisfy (decrypted == plaintext) "Decrypted should match plaintext"
    | .error e => throw (IO.userError s!"Decrypt failed: {e}")
  | .error e => throw (IO.userError s!"Encrypt failed: {e}")

test "encryptEasy/decryptEasy roundtrip" := do
  let _ ← Crypt.init
  let key ← Crypt.SecretBox.SecretKey.generate
  let plaintext := "Easy mode encryption".toUTF8
  match ← Crypt.SecretBox.encryptEasy plaintext key with
  | .ok encrypted =>
    match ← Crypt.SecretBox.decryptEasy encrypted key with
    | .ok decrypted => shouldSatisfy (decrypted == plaintext) "Decrypted should match plaintext"
    | .error e => throw (IO.userError s!"Decrypt failed: {e}")
  | .error e => throw (IO.userError s!"Encrypt failed: {e}")

test "decrypt rejects tampered ciphertext" := do
  let _ ← Crypt.init
  let key ← Crypt.SecretBox.SecretKey.generate
  let nonce ← Crypt.SecretBox.generateNonce
  let plaintext := "Don't tamper with me".toUTF8
  match ← Crypt.SecretBox.encrypt plaintext nonce key with
  | .ok ciphertext =>
    -- Flip a bit in the ciphertext
    let tampered := ciphertext.set! 0 (ciphertext.get! 0 ^^^ 0xFF)
    match ← Crypt.SecretBox.decrypt tampered nonce key with
    | .ok _ => throw (IO.userError "Should have failed")
    | .error .decryptFailed => pure ()
    | .error e => throw (IO.userError s!"Wrong error: {e}")
  | .error e => throw (IO.userError s!"Encrypt failed: {e}")

test "decrypt rejects wrong key" := do
  let _ ← Crypt.init
  let key1 ← Crypt.SecretBox.SecretKey.generate
  let key2 ← Crypt.SecretBox.SecretKey.generate
  let nonce ← Crypt.SecretBox.generateNonce
  let plaintext := "Secret".toUTF8
  match ← Crypt.SecretBox.encrypt plaintext nonce key1 with
  | .ok ciphertext =>
    match ← Crypt.SecretBox.decrypt ciphertext nonce key2 with
    | .ok _ => throw (IO.userError "Should have failed")
    | .error .decryptFailed => pure ()
    | .error e => throw (IO.userError s!"Wrong error: {e}")
  | .error e => throw (IO.userError s!"Encrypt failed: {e}")

test "ciphertext is larger than plaintext" := do
  let _ ← Crypt.init
  let key ← Crypt.SecretBox.SecretKey.generate
  let nonce ← Crypt.SecretBox.generateNonce
  let plaintext := "Hello".toUTF8
  match ← Crypt.SecretBox.encrypt plaintext nonce key with
  | .ok ciphertext =>
    -- Ciphertext = plaintext + 16-byte MAC
    ciphertext.size ≡ plaintext.size + 16
  | .error e => throw (IO.userError s!"Encrypt failed: {e}")



end SecretBoxTests

-- ============================================================================
-- Main
-- ============================================================================

def main : IO UInt32 := runAllSuites
