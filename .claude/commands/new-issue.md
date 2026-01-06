# Create New Issue

Create a new issue in the tracker.

## Instructions

1. Parse $ARGUMENTS for issue details:
   - First quoted string or unquoted text = title
   - `--priority=<level>` = priority (low, medium, high, critical)
   - `--label=<label>` = optional label
2. If no title provided, ask the user for one
3. Run `tracker add "<title>" --priority=<priority>` to create the issue
4. Report the new issue ID to the user
5. Suggest next steps (e.g., start working with `/work-issue <id>`)

## Example Usage

```
/new-issue "Add dark mode support"
/new-issue Fix login bug --priority=high
/new-issue "Refactor database layer" --priority=medium
```

## Priority Levels

- **critical**: Production-breaking, needs immediate attention
- **high**: Important, should be addressed soon
- **medium**: Normal priority (default)
- **low**: Nice to have, can wait

## After Creation

Inform the user:
- The issue ID created
- How to start working on it: `tracker update <id> --status=in-progress`
- How to add progress: `tracker progress <id> "message"`
