import Lake
open Lake DSL

package lean_workspace where
  version := v!"0.1.0"

require batteries from git "https://github.com/leanprover-community/batteries" @ "v4.26.0"
-- Auto-generated one-library-per-project layout (fast monorepo cutover).

lean_lib apps_agent_mail where
  srcDir := "apps/agent-mail"
  roots := #[`AgentMail]

lean_lib apps_ask where
  srcDir := "apps/ask"
  roots := #[`Main]

lean_lib apps_blockfall where
  srcDir := "apps/blockfall"
  roots := #[`Blockfall]

lean_lib apps_cairn where
  srcDir := "apps/cairn"
  roots := #[`Cairn]

lean_lib apps_chatline where
  srcDir := "apps/chatline"
  roots := #[`Uchatline]

lean_lib apps_enchiridion where
  srcDir := "apps/enchiridion"
  roots := #[`Enchiridion]

lean_lib apps_eschaton where
  srcDir := "apps/eschaton"
  roots := #[`Eschaton]

lean_lib apps_homebase_app where
  srcDir := "apps/homebase-app"
  roots := #[`HomebaseApp]

lean_lib apps_image_gen where
  srcDir := "apps/image-gen"
  roots := #[`ImageGen]

lean_lib apps_lighthouse where
  srcDir := "apps/lighthouse"
  roots := #[`Lighthouse]

lean_lib apps_minefield where
  srcDir := "apps/minefield"
  roots := #[`Minefield]

lean_lib apps_solitaire where
  srcDir := "apps/solitaire"
  roots := #[`Solitaire]

lean_lib apps_timekeeper where
  srcDir := "apps/timekeeper"
  roots := #[`Timekeeper]

lean_lib apps_todo_app where
  srcDir := "apps/todo-app"
  roots := #[`TodoApp]

lean_lib apps_tracker where
  srcDir := "apps/tracker"
  roots := #[`Tracker]

lean_lib apps_twenty48 where
  srcDir := "apps/twenty48"
  roots := #[`Twenty48]

lean_lib audio_fugue where
  srcDir := "audio/fugue"
  roots := #[`Fugue]

lean_lib data_cellar where
  srcDir := "data/cellar"
  roots := #[`Cellar]

lean_lib data_chisel where
  srcDir := "data/chisel"
  roots := #[`Chisel]

lean_lib data_collimator where
  srcDir := "data/collimator"
  roots := #[`Collimator]

lean_lib data_convergent where
  srcDir := "data/convergent"
  roots := #[`Convergent]

lean_lib data_entity where
  srcDir := "data/entity"
  roots := #[`Entity]

lean_lib data_ledger where
  srcDir := "data/ledger"
  roots := #[`Ledger]

lean_lib data_quarry where
  srcDir := "data/quarry"
  roots := #[`Quarry]

lean_lib data_reactive where
  srcDir := "data/reactive"
  roots := #[`Reactive]

lean_lib data_tabular where
  srcDir := "data/tabular"
  roots := #[`Tabular]

lean_lib data_tileset where
  srcDir := "data/tileset"
  roots := #[`Tileset]

lean_lib data_totem where
  srcDir := "data/totem"
  roots := #[`Totem]

lean_lib graphics_afferent where
  srcDir := "graphics/afferent"
  roots := #[`Afferent]

lean_lib graphics_afferent_buttons where
  srcDir := "graphics/afferent-buttons"
  roots := #[`AfferentButtons]

lean_lib graphics_afferent_charts where
  srcDir := "graphics/afferent-charts"
  roots := #[`AfferentCharts]

lean_lib graphics_afferent_chat where
  srcDir := "graphics/afferent-chat"
  roots := #[`AfferentChat]

lean_lib graphics_afferent_demos where
  srcDir := "graphics/afferent-demos"
  roots := #[`Demos]

lean_lib graphics_afferent_math where
  srcDir := "graphics/afferent-math"
  roots := #[`AfferentMath]

lean_lib graphics_afferent_progress_bars where
  srcDir := "graphics/afferent-progress-bars"
  roots := #[`AfferentProgressBars]

lean_lib graphics_afferent_spinners where
  srcDir := "graphics/afferent-spinners"
  roots := #[`AfferentSpinners]

lean_lib graphics_afferent_text_inputs where
  srcDir := "graphics/afferent-text-inputs"
  roots := #[`AfferentTextInputs]

lean_lib graphics_afferent_time_picker where
  srcDir := "graphics/afferent-time-picker"
  roots := #[`AfferentTimePicker]

lean_lib graphics_afferent_worldmap where
  srcDir := "graphics/afferent-worldmap"
  roots := #[`AfferentWorldmap]

lean_lib graphics_assimptor where
  srcDir := "graphics/assimptor"
  roots := #[`Assimptor]

lean_lib graphics_chroma where
  srcDir := "graphics/chroma"
  roots := #[`Chroma]

lean_lib graphics_grove where
  srcDir := "graphics/grove"
  roots := #[`Grove]

lean_lib graphics_raster where
  srcDir := "graphics/raster"
  roots := #[`Raster]

lean_lib graphics_shader where
  srcDir := "graphics/shader"
  roots := #[`Shader]

lean_lib graphics_terminus where
  srcDir := "graphics/terminus"
  roots := #[`Terminus]

lean_lib graphics_tincture where
  srcDir := "graphics/tincture"
  roots := #[`Tincture]

lean_lib graphics_trellis where
  srcDir := "graphics/trellis"
  roots := #[`Trellis]

lean_lib graphics_vane where
  srcDir := "graphics/vane"
  roots := #[`Vane]

lean_lib graphics_worldmap where
  srcDir := "graphics/worldmap"
  roots := #[`Worldmap]

lean_lib math_linalg where
  srcDir := "math/linalg"
  roots := #[`Linalg]

lean_lib math_measures where
  srcDir := "math/measures"
  roots := #[`Measures]

lean_lib network_exchange where
  srcDir := "network/exchange"
  roots := #[`Exchange]

lean_lib network_jack where
  srcDir := "network/jack"
  roots := #[`Jack]

lean_lib network_legate where
  srcDir := "network/legate"
  roots := #[`Legate]

lean_lib network_oracle where
  srcDir := "network/oracle"
  roots := #[`Oracle]

lean_lib network_protolean where
  srcDir := "network/protolean"
  roots := #[`Protolean]

lean_lib network_wisp where
  srcDir := "network/wisp"
  roots := #[`Wisp]

lean_lib testing_crucible where
  srcDir := "testing/crucible"
  roots := #[`Crucible]

lean_lib util_chronos where
  srcDir := "util/chronos"
  roots := #[`Chronos]

lean_lib util_conduit where
  srcDir := "util/conduit"
  roots := #[`Conduit]

lean_lib util_crypt where
  srcDir := "util/crypt"
  roots := #[`Crypt]

lean_lib util_docgen where
  srcDir := "util/docgen"
  roots := #[`Docgen]

lean_lib util_parlance where
  srcDir := "util/parlance"
  roots := #[`Parlance]

lean_lib util_rune where
  srcDir := "util/rune"
  roots := #[`Rune]

lean_lib util_selene where
  srcDir := "util/selene"
  roots := #[`Selene]

lean_lib util_sift where
  srcDir := "util/sift"
  roots := #[`Sift]

lean_lib util_smalltalk where
  srcDir := "util/smalltalk"
  roots := #[`Smalltalk]

lean_lib util_staple where
  srcDir := "util/staple"
  roots := #[`Staple]

lean_lib util_tracer where
  srcDir := "util/tracer"
  roots := #[`Tracer]

lean_lib web_chronicle where
  srcDir := "web/chronicle"
  roots := #[`Chronicle]

lean_lib web_citadel where
  srcDir := "web/citadel"
  roots := #[`Citadel]

lean_lib web_docsite where
  srcDir := "web/docsite"
  roots := #[`Docsite]

lean_lib web_herald where
  srcDir := "web/herald"
  roots := #[`Herald]

lean_lib web_loom where
  srcDir := "web/loom"
  roots := #[`Loom]

lean_lib web_markup where
  srcDir := "web/markup"
  roots := #[`Markup]

lean_lib web_scribe where
  srcDir := "web/scribe"
  roots := #[`Scribe]

lean_lib web_stencil where
  srcDir := "web/stencil"
  roots := #[`Stencil]

lean_exe workspace_smoke where
  root := `WorkspaceSmoke

lean_exe afferent_demos where
  srcDir := "graphics/afferent-demos"
  root := `AfferentDemos.Main
  moreLinkArgs := #[
    ".native-libs/lib/libafferent_native.a",
    ".native-libs/lib/libraster_native.a",
    ".native-libs/lib/libchronos_native.a",
    "-L/opt/homebrew/lib",
    "-framework", "Cocoa",
    "-framework", "Metal",
    "-framework", "MetalKit",
    "-framework", "QuartzCore",
    "-framework", "CoreText",
    "-framework", "CoreGraphics",
    "-framework", "Foundation",
    "-lfreetype",
    "-lz",
    "-lbz2",
    "-liconv",
    "-lm",
    "-lobjc"
  ]
