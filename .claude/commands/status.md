# Workspace Status

Show git status across all submodules in the workspace.

## Instructions

1. Run `just status` to get git status for all projects
2. Summarize the results:
   - Projects with uncommitted changes
   - Projects with staged changes
   - Projects with untracked files
3. If specific projects are mentioned in $ARGUMENTS, focus on those

## Example Usage

```
/status
/status afferent terminus
```
