# Close Issue

Close a resolved issue with a summary.

## Instructions

1. Extract issue ID from $ARGUMENTS
2. If no ID provided, run `tracker list --status=in-progress` and ask which to close
3. Extract or ask for a closing summary
4. Run `tracker close <id> "<summary>"` to close the issue
5. Confirm closure to the user

## Example Usage

```
/close-issue 001 "Fixed in commit abc123"
/close-issue 001                          # Will prompt for summary
```

## Closing Summary Guidelines

A good closing summary should include:
- What was done to resolve the issue
- Relevant commit hashes or PR numbers
- Any follow-up items (create new issues if needed)

## After Closing

- Confirm the issue is closed
- If there are related follow-up items, offer to create new issues
- Remind user to commit the `.issues/` changes with their code
