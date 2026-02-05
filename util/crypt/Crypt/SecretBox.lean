/-
  Crypt.SecretBox - XChaCha20-Poly1305 symmetric encryption
-/
import Crypt.Core
import Crypt.Random

namespace Crypt.SecretBox

/-- Key size (32 bytes / 256 bits) -/
def keySize : Nat := 32

/-- Nonce size (24 bytes for XChaCha20) -/
def nonceSize : Nat := 24

/-- Authentication tag size (16 bytes) -/
def tagSize : Nat := 16

/-- Opaque type for secret keys (zeroed on finalization) -/
opaque SecretKeyPointed : NonemptyType
def SecretKey := SecretKeyPointed.type
instance : Nonempty SecretKey := SecretKeyPointed.property

/-- Generate a new random secret key -/
@[extern "crypt_secretbox_keygen"]
opaque SecretKey.generate : IO SecretKey

/-- Create a secret key from bytes (must be exactly 32 bytes) -/
@[extern "crypt_secretbox_key_from_bytes"]
opaque SecretKey.fromBytes (bytes : @& ByteArray) : IO (Except Crypt.CryptError SecretKey)

/-- Export key bytes (use carefully - exposes key material) -/
@[extern "crypt_secretbox_key_to_bytes"]
opaque SecretKey.toBytes (key : @& SecretKey) : IO ByteArray

/-- Generate a random nonce for encryption -/
def generateNonce : IO ByteArray := Crypt.Random.bytes nonceSize

/-- Encrypt a message using XChaCha20-Poly1305.
    @param plaintext The message to encrypt
    @param nonce 24-byte nonce (use generateNonce)
    @param key The secret key
    @return Ciphertext with authentication tag appended (plaintext.size + 16 bytes)
-/
@[extern "crypt_secretbox_encrypt"]
opaque encrypt (plaintext : @& ByteArray) (nonce : @& ByteArray) (key : @& SecretKey)
               : IO (Except Crypt.CryptError ByteArray)

/-- Decrypt a message using XChaCha20-Poly1305.
    @param ciphertext The encrypted message (includes auth tag)
    @param nonce The same nonce used for encryption
    @param key The secret key
    @return Original plaintext, or error if authentication fails
-/
@[extern "crypt_secretbox_decrypt"]
opaque decrypt (ciphertext : @& ByteArray) (nonce : @& ByteArray) (key : @& SecretKey)
               : IO (Except Crypt.CryptError ByteArray)

/-- Encrypt with auto-generated nonce prepended to output.
    Convenience function that generates a nonce and prepends it to the ciphertext.
    Output format: [24-byte nonce][ciphertext with tag]
-/
def encryptEasy (plaintext : ByteArray) (key : SecretKey) : IO (Except Crypt.CryptError ByteArray) := do
  let nonce ← generateNonce
  match ← encrypt plaintext nonce key with
  | .ok ciphertext => return .ok (nonce ++ ciphertext)
  | .error e => return .error e

/-- Decrypt message encrypted with encryptEasy.
    Extracts nonce from first 24 bytes.
-/
def decryptEasy (combined : ByteArray) (key : SecretKey) : IO (Except Crypt.CryptError ByteArray) := do
  if combined.size < nonceSize + tagSize then
    return .error (.invalidNonce "Combined ciphertext too short")
  let nonce := combined.extract 0 nonceSize
  let ciphertext := combined.extract nonceSize combined.size
  decrypt ciphertext nonce key

end Crypt.SecretBox
