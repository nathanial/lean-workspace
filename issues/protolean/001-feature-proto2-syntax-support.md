# Proto2 Syntax Support

**Priority:** High
**Section:** Feature Proposals
**Estimated Effort:** Large
**Dependencies:** None

## Description
Add support for parsing and code generation from Proto2 syntax files.

## Rationale
Proto2 is still widely used in legacy systems. Many organizations have existing .proto files using Proto2 syntax with required fields, extensions, and groups.

## Affected Files
- `/Users/Shared/Projects/lean-workspace/protolean/Protolean/Syntax/AST.lean` (add Proto2-specific constructs)
- `/Users/Shared/Projects/lean-workspace/protolean/Protolean/Parser/Proto.lean` (parse "proto2" syntax and required/extensions)
- `/Users/Shared/Projects/lean-workspace/protolean/Protolean/Codegen/Types.lean` (generate required field handling)
