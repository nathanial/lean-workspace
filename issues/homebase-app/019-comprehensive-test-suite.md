# Build Comprehensive Test Suite

## Summary

Expand test coverage beyond Kanban to cover all sections as they're implemented. Establish testing patterns and infrastructure.

## Current State

- Crucible test framework available
- Kanban tests exist (12 tests)
- EntityPull tests exist (8 tests)
- No tests for: Auth, Views, Routes, other sections
- No integration tests
- No end-to-end tests

## Requirements

### Test Organization

```
HomebaseApp/Tests/
  Auth.lean           -- Authentication tests
  Kanban.lean         -- Kanban CRUD tests (exists)
  EntityPull.lean     -- Entity pull tests (exists)
  Validation.lean     -- Input validation tests
  Helpers.lean        -- Helper function tests
  Views/
    Layout.lean       -- Layout rendering tests
    Kanban.lean       -- Kanban view tests
  Integration/
    KanbanFlow.lean   -- Full Kanban workflow
    AuthFlow.lean     -- Registration → Login → Use → Logout
  Fixtures/
    TestData.lean     -- Shared test data
    Mocks.lean        -- Mock objects and helpers
```

### Unit Test Categories

#### Validation Tests (when #009 implemented)

```lean
testSuite "Validation" do

  test "validateEmail accepts valid email" := do
    validateEmail "user@example.com" `shouldBeOk`

  test "validateEmail rejects empty string" := do
    validateEmail "" `shouldBeError`

  test "validateEmail rejects missing @" := do
    validateEmail "userexample.com" `shouldBeError`

  test "validatePassword rejects short passwords" := do
    validatePassword "short" `shouldBeError`

  test "validateMaxLength enforces limit" := do
    let longString := String.replicate 1000 'a'
    validateMaxLength "field" 100 longString `shouldBeError`
```

#### Helper Tests

```lean
testSuite "Helpers" do

  test "formatTimestamp produces readable date" := do
    let ts := 1703980800  -- 2023-12-31
    formatTimestamp ts `shouldContain` "2023"

  test "sanitizeInput removes HTML tags" := do
    sanitizeInput "<script>alert('xss')</script>" `shouldNotContain` "<script>"

  test "getAttrString extracts string value" := do
    let entity := makeTestEntity [
      (":user/name", .string "Alice")
    ]
    getAttrString entity ":user/name" `shouldBe` some "Alice"
```

#### View Tests

```lean
testSuite "Views.Kanban" do

  test "cardView renders title" := do
    let card := { id := 1, title := "Test Card", ... }
    let html := renderToString (Views.Kanban.cardView card)

    html `shouldContain` "Test Card"

  test "cardView renders labels as pills" := do
    let card := { id := 1, labels := "bug,urgent", ... }
    let html := renderToString (Views.Kanban.cardView card)

    html `shouldContain` "label-bug"
    html `shouldContain` "label-urgent"

  test "columnView includes add card button" := do
    let column := { id := 1, name := "Todo", cards := [] }
    let html := renderToString (Views.Kanban.columnView column)

    html `shouldContain` "Add Card"
```

#### Route Tests

```lean
testSuite "Routes" do

  test "kanban routes generate correct paths" := do
    Routes.kanban.index.path `shouldBe` "/kanban"
    Routes.kanban.showCard 5 |>.path `shouldBe` "/kanban/card/5"

  test "routes with params substitute correctly" := do
    Routes.kanban.editColumn 3 |>.path `shouldBe` "/kanban/column/3/edit"
```

### Integration Tests

```lean
testSuite "Integration.KanbanFlow" do

  test "full card lifecycle: create, edit, move, delete" := do
    let db ← createTestDb
    let userId ← createTestUser db

    -- Create column
    let colId ← Kanban.createColumn db userId "Todo"

    -- Create card in column
    let cardId ← Kanban.createCard db userId colId "New Card" "" ""

    -- Verify card exists
    let card ← Kanban.getCard db cardId
    card.isSome `shouldBe` true
    card.get!.title `shouldBe` "New Card"

    -- Edit card
    Kanban.updateCard db cardId "Updated Card" "Description" "bug"
    let updated ← Kanban.getCard db cardId
    updated.get!.title `shouldBe` "Updated Card"

    -- Create second column and move card
    let col2Id ← Kanban.createColumn db userId "Done"
    Kanban.moveCard db cardId col2Id

    let moved ← Kanban.getCard db cardId
    moved.get!.column `shouldBe` col2Id

    -- Delete card
    Kanban.deleteCard db cardId
    let deleted ← Kanban.getCard db cardId
    deleted `shouldBe` none

testSuite "Integration.AuthFlow" do

  test "registration to logout flow" := do
    let db ← createTestDb
    let ctx ← mockContext db

    -- Register
    let regResult ← Auth.register ctx {
      email := "new@example.com"
      password := "password123"
      name := "New User"
    }
    regResult.status `shouldBe` 302

    -- Login
    let loginResult ← Auth.login ctx {
      email := "new@example.com"
      password := "password123"
    }
    loginResult.status `shouldBe` 302
    let userId := loginResult.session.get! "user_id"

    -- Access protected page
    let protectedCtx := ctx.withSession loginResult.session
    let homeResult ← Home.index protectedCtx
    homeResult.status `shouldBe` 200

    -- Logout
    let logoutResult ← Auth.logout protectedCtx
    logoutResult.session.get? "user_id" `shouldBe` none

    -- Cannot access protected page
    let afterLogout ← Home.index ctx
    afterLogout.status `shouldBe` 302  -- Redirect to login
```

### Test Fixtures

```lean
-- Tests/Fixtures/TestData.lean

def sampleKanbanBoard : TestBoard := {
  columns := [
    { name := "Backlog", cards := [
      { title := "Research API options", labels := "research" },
      { title := "Setup CI/CD", labels := "devops,blocked" }
    ]},
    { name := "In Progress", cards := [
      { title := "Implement login", labels := "feature,urgent" }
    ]},
    { name := "Done", cards := [] }
  ]
}

def createSampleBoard (db : Database) (userId : EntityId) : IO Unit := do
  for col in sampleKanbanBoard.columns do
    let colId ← createColumn db userId col.name
    for card in col.cards do
      createCard db userId colId card.title "" card.labels
```

### Test Utilities

```lean
-- Tests/Fixtures/Mocks.lean

structure MockRequest where
  method : Method := .GET
  path : String := "/"
  headers : List (String × String) := []
  body : String := ""
  params : HashMap String String := {}

def mockRequest (r : MockRequest) : ActionContext → ActionContext :=
  fun ctx => { ctx with request := r.toRequest }

def withFormData (data : List (String × String)) : MockRequest → MockRequest :=
  fun req => { req with
    method := .POST
    body := encodeFormData data
    headers := [("Content-Type", "application/x-www-form-urlencoded")]
  }

-- Assertion helpers
def shouldContainHtml (html : String) (expected : String) : TestM Unit := do
  unless html.containsSubstr expected do
    throw s!"Expected HTML to contain: {expected}"

def shouldRenderWithoutErrors (view : HtmlM Unit) : TestM Unit := do
  let _ ← renderToString view  -- Should not throw
  pure ()
```

### CI Integration

```yaml
# .github/workflows/test.yml
test:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - name: Setup Lean
      uses: leanprover/lean-action@v1
    - name: Build
      run: lake build
    - name: Run tests
      run: lake test
```

## Acceptance Criteria

- [ ] Test infrastructure established
- [ ] Mock/stub helpers available
- [ ] Auth tests comprehensive
- [ ] View rendering tests
- [ ] Route generation tests
- [ ] Integration tests for key flows
- [ ] Test fixtures for common data
- [ ] All tests pass
- [ ] Tests run in CI

## Technical Notes

- Crucible framework used throughout
- Consider property-based testing (plausible)
- View tests render to string and check content
- Integration tests use real database operations
- Keep tests fast (< 1 second each)

## Priority

High - Testing prevents regressions

## Estimate

Large - Comprehensive test infrastructure
