# Add Test Coverage for Authentication

## Summary

The authentication system lacks test coverage. Add comprehensive tests for registration, login, logout, and session management.

## Current State

- Auth implementation in `Actions/Auth.lean`
- Password hashing in `Helpers.lean`
- Session management via Loom
- No tests for auth functionality

## Requirements

### Test Cases

#### Registration Tests

```lean
testSuite "Auth.Registration" do

  test "successful registration creates user" := do
    let db ← createTestDb
    let ctx ← mockContext db

    -- Register new user
    let result ← Auth.register ctx {
      email := "test@example.com"
      password := "password123"
      name := "Test User"
    }

    -- Verify user created
    let user ← findUserByEmail db "test@example.com"
    user.isSome `shouldBe` true
    result.status `shouldBe` 302  -- Redirect

  test "registration fails with duplicate email" := do
    let db ← createTestDb
    let ctx ← mockContext db

    -- Create existing user
    createUser db "existing@example.com" "password" "Existing"

    -- Try to register with same email
    let result ← Auth.register ctx {
      email := "existing@example.com"
      password := "newpassword"
      name := "New User"
    }

    -- Should fail
    result.flash `shouldContain` "Email already registered"

  test "registration fails with empty email" := do
    let db ← createTestDb
    let ctx ← mockContext db

    let result ← Auth.register ctx {
      email := ""
      password := "password123"
      name := "Test"
    }

    result.flash `shouldContain` "Email and password required"

  test "registration fails with empty password" := do
    let db ← createTestDb
    let ctx ← mockContext db

    let result ← Auth.register ctx {
      email := "test@example.com"
      password := ""
      name := "Test"
    }

    result.flash `shouldContain` "Email and password required"

  test "password is hashed, not stored plain" := do
    let db ← createTestDb
    let ctx ← mockContext db

    Auth.register ctx {
      email := "test@example.com"
      password := "mypassword"
      name := "Test"
    }

    let user ← findUserByEmail db "test@example.com"
    let hash := user.get!.passwordHash

    hash `shouldNotBe` "mypassword"
    hash.length `shouldBeGreaterThan` 0
```

#### Login Tests

```lean
testSuite "Auth.Login" do

  test "successful login sets session" := do
    let db ← createTestDb
    createUser db "test@example.com" "password123" "Test"
    let ctx ← mockContext db

    let result ← Auth.login ctx {
      email := "test@example.com"
      password := "password123"
    }

    result.status `shouldBe` 302
    result.session.get? "user_id" `shouldBeSome`

  test "login fails with wrong password" := do
    let db ← createTestDb
    createUser db "test@example.com" "password123" "Test"
    let ctx ← mockContext db

    let result ← Auth.login ctx {
      email := "test@example.com"
      password := "wrongpassword"
    }

    result.flash `shouldContain` "Invalid email or password"
    result.session.get? "user_id" `shouldBe` none

  test "login fails with non-existent email" := do
    let db ← createTestDb
    let ctx ← mockContext db

    let result ← Auth.login ctx {
      email := "nobody@example.com"
      password := "password"
    }

    result.flash `shouldContain` "Invalid email or password"

  test "login is case-insensitive for email" := do
    let db ← createTestDb
    createUser db "test@example.com" "password123" "Test"
    let ctx ← mockContext db

    let result ← Auth.login ctx {
      email := "TEST@EXAMPLE.COM"
      password := "password123"
    }

    result.status `shouldBe` 302  -- Should succeed
```

#### Logout Tests

```lean
testSuite "Auth.Logout" do

  test "logout clears session" := do
    let db ← createTestDb
    let ctx ← mockContextWithSession db { user_id := "123" }

    let result ← Auth.logout ctx

    result.session.get? "user_id" `shouldBe` none
    result.status `shouldBe` 302

  test "logout redirects to home" := do
    let db ← createTestDb
    let ctx ← mockContextWithSession db { user_id := "123" }

    let result ← Auth.logout ctx

    result.redirectUrl `shouldBe` "/"
```

#### Session Tests

```lean
testSuite "Auth.Session" do

  test "requireAuth allows authenticated users" := do
    let db ← createTestDb
    let ctx ← mockContextWithSession db { user_id := "123" }

    let result ← requireAuth ctx (fun _ => pure (ok "allowed"))

    result.body `shouldBe` "allowed"

  test "requireAuth redirects unauthenticated users" := do
    let db ← createTestDb
    let ctx ← mockContext db  -- No session

    let result ← requireAuth ctx (fun _ => pure (ok "allowed"))

    result.status `shouldBe` 302
    result.redirectUrl `shouldBe` "/login"

  test "currentUserId returns user from session" := do
    let db ← createTestDb
    let ctx ← mockContextWithSession db { user_id := "456" }

    let userId ← currentUserId ctx

    userId `shouldBe` some 456

  test "currentUserName returns name from database" := do
    let db ← createTestDb
    let userId ← createUser db "test@example.com" "pass" "Alice"
    let ctx ← mockContextWithSession db { user_id := toString userId }

    let name ← currentUserName ctx

    name `shouldBe` some "Alice"
```

#### Password Hashing Tests

```lean
testSuite "Helpers.Password" do

  test "hashPassword produces consistent hash for same input" := do
    let hash1 := hashPassword "mypassword"
    let hash2 := hashPassword "mypassword"

    hash1 `shouldBe` hash2

  test "hashPassword produces different hashes for different inputs" := do
    let hash1 := hashPassword "password1"
    let hash2 := hashPassword "password2"

    hash1 `shouldNotBe` hash2

  test "verifyPassword returns true for correct password" := do
    let hash := hashPassword "correctpassword"
    let result := verifyPassword "correctpassword" hash

    result `shouldBe` true

  test "verifyPassword returns false for wrong password" := do
    let hash := hashPassword "correctpassword"
    let result := verifyPassword "wrongpassword" hash

    result `shouldBe` false

  test "hash is not reversible to original password" := do
    let hash := hashPassword "secret"

    -- Hash should not contain original password
    hash.containsSubstr "secret" `shouldBe` false
```

### Test Infrastructure

```lean
-- Tests/TestHelpers.lean

def createTestDb : IO Database := do
  -- Create in-memory or temp file database
  Database.connect ":memory:"

def mockContext (db : Database) : IO ActionContext := do
  pure {
    request := { method := .GET, path := "/", headers := [], body := "" }
    db := db
    session := HashMap.empty
    params := HashMap.empty
  }

def mockContextWithSession (db : Database) (session : HashMap String String) : IO ActionContext := do
  pure {
    request := { method := .GET, path := "/", headers := [], body := "" }
    db := db
    session := session
    params := HashMap.empty
  }

def createUser (db : Database) (email password name : String) : IO EntityId := do
  let hash := hashPassword password
  db.transact [
    .tempid "user" |>.add ":user/email" (.string email)
    .tempid "user" |>.add ":user/password-hash" (.string hash)
    .tempid "user" |>.add ":user/name" (.string name)
  ]
```

## Acceptance Criteria

- [ ] Registration success/failure tests
- [ ] Login success/failure tests
- [ ] Logout tests
- [ ] Session management tests
- [ ] Password hashing tests
- [ ] Test helpers for auth scenarios
- [ ] All tests passing
- [ ] Tests run in CI

## Technical Notes

- Use Crucible test framework
- May need mock/stub infrastructure for ActionContext
- Consider property-based tests for password hashing
- Isolated test database per test

## Priority

High - Auth is security-critical

## Estimate

Medium - Test infrastructure + comprehensive cases
