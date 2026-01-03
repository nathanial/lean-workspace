# Test Project

Run tests for the specified Lean project.

## Instructions

1. Identify the project to test from user input: $ARGUMENTS
2. Find the project directory (check all categories: graphics/, web/, network/, data/, apps/, util/, math/, audio/, testing/)
3. Ensure the project is built first (use `lake build` or `./build.sh` as appropriate)
4. Run tests: `cd <category>/<project> && lake test`
5. Report test results clearly, highlighting any failures

## Example Usage

```
/test crucible
/test wisp
/test collimator
```
