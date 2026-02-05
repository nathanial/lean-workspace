/-
  Crypt.Hash - BLAKE2b generic hashing
-/
import Crypt.Core

namespace Crypt.Hash

/-- Default hash output size (32 bytes / 256 bits) -/
def defaultSize : Nat := 32

/-- Minimum hash output size (16 bytes) -/
def minSize : Nat := 16

/-- Maximum hash output size (64 bytes) -/
def maxSize : Nat := 64

/-- Compute BLAKE2b hash of input data (internal with USize).
    @param data Input bytes to hash
    @param outLen Output hash length in bytes (16-64, default 32)
    @param key Optional key for keyed hashing (16-64 bytes if provided)
-/
@[extern "crypt_hash_blake2b"]
opaque blake2bCore (data : @& ByteArray) (outLen : USize)
                   (key : @& Option ByteArray) : IO (Except Crypt.CryptError ByteArray)

/-- Compute BLAKE2b hash of input data. -/
def blake2b (data : ByteArray) (outLen : Nat := defaultSize)
            (key : Option ByteArray := none) : IO (Except Crypt.CryptError ByteArray) :=
  blake2bCore data outLen.toUSize key

/-- Compute hash (32 bytes) using BLAKE2b-256 -/
def hash256 (data : ByteArray) : IO (Except Crypt.CryptError ByteArray) :=
  blake2b data 32

/-- Compute hash (64 bytes) using BLAKE2b-512 -/
def hash512 (data : ByteArray) : IO (Except Crypt.CryptError ByteArray) :=
  blake2b data 64

/-- Streaming hash state (opaque handle) -/
opaque HashStatePointed : NonemptyType
def HashState := HashStatePointed.type
instance : Nonempty HashState := HashStatePointed.property

/-- Initialize a streaming hash state (internal with USize) -/
@[extern "crypt_hash_init"]
opaque HashState.initCore (outLen : USize)
                          (key : @& Option ByteArray) : IO (Except Crypt.CryptError HashState)

/-- Initialize a streaming hash state -/
def HashState.init (outLen : Nat := defaultSize)
                   (key : Option ByteArray := none) : IO (Except Crypt.CryptError HashState) :=
  HashState.initCore outLen.toUSize key

/-- Update hash state with more data -/
@[extern "crypt_hash_update"]
opaque HashState.update (state : @& HashState) (data : @& ByteArray) : IO (Except Crypt.CryptError Unit)

/-- Finalize and get the hash -/
@[extern "crypt_hash_final"]
opaque HashState.final (state : @& HashState) : IO (Except Crypt.CryptError ByteArray)

end Crypt.Hash
