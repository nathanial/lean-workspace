import Raster
import Crucible

namespace RasterTests.TransformTests

open Crucible
open Raster

testSuite "Transform"

test "flipHorizontal preserves dimensions" := do
  let img := Image.create 10 5 .rgba [255, 0, 0, 255]
  let flipped := Transform.flipHorizontal img
  flipped.width ≡ 10
  flipped.height ≡ 5
  flipped.data.size ≡ img.data.size

test "flipVertical preserves dimensions" := do
  let img := Image.create 10 5 .rgb [0, 255, 0]
  let flipped := Transform.flipVertical img
  flipped.width ≡ 10
  flipped.height ≡ 5
  flipped.data.size ≡ img.data.size

test "rotate90 swaps dimensions" := do
  let img := Image.create 10 5 .rgba [0, 0, 255, 255]
  let rotated := Transform.rotate90 img
  rotated.width ≡ 5
  rotated.height ≡ 10
  rotated.data.size ≡ img.data.size

test "rotate180 preserves dimensions" := do
  let img := Image.create 8 6 .rgb [128, 128, 128]
  let rotated := Transform.rotate180 img
  rotated.width ≡ 8
  rotated.height ≡ 6
  rotated.data.size ≡ img.data.size

test "rotate270 swaps dimensions" := do
  let img := Image.create 10 5 .rgba [255, 255, 0, 255]
  let rotated := Transform.rotate270 img
  rotated.width ≡ 5
  rotated.height ≡ 10
  rotated.data.size ≡ img.data.size

test "crop valid region succeeds" := do
  let img := Image.create 10 10 .rgba [255, 0, 0, 255]
  let result := Transform.crop img 2 2 5 5
  match result with
  | .ok cropped =>
    cropped.width ≡ 5
    cropped.height ≡ 5
  | .error _ => shouldSatisfy false "crop should succeed"

test "crop out of bounds fails" := do
  let img := Image.create 10 10 .rgba [255, 0, 0, 255]
  let result := Transform.crop img 8 8 5 5
  match result with
  | .ok _ => shouldSatisfy false "crop should fail"
  | .error e =>
    match e with
    | .outOfBounds _ _ _ _ => pure ()
    | _ => shouldSatisfy false "should be outOfBounds error"

test "crop zero dimensions fails" := do
  let img := Image.create 10 10 .rgb [0, 0, 0]
  let result := Transform.crop img 0 0 0 5
  match result with
  | .ok _ => shouldSatisfy false "crop with zero width should fail"
  | .error _ => pure ()

testSuite "Color"

test "getPixel returns correct values" := do
  let img := Image.create 2 2 .rgba [255, 128, 64, 255]
  match img.getPixel 0 0 with
  | some pixel =>
    pixel.length ≡ 4
    pixel[0]? ≡ some 255
    pixel[1]? ≡ some 128
    pixel[2]? ≡ some 64
    pixel[3]? ≡ some 255
  | none => shouldSatisfy false "getPixel should return value"

test "getPixel out of bounds returns none" := do
  let img := Image.create 5 5 .rgb [0, 0, 0]
  shouldBeNone (img.getPixel 10 10)

test "setPixel modifies correct position" := do
  let img := Image.create 3 3 .rgba [0, 0, 0, 255]
  let modified := img.setPixel 1 1 [255, 255, 255, 255]
  match modified.getPixel 1 1 with
  | some pixel =>
    pixel[0]? ≡ some 255
    pixel[1]? ≡ some 255
    pixel[2]? ≡ some 255
  | none => shouldSatisfy false "setPixel should work"

test "getRed works for rgba" := do
  let img := Image.create 2 2 .rgba [100, 150, 200, 255]
  (img.getRed 0 0) ≡ some 100

test "getGreen works for rgba" := do
  let img := Image.create 2 2 .rgba [100, 150, 200, 255]
  (img.getGreen 0 0) ≡ some 150

test "getBlue works for rgba" := do
  let img := Image.create 2 2 .rgba [100, 150, 200, 255]
  (img.getBlue 0 0) ≡ some 200

test "getAlpha works for rgba" := do
  let img := Image.create 2 2 .rgba [100, 150, 200, 128]
  (img.getAlpha 0 0) ≡ some 128

test "fill changes all pixels" := do
  let img := Image.create 3 3 .rgb [0, 0, 0]
  let filled := img.fill [255, 128, 64]
  match filled.getPixel 1 1 with
  | some pixel =>
    pixel[0]? ≡ some 255
    pixel[1]? ≡ some 128
    pixel[2]? ≡ some 64
  | none => shouldSatisfy false "filled pixel should exist"



end RasterTests.TransformTests
