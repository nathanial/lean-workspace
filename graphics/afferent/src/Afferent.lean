-- This module serves as the root of the `Afferent` library.
-- Import modules here that should be built as part of the library.

-- Embedded shader sources
import Afferent.Runtime.Shader.Sources

-- Core types
import Afferent.Core.Types
import Afferent.Core.Path
import Afferent.Core.Transform
import Afferent.Core.Paint

-- Rendering
import Afferent.Graphics.Render.Tessellation
import Afferent.Graphics.Render.Earcut
import Afferent.Graphics.Render.Dynamic
import Afferent.Graphics.Render.Mesh
import Afferent.Graphics.Render.FPSCamera

-- Linear algebra (from Linalg library)
import Linalg

-- Canvas API
import Afferent.Graphics.Canvas.State
import Afferent.Graphics.Canvas.Context

-- Text
import Afferent.Graphics.Text.Font
import Afferent.Graphics.Text.Measurer

-- Layered architecture
import Afferent.Draw
import Afferent.Widget
import Afferent.Output
import Afferent.Runner
import Afferent.UI.Layout

-- Re-export useful Linalg types
namespace Afferent
export Linalg (Vec2 Vec3 Vec4 Mat4 Quat)
-- Note: Linalg.Easing is available as a namespace (e.g., Linalg.Easing.quadInOut)
end Afferent
