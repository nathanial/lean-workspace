# Log Issue Progress

Quick command to log progress on an issue.

## Instructions

1. Parse $ARGUMENTS for issue ID and progress message
2. Format: `<id> <message>` or `<id> "<message>"`
3. Run `tracker progress <id> "<message>"`
4. Confirm the progress was logged

## Example Usage

```
/progress 001 Found the root cause
/progress 001 "Implemented fix, tests passing"
/progress abc123 Ready for review
```

## When to Log Progress

- Found root cause of a bug
- Completed a sub-task
- Identified relevant files
- Made a key decision
- Encountered a blocker
- Ready for next step

## Tips

- Be specific: include file paths, line numbers
- Reference commits when relevant
- Note any decisions made and why
