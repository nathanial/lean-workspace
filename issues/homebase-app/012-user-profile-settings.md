# Add User Profile and Settings Page

## Summary

Users currently have no way to view or edit their profile, change their password, or configure preferences. Add a settings section.

## Current State

- Users have: email, password-hash, name
- No profile view page
- No password change functionality
- No user preferences stored
- No account deletion option

## Requirements

### Data Model Additions

```lean
-- User preferences (add to Models.lean)
def userTimezone : LedgerAttribute := ⟨":user/timezone", .string, .one⟩
def userDateFormat : LedgerAttribute := ⟨":user/date-format", .string, .one⟩
def userTheme : LedgerAttribute := ⟨":user/theme", .string, .one⟩

-- Extended user structure
structure UserProfile where
  id : Nat
  email : String
  name : String
  timezone : String           -- e.g., "America/New_York"
  dateFormat : String         -- e.g., "MM/DD/YYYY" or "DD/MM/YYYY"
  theme : String              -- e.g., "light", "dark", "system"
  createdAt : Nat
  deriving Repr, BEq
```

### Routes

```
GET  /settings                    → Settings overview
GET  /settings/profile            → Profile edit form
PUT  /settings/profile            → Update profile
GET  /settings/password           → Password change form
PUT  /settings/password           → Change password
GET  /settings/preferences        → Preferences form
PUT  /settings/preferences        → Update preferences
POST /settings/delete-account     → Delete account (with confirmation)
GET  /settings/export             → Export user data
```

### Actions (Actions/Settings.lean)

```lean
def index : ActionM Unit := do
  requireAuth
  -- Show settings overview with links to subsections

def profileForm : ActionM Unit := do
  requireAuth
  let user ← getCurrentUser
  render (Views.Settings.profileForm user)

def updateProfile : ActionM Unit := do
  requireAuth
  let name ← param "name"
  let email ← param "email"
  -- Validate and update
  -- If email changed, may need re-verification

def passwordForm : ActionM Unit := do
  requireAuth
  render Views.Settings.passwordForm

def updatePassword : ActionM Unit := do
  requireAuth
  let currentPassword ← param "current_password"
  let newPassword ← param "new_password"
  let confirmPassword ← param "confirm_password"
  -- Verify current password
  -- Validate new password
  -- Update hash

def preferencesForm : ActionM Unit := do
  requireAuth
  let user ← getCurrentUser
  render (Views.Settings.preferencesForm user)

def updatePreferences : ActionM Unit := do
  requireAuth
  let timezone ← param "timezone"
  let dateFormat ← param "date_format"
  let theme ← param "theme"
  -- Update preferences

def deleteAccount : ActionM Unit := do
  requireAuth
  let confirmation ← param "confirm"
  if confirmation == "DELETE" then
    -- Delete all user data
    -- Log out
    -- Redirect to home
  else
    flash "error" "Type DELETE to confirm"

def exportData : ActionM Unit := do
  requireAuth
  let userId ← currentUserId
  -- Generate JSON export of all user data
  -- Return as download
```

### Views (Views/Settings.lean)

```lean
def index : HtmlM Unit := do
  layout "Settings" do
    h1 do text "Settings"

    div [class "settings-menu"] do
      a [href "/settings/profile"] do text "Profile"
      a [href "/settings/password"] do text "Change Password"
      a [href "/settings/preferences"] do text "Preferences"
      a [href "/settings/export"] do text "Export Data"
      a [href "/settings/delete-account", class "danger"] do text "Delete Account"

def profileForm (user : UserProfile) : HtmlM Unit := do
  layout "Edit Profile" do
    h1 do text "Edit Profile"

    form [method "post", action "/settings/profile"] do
      csrfToken

      label do text "Name"
      input [type "text", name "name", value user.name]

      label do text "Email"
      input [type "email", name "email", value user.email]

      button [type "submit"] do text "Save Changes"

def passwordForm : HtmlM Unit := do
  layout "Change Password" do
    h1 do text "Change Password"

    form [method "post", action "/settings/password"] do
      csrfToken

      label do text "Current Password"
      input [type "password", name "current_password"]

      label do text "New Password"
      input [type "password", name "new_password"]

      label do text "Confirm New Password"
      input [type "password", name "confirm_password"]

      button [type "submit"] do text "Change Password"

def preferencesForm (user : UserProfile) : HtmlM Unit := do
  layout "Preferences" do
    h1 do text "Preferences"

    form [method "post", action "/settings/preferences"] do
      csrfToken

      label do text "Theme"
      select [name "theme"] do
        option [value "light", selected (user.theme == "light")] do text "Light"
        option [value "dark", selected (user.theme == "dark")] do text "Dark"
        option [value "system", selected (user.theme == "system")] do text "System"

      label do text "Date Format"
      select [name "date_format"] do
        option [value "MM/DD/YYYY"] do text "MM/DD/YYYY"
        option [value "DD/MM/YYYY"] do text "DD/MM/YYYY"
        option [value "YYYY-MM-DD"] do text "YYYY-MM-DD"

      label do text "Timezone"
      select [name "timezone"] do
        -- Common timezones
        option [value "America/New_York"] do text "Eastern Time"
        option [value "America/Chicago"] do text "Central Time"
        option [value "America/Denver"] do text "Mountain Time"
        option [value "America/Los_Angeles"] do text "Pacific Time"
        option [value "UTC"] do text "UTC"

      button [type "submit"] do text "Save Preferences"

def deleteAccountForm : HtmlM Unit := do
  layout "Delete Account" do
    h1 [class "danger"] do text "Delete Account"

    div [class "warning"] do
      text "This action is permanent and cannot be undone."
      text " All your data will be deleted."

    form [method "post", action "/settings/delete-account"] do
      csrfToken

      label do text "Type DELETE to confirm:"
      input [type "text", name "confirm", placeholder "DELETE"]

      button [type "submit", class "danger"] do text "Delete My Account"
```

### Layout Integration

Add settings link to navbar:

```lean
-- In Layout.lean navbar
a [href "/settings"] do text "Settings"
```

## Acceptance Criteria

- [ ] Settings page accessible from navbar
- [ ] Users can edit name and email
- [ ] Users can change password (requires current password)
- [ ] Users can set theme preference
- [ ] Users can set timezone and date format
- [ ] Users can export all their data as JSON
- [ ] Users can delete their account (with confirmation)
- [ ] All changes logged in audit log

## Technical Notes

- Password change requires verifying current password first
- Email change may need verification workflow (future)
- Theme preference needs CSS variable support
- Data export should include all user entities
- Account deletion must cascade to all owned entities

## Priority

Medium - Important for user control over data

## Estimate

Medium - Multiple forms + data export logic
