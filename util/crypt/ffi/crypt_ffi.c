/*
 * Crypt FFI - libsodium bindings for Lean 4
 */

#include <lean/lean.h>
#include <sodium.h>
#include <string.h>
#include <stdlib.h>

/* ============================================================================
 * External Class Registration
 * ============================================================================ */

static lean_external_class* g_hash_state_class = NULL;
static lean_external_class* g_auth_key_class = NULL;
static lean_external_class* g_secret_key_class = NULL;
static int g_initialized = 0;

/* ============================================================================
 * Wrapper Types with Secure Memory
 * ============================================================================ */

typedef struct {
    crypto_generichash_state state;
    size_t outlen;
} HashStateWrapper;

typedef struct {
    unsigned char key[crypto_auth_KEYBYTES];
} AuthKeyWrapper;

typedef struct {
    unsigned char key[crypto_secretbox_KEYBYTES];
} SecretKeyWrapper;

/* ============================================================================
 * Finalizers with secure memory wiping
 * ============================================================================ */

static void hash_state_finalizer(void* ptr) {
    HashStateWrapper* wrapper = (HashStateWrapper*)ptr;
    sodium_memzero(wrapper, sizeof(HashStateWrapper));
    free(wrapper);
}

static void auth_key_finalizer(void* ptr) {
    AuthKeyWrapper* wrapper = (AuthKeyWrapper*)ptr;
    sodium_memzero(wrapper->key, crypto_auth_KEYBYTES);
    free(wrapper);
}

static void secret_key_finalizer(void* ptr) {
    SecretKeyWrapper* wrapper = (SecretKeyWrapper*)ptr;
    sodium_memzero(wrapper->key, crypto_secretbox_KEYBYTES);
    free(wrapper);
}

static void noop_foreach(void* ptr, b_lean_obj_arg f) {
    (void)ptr;
    (void)f;
}

static void init_external_classes(void) {
    if (g_hash_state_class == NULL) {
        g_hash_state_class = lean_register_external_class(hash_state_finalizer, noop_foreach);
        g_auth_key_class = lean_register_external_class(auth_key_finalizer, noop_foreach);
        g_secret_key_class = lean_register_external_class(secret_key_finalizer, noop_foreach);
    }
}

/* ============================================================================
 * Error Helpers
 *
 * CryptError constructors:
 * 0: initFailed (String)
 * 1: invalidKey (String)
 * 2: invalidNonce (String)
 * 3: decryptFailed
 * 4: hashFailed (String)
 * 5: passwordHashFailed (String)
 * 6: verifyFailed
 * ============================================================================ */

static lean_obj_res mk_crypt_error(int tag, const char* msg) {
    lean_object* error;
    if (msg) {
        error = lean_alloc_ctor(tag, 1, 0);
        lean_ctor_set(error, 0, lean_mk_string(msg));
    } else {
        error = lean_alloc_ctor(tag, 0, 0);
    }
    return error;
}

static lean_obj_res mk_except_error(int tag, const char* msg) {
    lean_object* error = mk_crypt_error(tag, msg);
    /* Return Except.error */
    lean_object* except_error = lean_alloc_ctor(0, 1, 0);
    lean_ctor_set(except_error, 0, error);
    return lean_io_result_mk_ok(except_error);
}

static lean_obj_res mk_except_ok(lean_obj_arg value) {
    /* Return Except.ok */
    lean_object* except_ok = lean_alloc_ctor(1, 1, 0);
    lean_ctor_set(except_ok, 0, value);
    return lean_io_result_mk_ok(except_ok);
}

static lean_obj_res mk_except_ok_unit(void) {
    return mk_except_ok(lean_box(0));
}

/* ============================================================================
 * Core: Initialization
 * ============================================================================ */

LEAN_EXPORT lean_obj_res crypt_init(lean_obj_arg world) {
    if (!g_initialized) {
        if (sodium_init() < 0) {
            return mk_except_error(0, "sodium_init() failed");
        }
        init_external_classes();
        g_initialized = 1;
    }
    return mk_except_ok_unit();
}

LEAN_EXPORT lean_obj_res crypt_is_initialized(lean_obj_arg world) {
    return lean_io_result_mk_ok(lean_box(g_initialized ? 1 : 0));
}

/* ============================================================================
 * Random: Secure Random Bytes
 * ============================================================================ */

LEAN_EXPORT lean_obj_res crypt_random_bytes(size_t n, lean_obj_arg world) {
    lean_object* arr = lean_alloc_sarray(1, n, n);
    randombytes_buf(lean_sarray_cptr(arr), n);
    return lean_io_result_mk_ok(arr);
}

LEAN_EXPORT lean_obj_res crypt_random_uint32(lean_obj_arg world) {
    uint32_t val = randombytes_random();
    return lean_io_result_mk_ok(lean_box_uint32(val));
}

LEAN_EXPORT lean_obj_res crypt_random_uint32_uniform(uint32_t upper_bound, lean_obj_arg world) {
    uint32_t val = randombytes_uniform(upper_bound);
    return lean_io_result_mk_ok(lean_box_uint32(val));
}

/* ============================================================================
 * Hash: BLAKE2b
 * ============================================================================ */

LEAN_EXPORT lean_obj_res crypt_hash_blake2b(
    b_lean_obj_arg data,
    size_t outlen,
    b_lean_obj_arg key_opt,  /* Option ByteArray */
    lean_obj_arg world
) {
    size_t data_len = lean_sarray_size(data);
    const uint8_t* data_ptr = lean_sarray_cptr(data);

    /* Validate outlen */
    if (outlen < crypto_generichash_BYTES_MIN || outlen > crypto_generichash_BYTES_MAX) {
        return mk_except_error(4, "Output length must be 16-64 bytes");
    }

    /* Check for key (Option is: none = ctor 0, some = ctor 1 with value) */
    const uint8_t* key_ptr = NULL;
    size_t key_len = 0;

    if (!lean_is_scalar(key_opt) && lean_obj_tag(key_opt) == 1) {
        lean_object* key_arr = lean_ctor_get(key_opt, 0);
        key_len = lean_sarray_size(key_arr);
        if (key_len > 0) {
            if (key_len < crypto_generichash_KEYBYTES_MIN ||
                key_len > crypto_generichash_KEYBYTES_MAX) {
                return mk_except_error(1, "Key length must be 16-64 bytes");
            }
            key_ptr = lean_sarray_cptr(key_arr);
        }
    }

    lean_object* out = lean_alloc_sarray(1, outlen, outlen);

    if (crypto_generichash(lean_sarray_cptr(out), outlen,
                           data_ptr, data_len,
                           key_ptr, key_len) != 0) {
        lean_dec(out);
        return mk_except_error(4, "crypto_generichash failed");
    }

    return mk_except_ok(out);
}

/* Streaming hash state */
LEAN_EXPORT lean_obj_res crypt_hash_init(
    size_t outlen,
    b_lean_obj_arg key_opt,
    lean_obj_arg world
) {
    if (outlen < crypto_generichash_BYTES_MIN || outlen > crypto_generichash_BYTES_MAX) {
        return mk_except_error(4, "Output length must be 16-64 bytes");
    }

    const uint8_t* key_ptr = NULL;
    size_t key_len = 0;

    if (!lean_is_scalar(key_opt) && lean_obj_tag(key_opt) == 1) {
        lean_object* key_arr = lean_ctor_get(key_opt, 0);
        key_len = lean_sarray_size(key_arr);
        if (key_len > 0) {
            if (key_len < crypto_generichash_KEYBYTES_MIN ||
                key_len > crypto_generichash_KEYBYTES_MAX) {
                return mk_except_error(1, "Key length must be 16-64 bytes");
            }
            key_ptr = lean_sarray_cptr(key_arr);
        }
    }

    HashStateWrapper* wrapper = malloc(sizeof(HashStateWrapper));
    if (!wrapper) {
        return mk_except_error(4, "Failed to allocate hash state");
    }
    wrapper->outlen = outlen;

    if (crypto_generichash_init(&wrapper->state, key_ptr, key_len, outlen) != 0) {
        free(wrapper);
        return mk_except_error(4, "crypto_generichash_init failed");
    }

    lean_object* obj = lean_alloc_external(g_hash_state_class, wrapper);
    return mk_except_ok(obj);
}

LEAN_EXPORT lean_obj_res crypt_hash_update(
    b_lean_obj_arg state_obj,
    b_lean_obj_arg data,
    lean_obj_arg world
) {
    HashStateWrapper* wrapper = (HashStateWrapper*)lean_get_external_data(state_obj);
    size_t len = lean_sarray_size(data);
    const uint8_t* ptr = lean_sarray_cptr(data);

    if (crypto_generichash_update(&wrapper->state, ptr, len) != 0) {
        return mk_except_error(4, "crypto_generichash_update failed");
    }

    return mk_except_ok_unit();
}

LEAN_EXPORT lean_obj_res crypt_hash_final(
    b_lean_obj_arg state_obj,
    lean_obj_arg world
) {
    HashStateWrapper* wrapper = (HashStateWrapper*)lean_get_external_data(state_obj);

    lean_object* out = lean_alloc_sarray(1, wrapper->outlen, wrapper->outlen);

    if (crypto_generichash_final(&wrapper->state, lean_sarray_cptr(out), wrapper->outlen) != 0) {
        lean_dec(out);
        return mk_except_error(4, "crypto_generichash_final failed");
    }

    return mk_except_ok(out);
}

/* ============================================================================
 * Password: Argon2id
 * ============================================================================ */

LEAN_EXPORT lean_obj_res crypt_password_hash(
    b_lean_obj_arg password,
    b_lean_obj_arg salt,
    size_t opslimit,
    size_t memlimit,
    size_t outlen,
    lean_obj_arg world
) {
    const char* pwd = lean_string_cstr(password);
    size_t pwd_len = lean_string_size(password) - 1;  /* Exclude null terminator */

    size_t salt_len = lean_sarray_size(salt);
    if (salt_len != crypto_pwhash_SALTBYTES) {
        return mk_except_error(5, "Salt must be 16 bytes");
    }
    const uint8_t* salt_ptr = lean_sarray_cptr(salt);

    lean_object* out = lean_alloc_sarray(1, outlen, outlen);

    if (crypto_pwhash(lean_sarray_cptr(out), outlen,
                      pwd, pwd_len,
                      salt_ptr,
                      opslimit, memlimit,
                      crypto_pwhash_ALG_ARGON2ID13) != 0) {
        lean_dec(out);
        return mk_except_error(5, "crypto_pwhash failed (out of memory?)");
    }

    return mk_except_ok(out);
}

LEAN_EXPORT lean_obj_res crypt_password_hash_str(
    b_lean_obj_arg password,
    size_t opslimit,
    size_t memlimit,
    lean_obj_arg world
) {
    const char* pwd = lean_string_cstr(password);
    size_t pwd_len = lean_string_size(password) - 1;

    char hash[crypto_pwhash_STRBYTES];

    if (crypto_pwhash_str(hash, pwd, pwd_len, opslimit, memlimit) != 0) {
        return mk_except_error(5, "crypto_pwhash_str failed (out of memory?)");
    }

    return mk_except_ok(lean_mk_string(hash));
}

LEAN_EXPORT lean_obj_res crypt_password_verify(
    b_lean_obj_arg password,
    b_lean_obj_arg stored_hash,
    lean_obj_arg world
) {
    const char* pwd = lean_string_cstr(password);
    size_t pwd_len = lean_string_size(password) - 1;
    const char* hash = lean_string_cstr(stored_hash);

    int result = crypto_pwhash_str_verify(hash, pwd, pwd_len);
    return lean_io_result_mk_ok(lean_box(result == 0 ? 1 : 0));
}

LEAN_EXPORT lean_obj_res crypt_password_needs_rehash(
    b_lean_obj_arg stored_hash,
    size_t opslimit,
    size_t memlimit,
    lean_obj_arg world
) {
    const char* hash = lean_string_cstr(stored_hash);
    int result = crypto_pwhash_str_needs_rehash(hash, opslimit, memlimit);
    return lean_io_result_mk_ok(lean_box(result != 0 ? 1 : 0));
}

/* ============================================================================
 * Auth: HMAC (crypto_auth)
 * ============================================================================ */

LEAN_EXPORT lean_obj_res crypt_auth_keygen(lean_obj_arg world) {
    AuthKeyWrapper* wrapper = malloc(sizeof(AuthKeyWrapper));
    if (!wrapper) {
        return lean_io_result_mk_error(lean_mk_io_user_error(
            lean_mk_string("Failed to allocate auth key")));
    }

    crypto_auth_keygen(wrapper->key);

    lean_object* obj = lean_alloc_external(g_auth_key_class, wrapper);
    return lean_io_result_mk_ok(obj);
}

LEAN_EXPORT lean_obj_res crypt_auth_key_from_bytes(
    b_lean_obj_arg bytes,
    lean_obj_arg world
) {
    size_t len = lean_sarray_size(bytes);
    if (len != crypto_auth_KEYBYTES) {
        return mk_except_error(1, "Auth key must be 32 bytes");
    }

    AuthKeyWrapper* wrapper = malloc(sizeof(AuthKeyWrapper));
    if (!wrapper) {
        return mk_except_error(1, "Failed to allocate auth key");
    }

    memcpy(wrapper->key, lean_sarray_cptr(bytes), crypto_auth_KEYBYTES);

    lean_object* obj = lean_alloc_external(g_auth_key_class, wrapper);
    return mk_except_ok(obj);
}

LEAN_EXPORT lean_obj_res crypt_auth_key_to_bytes(
    b_lean_obj_arg key_obj,
    lean_obj_arg world
) {
    AuthKeyWrapper* wrapper = (AuthKeyWrapper*)lean_get_external_data(key_obj);

    lean_object* arr = lean_alloc_sarray(1, crypto_auth_KEYBYTES, crypto_auth_KEYBYTES);
    memcpy(lean_sarray_cptr(arr), wrapper->key, crypto_auth_KEYBYTES);

    return lean_io_result_mk_ok(arr);
}

LEAN_EXPORT lean_obj_res crypt_auth(
    b_lean_obj_arg message,
    b_lean_obj_arg key_obj,
    lean_obj_arg world
) {
    AuthKeyWrapper* wrapper = (AuthKeyWrapper*)lean_get_external_data(key_obj);
    size_t msg_len = lean_sarray_size(message);
    const uint8_t* msg_ptr = lean_sarray_cptr(message);

    lean_object* tag = lean_alloc_sarray(1, crypto_auth_BYTES, crypto_auth_BYTES);

    crypto_auth(lean_sarray_cptr(tag), msg_ptr, msg_len, wrapper->key);

    return lean_io_result_mk_ok(tag);
}

LEAN_EXPORT lean_obj_res crypt_auth_verify(
    b_lean_obj_arg tag,
    b_lean_obj_arg message,
    b_lean_obj_arg key_obj,
    lean_obj_arg world
) {
    if (lean_sarray_size(tag) != crypto_auth_BYTES) {
        return lean_io_result_mk_ok(lean_box(0));
    }

    AuthKeyWrapper* wrapper = (AuthKeyWrapper*)lean_get_external_data(key_obj);
    size_t msg_len = lean_sarray_size(message);
    const uint8_t* msg_ptr = lean_sarray_cptr(message);
    const uint8_t* tag_ptr = lean_sarray_cptr(tag);

    int result = crypto_auth_verify(tag_ptr, msg_ptr, msg_len, wrapper->key);
    return lean_io_result_mk_ok(lean_box(result == 0 ? 1 : 0));
}

/* ============================================================================
 * SecretBox: XChaCha20-Poly1305
 * ============================================================================ */

LEAN_EXPORT lean_obj_res crypt_secretbox_keygen(lean_obj_arg world) {
    SecretKeyWrapper* wrapper = malloc(sizeof(SecretKeyWrapper));
    if (!wrapper) {
        return lean_io_result_mk_error(lean_mk_io_user_error(
            lean_mk_string("Failed to allocate secret key")));
    }

    crypto_secretbox_keygen(wrapper->key);

    lean_object* obj = lean_alloc_external(g_secret_key_class, wrapper);
    return lean_io_result_mk_ok(obj);
}

LEAN_EXPORT lean_obj_res crypt_secretbox_key_from_bytes(
    b_lean_obj_arg bytes,
    lean_obj_arg world
) {
    size_t len = lean_sarray_size(bytes);
    if (len != crypto_secretbox_KEYBYTES) {
        return mk_except_error(1, "Secret key must be 32 bytes");
    }

    SecretKeyWrapper* wrapper = malloc(sizeof(SecretKeyWrapper));
    if (!wrapper) {
        return mk_except_error(1, "Failed to allocate secret key");
    }

    memcpy(wrapper->key, lean_sarray_cptr(bytes), crypto_secretbox_KEYBYTES);

    lean_object* obj = lean_alloc_external(g_secret_key_class, wrapper);
    return mk_except_ok(obj);
}

LEAN_EXPORT lean_obj_res crypt_secretbox_key_to_bytes(
    b_lean_obj_arg key_obj,
    lean_obj_arg world
) {
    SecretKeyWrapper* wrapper = (SecretKeyWrapper*)lean_get_external_data(key_obj);

    lean_object* arr = lean_alloc_sarray(1, crypto_secretbox_KEYBYTES, crypto_secretbox_KEYBYTES);
    memcpy(lean_sarray_cptr(arr), wrapper->key, crypto_secretbox_KEYBYTES);

    return lean_io_result_mk_ok(arr);
}

LEAN_EXPORT lean_obj_res crypt_secretbox_encrypt(
    b_lean_obj_arg plaintext,
    b_lean_obj_arg nonce,
    b_lean_obj_arg key_obj,
    lean_obj_arg world
) {
    size_t nonce_len = lean_sarray_size(nonce);
    if (nonce_len != crypto_secretbox_NONCEBYTES) {
        return mk_except_error(2, "Nonce must be 24 bytes");
    }

    SecretKeyWrapper* wrapper = (SecretKeyWrapper*)lean_get_external_data(key_obj);
    size_t pt_len = lean_sarray_size(plaintext);
    const uint8_t* pt_ptr = lean_sarray_cptr(plaintext);
    const uint8_t* nonce_ptr = lean_sarray_cptr(nonce);

    size_t ct_len = pt_len + crypto_secretbox_MACBYTES;
    lean_object* ciphertext = lean_alloc_sarray(1, ct_len, ct_len);

    if (crypto_secretbox_easy(lean_sarray_cptr(ciphertext), pt_ptr, pt_len,
                              nonce_ptr, wrapper->key) != 0) {
        lean_dec(ciphertext);
        return mk_except_error(3, NULL);  /* Should never happen */
    }

    return mk_except_ok(ciphertext);
}

LEAN_EXPORT lean_obj_res crypt_secretbox_decrypt(
    b_lean_obj_arg ciphertext,
    b_lean_obj_arg nonce,
    b_lean_obj_arg key_obj,
    lean_obj_arg world
) {
    size_t nonce_len = lean_sarray_size(nonce);
    if (nonce_len != crypto_secretbox_NONCEBYTES) {
        return mk_except_error(2, "Nonce must be 24 bytes");
    }

    size_t ct_len = lean_sarray_size(ciphertext);
    if (ct_len < crypto_secretbox_MACBYTES) {
        return mk_except_error(3, NULL);  /* decryptFailed */
    }

    SecretKeyWrapper* wrapper = (SecretKeyWrapper*)lean_get_external_data(key_obj);
    const uint8_t* ct_ptr = lean_sarray_cptr(ciphertext);
    const uint8_t* nonce_ptr = lean_sarray_cptr(nonce);

    size_t pt_len = ct_len - crypto_secretbox_MACBYTES;
    lean_object* plaintext = lean_alloc_sarray(1, pt_len, pt_len);

    if (crypto_secretbox_open_easy(lean_sarray_cptr(plaintext), ct_ptr, ct_len,
                                   nonce_ptr, wrapper->key) != 0) {
        lean_dec(plaintext);
        return mk_except_error(3, NULL);  /* decryptFailed - authentication failed */
    }

    return mk_except_ok(plaintext);
}
