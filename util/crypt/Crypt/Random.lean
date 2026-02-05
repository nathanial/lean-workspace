/-
  Crypt.Random - Secure random byte generation
-/
import Crypt.Core

namespace Crypt.Random

/-- Generate cryptographically secure random bytes.
    Uses libsodium's randombytes_buf which sources from /dev/urandom or equivalent. -/
@[extern "crypt_random_bytes"]
opaque bytesCore : (n : USize) → IO ByteArray

/-- Generate cryptographically secure random bytes. -/
def bytes (n : Nat) : IO ByteArray := bytesCore n.toUSize

/-- Generate a random UInt32 -/
@[extern "crypt_random_uint32"]
opaque uint32 : IO UInt32

/-- Generate a random UInt32 in range [0, upper_bound) -/
@[extern "crypt_random_uint32_uniform"]
opaque uint32Uniform : (upperBound : UInt32) → IO UInt32

end Crypt.Random
