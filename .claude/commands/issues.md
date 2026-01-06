# List Issues

List all open issues in the current project or workspace.

## Instructions

1. Determine the current project directory (look for `lakefile.lean` or `.issues/` folder)
2. Run `tracker list` to get all open issues, or filter by project:
   - `tracker list --project=<name>` or `tracker list -p <name>` to filter by project
   - `tracker list --all` to include closed issues
   - `tracker list --status=in-progress` to filter by status
3. If $ARGUMENTS contains a project name, use `tracker list --project=<name>`
4. If $ARGUMENTS contains "all" or "--all", run `tracker list --all`
5. Present issues in a summary format:
   - Issue ID
   - Title
   - Priority (if high or critical, highlight it)
   - Status
   - Project (if filtering across multiple projects)

## Example Usage

```
/issues                    # List all open issues
/issues parlance           # List issues for parlance project
/issues tracker            # List issues for tracker project
/issues all                # Include closed issues
/issues --status=in-progress  # Filter by status
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
