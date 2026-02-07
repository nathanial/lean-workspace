import Afferent.Canopy.Reactive

namespace Tracker.GUI

open Afferent.Canopy.Reactive

structure GuiApp where
  render : ComponentRender
  shutdown : IO Unit := pure ()

end Tracker.GUI
