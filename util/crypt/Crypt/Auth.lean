/-
  Crypt.Auth - HMAC authentication (crypto_auth)
-/
import Crypt.Core

namespace Crypt.Auth

/-- HMAC key size (32 bytes) -/
def keySize : Nat := 32

/-- HMAC tag size (32 bytes) -/
def tagSize : Nat := 32

/-- Opaque type for authentication keys (zeroed on finalization) -/
opaque AuthKeyPointed : NonemptyType
def AuthKey := AuthKeyPointed.type
instance : Nonempty AuthKey := AuthKeyPointed.property

/-- Generate a new random authentication key -/
@[extern "crypt_auth_keygen"]
opaque AuthKey.generate : IO AuthKey

/-- Create an authentication key from bytes (must be exactly 32 bytes) -/
@[extern "crypt_auth_key_from_bytes"]
opaque AuthKey.fromBytes (bytes : @& ByteArray) : IO (Except Crypt.CryptError AuthKey)

/-- Export key bytes (use carefully - exposes key material) -/
@[extern "crypt_auth_key_to_bytes"]
opaque AuthKey.toBytes (key : @& AuthKey) : IO ByteArray

/-- Compute HMAC authentication tag -/
@[extern "crypt_auth"]
opaque auth (message : @& ByteArray) (key : @& AuthKey) : IO ByteArray

/-- Verify HMAC authentication tag -/
@[extern "crypt_auth_verify"]
opaque verify (tag : @& ByteArray) (message : @& ByteArray) (key : @& AuthKey) : IO Bool

end Crypt.Auth
