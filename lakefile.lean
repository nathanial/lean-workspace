import Lake
open Lake DSL

package lean_workspace where
  version := v!"0.1.0"
  testDriver := "linalg_tests"

require batteries from git "https://github.com/leanprover-community/batteries" @ "v4.26.0"
-- Auto-generated one-library-per-project layout (fast monorepo cutover).

lean_lib apps_agent_mail where
  srcDir := "apps/agent-mail"
  roots := #[`AgentMail]

lean_lib apps_ask where
  srcDir := "apps/ask"
  roots := #[`Ask]

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
  srcDir := "graphics/afferent/widgets/afferent-buttons"
  roots := #[`AfferentButtons]

lean_lib graphics_afferent_charts where
  srcDir := "graphics/afferent/widgets/afferent-charts"
  roots := #[`AfferentCharts]

lean_lib graphics_afferent_chat where
  srcDir := "graphics/afferent/widgets/afferent-chat"
  roots := #[`AfferentChat]

lean_lib graphics_afferent_demos where
  srcDir := "graphics/afferent-demos"
  roots := #[`Demos]

lean_lib graphics_afferent_math where
  srcDir := "graphics/afferent/widgets/afferent-math"
  roots := #[`AfferentMath]

lean_lib graphics_afferent_progress_bars where
  srcDir := "graphics/afferent/widgets/afferent-progress-bars"
  roots := #[`AfferentProgressBars]

lean_lib graphics_afferent_spinners where
  srcDir := "graphics/afferent/widgets/afferent-spinners"
  roots := #[`AfferentSpinners]

lean_lib graphics_afferent_text_inputs where
  srcDir := "graphics/afferent/widgets/afferent-text-inputs"
  roots := #[`AfferentTextInputs]

lean_lib graphics_afferent_time_picker where
  srcDir := "graphics/afferent/widgets/afferent-time-picker"
  roots := #[`AfferentTimePicker]

lean_lib graphics_afferent_worldmap where
  srcDir := "graphics/afferent/widgets/afferent-worldmap"
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

lean_lib math_linalg_tests where
  srcDir := "math/linalg"
  roots := #[`LinalgTests.Main]

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

lean_exe linalg_tests where
  srcDir := "math/linalg"
  root := `LinalgTests.Main

def terminalUiLinkArgs : Array String := #[
  ".native-libs/lib/libparlance_native.a",
  ".native-libs/lib/libterminus_native.a",
  ".native-libs/lib/libraster_native.a",
  ".native-libs/lib/libchronos_native.a",
  ".native-libs/lib/libwisp_native.a",
  "-L/opt/homebrew/lib",
  "-L/opt/homebrew/opt/openssl@3/lib",
  "-L/opt/homebrew/opt/curl/lib",
  "-lcurl",
  "-lssl",
  "-lcrypto"
]

def oracleLinkArgs : Array String := #[
  ".native-libs/lib/libparlance_native.a",
  ".native-libs/lib/libchronos_native.a",
  ".native-libs/lib/libwisp_native.a",
  "-L/opt/homebrew/lib",
  "-L/opt/homebrew/opt/openssl@3/lib",
  "-L/opt/homebrew/opt/curl/lib",
  "-lcurl",
  "-lssl",
  "-lcrypto"
]

def loomLinkArgs : Array String := #[
  ".native-libs/lib/libcrypt_native.a",
  ".native-libs/lib/libjack_native.a",
  ".native-libs/lib/libquarry_native.a",
  ".native-libs/lib/libcitadel_native.a",
  ".native-libs/lib/libwisp_native.a",
  ".native-libs/lib/libchronos_native.a",
  "-L/opt/homebrew/lib",
  "-L/opt/homebrew/opt/openssl@3/lib",
  "-L/opt/homebrew/opt/curl/lib",
  "-lsodium",
  "-lcurl",
  "-lssl",
  "-lcrypto"
]

def agentMailLinkArgs : Array String := #[
  ".native-libs/lib/libchronos_native.a",
  ".native-libs/lib/libjack_native.a",
  ".native-libs/lib/libquarry_native.a",
  ".native-libs/lib/libcitadel_native.a",
  ".native-libs/lib/libwisp_native.a",
  "-L/opt/homebrew/lib",
  "-L/opt/homebrew/opt/openssl@3/lib",
  "-L/opt/homebrew/opt/curl/lib",
  "-lcurl",
  "-lssl",
  "-lcrypto"
]

def afferentMetalLinkArgs : Array String := #[
  ".native-libs/lib/libafferent_native.a",
  ".native-libs/lib/libraster_native.a",
  ".native-libs/lib/libchronos_native.a",
  ".native-libs/lib/libwisp_native.a",
  "-L/opt/homebrew/lib",
  "-L/opt/homebrew/opt/openssl@3/lib",
  "-L/opt/homebrew/opt/curl/lib",
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
  "-lobjc",
  "-lcurl",
  "-lssl",
  "-lcrypto"
]

def trackerGuiLinkArgs : Array String := #[
  ".native-libs/lib/libparlance_native.a",
  ".native-libs/lib/libterminus_native.a",
  ".native-libs/lib/libraster_native.a",
  ".native-libs/lib/libchronos_native.a",
  ".native-libs/lib/libwisp_native.a",
  ".native-libs/lib/libafferent_native.a",
  "-L/opt/homebrew/lib",
  "-L/opt/homebrew/opt/openssl@3/lib",
  "-L/opt/homebrew/opt/curl/lib",
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
  "-lobjc",
  "-lcurl",
  "-lssl",
  "-lcrypto"
]

lean_exe afferent_demos where
  srcDir := "graphics/afferent-demos"
  root := `AfferentDemos.Main
  moreLinkArgs := afferentMetalLinkArgs

lean_exe eschaton where
  srcDir := "apps/eschaton"
  root := `Main
  moreLinkArgs := afferentMetalLinkArgs

lean_exe agent_mail where
  srcDir := "apps/agent-mail"
  root := `AgentMail.Main
  moreLinkArgs := agentMailLinkArgs

lean_exe ask where
  srcDir := "apps/ask"
  root := `Main
  moreLinkArgs := oracleLinkArgs

lean_exe blockfall where
  srcDir := "apps/blockfall"
  root := `Blockfall.Main
  moreLinkArgs := terminalUiLinkArgs

lean_exe cairn where
  srcDir := "apps/cairn"
  root := `Main
  moreLinkArgs := afferentMetalLinkArgs

lean_exe chatline where
  srcDir := "apps/chatline"
  root := `Uchatline.Main

lean_exe enchiridion where
  srcDir := "apps/enchiridion"
  root := `Enchiridion.Main
  moreLinkArgs := terminalUiLinkArgs

lean_exe homebase_app where
  srcDir := "apps/homebase-app"
  root := `HomebaseApp.Main
  moreLinkArgs := loomLinkArgs

lean_exe image_gen where
  srcDir := "apps/image-gen"
  root := `ImageGen.Main
  moreLinkArgs := oracleLinkArgs

lean_exe lighthouse where
  srcDir := "apps/lighthouse"
  root := `Lighthouse.Main
  moreLinkArgs := terminalUiLinkArgs

lean_exe minefield where
  srcDir := "apps/minefield"
  root := `Minefield.Main
  moreLinkArgs := terminalUiLinkArgs

lean_exe solitaire where
  srcDir := "apps/solitaire"
  root := `Solitaire.Main
  moreLinkArgs := terminalUiLinkArgs

lean_exe timekeeper where
  srcDir := "apps/timekeeper"
  root := `Timekeeper.Entry
  moreLinkArgs := terminalUiLinkArgs

lean_exe todo_app where
  srcDir := "apps/todo-app"
  root := `TodoApp.Main
  moreLinkArgs := loomLinkArgs

lean_exe tracker where
  srcDir := "apps/tracker"
  root := `Tracker.Entry
  moreLinkArgs := trackerGuiLinkArgs

lean_exe tracker_bench where
  srcDir := "apps/tracker"
  root := `TrackerBench.Main
  moreLinkArgs := terminalUiLinkArgs

lean_exe twenty48 where
  srcDir := "apps/twenty48"
  root := `Twenty48.Main
  moreLinkArgs := terminalUiLinkArgs



-- Monorepo test targets (auto-generated during test namespace deconflict).

lean_lib apps_agent_mail_tests_lib where
  srcDir := "apps/agent-mail"
  roots := #[`AgentMailTests]

lean_lib apps_blockfall_tests_lib where
  srcDir := "apps/blockfall"
  roots := #[`BlockfallTests]

lean_lib apps_cairn_tests_lib where
  srcDir := "apps/cairn"
  roots := #[`CairnTests]

lean_lib apps_chatline_tests_lib where
  srcDir := "apps/chatline"
  roots := #[`UchatlineTests]

lean_lib apps_enchiridion_tests_lib where
  srcDir := "apps/enchiridion"
  roots := #[`EnchiridionTests]

lean_lib apps_eschaton_tests_lib where
  srcDir := "apps/eschaton"
  roots := #[`EschatonTests]

lean_lib apps_homebase_app_tests_lib where
  srcDir := "apps/homebase-app"
  roots := #[`HomebaseAppTests]

lean_lib apps_image_gen_tests_lib where
  srcDir := "apps/image-gen"
  roots := #[`ImageGenTests]

lean_lib apps_lighthouse_tests_lib where
  srcDir := "apps/lighthouse"
  roots := #[`LighthouseTests]

lean_lib apps_minefield_tests_lib where
  srcDir := "apps/minefield"
  roots := #[`MinefieldTests]

lean_lib apps_solitaire_tests_lib where
  srcDir := "apps/solitaire"
  roots := #[`SolitaireTests]

lean_lib apps_timekeeper_tests_lib where
  srcDir := "apps/timekeeper"
  roots := #[`TimekeeperTests]

lean_lib apps_todo_app_tests_lib where
  srcDir := "apps/todo-app"
  roots := #[`TodoAppTests]

lean_lib apps_tracker_tests_lib where
  srcDir := "apps/tracker"
  roots := #[`TrackerTests]

lean_lib apps_twenty48_tests_lib where
  srcDir := "apps/twenty48"
  roots := #[`Twenty48Tests]

lean_lib audio_fugue_tests_lib where
  srcDir := "audio/fugue"
  roots := #[`FugueTests]

lean_lib data_cellar_tests_lib where
  srcDir := "data/cellar"
  roots := #[`CellarTests]

lean_lib data_chisel_tests_lib where
  srcDir := "data/chisel"
  roots := #[`ChiselTests]

lean_lib data_collimator_tests_lib where
  srcDir := "data/collimator"
  roots := #[`CollimatorTests]

lean_lib data_convergent_tests_lib where
  srcDir := "data/convergent"
  roots := #[`ConvergentTests]

lean_lib data_entity_tests_lib where
  srcDir := "data/entity"
  roots := #[`EntityTests]

lean_lib data_ledger_tests_lib where
  srcDir := "data/ledger"
  roots := #[`LedgerTests]

lean_lib data_quarry_tests_lib where
  srcDir := "data/quarry"
  roots := #[`QuarryTests]

lean_lib data_reactive_tests_lib where
  srcDir := "data/reactive"
  roots := #[`ReactiveTests]

lean_lib data_tabular_tests_lib where
  srcDir := "data/tabular"
  roots := #[`TabularTests]

lean_lib data_tileset_tests_lib where
  srcDir := "data/tileset"
  roots := #[`TilesetTests]

lean_lib data_totem_tests_lib where
  srcDir := "data/totem"
  roots := #[`TotemTests]

lean_lib graphics_afferent_tests_lib where
  srcDir := "graphics/afferent"
  roots := #[`AfferentTests]

lean_lib graphics_afferent_buttons_tests_lib where
  srcDir := "graphics/afferent/widgets/afferent-buttons"
  roots := #[`AfferentButtonsTests]

lean_lib graphics_afferent_charts_tests_lib where
  srcDir := "graphics/afferent/widgets/afferent-charts"
  roots := #[`AfferentChartsTests]

lean_lib graphics_afferent_chat_tests_lib where
  srcDir := "graphics/afferent/widgets/afferent-chat"
  roots := #[`AfferentChatTests]

lean_lib graphics_afferent_demos_tests_lib where
  srcDir := "graphics/afferent-demos"
  roots := #[`AfferentDemosTests]

lean_lib graphics_afferent_math_tests_lib where
  srcDir := "graphics/afferent/widgets/afferent-math"
  roots := #[`AfferentMathTests]

lean_lib graphics_afferent_progress_bars_tests_lib where
  srcDir := "graphics/afferent/widgets/afferent-progress-bars"
  roots := #[`AfferentProgressBarsTests]

lean_lib graphics_afferent_spinners_tests_lib where
  srcDir := "graphics/afferent/widgets/afferent-spinners"
  roots := #[`AfferentSpinnersTests]

lean_lib graphics_afferent_text_inputs_tests_lib where
  srcDir := "graphics/afferent/widgets/afferent-text-inputs"
  roots := #[`AfferentTextInputsTests]

lean_lib graphics_afferent_time_picker_tests_lib where
  srcDir := "graphics/afferent/widgets/afferent-time-picker"
  roots := #[`AfferentTimePickerTests]

lean_lib graphics_afferent_worldmap_tests_lib where
  srcDir := "graphics/afferent/widgets/afferent-worldmap"
  roots := #[`AfferentWorldmapTests]

lean_lib graphics_chroma_tests_lib where
  srcDir := "graphics/chroma"
  roots := #[`ChromaTests]

lean_lib graphics_grove_tests_lib where
  srcDir := "graphics/grove"
  roots := #[`GroveTests]

lean_lib graphics_raster_tests_lib where
  srcDir := "graphics/raster"
  roots := #[`RasterTests]

lean_lib graphics_shader_tests_lib where
  srcDir := "graphics/shader"
  roots := #[`ShaderTests]

lean_lib graphics_terminus_tests_lib where
  srcDir := "graphics/terminus"
  roots := #[`TerminusTests]

lean_lib graphics_tincture_tests_lib where
  srcDir := "graphics/tincture"
  roots := #[`TinctureTests]

lean_lib graphics_trellis_tests_lib where
  srcDir := "graphics/trellis"
  roots := #[`TrellisTests]

lean_lib graphics_vane_tests_lib where
  srcDir := "graphics/vane"
  roots := #[`VaneTests]

lean_lib graphics_worldmap_tests_lib where
  srcDir := "graphics/worldmap"
  roots := #[`WorldmapTests]

lean_lib math_measures_tests_lib where
  srcDir := "math/measures"
  roots := #[`MeasuresTests]

lean_lib network_exchange_tests_lib where
  srcDir := "network/exchange"
  roots := #[`ExchangeTests]

lean_lib network_jack_tests_lib where
  srcDir := "network/jack"
  roots := #[`JackTests]

lean_lib network_legate_tests_lib where
  srcDir := "network/legate"
  roots := #[`LegateTests]

lean_lib network_oracle_tests_lib where
  srcDir := "network/oracle"
  roots := #[`OracleTests]

lean_lib network_protolean_tests_lib where
  srcDir := "network/protolean"
  roots := #[`ProtoleanTests]

lean_lib network_wisp_tests_lib where
  srcDir := "network/wisp"
  roots := #[`WispTests]

lean_lib testing_crucible_tests_lib where
  srcDir := "testing/crucible"
  roots := #[`CrucibleTests]

lean_lib util_chronos_tests_lib where
  srcDir := "util/chronos"
  roots := #[`ChronosTests]

lean_lib util_conduit_tests_lib where
  srcDir := "util/conduit"
  roots := #[`ConduitTests]

lean_lib util_crypt_tests_lib where
  srcDir := "util/crypt"
  roots := #[`CryptTests]

lean_lib util_docgen_tests_lib where
  srcDir := "util/docgen"
  roots := #[`DocgenTests]

lean_lib util_parlance_tests_lib where
  srcDir := "util/parlance"
  roots := #[`ParlanceTests]

lean_lib util_rune_tests_lib where
  srcDir := "util/rune"
  roots := #[`RuneTests]

lean_lib util_selene_tests_lib where
  srcDir := "util/selene"
  roots := #[`SeleneTests]

lean_lib util_sift_tests_lib where
  srcDir := "util/sift"
  roots := #[`SiftTests]

lean_lib util_smalltalk_tests_lib where
  srcDir := "util/smalltalk"
  roots := #[`SmalltalkTests]

lean_lib util_staple_tests_lib where
  srcDir := "util/staple"
  roots := #[`StapleTests]

lean_lib util_tracer_tests_lib where
  srcDir := "util/tracer"
  roots := #[`TracerTests]

lean_lib web_chronicle_tests_lib where
  srcDir := "web/chronicle"
  roots := #[`ChronicleTests]

lean_lib web_citadel_tests_lib where
  srcDir := "web/citadel"
  roots := #[`CitadelTests]

lean_lib web_docsite_tests_lib where
  srcDir := "web/docsite"
  roots := #[`DocsiteTests]

lean_lib web_herald_tests_lib where
  srcDir := "web/herald"
  roots := #[`HeraldTests]

lean_lib web_loom_tests_lib where
  srcDir := "web/loom"
  roots := #[`LoomTests]

lean_lib web_markup_tests_lib where
  srcDir := "web/markup"
  roots := #[`MarkupTests]

lean_lib web_scribe_tests_lib where
  srcDir := "web/scribe"
  roots := #[`ScribeTests]

lean_lib web_stencil_tests_lib where
  srcDir := "web/stencil"
  roots := #[`StencilTests]

lean_exe apps_agent_mail_tests_exe where
  srcDir := "apps/agent-mail"
  root := `AgentMailTests.Main
  moreLinkArgs := #[
    ".native-libs/lib/libchronos_native.a",
    ".native-libs/lib/libjack_native.a",
    ".native-libs/lib/libquarry_native.a",
    ".native-libs/lib/libcitadel_native.a",
    ".native-libs/lib/libwisp_native.a",
    "-L/opt/homebrew/lib",
    "-L/opt/homebrew/opt/openssl@3/lib",
    "-L/opt/homebrew/opt/curl/lib",
    "-lcurl",
    "-lssl",
    "-lcrypto"
  ]

lean_exe apps_blockfall_tests_exe where
  srcDir := "apps/blockfall"
  root := `BlockfallTests.Main

lean_exe apps_cairn_tests_exe where
  srcDir := "apps/cairn"
  root := `CairnTests.Main

lean_exe apps_chatline_tests_exe where
  srcDir := "apps/chatline"
  root := `UchatlineTests.Main

lean_exe apps_enchiridion_tests_exe where
  srcDir := "apps/enchiridion"
  root := `EnchiridionTests.Main

lean_exe apps_eschaton_tests_exe where
  srcDir := "apps/eschaton"
  root := `EschatonTests.Main

lean_exe apps_homebase_app_tests_exe where
  srcDir := "apps/homebase-app"
  root := `HomebaseAppTests.Main

lean_exe apps_image_gen_tests_exe where
  srcDir := "apps/image-gen"
  root := `ImageGenTests.Main

lean_exe apps_lighthouse_tests_exe where
  srcDir := "apps/lighthouse"
  root := `LighthouseTests.Main

lean_exe apps_minefield_tests_exe where
  srcDir := "apps/minefield"
  root := `MinefieldTests.Main

lean_exe apps_solitaire_tests_exe where
  srcDir := "apps/solitaire"
  root := `SolitaireTests.Main

lean_exe apps_timekeeper_tests_exe where
  srcDir := "apps/timekeeper"
  root := `TimekeeperTests.Main

lean_exe apps_todo_app_tests_exe where
  srcDir := "apps/todo-app"
  root := `TodoAppTests.Main

lean_exe apps_tracker_tests_exe where
  srcDir := "apps/tracker"
  root := `TrackerTests.Main
  moreLinkArgs := terminalUiLinkArgs

lean_exe apps_twenty48_tests_exe where
  srcDir := "apps/twenty48"
  root := `Twenty48Tests.Main

lean_exe audio_fugue_tests_exe where
  srcDir := "audio/fugue"
  root := `FugueTests.Main

lean_exe data_cellar_tests_exe where
  srcDir := "data/cellar"
  root := `CellarTests.Main

lean_exe data_chisel_tests_exe where
  srcDir := "data/chisel"
  root := `ChiselTests.Main

lean_exe data_collimator_tests_exe where
  srcDir := "data/collimator"
  root := `CollimatorTests.Main

lean_exe data_convergent_tests_exe where
  srcDir := "data/convergent"
  root := `ConvergentTests.Main

lean_exe data_entity_tests_exe where
  srcDir := "data/entity"
  root := `EntityTests.Main

lean_exe data_ledger_tests_exe where
  srcDir := "data/ledger"
  root := `LedgerTests.Main

lean_exe data_quarry_tests_exe where
  srcDir := "data/quarry"
  root := `QuarryTests.Main
  moreLinkArgs := #[
    ".native-libs/lib/libquarry_native.a"
  ]

lean_exe data_reactive_tests_exe where
  srcDir := "data/reactive"
  root := `ReactiveTests.Main
  moreLinkArgs := #[
    ".native-libs/lib/libchronos_native.a"
  ]

lean_exe data_tabular_tests_exe where
  srcDir := "data/tabular"
  root := `TabularTests.Main

lean_exe data_tileset_tests_exe where
  srcDir := "data/tileset"
  root := `TilesetTests.Main
  moreLinkArgs := #[
    ".native-libs/lib/libraster_native.a",
    ".native-libs/lib/libwisp_native.a",
    ".native-libs/lib/libchronos_native.a",
    "-L/opt/homebrew/lib",
    "-L/opt/homebrew/opt/openssl@3/lib",
    "-L/opt/homebrew/opt/curl/lib",
    "-lcurl",
    "-lssl",
    "-lcrypto"
  ]

lean_exe data_totem_tests_exe where
  srcDir := "data/totem"
  root := `TotemTests.Main

lean_exe graphics_afferent_buttons_tests_exe where
  srcDir := "graphics/afferent/widgets/afferent-buttons"
  root := `AfferentButtonsTests.Main
  moreLinkArgs := afferentMetalLinkArgs

lean_exe graphics_afferent_charts_tests_exe where
  srcDir := "graphics/afferent/widgets/afferent-charts"
  root := `AfferentChartsTests.Main
  moreLinkArgs := afferentMetalLinkArgs

lean_exe graphics_afferent_chat_tests_exe where
  srcDir := "graphics/afferent/widgets/afferent-chat"
  root := `AfferentChatTests.Main
  moreLinkArgs := afferentMetalLinkArgs

lean_exe graphics_afferent_demos_tests_exe where
  srcDir := "graphics/afferent-demos"
  root := `AfferentDemosTests.Main
  moreLinkArgs := afferentMetalLinkArgs

lean_exe graphics_afferent_math_tests_exe where
  srcDir := "graphics/afferent/widgets/afferent-math"
  root := `AfferentMathTests.Main
  moreLinkArgs := afferentMetalLinkArgs

lean_exe graphics_afferent_progress_bars_tests_exe where
  srcDir := "graphics/afferent/widgets/afferent-progress-bars"
  root := `AfferentProgressBarsTests.Main
  moreLinkArgs := afferentMetalLinkArgs

lean_exe graphics_afferent_spinners_tests_exe where
  srcDir := "graphics/afferent/widgets/afferent-spinners"
  root := `AfferentSpinnersTests.Main
  moreLinkArgs := afferentMetalLinkArgs

lean_exe graphics_afferent_text_inputs_tests_exe where
  srcDir := "graphics/afferent/widgets/afferent-text-inputs"
  root := `AfferentTextInputsTests.Main
  moreLinkArgs := afferentMetalLinkArgs

lean_exe graphics_afferent_time_picker_tests_exe where
  srcDir := "graphics/afferent/widgets/afferent-time-picker"
  root := `AfferentTimePickerTests.Main
  moreLinkArgs := afferentMetalLinkArgs

lean_exe graphics_afferent_worldmap_tests_exe where
  srcDir := "graphics/afferent/widgets/afferent-worldmap"
  root := `AfferentWorldmapTests.Main
  moreLinkArgs := afferentMetalLinkArgs

lean_exe graphics_afferent_tests_exe where
  srcDir := "graphics/afferent"
  root := `AfferentTests
  moreLinkArgs := afferentMetalLinkArgs

lean_exe graphics_chroma_tests_exe where
  srcDir := "graphics/chroma"
  root := `ChromaTests.Main

lean_exe graphics_grove_tests_exe where
  srcDir := "graphics/grove"
  root := `GroveTests.Main

lean_exe graphics_raster_tests_exe where
  srcDir := "graphics/raster"
  root := `RasterTests.Main

lean_exe graphics_shader_tests_exe where
  srcDir := "graphics/shader"
  root := `ShaderTests.Main

lean_exe graphics_terminus_tests_exe where
  srcDir := "graphics/terminus"
  root := `TerminusTests.Main
  moreLinkArgs := #[
    ".native-libs/lib/libterminus_native.a",
    ".native-libs/lib/libraster_native.a",
    ".native-libs/lib/libchronos_native.a"
  ]

lean_exe graphics_tincture_tests_exe where
  srcDir := "graphics/tincture"
  root := `TinctureTests.Main

lean_exe graphics_trellis_tests_exe where
  srcDir := "graphics/trellis"
  root := `TrellisTests.Main
  moreLinkArgs := #[
    ".native-libs/lib/libchronos_native.a"
  ]

lean_exe graphics_vane_tests_exe where
  srcDir := "graphics/vane"
  root := `VaneTests.Main

lean_exe graphics_worldmap_tests_exe where
  srcDir := "graphics/worldmap"
  root := `WorldmapTests.Main

lean_exe math_linalg_tests_exe where
  srcDir := "math/linalg"
  root := `LinalgTests.Main

lean_exe math_measures_tests_exe where
  srcDir := "math/measures"
  root := `MeasuresTests.Main

lean_exe network_exchange_tests_exe where
  srcDir := "network/exchange"
  root := `ExchangeTests.Main

lean_exe network_jack_tests_exe where
  srcDir := "network/jack"
  root := `JackTests.Main
  moreLinkArgs := #[
    ".native-libs/lib/libjack_native.a"
  ]

lean_exe network_legate_tests_exe where
  srcDir := "network/legate"
  root := `LegateTests.Main

lean_exe network_legate_tests_integration_exe where
  srcDir := "network/legate"
  root := `LegateTests.integration.Main

lean_exe network_oracle_tests_exe where
  srcDir := "network/oracle"
  root := `OracleTests.Main
  moreLinkArgs := #[
    ".native-libs/lib/libchronos_native.a",
    ".native-libs/lib/libwisp_native.a",
    "-L/opt/homebrew/lib",
    "-L/opt/homebrew/opt/openssl@3/lib",
    "-L/opt/homebrew/opt/curl/lib",
    "-lcurl",
    "-lssl",
    "-lcrypto"
  ]

lean_exe network_protolean_tests_exe where
  srcDir := "network/protolean"
  root := `ProtoleanTests.Main

lean_exe network_wisp_tests_exe where
  srcDir := "network/wisp"
  root := `WispTests.Main
  moreLinkArgs := #[
    ".native-libs/lib/libwisp_native.a",
    ".native-libs/lib/libchronos_native.a",
    "-L/opt/homebrew/lib",
    "-L/opt/homebrew/opt/openssl@3/lib",
    "-L/opt/homebrew/opt/curl/lib",
    "-lcurl",
    "-lssl",
    "-lcrypto"
  ]

lean_exe testing_crucible_tests_exe where
  srcDir := "testing/crucible"
  root := `CrucibleTests.Main

lean_exe util_chronos_tests_exe where
  srcDir := "util/chronos"
  root := `ChronosTests.Main
  moreLinkArgs := #[
    ".native-libs/lib/libchronos_native.a"
  ]

lean_exe util_conduit_tests_exe where
  srcDir := "util/conduit"
  root := `ConduitTests.Main
  moreLinkArgs := #[
    ".native-libs/lib/libconduit_native.a"
  ]

lean_exe util_crypt_tests_exe where
  srcDir := "util/crypt"
  root := `CryptTests.Main
  moreLinkArgs := #[
    ".native-libs/lib/libcrypt_native.a",
    "-L/opt/homebrew/lib",
    "-lsodium"
  ]

lean_exe util_docgen_tests_exe where
  srcDir := "util/docgen"
  root := `DocgenTests.Main

lean_exe util_parlance_tests_exe where
  srcDir := "util/parlance"
  root := `ParlanceTests.Main

lean_exe util_rune_tests_exe where
  srcDir := "util/rune"
  root := `RuneTests.Main

lean_exe util_selene_tests_exe where
  srcDir := "util/selene"
  root := `SeleneTests.Main
  moreLinkArgs := #[
    ".native-libs/lib/libselene_native.a",
    "-lm"
  ]

lean_exe util_sift_tests_exe where
  srcDir := "util/sift"
  root := `SiftTests.Main

lean_exe util_smalltalk_tests_exe where
  srcDir := "util/smalltalk"
  root := `SmalltalkTests.Main

lean_exe util_staple_tests_exe where
  srcDir := "util/staple"
  root := `StapleTests

lean_exe util_tracer_tests_exe where
  srcDir := "util/tracer"
  root := `TracerTests.Main

lean_exe web_chronicle_tests_exe where
  srcDir := "web/chronicle"
  root := `ChronicleTests.Main

lean_exe web_citadel_tests_exe where
  srcDir := "web/citadel"
  root := `CitadelTests.Main

lean_exe web_docsite_tests_exe where
  srcDir := "web/docsite"
  root := `DocsiteTests.Main

lean_exe web_herald_tests_exe where
  srcDir := "web/herald"
  root := `HeraldTests.Main

lean_exe web_loom_tests_exe where
  srcDir := "web/loom"
  root := `LoomTests.Main

lean_exe web_markup_tests_exe where
  srcDir := "web/markup"
  root := `MarkupTests.Main

lean_exe web_scribe_tests_exe where
  srcDir := "web/scribe"
  root := `ScribeTests.Main

lean_exe web_stencil_tests_exe where
  srcDir := "web/stencil"
  root := `StencilTests.Main
