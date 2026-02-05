#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

LEAN_PREFIX="$(lean --print-prefix)"

mkdir -p \
  .native-libs/obj/afferent \
  .native-libs/obj/raster \
  .native-libs/obj/chronos \
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

# Jack native library
rm -rf .native-libs/obj/jack
mkdir -p .native-libs/obj/jack
/usr/bin/clang -std=c11 -c network/jack/ffi/socket.c -o .native-libs/obj/jack/socket.o \
  -I"$LEAN_PREFIX/include"
/usr/bin/libtool -static -o .native-libs/lib/libjack_native.a .native-libs/obj/jack/socket.o

# Quarry native library (uses vendored SQLite amalgamation)
rm -rf .native-libs/obj/quarry
mkdir -p .native-libs/obj/quarry
/usr/bin/clang -std=c11 -c data/quarry/native/src/quarry_ffi.c -o .native-libs/obj/quarry/quarry_ffi.o \
  -I"$LEAN_PREFIX/include" \
  -Idata/quarry/native/sqlite
/usr/bin/clang -std=c11 -c data/quarry/native/sqlite/sqlite3.c -o .native-libs/obj/quarry/sqlite3.o \
  -DSQLITE_THREADSAFE=1 \
  -DSQLITE_ENABLE_COLUMN_METADATA=1 \
  -Idata/quarry/native/sqlite
/usr/bin/libtool -static -o .native-libs/lib/libquarry_native.a \
  .native-libs/obj/quarry/quarry_ffi.o \
  .native-libs/obj/quarry/sqlite3.o

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
