import Raster
import Crucible

namespace Tests.TypeTests

open Crucible
open Raster

testSuite "PixelFormat"

test "gray has 1 channel" :=
  PixelFormat.gray.channels ≡ 1

test "grayA has 2 channels" :=
  PixelFormat.grayA.channels ≡ 2

test "rgb has 3 channels" :=
  PixelFormat.rgb.channels ≡ 3

test "rgba has 4 channels" :=
  PixelFormat.rgba.channels ≡ 4

test "fromChannels roundtrip" := do
  PixelFormat.fromChannels 1 ≡ PixelFormat.gray
  PixelFormat.fromChannels 2 ≡ PixelFormat.grayA
  PixelFormat.fromChannels 3 ≡ PixelFormat.rgb
  PixelFormat.fromChannels 4 ≡ PixelFormat.rgba

testSuite "Image"

test "create produces correct dimensions" := do
  let img := Image.create 10 20 .rgba [255, 0, 0, 255]
  img.width ≡ 10
  img.height ≡ 20
  img.format ≡ PixelFormat.rgba

test "create produces correct data size" := do
  let img := Image.create 10 20 .rgba [255, 0, 0, 255]
  img.data.size ≡ (10 * 20 * 4)

test "create produces valid image" := do
  let img := Image.create 5 5 .rgb [0, 128, 255]
  shouldSatisfy img.isValid "created image should be valid"

test "pixelCount is correct" := do
  let img := Image.create 8 6 .gray [128]
  img.pixelCount ≡ 48

test "expectedDataSize matches actual" := do
  let img := Image.create 4 4 .rgba [0, 0, 0, 255]
  img.expectedDataSize ≡ img.data.size

test "empty image is created correctly" := do
  let img := Image.empty 3 3 .rgb
  img.width ≡ 3
  img.height ≡ 3
  img.data.size ≡ 0



end Tests.TypeTests
