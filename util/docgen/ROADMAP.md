# Docgen Roadmap

This document outlines potential improvements, new features, and code cleanup opportunities for the Docgen documentation generator.

---

## Feature Proposals

### [Priority: High] Markdown Rendering in Doc Comments

**Description:** Currently, doc comments are rendered as simple preformatted text with paragraph splitting. Add proper markdown rendering support for doc comments.

**Rationale:** Lean doc comments often contain markdown formatting (code blocks, links, lists, headers) that should be rendered properly in the generated documentation. This is standard practice in documentation generators.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/util/docgen/Docgen/Render/Html.lean` (lines 71-78)

**Implementation Notes:**
- Consider using a lightweight markdown parser
- Support code blocks with syntax highlighting
- Handle inline code, links, bold, italic, lists
- See TODO comment on line 75: "Add markdown rendering"

**Estimated Effort:** Medium

**Dependencies:** May require adding a markdown parsing dependency or implementing a basic parser

---

### [Priority: High] Actual Environment Loading from Compiled Project

**Description:** Complete the environment loading implementation to extract documentation from real compiled Lean projects rather than stub data.

**Rationale:** The current `generate` function in `Site.lean` creates a stub project (lines 86-90) instead of loading the actual environment. The `generateFromEnv` function exists but isn't connected to the CLI workflow.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/util/docgen/Docgen/Generate/Site.lean` (lines 74-98)
- `/Users/Shared/Projects/lean-workspace/util/docgen/Docgen/Extract/Environment.lean`
- `/Users/Shared/Projects/lean-workspace/util/docgen/Docgen/CLI.lean` (runBuild function)

**Implementation Notes:**
- Need to detect project modules from lakefile
- Load compiled `.olean` files
- Call `generateFromEnv` with properly loaded environment

**Estimated Effort:** Large

**Dependencies:** None

---

### [Priority: High] Module Doc Comment Extraction

**Description:** Implement proper extraction of module-level doc comments (`/-! ... -/`).

**Rationale:** The `getModuleDoc` function in `DocStrings.lean` (lines 20-24) currently returns `none` with a comment noting "proper extraction requires more work."

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/util/docgen/Docgen/Extract/DocStrings.lean` (lines 19-24)

**Implementation Notes:**
- Module docs are stored differently than declaration docs
- May need to access `ModuleDoc` extension or parse source files

**Estimated Effort:** Medium

**Dependencies:** Environment loading feature

---

### [Priority: Medium] Source File and Line Number Extraction

**Description:** Extract actual source file locations and line numbers for declarations.

**Rationale:** DocItem has `sourceFile` and `sourceLine` fields but they are always set to `none` in `extractDocItem` (lines 26-27 in Module.lean). This prevents source links from working.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/util/docgen/Docgen/Extract/Module.lean` (lines 16-29)
- `/Users/Shared/Projects/lean-workspace/util/docgen/Docgen/Extract/Environment.lean`

**Implementation Notes:**
- Use `Lean.Environment.getModuleIdxFor?` and source position info
- May require additional Lean API access

**Estimated Effort:** Medium

**Dependencies:** None

---

### [Priority: Medium] Structure and Inductive Extended Information

**Description:** Render structure fields and inductive constructors with their types and doc comments.

**Rationale:** The type system includes `StructureInfo` and `InductiveInfo` (lines 44-76 in Types.lean) but these are not populated or rendered. Structures currently appear without field information.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/util/docgen/Docgen/Core/Types.lean` (StructureInfo, InductiveInfo)
- `/Users/Shared/Projects/lean-workspace/util/docgen/Docgen/Extract/Module.lean`
- `/Users/Shared/Projects/lean-workspace/util/docgen/Docgen/Render/Html.lean`

**Implementation Notes:**
- `ppStructureFields` and `ppInductiveConstructors` exist in Signatures.lean but aren't used
- `getStructureFieldDocsIO` and `getConstructorDocStringIO` exist in DocStrings.lean
- Need to integrate these into extraction and add rendering

**Estimated Effort:** Medium

**Dependencies:** None

---

### [Priority: Medium] Typeclass Instance Documentation

**Description:** Show which typeclasses a type implements and list all instances for a typeclass.

**Rationale:** Typeclass instances are fundamental to Lean but currently only appear as individual items. Users should see the relationship between classes and their instances.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/util/docgen/Docgen/Core/Types.lean`
- `/Users/Shared/Projects/lean-workspace/util/docgen/Docgen/Extract/Module.lean`
- `/Users/Shared/Projects/lean-workspace/util/docgen/Docgen/Render/Html.lean`

**Implementation Notes:**
- Add `instances` field to DocItem for classes
- Add `implementedClasses` field for types
- Group instances in rendered output

**Estimated Effort:** Medium

**Dependencies:** None

---

### [Priority: Medium] Syntax Highlighting for Lean Code

**Description:** Add syntax highlighting for type signatures and code blocks in doc comments.

**Rationale:** Raw type signatures are harder to read without highlighting. Other doc generators (rustdoc, haddock) highlight code.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/util/docgen/Docgen/Render/Html.lean`
- `/Users/Shared/Projects/lean-workspace/util/docgen/assets/style.css`

**Implementation Notes:**
- Could use a JavaScript-based highlighter (Prism.js, highlight.js) or generate highlighted HTML server-side
- Add `language-lean` class is already present on code blocks

**Estimated Effort:** Medium

**Dependencies:** None

---

### [Priority: Medium] Hierarchical Module Tree Navigation

**Description:** Render sidebar as a collapsible tree structure matching module hierarchy.

**Rationale:** Current sidebar groups by top-level namespace but shows flat list within each group. Large projects need hierarchical navigation.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/util/docgen/Docgen/Render/Navigation.lean`
- `/Users/Shared/Projects/lean-workspace/util/docgen/assets/style.css`

**Implementation Notes:**
- Use `submodules` field already populated in DocModule
- Add JavaScript for tree expand/collapse
- Consider remembering open state in localStorage

**Estimated Effort:** Medium

**Dependencies:** None

---

### [Priority: Medium] Cross-Reference Links

**Description:** Automatically link type names in signatures to their documentation pages.

**Rationale:** Type signatures currently render as plain text. Clicking on a type should navigate to its documentation.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/util/docgen/Docgen/Render/Html.lean`
- `/Users/Shared/Projects/lean-workspace/util/docgen/Docgen/Extract/Signatures.lean`

**Implementation Notes:**
- Build lookup table of all documented names to URLs
- Parse signatures and wrap recognized names in links
- Handle qualified vs unqualified names

**Estimated Effort:** Large

**Dependencies:** None

---

### [Priority: Medium] Keyboard Navigation for Search

**Description:** Add arrow key navigation and Enter to select in search results.

**Rationale:** Better UX for power users who prefer keyboard navigation.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/util/docgen/Docgen/Render/Search.lean` (searchJs)

**Implementation Notes:**
- Track selected index in search results
- Handle ArrowUp, ArrowDown, Enter, Escape keys
- Highlight currently selected result

**Estimated Effort:** Small

**Dependencies:** None

---

### [Priority: Medium] Watch Mode for Development

**Description:** Add a `--watch` flag that rebuilds documentation when source files change.

**Rationale:** Useful for iterating on documentation during development.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/util/docgen/Docgen/CLI.lean`
- New file for file watching

**Implementation Notes:**
- Use FSEvents (macOS) or inotify (Linux) for file watching
- Debounce rebuilds to avoid excessive regeneration
- Consider serving docs locally with auto-reload

**Estimated Effort:** Medium

**Dependencies:** File watching FFI or library

---

### [Priority: Low] Local Development Server

**Description:** Add a `docgen serve` command to serve generated docs locally.

**Rationale:** Convenience feature for previewing documentation.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/util/docgen/Docgen/CLI.lean`
- New file for HTTP server

**Implementation Notes:**
- Could use Citadel for serving static files
- Default port 8080 or configurable
- Combine with watch mode for live preview

**Estimated Effort:** Medium

**Dependencies:** HTTP server (citadel from workspace)

---

### [Priority: Low] Custom Theme Support

**Description:** Allow users to provide custom CSS files.

**Rationale:** Projects may want branded documentation.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/util/docgen/Docgen/Core/Config.lean`
- `/Users/Shared/Projects/lean-workspace/util/docgen/Docgen/CLI.lean`
- `/Users/Shared/Projects/lean-workspace/util/docgen/Docgen/Generate/Assets.lean`

**Implementation Notes:**
- Add `--theme` CLI flag for custom CSS path
- Either replace or append to default styles
- Consider theme variables for easy customization

**Estimated Effort:** Small

**Dependencies:** None

---

### [Priority: Low] JSON Export Format

**Description:** Export documentation as structured JSON for integration with other tools.

**Rationale:** JSON output enables integration with documentation hosting platforms, IDEs, or alternative renderers.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/util/docgen/Docgen/CLI.lean`
- New file `Docgen/Export/Json.lean`

**Implementation Notes:**
- Add `--format json` or `docgen export` command
- Include all DocProject, DocModule, DocItem data
- Consider JSON Schema for validation

**Estimated Effort:** Small

**Dependencies:** None

---

### [Priority: Low] Documentation Coverage Report

**Description:** Generate a report showing what percentage of declarations are documented.

**Rationale:** Helps maintainers track documentation completeness.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/util/docgen/Docgen/CLI.lean`
- `/Users/Shared/Projects/lean-workspace/util/docgen/Docgen/Extract/Module.lean`

**Implementation Notes:**
- `computeStats` already calculates documented/undocumented counts
- Add `docgen stats` command or `--show-stats` flag
- Could output as text, JSON, or HTML report

**Estimated Effort:** Small

**Dependencies:** None

---

### [Priority: Low] Example Sections in Doc Comments

**Description:** Parse and highlight example code blocks in doc comments specially.

**Rationale:** Examples are critical for documentation but currently render the same as other code blocks.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/util/docgen/Docgen/Render/Html.lean`

**Implementation Notes:**
- Detect `## Example` or `# Example` sections
- Apply special styling for example blocks
- Consider a "copy" button for examples

**Estimated Effort:** Small

**Dependencies:** Markdown rendering feature

---

## Code Improvements

### [Priority: High] Improve Typeclass Classification

**Current State:** `isClass` in Environment.lean (lines 42-46) uses `ii.isRec` which is not the correct way to detect typeclasses.

**Proposed Change:** Use `isClass` from Lean's type class machinery or check the `@[class]` attribute.

**Benefits:** Correct classification of typeclasses vs regular inductives.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/util/docgen/Docgen/Extract/Environment.lean` (lines 42-46)

**Estimated Effort:** Small

---

### [Priority: High] Use MetaM for Pretty Printing

**Current State:** `ppConstantSignature` in Signatures.lean (lines 21-25) uses raw `toString info.type` which produces verbose, hard-to-read output.

**Proposed Change:** Use `Lean.Meta.ppExpr` or similar for proper pretty-printing with implicit argument handling.

**Benefits:** More readable type signatures, consistent with what users see in Lean.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/util/docgen/Docgen/Extract/Signatures.lean` (lines 21-25)

**Implementation Notes:**
- `SignatureOptions` structure exists but isn't used
- Need to run in MetaM context

**Estimated Effort:** Medium

---

### [Priority: Medium] Eliminate Duplicate containsSubstr Helper

**Current State:** `containsSubstr` is defined in both `DocStrings.lean` (line 11-12) and `Config.lean` (lines 45-46).

**Proposed Change:** Move to a shared utilities module or use String.containsSubstr if it exists in Batteries.

**Benefits:** DRY principle, easier maintenance.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/util/docgen/Docgen/Extract/DocStrings.lean` (lines 11-12)
- `/Users/Shared/Projects/lean-workspace/util/docgen/Docgen/Core/Config.lean` (lines 44-46)

**Estimated Effort:** Small

---

### [Priority: Medium] Improve Module Name Detection

**Current State:** `getModuleFor` in Environment.lean (lines 65-68) uses name prefix as a rough approximation.

**Proposed Change:** Use actual module information from the environment.

**Benefits:** Accurate module assignment, especially for re-exported names.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/util/docgen/Docgen/Extract/Environment.lean` (lines 64-68)

**Estimated Effort:** Medium

---

### [Priority: Medium] Duplicate nameFromComponents Function

**Current State:** `nameFromComponents` is defined identically in both `Html.lean` (lines 14-15) and `Navigation.lean` (lines 44-46).

**Proposed Change:** Move to a shared module or Types.lean.

**Benefits:** DRY principle, single source of truth.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/util/docgen/Docgen/Render/Html.lean` (lines 13-15)
- `/Users/Shared/Projects/lean-workspace/util/docgen/Docgen/Render/Navigation.lean` (lines 44-46)

**Estimated Effort:** Small

---

### [Priority: Medium] Add Error Handling for File Operations

**Current State:** `writeFile` in Assets.lean doesn't handle I/O errors gracefully.

**Proposed Change:** Add proper error handling with informative messages.

**Benefits:** Better user feedback on file system errors.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/util/docgen/Docgen/Generate/Assets.lean` (lines 11-16)

**Estimated Effort:** Small

---

### [Priority: Low] Use Scribe Script Tag Helper

**Current State:** Search JavaScript is included as raw string but the HTML doesn't include a script tag in the layout.

**Proposed Change:** Add script tag to layout template to load search.js.

**Benefits:** Search functionality will actually work in generated pages.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/util/docgen/Docgen/Render/Html.lean` (layout function)

**Estimated Effort:** Small

---

### [Priority: Low] Consider Lazy Loading for Search Index

**Current State:** Search JavaScript loads entire index on page load.

**Proposed Change:** For large projects, consider lazy loading or paginated search.

**Benefits:** Better performance for large documentation sites.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/util/docgen/Docgen/Render/Search.lean`

**Estimated Effort:** Medium

---

## Code Cleanup

### [Priority: High] Remove TODO Comment and Implement Feature

**Issue:** TODO comment on line 75 of Html.lean: "Add markdown rendering"

**Location:** `/Users/Shared/Projects/lean-workspace/util/docgen/Docgen/Render/Html.lean` (line 75)

**Action Required:** Either implement markdown rendering or update comment with tracking issue.

**Estimated Effort:** Medium (if implementing), Small (if just updating comment)

---

### [Priority: Medium] Address TODO in Site.lean

**Issue:** Lines 85-86 contain: "TODO: Actually load the environment and extract docs" with a stub project.

**Location:** `/Users/Shared/Projects/lean-workspace/util/docgen/Docgen/Generate/Site.lean` (lines 84-86)

**Action Required:** Complete environment loading implementation and remove stub.

**Estimated Effort:** Large

---

### [Priority: Medium] Module Doc Extraction Placeholder

**Issue:** `getModuleDoc` returns `none` with comment noting it's incomplete.

**Location:** `/Users/Shared/Projects/lean-workspace/util/docgen/Docgen/Extract/DocStrings.lean` (lines 19-24)

**Action Required:** Implement proper module doc extraction.

**Estimated Effort:** Medium

---

### [Priority: Medium] Expand Test Coverage

**Issue:** Tests only cover basic type operations. No tests for extraction, rendering, or generation.

**Location:** `/Users/Shared/Projects/lean-workspace/util/docgen/Tests/Main.lean`

**Action Required:** Add tests for:
- DocString cleaning and extraction
- Signature pretty-printing
- HTML rendering output
- Search index generation
- Config filtering logic

**Estimated Effort:** Medium

---

### [Priority: Low] Add Type Annotations to Implicit Returns

**Issue:** Some functions use `Id.run` with mutable state but lack explicit return type annotations.

**Location:** Multiple files in Extract/ and Render/

**Action Required:** Add explicit type annotations for clarity.

**Estimated Effort:** Small

---

### [Priority: Low] Standardize Error Messages

**Issue:** Error messages in Site.lean use inconsistent formatting.

**Location:** `/Users/Shared/Projects/lean-workspace/util/docgen/Docgen/Generate/Site.lean`

**Action Required:** Create consistent error message format, consider structured errors.

**Estimated Effort:** Small

---

### [Priority: Low] Document Internal API Functions

**Issue:** Many functions lack doc comments describing their purpose and parameters.

**Location:** All source files in Docgen/

**Action Required:** Add doc comments to exported functions, especially in the Extract and Render namespaces.

**Estimated Effort:** Medium

---

## Testing Improvements

### [Priority: Medium] Integration Test with Sample Project

**Description:** Create a small sample Lean project with various declaration types and test that docgen produces expected output.

**Affected Files:**
- New `Tests/Integration/` directory
- New test fixtures

**Estimated Effort:** Medium

---

### [Priority: Medium] Snapshot Testing for HTML Output

**Description:** Use snapshot testing to verify HTML output doesn't change unexpectedly.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/util/docgen/Tests/Main.lean`
- New snapshot files

**Estimated Effort:** Small

---

### [Priority: Low] Property-Based Testing for Doc String Cleaning

**Description:** Use property-based testing to verify doc string normalization handles edge cases.

**Affected Files:**
- `/Users/Shared/Projects/lean-workspace/util/docgen/Tests/Main.lean`

**Dependencies:** Consider adding plausible dependency

**Estimated Effort:** Small

---

## Documentation Improvements

### [Priority: Medium] Add Architecture Documentation

**Description:** Document the overall architecture and data flow of docgen.

**Location:** CLAUDE.md or new ARCHITECTURE.md

**Estimated Effort:** Small

---

### [Priority: Low] Add Examples to README

**Description:** Show sample input (Lean code) and output (generated HTML) in README.

**Location:** `/Users/Shared/Projects/lean-workspace/util/docgen/README.md`

**Estimated Effort:** Small

---

## Summary

### High Priority (Should be addressed first)
1. Actual environment loading from compiled projects
2. Markdown rendering in doc comments
3. Module doc comment extraction
4. Improve typeclass classification
5. Use MetaM for pretty printing

### Medium Priority (Important improvements)
1. Source file/line extraction
2. Structure and inductive extended info
3. Typeclass instance documentation
4. Syntax highlighting
5. Hierarchical module tree navigation
6. Cross-reference links
7. Expand test coverage

### Low Priority (Nice to have)
1. Watch mode
2. Local development server
3. Custom themes
4. JSON export
5. Coverage report
6. Example sections
