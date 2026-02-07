#!/bin/bash
set -euo pipefail
shopt -s nullglob

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

LEAN_PREFIX="$(lean --print-prefix)"
LUA_VERSION="5.4.7"
SELENE_LUA_DIR="util/selene/native/lua"
SQLITE_VERSION="3470200"
SQLITE_YEAR="2024"
QUARRY_SQLITE_DIR="data/quarry/native/sqlite"

ensure_selene_lua_sources() {
  if [ -f "$SELENE_LUA_DIR/lua.h" ]; then
    return 0
  fi

  echo "Selene Lua sources missing, attempting download of Lua $LUA_VERSION..."
  mkdir -p "$SELENE_LUA_DIR"
  local lua_tar="/tmp/lua.tar.gz"
  local lua_src_dir="/tmp/lua-${LUA_VERSION}"
  local lua_url="https://www.lua.org/ftp/lua-${LUA_VERSION}.tar.gz"

  if ! curl -fsSL -o "$lua_tar" "$lua_url"; then
    echo "warning: failed to download $lua_url" >&2
    return 1
  fi

  rm -rf "$lua_src_dir"
  if ! tar -xzf "$lua_tar" -C /tmp; then
    echo "warning: failed to extract Lua source archive" >&2
    rm -f "$lua_tar"
    return 1
  fi

  cp -f "$lua_src_dir"/src/* "$SELENE_LUA_DIR"/
  rm -f "$lua_tar"
  rm -rf "$lua_src_dir"

  [ -f "$SELENE_LUA_DIR/lua.h" ]
}

ensure_quarry_sqlite_sources() {
  if [ -f "$QUARRY_SQLITE_DIR/sqlite3.c" ]; then
    return 0
  fi

  echo "Quarry SQLite amalgamation missing, attempting download..."
  mkdir -p "$QUARRY_SQLITE_DIR"
  local sqlite_zip="/tmp/sqlite-amalgamation-${SQLITE_VERSION}.zip"
  local sqlite_url="https://www.sqlite.org/${SQLITE_YEAR}/sqlite-amalgamation-${SQLITE_VERSION}.zip"

  if ! curl -fsSL -o "$sqlite_zip" "$sqlite_url"; then
    echo "warning: failed to download $sqlite_url" >&2
    return 1
  fi

  if ! unzip -j -o "$sqlite_zip" -d "$QUARRY_SQLITE_DIR" >/dev/null; then
    echo "warning: failed to extract SQLite amalgamation archive" >&2
    rm -f "$sqlite_zip"
    return 1
  fi

  rm -f "$sqlite_zip"
  [ -f "$QUARRY_SQLITE_DIR/sqlite3.c" ]
}

mkdir -p \
  .native-libs/obj/afferent \
  .native-libs/obj/raster \
  .native-libs/obj/chronos \
  .native-libs/obj/conduit \
  .native-libs/obj/crypt \
  .native-libs/obj/selene \
  .native-libs/obj/terminus \
  .native-libs/obj/parlance \
  .native-libs/obj/jack \
  .native-libs/obj/quarry \
  .native-libs/obj/citadel \
  .native-libs/obj/wisp \
  .native-libs/lib

# Afferent native library
rm -rf .native-libs/obj/afferent
mkdir -p .native-libs/obj/afferent
AFF_SOURCES=(
  graphics/afferent/native/src/common/*.c
  graphics/afferent/native/src/lean_bridge/*.c
  graphics/afferent/native/src/lean_bridge/*.m
  graphics/afferent/native/src/texture.c
  graphics/afferent/native/src/metal/render.m
  graphics/afferent/native/src/metal/window.m
  graphics/afferent/native/src/metal/fragment_compiler.m
)

for src in "${AFF_SOURCES[@]}"; do
  key="${src//\//_}"
  key="${key//./_}"
  obj=".native-libs/obj/afferent/${key}.o"

  if [[ "$src" == *.m ]]; then
    /usr/bin/clang -fobjc-arc -c "$src" -o "$obj" \
      -I"$LEAN_PREFIX/include" \
      -Igraphics/afferent/native/include \
      -Igraphics/afferent/native/src \
      -Igraphics/afferent/native/src/lean_bridge \
      -Igraphics/afferent/native/src/metal \
      -I/opt/homebrew/include \
      -I/opt/homebrew/include/freetype2
  else
    /usr/bin/clang -std=c11 -c "$src" -o "$obj" \
      -I"$LEAN_PREFIX/include" \
      -Igraphics/afferent/native/include \
      -Igraphics/afferent/native/src \
      -Igraphics/afferent/native/src/lean_bridge \
      -Igraphics/afferent/native/src/metal \
      -I/opt/homebrew/include \
      -I/opt/homebrew/include/freetype2
  fi
done

/usr/bin/libtool -static -o .native-libs/lib/libafferent_native.a .native-libs/obj/afferent/*.o

# Raster native library
rm -rf .native-libs/obj/raster
mkdir -p .native-libs/obj/raster
/usr/bin/clang -std=c11 -c graphics/raster/native/src/raster_ffi.c -o .native-libs/obj/raster/raster_ffi.o \
  -I"$LEAN_PREFIX/include" \
  -Igraphics/raster/native/stb
/usr/bin/libtool -static -o .native-libs/lib/libraster_native.a .native-libs/obj/raster/raster_ffi.o

# Chronos native library
rm -rf .native-libs/obj/chronos
mkdir -p .native-libs/obj/chronos
/usr/bin/clang -std=c11 -c util/chronos/ffi/chronos_ffi.c -o .native-libs/obj/chronos/chronos_ffi.o \
  -I"$LEAN_PREFIX/include"
/usr/bin/libtool -static -o .native-libs/lib/libchronos_native.a .native-libs/obj/chronos/chronos_ffi.o

# Conduit native library
rm -rf .native-libs/obj/conduit
mkdir -p .native-libs/obj/conduit
/usr/bin/clang -std=c11 -c util/conduit/native/src/conduit_ffi.c -o .native-libs/obj/conduit/conduit_ffi.o \
  -I"$LEAN_PREFIX/include"
/usr/bin/libtool -static -o .native-libs/lib/libconduit_native.a .native-libs/obj/conduit/conduit_ffi.o

# Crypt native library
rm -rf .native-libs/obj/crypt
mkdir -p .native-libs/obj/crypt
/usr/bin/clang -std=c11 -c util/crypt/ffi/crypt_ffi.c -o .native-libs/obj/crypt/crypt_ffi.o \
  -I"$LEAN_PREFIX/include" \
  -I/opt/homebrew/include
/usr/bin/libtool -static -o .native-libs/lib/libcrypt_native.a .native-libs/obj/crypt/crypt_ffi.o

# Selene native library (vendored Lua + FFI)
rm -rf .native-libs/obj/selene
mkdir -p .native-libs/obj/selene
if ensure_selene_lua_sources; then
  SELENE_LUA_SOURCES=(util/selene/native/lua/*.c)
  for src in "${SELENE_LUA_SOURCES[@]}"; do
    base="$(basename "$src")"
    if [[ "$base" == "lua.c" || "$base" == "luac.c" ]]; then
      continue
    fi

    /usr/bin/clang -std=gnu99 -DLUA_COMPAT_5_3 -c "$src" -o ".native-libs/obj/selene/${base%.c}.o" \
      -I"$SELENE_LUA_DIR"
  done
  /usr/bin/clang -std=gnu99 -c util/selene/native/src/selene_ffi.c -o .native-libs/obj/selene/selene_ffi.o \
    -I"$LEAN_PREFIX/include" \
    -I"$SELENE_LUA_DIR"
  /usr/bin/libtool -static -o .native-libs/lib/libselene_native.a .native-libs/obj/selene/*.o
else
  echo "warning: building stub libselene_native.a (vendored Lua sources unavailable)" >&2
  cat > .native-libs/obj/selene/selene_stub.c <<'EOF'
void selene_native_stub(void) {}
EOF
  /usr/bin/clang -std=c11 -c .native-libs/obj/selene/selene_stub.c -o .native-libs/obj/selene/selene_stub.o
  /usr/bin/libtool -static -o .native-libs/lib/libselene_native.a .native-libs/obj/selene/selene_stub.o
fi

# Terminus native library
rm -rf .native-libs/obj/terminus
mkdir -p .native-libs/obj/terminus
/usr/bin/clang -std=c11 -c graphics/terminus/ffi/terminus.c -o .native-libs/obj/terminus/terminus.o \
  -I"$LEAN_PREFIX/include"
/usr/bin/libtool -static -o .native-libs/lib/libterminus_native.a .native-libs/obj/terminus/terminus.o

# Parlance REPL native library
rm -rf .native-libs/obj/parlance
mkdir -p .native-libs/obj/parlance
/usr/bin/clang -std=c11 -c util/parlance/ffi/parlance_repl.c -o .native-libs/obj/parlance/parlance_repl.o \
  -I"$LEAN_PREFIX/include"
/usr/bin/libtool -static -o .native-libs/lib/libparlance_native.a .native-libs/obj/parlance/parlance_repl.o

# Jack native library
rm -rf .native-libs/obj/jack
mkdir -p .native-libs/obj/jack
/usr/bin/clang -std=c11 -c network/jack/ffi/socket.c -o .native-libs/obj/jack/socket.o \
  -I"$LEAN_PREFIX/include"
/usr/bin/libtool -static -o .native-libs/lib/libjack_native.a .native-libs/obj/jack/socket.o

# Quarry native library (uses vendored SQLite amalgamation)
rm -rf .native-libs/obj/quarry
mkdir -p .native-libs/obj/quarry
if ensure_quarry_sqlite_sources; then
  /usr/bin/clang -std=c11 -c data/quarry/native/src/quarry_ffi.c -o .native-libs/obj/quarry/quarry_ffi.o \
    -I"$LEAN_PREFIX/include" \
    -I"$QUARRY_SQLITE_DIR"
  /usr/bin/clang -std=c11 -c "$QUARRY_SQLITE_DIR/sqlite3.c" -o .native-libs/obj/quarry/sqlite3.o \
    -DSQLITE_THREADSAFE=1 \
    -DSQLITE_ENABLE_COLUMN_METADATA=1 \
    -DSQLITE_ENABLE_FTS5=1 \
    -DSQLITE_ENABLE_RTREE=1 \
    -I"$QUARRY_SQLITE_DIR"
  /usr/bin/libtool -static -o .native-libs/lib/libquarry_native.a \
    .native-libs/obj/quarry/quarry_ffi.o \
    .native-libs/obj/quarry/sqlite3.o
else
  echo "warning: building stub libquarry_native.a (SQLite amalgamation unavailable)" >&2
  cat > .native-libs/obj/quarry/quarry_stub.c <<'EOF'
void quarry_native_stub(void) {}
EOF
  /usr/bin/clang -std=c11 -c .native-libs/obj/quarry/quarry_stub.c -o .native-libs/obj/quarry/quarry_stub.o
  /usr/bin/libtool -static -o .native-libs/lib/libquarry_native.a .native-libs/obj/quarry/quarry_stub.o
fi

# Citadel native library (OpenSSL TLS bindings)
rm -rf .native-libs/obj/citadel
mkdir -p .native-libs/obj/citadel
/usr/bin/clang -std=c11 -c web/citadel/ffi/socket.c -o .native-libs/obj/citadel/socket.o \
  -I"$LEAN_PREFIX/include" \
  -I/opt/homebrew/include \
  -I/opt/homebrew/opt/openssl@3/include
/usr/bin/libtool -static -o .native-libs/lib/libcitadel_native.a .native-libs/obj/citadel/socket.o

# Wisp native library (libcurl bindings)
rm -rf .native-libs/obj/wisp
mkdir -p .native-libs/obj/wisp
/usr/bin/clang -std=c11 -c network/wisp/native/src/wisp_ffi.c -o .native-libs/obj/wisp/wisp_ffi.o \
  -I"$LEAN_PREFIX/include" \
  -Inetwork/wisp/native/include \
  -I/opt/homebrew/include \
  -I/opt/homebrew/opt/curl/include
/usr/bin/libtool -static -o .native-libs/lib/libwisp_native.a .native-libs/obj/wisp/wisp_ffi.o

echo "Built native libs in $ROOT_DIR/.native-libs/lib"
