# List Issues

List all open issues in the current project or workspace.

## Instructions

1. Determine the current project directory (look for `lakefile.lean` or `.issues/` folder)
2. Run `tracker list` to get all open issues
3. If $ARGUMENTS contains "all" or "--all", show issues from all projects in the workspace
4. Present issues in a summary format:
   - Issue ID
   - Title
   - Priority (if high or critical, highlight it)
   - Status

## Example Usage

```
/issues              # List issues in current project
/issues all          # List issues across all workspace projects
/issues --priority   # Sort by priority
```

## Output Format

Present issues as a table or list:

```
ID    | Priority | Title
------+----------+---------------------------
001   | high     | Fix memory leak in parser
002   | medium   | Add unit tests for API
```

If no issues exist, inform the user they can create one with `/new-issue`.
