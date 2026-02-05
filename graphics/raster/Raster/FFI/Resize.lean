/-
  Raster.FFI.Resize - Low-level FFI bindings for image resizing
-/

namespace Raster.FFI

/-- Resize image using stb_image_resize2.
    Uses linear interpolation for high-quality results.
    Returns the resized image data as a ByteArray. -/
@[extern "raster_resize"]
opaque resize (srcData : @& ByteArray)
    (srcWidth srcHeight : UInt32)
    (dstWidth dstHeight : UInt32)
    (channels : UInt8)
    : IO ByteArray

end Raster.FFI
