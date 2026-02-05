# Roadmap

This document tracks potential improvements, new features, and code cleanup opportunities for the `timeout` utility - a macOS-compatible implementation of GNU timeout.

## Feature Proposals

### [Priority: High] Add Signal Selection Option (-s/--signal)
**Description:** Allow users to specify which signal to send when the timeout expires, matching GNU timeout behavior.
**Rationale:** GNU timeout supports `-s SIGNAL` or `--signal=SIGNAL` to send a specific signal instead of SIGTERM. This is essential for compatibility and gives users control over how processes are terminated (e.g., SIGINT for graceful shutdown, SIGKILL for immediate termination).
**Affected Files:** `timeout`
**Estimated Effort:** Small
**Implementation Notes:**
- Add `-s` and `--signal` option parsing
- Validate signal names/numbers
- Replace hardcoded `kill -TERM` with the user-specified signal

### [Priority: High] Add Kill After Option (-k/--kill-after)
**Description:** Implement the `-k DURATION` option to send SIGKILL after a grace period if the process is still running.
**Rationale:** GNU timeout supports `-k DURATION` to control how long to wait before sending SIGKILL after the initial signal. Currently, the script hardcodes a 1-second wait, which may not be appropriate for all use cases.
**Affected Files:** `timeout`
**Estimated Effort:** Small
**Implementation Notes:**
- Add `-k` and `--kill-after` option parsing
- Make the SIGKILL delay configurable (current hardcoded `sleep 1`)
- If `-k` is not specified, consider whether to send SIGKILL at all (GNU timeout does not send SIGKILL by default)

### [Priority: Medium] Add Foreground Mode (--foreground)
**Description:** Allow the command to run in the foreground and receive signals directly.
**Rationale:** GNU timeout supports `--foreground` which allows the command to access the TTY and receive keyboard signals. This is useful for interactive commands.
**Affected Files:** `timeout`
**Estimated Effort:** Medium
**Implementation Notes:**
- When in foreground mode, don't background the command
- Handle signal forwarding differently

### [Priority: Medium] Add Preserve Status Option (--preserve-status)
**Description:** Exit with the same status as the command, even on timeout.
**Rationale:** GNU timeout supports `--preserve-status` which returns the command's exit status even when it times out (receiving the signal). This is useful for scripts that need to distinguish between different failure modes.
**Affected Files:** `timeout`
**Estimated Effort:** Small

### [Priority: Medium] Support Days Duration Suffix
**Description:** Add support for the `d` suffix to specify durations in days.
**Rationale:** GNU timeout supports `d` for days in addition to `s`, `m`, and `h`. While less commonly used, it provides full GNU compatibility.
**Affected Files:** `timeout`
**Estimated Effort:** Small
**Implementation Notes:**
- Add `d` case to `parse_duration()` function
- Multiply by 86400 (seconds per day)

### [Priority: Low] Add Verbose Mode (-v/--verbose)
**Description:** Add optional verbose output to show when timeout is triggered.
**Rationale:** Debugging timeout issues can be difficult. A verbose mode would help users understand when and why timeouts occur.
**Affected Files:** `timeout`
**Estimated Effort:** Small

### [Priority: Low] Support Fractional Seconds Without bc
**Description:** Handle fractional seconds using pure bash arithmetic where possible.
**Rationale:** The current implementation requires `bc` for fractional duration calculations. While `bc` is commonly available, eliminating this dependency would make the script more portable.
**Affected Files:** `timeout`
**Estimated Effort:** Medium
**Implementation Notes:**
- For simple cases, bash can handle integer arithmetic
- Consider using awk as an alternative to bc
- Note: macOS `sleep` supports fractional seconds natively

## Code Improvements

### [Priority: High] Fix Potential Race Condition in Timeout Detection
**Current State:** The script uses a temp file marker to detect timeout. There's a small window where the command could exit and the timeout could trigger simultaneously.
**Proposed Change:** Use a more robust mechanism such as tracking the actual exit cause via signal handlers or process group management.
**Benefits:** More reliable timeout detection, eliminates edge case bugs.
**Affected Files:** `timeout`
**Estimated Effort:** Medium

### [Priority: High] Improve SIGKILL Behavior to Match GNU timeout
**Current State:** The script always sends SIGKILL after 1 second if the process is still running. GNU timeout only sends SIGKILL if `-k` is specified.
**Proposed Change:** Only send SIGKILL when `-k/--kill-after` is specified. Otherwise, just send the initial signal and wait.
**Benefits:** Better compatibility with GNU timeout, less aggressive default behavior.
**Affected Files:** `timeout`
**Estimated Effort:** Small

### [Priority: Medium] Use Process Groups for Reliable Child Termination
**Current State:** The script kills only the direct child process. If the command spawns subprocesses, they may continue running after timeout.
**Proposed Change:** Create a new process group and kill the entire group on timeout.
**Benefits:** Ensures all descendant processes are terminated, preventing zombie processes.
**Affected Files:** `timeout`
**Estimated Effort:** Medium
**Implementation Notes:**
- Use `setsid` or `set -m` for process group creation
- Kill with negative PID to target the group

### [Priority: Medium] Add Proper Option Parsing with getopts
**Current State:** The script expects exactly `DURATION COMMAND [ARGS]` with no option flags.
**Proposed Change:** Implement proper option parsing using `getopts` to support flags like `-s`, `-k`, `--help`, `--version`.
**Benefits:** Better UX, GNU compatibility, cleaner argument handling.
**Affected Files:** `timeout`
**Estimated Effort:** Medium
**Implementation Notes:**
- Use `getopts` for short options
- Parse long options manually or use a helper function
- Handle `--` to separate options from command

### [Priority: Medium] Handle Commands That Ignore SIGTERM
**Current State:** If a command traps or ignores SIGTERM, the script waits 1 second then sends SIGKILL.
**Proposed Change:** Make this behavior configurable and document it clearly.
**Benefits:** Better handling of stubborn processes, user control over termination strategy.
**Affected Files:** `timeout`
**Estimated Effort:** Small

### [Priority: Low] Validate Duration is Positive
**Current State:** The regex allows durations like `0` or `0.0` which are technically valid but meaningless.
**Proposed Change:** Warn or error on zero or negative durations.
**Benefits:** Better error messages for user mistakes.
**Affected Files:** `timeout`
**Estimated Effort:** Small

### [Priority: Low] Remove bc Dependency for Integer Durations
**Current State:** All duration conversions go through `bc`, even for simple integers.
**Proposed Change:** Use bash arithmetic for integer cases, only invoke `bc` for fractional values.
**Benefits:** Slight performance improvement, reduced dependencies for common cases.
**Affected Files:** `timeout`
**Estimated Effort:** Small

## Code Cleanup

### [Priority: High] Add --help and --version Flags
**Issue:** The script shows usage on too few arguments but doesn't support `--help` or `--version` flags.
**Location:** `timeout`, lines 78-81
**Action Required:**
- Check for `--help` or `-h` as the first argument and show usage
- Check for `--version` and display version information
- Consider supporting `-V` for version as well
**Estimated Effort:** Small

### [Priority: Medium] Remove Stale .gitignore Entries
**Issue:** The `.gitignore` contains `.lake` and `lake-manifest.json` which are Lean-specific files. This is a pure shell script project that doesn't use Lake.
**Location:** `.gitignore`
**Action Required:** Remove or replace with shell-project-appropriate ignore patterns (e.g., `*.log`, `*.tmp`).
**Estimated Effort:** Small

### [Priority: Medium] Add README.md Documentation
**Issue:** The project lacks a README file explaining installation, usage, and compatibility notes.
**Location:** Project root (new file)
**Action Required:**
- Create README.md with usage examples
- Document differences from GNU timeout
- Add installation instructions (reference install.sh)
- Note macOS-specific considerations
**Estimated Effort:** Small

### [Priority: Low] Add Uninstall Script
**Issue:** There's an install.sh but no uninstall.sh for clean removal.
**Location:** Project root (new file)
**Action Required:** Create `uninstall.sh` that removes `/usr/local/bin/timeout`.
**Estimated Effort:** Small

### [Priority: Low] Improve Error Messages
**Issue:** Some error messages could be more descriptive.
**Location:** `timeout`, various locations
**Action Required:**
- Add context to error messages (e.g., "timeout: error: ...")
- Consider colorized output for TTY
- Match GNU timeout error message style
**Estimated Effort:** Small

### [Priority: Low] Add Shellcheck Compliance
**Issue:** The script should pass shellcheck without warnings for best practices.
**Location:** `timeout`
**Action Required:**
- Run `shellcheck timeout` and address any warnings
- Add shellcheck disable comments for intentional patterns
**Estimated Effort:** Small

## Testing

### [Priority: High] Add Test Suite
**Issue:** No automated tests exist for the timeout utility.
**Location:** New `tests/` directory
**Action Required:**
- Create basic test cases for:
  - Normal command completion (before timeout)
  - Timeout triggering (command killed)
  - Various duration formats (5, 5s, 2m, 1h)
  - Exit code preservation
  - Signal handling
- Consider using bats (Bash Automated Testing System) or simple shell tests
**Estimated Effort:** Medium

## Documentation

### [Priority: Medium] Add Man Page
**Issue:** No man page is provided for system-level documentation.
**Location:** New `timeout.1` file
**Action Required:**
- Create a man page in troff format
- Update install.sh to optionally install the man page
**Estimated Effort:** Medium

## Compatibility Notes

The following GNU timeout features are not currently implemented:
- `-s, --signal=SIGNAL` - specify the signal to send
- `-k, --kill-after=DURATION` - send SIGKILL after grace period
- `--foreground` - run command in foreground
- `--preserve-status` - preserve exit status on timeout
- `-v, --verbose` - diagnose signals sent

These represent the primary gaps between this implementation and full GNU timeout compatibility.
