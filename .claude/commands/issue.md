# Show Issue

Display detailed information about a specific issue.

## Instructions

1. Extract the issue ID from $ARGUMENTS
2. If no ID provided, run `tracker list` and ask the user which issue they want to see
3. Run `tracker show <id>` to get full issue details
4. Present the issue information clearly:
   - Title and ID
   - Status and priority
   - Description
   - Progress history (if any)
   - Related files or commits

## Example Usage

```
/issue 001           # Show issue 001
/issue abc123        # Show issue by ID
```

## Output Format

Display the issue with clear sections:

```
Issue #001: Fix memory leak in parser
Status: in-progress | Priority: high

Description:
  The parser leaks memory when processing large files...

Progress:
  - 2024-01-15: Found root cause in tokenizer
  - 2024-01-16: Implementing fix...

Related:
  - web/herald/Herald/Parser.lean
```
