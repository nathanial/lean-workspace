#!/bin/bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

LEAN_PREFIX="$(lean --print-prefix)"

mkdir -p .native-libs/obj/afferent .native-libs/obj/raster .native-libs/obj/chronos .native-libs/lib

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

echo "Built native libs in $ROOT_DIR/.native-libs/lib"
