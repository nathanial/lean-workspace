/-
  Raster.FFI.Write - Low-level FFI bindings for image writing
-/

namespace Raster.FFI

/-- Write image as PNG to file -/
@[extern "raster_write_png"]
opaque writePng (path : @& String) (width height channels : UInt32)
    (data : @& ByteArray) : IO Unit

/-- Write image as JPEG to file -/
@[extern "raster_write_jpeg"]
opaque writeJpeg (path : @& String) (width height channels : UInt32)
    (data : @& ByteArray) (quality : UInt8) : IO Unit

/-- Write image as BMP to file -/
@[extern "raster_write_bmp"]
opaque writeBmp (path : @& String) (width height channels : UInt32)
    (data : @& ByteArray) : IO Unit

/-- Encode image to PNG in memory -/
@[extern "raster_encode_png"]
opaque encodePng (width height channels : UInt32) (data : @& ByteArray)
    : IO ByteArray

/-- Encode image to JPEG in memory -/
@[extern "raster_encode_jpeg"]
opaque encodeJpeg (width height channels : UInt32) (data : @& ByteArray)
    (quality : UInt8) : IO ByteArray

end Raster.FFI
