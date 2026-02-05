/-
  Tests for Staple.IncludeStr and Staple.IncludeBytes
-/
import Crucible
import Staple.IncludeStr
import Staple.IncludeBytes

namespace Tests.Include

open Crucible
open Staple

testSuite "Staple.Include"

-- Test include_str%
def sampleText : String := include_str% "fixtures/sample.txt"

test "include_str% - reads file content" := do
  sampleText ≡ "Hello, World!"

test "include_str% - preserves exact content" := do
  sampleText.length ≡ 13

-- Test include_bytes%
def sampleBytes : ByteArray := include_bytes% "fixtures/sample.bin"

test "include_bytes% - reads binary content" := do
  sampleBytes.size ≡ 5

test "include_bytes% - preserves byte values" := do
  (sampleBytes.get! 0) ≡ 0
  (sampleBytes.get! 1) ≡ 1
  (sampleBytes.get! 2) ≡ 2
  (sampleBytes.get! 3) ≡ 255
  (sampleBytes.get! 4) ≡ 254



end Tests.Include
