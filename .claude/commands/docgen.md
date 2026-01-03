# Generate Documentation

Generate documentation for the specified Lean project using docgen.

## Instructions

1. Identify the project from user input: $ARGUMENTS
2. Find the project directory
3. Ensure the project is built first
4. Run documentation generator: `lake exe docgen`
5. Report where documentation was generated

## Notes

- The docgen tool is in `util/docgen`
- Generated docs typically go to a `docs/` or `_docs/` directory
- Some projects may have custom documentation targets

## Example Usage

```
/docgen collimator
/docgen terminus
```
