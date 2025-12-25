# Upgrade to Production-Grade Password Hashing

## Summary

The current password hashing uses a simple polynomial hash which is not cryptographically secure. Upgrade to a production-grade algorithm like Argon2 or bcrypt.

## Current State

In `HomebaseApp/Helpers.lean`:

```lean
def polyHash (s : String) : UInt64 :=
  let prime : UInt64 := 31
  let mod : UInt64 := 1000000007
  s.foldl (fun acc c =>
    (acc * prime + c.toNat.toUInt64) % mod
  ) 0

def hashPassword (password : String) : String :=
  let hash := polyHash password
  s!"{hash}"

def verifyPassword (password : String) (hash : String) : Bool :=
  hashPassword password == hash
```

## Problems

1. **Not cryptographically secure**: Polynomial hashing is designed for hash tables, not security
2. **No salt**: Same password always produces same hash (rainbow table vulnerable)
3. **Too fast**: Can be brute-forced quickly
4. **Fixed output size**: Limited entropy in 64-bit output
5. **Collision risk**: Higher probability of collisions

## Requirements

### Recommended Algorithm: Argon2id

- Winner of Password Hashing Competition
- Memory-hard (resistant to GPU attacks)
- Configurable time/memory cost

### Alternative: bcrypt

- Well-established
- Widely available
- Automatic salt handling

### Implementation Options

#### Option 1: FFI to libsodium (Recommended)

```lean
-- Native FFI binding
@[extern "lean_argon2_hash"]
opaque argon2Hash : String → IO String

@[extern "lean_argon2_verify"]
opaque argon2Verify : String → String → IO Bool
```

```c
// ffi/crypto.c
#include <sodium.h>

lean_obj_res lean_argon2_hash(b_lean_obj_arg password) {
    const char* pwd = lean_string_cstr(password);
    char hash[crypto_pwhash_STRBYTES];

    if (crypto_pwhash_str(hash, pwd, strlen(pwd),
        crypto_pwhash_OPSLIMIT_INTERACTIVE,
        crypto_pwhash_MEMLIMIT_INTERACTIVE) != 0) {
        return lean_io_result_mk_error(...);
    }

    return lean_io_result_mk_ok(lean_mk_string(hash));
}

lean_obj_res lean_argon2_verify(b_lean_obj_arg hash, b_lean_obj_arg password) {
    if (crypto_pwhash_str_verify(lean_string_cstr(hash),
        lean_string_cstr(password),
        strlen(lean_string_cstr(password))) == 0) {
        return lean_io_result_mk_ok(lean_box(1)); // true
    }
    return lean_io_result_mk_ok(lean_box(0)); // false
}
```

#### Option 2: Shell out to external tool

```lean
def hashPassword (password : String) : IO String := do
  let result ← IO.Process.output {
    cmd := "python3"
    args := #["-c", s!"import bcrypt; print(bcrypt.hashpw('{password}'.encode(), bcrypt.gensalt()).decode())"]
  }
  return result.stdout.trim
```

(Not recommended for production but works for prototype)

### Migration Strategy

1. Add new hash field `:user/password-hash-v2`
2. On login with old hash:
   - Verify with old algorithm
   - Re-hash with new algorithm
   - Store in v2 field
3. After migration period, remove v1 support

## Acceptance Criteria

- [ ] Passwords hashed with Argon2id or bcrypt
- [ ] Salt automatically included in hash
- [ ] Existing users can still log in (migration path)
- [ ] Hash timing is constant (timing attack resistant)
- [ ] Memory cost appropriate for deployment environment

## Technical Notes

- libsodium is well-maintained and has C API
- bcrypt available via many libraries
- Hash verification must be constant-time
- Consider password strength requirements too

## Priority

**High** - Security vulnerability in current implementation

## Estimate

Medium - FFI integration + testing + migration
