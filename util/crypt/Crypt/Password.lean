/-
  Crypt.Password - Argon2id password hashing
-/
import Crypt.Core

namespace Crypt.Password

/-- Memory limit presets (in bytes) -/
def memLimitInteractive : Nat := 67108864    -- 64 MB
def memLimitModerate : Nat := 268435456      -- 256 MB
def memLimitSensitive : Nat := 1073741824    -- 1 GB

/-- Operations limit presets -/
def opsLimitInteractive : Nat := 2
def opsLimitModerate : Nat := 3
def opsLimitSensitive : Nat := 4

/-- Salt size for password hashing (16 bytes) -/
def saltSize : Nat := 16

/-- Default output hash size (32 bytes) -/
def hashSize : Nat := 32

/-- Hash a password using Argon2id (internal with USize). -/
@[extern "crypt_password_hash"]
opaque hashCore (password : @& String) (salt : @& ByteArray)
                (opsLimit : USize) (memLimit : USize) (outLen : USize)
                : IO (Except Crypt.CryptError ByteArray)

/-- Hash a password using Argon2id.
    @param password The password to hash
    @param salt 16-byte salt (use Random.bytes 16 to generate)
    @param opsLimit CPU cost parameter (use opsLimitInteractive for default)
    @param memLimit Memory cost in bytes (use memLimitInteractive for default)
    @param outLen Output hash length (default 32 bytes)
-/
def hash (password : String) (salt : ByteArray)
         (opsLimit : Nat := opsLimitInteractive)
         (memLimit : Nat := memLimitInteractive)
         (outLen : Nat := hashSize) : IO (Except Crypt.CryptError ByteArray) :=
  hashCore password salt opsLimit.toUSize memLimit.toUSize outLen.toUSize

/-- Hash a password for storage (internal with USize). -/
@[extern "crypt_password_hash_str"]
opaque hashStrCore (password : @& String) (opsLimit : USize) (memLimit : USize)
                   : IO (Except Crypt.CryptError String)

/-- Hash a password for storage (includes algorithm params in output).
    Returns a string suitable for storage/comparison.
    Uses Argon2id with interactive parameters. -/
def hashStr (password : String)
            (opsLimit : Nat := opsLimitInteractive)
            (memLimit : Nat := memLimitInteractive) : IO (Except Crypt.CryptError String) :=
  hashStrCore password opsLimit.toUSize memLimit.toUSize

/-- Verify a password against a stored hash string -/
@[extern "crypt_password_verify"]
opaque verify (password : @& String) (storedHash : @& String) : IO Bool

/-- Check if a stored hash needs rehashing (internal with USize). -/
@[extern "crypt_password_needs_rehash"]
opaque needsRehashCore (storedHash : @& String) (opsLimit : USize) (memLimit : USize) : IO Bool

/-- Check if a stored hash needs rehashing (params changed) -/
def needsRehash (storedHash : String)
                (opsLimit : Nat := opsLimitInteractive)
                (memLimit : Nat := memLimitInteractive) : IO Bool :=
  needsRehashCore storedHash opsLimit.toUSize memLimit.toUSize

end Crypt.Password
