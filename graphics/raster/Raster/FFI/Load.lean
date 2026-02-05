/-
  Raster.FFI.Load - Low-level FFI bindings for image loading
-/

namespace Raster.FFI

/-- Load image from file path.
    Returns: (data, width, height, channels) or error.
    The data is a ByteArray containing raw pixel data.
    If requestedChannels is 0, uses the image's native channel count. -/
@[extern "raster_load_from_file"]
opaque loadFromFile (path : @& String) (requestedChannels : UInt8)
    : IO (ByteArray × UInt32 × UInt32 × UInt32)

/-- Load image from memory buffer.
    Returns: (data, width, height, channels) or error.
    If requestedChannels is 0, uses the image's native channel count. -/
@[extern "raster_load_from_memory"]
opaque loadFromMemory (buffer : @& ByteArray) (requestedChannels : UInt8)
    : IO (ByteArray × UInt32 × UInt32 × UInt32)

/-- Get info about an image file without loading full pixel data.
    Returns: (width, height, channels) -/
@[extern "raster_info_from_file"]
opaque infoFromFile (path : @& String) : IO (UInt32 × UInt32 × UInt32)

end Raster.FFI
