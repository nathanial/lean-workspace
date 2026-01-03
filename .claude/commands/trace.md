# Add Tracing

Help add tracing and debugging output to Lean code.

## Instructions

1. Identify the code to trace from user context or $ARGUMENTS
2. Use the tracer library patterns for structured tracing:

```lean
import Tracer

-- Simple trace
trace "message" in expr

-- Trace with value
dbg_trace s!"value = {value}"

-- Conditional tracing
if debugMode then
  trace s!"debug: {state}" in result
else
  result
```

3. For IO code, use:

```lean
IO.println s!"[DEBUG] {message}"
```

4. Recommend removing traces before committing to production code

## Example Usage

```
/trace this function
/trace add logging to handleRequest
```
