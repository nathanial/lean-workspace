/-
  Afferent FFI Texture
  Texture loading and sprite rendering bindings.
  Uses raster library for image decoding.
-/
import Afferent.FFI.Types
import Afferent.FFI.FloatBuffer
import Raster

namespace Afferent.FFI

-- Create a texture from already-decoded RGBA pixel data
@[extern "lean_afferent_texture_create_from_rgba"]
private opaque Texture.createFromRGBA (data : @& ByteArray) (width height : UInt32) : IO Texture

-- Load a texture from a file path (supports PNG, JPG, etc)
-- Uses raster library for decoding
def Texture.load (path : String) : IO Texture := do
  let img ← Raster.Image.loadAs path .rgba
  Texture.createFromRGBA img.data img.width.toUInt32 img.height.toUInt32

-- Load a texture from memory (PNG/JPG data in ByteArray)
-- Uses raster library for decoding
def Texture.loadFromMemory (data : ByteArray) : IO Texture := do
  let img ← Raster.Image.loadFromMemoryAs data .rgba
  Texture.createFromRGBA img.data img.width.toUInt32 img.height.toUInt32

-- Create a texture directly from a Raster.Image (must be RGBA format)
def Texture.fromImage (img : Raster.Image) : IO Texture := do
  if img.format != .rgba then
    throw (IO.userError "Texture.fromImage requires RGBA format image")
  Texture.createFromRGBA img.data img.width.toUInt32 img.height.toUInt32

-- Destroy a texture
@[extern "lean_afferent_texture_destroy"]
opaque Texture.destroy (texture : @& Texture) : IO Unit

-- Get texture dimensions (width, height)
@[extern "lean_afferent_texture_get_size"]
opaque Texture.getSize (texture : @& Texture) : IO (UInt32 × UInt32)

-- Draw sprites from FloatBuffer already in SpriteInstanceData layout.
@[extern "lean_afferent_renderer_draw_sprites_instance_buffer"]
opaque Renderer.drawSpritesInstanceBuffer
  (renderer : @& Renderer)
  (texture : @& Texture)
  (buffer : @& FloatBuffer)
  (count : UInt32)
  (canvasWidth : Float)
  (canvasHeight : Float) : IO Unit

/-- Compatibility wrapper for older call sites.
    NOTE: Source UV rectangle parameters are currently ignored. -/
def Renderer.drawTexturedRect
  (renderer : @& Renderer)
  (texture : @& Texture)
  (_srcX _srcY _srcW _srcH : Float)
  (dstX dstY dstW dstH : Float)
  (canvasWidth canvasHeight : Float)
  (alpha : Float) : IO Unit := do
  let centerX := dstX + dstW * 0.5
  let centerY := dstY + dstH * 0.5
  let halfSize := dstW * 0.5
  let buf ← FloatBuffer.create 5
  FloatBuffer.setVec5 buf 0 centerX centerY 0.0 halfSize alpha
  Renderer.drawSpritesInstanceBuffer renderer texture buf 1 canvasWidth canvasHeight
  FloatBuffer.destroy buf

end Afferent.FFI
