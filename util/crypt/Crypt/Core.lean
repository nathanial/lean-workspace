/-
  Crypt.Core - Initialization and error handling
-/

namespace Crypt

/-- Error type for cryptographic operations -/
inductive CryptError
  | initFailed : String → CryptError
  | invalidKey : String → CryptError
  | invalidNonce : String → CryptError
  | decryptFailed : CryptError
  | hashFailed : String → CryptError
  | passwordHashFailed : String → CryptError
  | verifyFailed : CryptError
  deriving Repr, BEq, Inhabited

instance : ToString CryptError where
  toString
    | .initFailed msg => s!"Initialization failed: {msg}"
    | .invalidKey msg => s!"Invalid key: {msg}"
    | .invalidNonce msg => s!"Invalid nonce: {msg}"
    | .decryptFailed => "Decryption failed: authentication failed"
    | .hashFailed msg => s!"Hash failed: {msg}"
    | .passwordHashFailed msg => s!"Password hash failed: {msg}"
    | .verifyFailed => "Verification failed"

/-- Initialize libsodium. Must be called before any other crypt operations.
    Safe to call multiple times. -/
@[extern "crypt_init"]
opaque init : IO (Except CryptError Unit)

/-- Check if libsodium has been initialized -/
@[extern "crypt_is_initialized"]
opaque isInitialized : IO Bool

end Crypt
