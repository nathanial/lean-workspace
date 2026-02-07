/-
  Tracker - Local issue tracker for Claude Code.

  A git-friendly issue tracker with:
  - CLI mode for programmatic access (JSON output by default)
  - TUI mode for interactive use
  - Ledger-backed normalized storage
-/

import Tracker.Core.Types
import Tracker.Core.Parser
import Tracker.Core.Storage
import Tracker.CLI.Commands
import Tracker.CLI.Output
import Tracker.CLI.Handlers
import Tracker.TUI
import Tracker.GUI.App
import Tracker.Main
