/-
  Scribe.AttrValues - Type-safe attribute value enums

  Provides enumerated types for common HTML attribute values,
  enabling compile-time validation of attribute values.

  Usage:
  ```lean
  import Scribe

  open Scribe in
  def loginForm : HtmlM Unit := do
    form [formMethod .post, formAction "/login"] do
      input [inputType .email, name_ "email", required_]
      input [inputType .password, name_ "password", required_]
      button [buttonType .submit] (text "Log In")
  ```
-/
import Scribe.Html

namespace Scribe

-- ============================================================================
-- Input Types
-- ============================================================================

/-- HTML input element types -/
inductive InputType where
  | text
  | password
  | email
  | number
  | tel
  | url
  | search
  | date
  | time
  | datetimeLocal
  | month
  | week
  | color
  | file
  | hidden
  | checkbox
  | radio
  | range
  | submit
  | reset
  | button
  | image
  deriving Repr, BEq

namespace InputType
def toString : InputType → String
  | .text => "text"
  | .password => "password"
  | .email => "email"
  | .number => "number"
  | .tel => "tel"
  | .url => "url"
  | .search => "search"
  | .date => "date"
  | .time => "time"
  | .datetimeLocal => "datetime-local"
  | .month => "month"
  | .week => "week"
  | .color => "color"
  | .file => "file"
  | .hidden => "hidden"
  | .checkbox => "checkbox"
  | .radio => "radio"
  | .range => "range"
  | .submit => "submit"
  | .reset => "reset"
  | .button => "button"
  | .image => "image"

instance : ToString InputType := ⟨toString⟩
end InputType

/-- Type-safe input type attribute -/
def inputType (t : InputType) : Attr := ⟨"type", t.toString⟩

-- ============================================================================
-- Button Types
-- ============================================================================

/-- HTML button element types -/
inductive ButtonType where
  | submit
  | reset
  | button
  deriving Repr, BEq

namespace ButtonType
def toString : ButtonType → String
  | .submit => "submit"
  | .reset => "reset"
  | .button => "button"

instance : ToString ButtonType := ⟨toString⟩
end ButtonType

/-- Type-safe button type attribute -/
def buttonType (t : ButtonType) : Attr := ⟨"type", t.toString⟩

-- ============================================================================
-- Form Methods
-- ============================================================================

/-- HTTP methods for form submission -/
inductive FormMethod where
  | get
  | post
  | dialog
  deriving Repr, BEq

namespace FormMethod
def toString : FormMethod → String
  | .get => "GET"
  | .post => "POST"
  | .dialog => "dialog"

instance : ToString FormMethod := ⟨toString⟩
end FormMethod

/-- Type-safe form method attribute -/
def formMethod (m : FormMethod) : Attr := ⟨"method", m.toString⟩

-- ============================================================================
-- Form Encoding Types
-- ============================================================================

/-- Form encoding types -/
inductive FormEnctype where
  | urlencoded
  | multipart
  | plain
  deriving Repr, BEq

namespace FormEnctype
def toString : FormEnctype → String
  | .urlencoded => "application/x-www-form-urlencoded"
  | .multipart => "multipart/form-data"
  | .plain => "text/plain"

instance : ToString FormEnctype := ⟨toString⟩
end FormEnctype

/-- Type-safe form enctype attribute -/
def formEnctype (e : FormEnctype) : Attr := ⟨"enctype", e.toString⟩

-- ============================================================================
-- Target Values
-- ============================================================================

/-- Target window/frame values -/
inductive Target where
  | self
  | blank
  | parent
  | top
  deriving Repr, BEq

namespace Target
def toString : Target → String
  | .self => "_self"
  | .blank => "_blank"
  | .parent => "_parent"
  | .top => "_top"

instance : ToString Target := ⟨toString⟩
end Target

/-- Type-safe target attribute -/
def target (t : Target) : Attr := ⟨"target", t.toString⟩

-- ============================================================================
-- Autocomplete Values
-- ============================================================================

/-- Common autocomplete values -/
inductive Autocomplete where
  | off
  | on
  | name
  | honorificPrefix
  | givenName
  | additionalName
  | familyName
  | honorificSuffix
  | nickname
  | email
  | username
  | newPassword
  | currentPassword
  | oneTimeCode
  | organizationTitle
  | organization
  | streetAddress
  | addressLine1
  | addressLine2
  | addressLine3
  | addressLevel1
  | addressLevel2
  | addressLevel3
  | addressLevel4
  | country
  | countryName
  | postalCode
  | ccName
  | ccGivenName
  | ccAdditionalName
  | ccFamilyName
  | ccNumber
  | ccExp
  | ccExpMonth
  | ccExpYear
  | ccCsc
  | ccType
  | transactionCurrency
  | transactionAmount
  | language
  | bday
  | bdayDay
  | bdayMonth
  | bdayYear
  | sex
  | tel
  | telCountryCode
  | telNational
  | telAreaCode
  | telLocal
  | telExtension
  | impp
  | url
  | photo
  deriving Repr, BEq

namespace Autocomplete
def toString : Autocomplete → String
  | .off => "off"
  | .on => "on"
  | .name => "name"
  | .honorificPrefix => "honorific-prefix"
  | .givenName => "given-name"
  | .additionalName => "additional-name"
  | .familyName => "family-name"
  | .honorificSuffix => "honorific-suffix"
  | .nickname => "nickname"
  | .email => "email"
  | .username => "username"
  | .newPassword => "new-password"
  | .currentPassword => "current-password"
  | .oneTimeCode => "one-time-code"
  | .organizationTitle => "organization-title"
  | .organization => "organization"
  | .streetAddress => "street-address"
  | .addressLine1 => "address-line1"
  | .addressLine2 => "address-line2"
  | .addressLine3 => "address-line3"
  | .addressLevel1 => "address-level1"
  | .addressLevel2 => "address-level2"
  | .addressLevel3 => "address-level3"
  | .addressLevel4 => "address-level4"
  | .country => "country"
  | .countryName => "country-name"
  | .postalCode => "postal-code"
  | .ccName => "cc-name"
  | .ccGivenName => "cc-given-name"
  | .ccAdditionalName => "cc-additional-name"
  | .ccFamilyName => "cc-family-name"
  | .ccNumber => "cc-number"
  | .ccExp => "cc-exp"
  | .ccExpMonth => "cc-exp-month"
  | .ccExpYear => "cc-exp-year"
  | .ccCsc => "cc-csc"
  | .ccType => "cc-type"
  | .transactionCurrency => "transaction-currency"
  | .transactionAmount => "transaction-amount"
  | .language => "language"
  | .bday => "bday"
  | .bdayDay => "bday-day"
  | .bdayMonth => "bday-month"
  | .bdayYear => "bday-year"
  | .sex => "sex"
  | .tel => "tel"
  | .telCountryCode => "tel-country-code"
  | .telNational => "tel-national"
  | .telAreaCode => "tel-area-code"
  | .telLocal => "tel-local"
  | .telExtension => "tel-extension"
  | .impp => "impp"
  | .url => "url"
  | .photo => "photo"

instance : ToString Autocomplete := ⟨toString⟩
end Autocomplete

/-- Type-safe autocomplete attribute -/
def autocomplete (a : Autocomplete) : Attr := ⟨"autocomplete", a.toString⟩

-- ============================================================================
-- Loading Strategy
-- ============================================================================

/-- Image/iframe loading strategies -/
inductive Loading where
  | eager
  | lazy
  deriving Repr, BEq

namespace Loading
def toString : Loading → String
  | .eager => "eager"
  | .lazy => "lazy"

instance : ToString Loading := ⟨toString⟩
end Loading

/-- Type-safe loading attribute -/
def loading (l : Loading) : Attr := ⟨"loading", l.toString⟩

-- ============================================================================
-- Cross-Origin
-- ============================================================================

/-- Cross-origin resource sharing modes -/
inductive CrossOrigin where
  | anonymous
  | useCredentials
  deriving Repr, BEq

namespace CrossOrigin
def toString : CrossOrigin → String
  | .anonymous => "anonymous"
  | .useCredentials => "use-credentials"

instance : ToString CrossOrigin := ⟨toString⟩
end CrossOrigin

/-- Type-safe crossorigin attribute -/
def crossorigin (c : CrossOrigin) : Attr := ⟨"crossorigin", c.toString⟩

-- ============================================================================
-- Referrer Policy
-- ============================================================================

/-- Referrer policy values -/
inductive ReferrerPolicy where
  | noReferrer
  | noReferrerWhenDowngrade
  | origin
  | originWhenCrossOrigin
  | sameOrigin
  | strictOrigin
  | strictOriginWhenCrossOrigin
  | unsafeUrl
  deriving Repr, BEq

namespace ReferrerPolicy
def toString : ReferrerPolicy → String
  | .noReferrer => "no-referrer"
  | .noReferrerWhenDowngrade => "no-referrer-when-downgrade"
  | .origin => "origin"
  | .originWhenCrossOrigin => "origin-when-cross-origin"
  | .sameOrigin => "same-origin"
  | .strictOrigin => "strict-origin"
  | .strictOriginWhenCrossOrigin => "strict-origin-when-cross-origin"
  | .unsafeUrl => "unsafe-url"

instance : ToString ReferrerPolicy := ⟨toString⟩
end ReferrerPolicy

/-- Type-safe referrerpolicy attribute -/
def referrerPolicy (r : ReferrerPolicy) : Attr := ⟨"referrerpolicy", r.toString⟩

-- ============================================================================
-- Rel Values (for links)
-- ============================================================================

/-- Link relationship types -/
inductive Rel where
  | alternate
  | author
  | bookmark
  | canonical
  | dnsPrefetch
  | external
  | help
  | icon
  | license
  | manifest
  | modulepreload
  | next
  | nofollow
  | noopener
  | noreferrer
  | opener
  | pingback
  | preconnect
  | prefetch
  | preload
  | prerender
  | prev
  | search
  | stylesheet
  | tag
  deriving Repr, BEq

namespace Rel
def toString : Rel → String
  | .alternate => "alternate"
  | .author => "author"
  | .bookmark => "bookmark"
  | .canonical => "canonical"
  | .dnsPrefetch => "dns-prefetch"
  | .external => "external"
  | .help => "help"
  | .icon => "icon"
  | .license => "license"
  | .manifest => "manifest"
  | .modulepreload => "modulepreload"
  | .next => "next"
  | .nofollow => "nofollow"
  | .noopener => "noopener"
  | .noreferrer => "noreferrer"
  | .opener => "opener"
  | .pingback => "pingback"
  | .preconnect => "preconnect"
  | .prefetch => "prefetch"
  | .preload => "preload"
  | .prerender => "prerender"
  | .prev => "prev"
  | .search => "search"
  | .stylesheet => "stylesheet"
  | .tag => "tag"

instance : ToString Rel := ⟨toString⟩
end Rel

/-- Type-safe rel attribute -/
def rel (r : Rel) : Attr := ⟨"rel", r.toString⟩

/-- Type-safe rel attribute with multiple values -/
def rels (rs : List Rel) : Attr := ⟨"rel", String.intercalate " " (rs.map Rel.toString)⟩

-- ============================================================================
-- Wrap (for textarea)
-- ============================================================================

/-- Textarea wrap modes -/
inductive Wrap where
  | soft
  | hard
  | off
  deriving Repr, BEq

namespace Wrap
def toString : Wrap → String
  | .soft => "soft"
  | .hard => "hard"
  | .off => "off"

instance : ToString Wrap := ⟨toString⟩
end Wrap

/-- Type-safe wrap attribute -/
def wrap (w : Wrap) : Attr := ⟨"wrap", w.toString⟩

-- ============================================================================
-- Dir (text direction)
-- ============================================================================

/-- Text direction values -/
inductive Dir where
  | ltr
  | rtl
  | auto
  deriving Repr, BEq

namespace Dir
def toString : Dir → String
  | .ltr => "ltr"
  | .rtl => "rtl"
  | .auto => "auto"

instance : ToString Dir := ⟨toString⟩
end Dir

/-- Type-safe dir attribute -/
def dir (d : Dir) : Attr := ⟨"dir", d.toString⟩

-- ============================================================================
-- Inputmode
-- ============================================================================

/-- Virtual keyboard modes -/
inductive Inputmode where
  | none
  | text
  | decimal
  | numeric
  | tel
  | search
  | email
  | url
  deriving Repr, BEq

namespace Inputmode
def toString : Inputmode → String
  | .none => "none"
  | .text => "text"
  | .decimal => "decimal"
  | .numeric => "numeric"
  | .tel => "tel"
  | .search => "search"
  | .email => "email"
  | .url => "url"

instance : ToString Inputmode := ⟨toString⟩
end Inputmode

/-- Type-safe inputmode attribute -/
def inputmode (i : Inputmode) : Attr := ⟨"inputmode", i.toString⟩

-- ============================================================================
-- Scope (for table headers)
-- ============================================================================

/-- Table header scope values -/
inductive Scope where
  | row
  | col
  | rowgroup
  | colgroup
  deriving Repr, BEq

namespace Scope
def toString : Scope → String
  | .row => "row"
  | .col => "col"
  | .rowgroup => "rowgroup"
  | .colgroup => "colgroup"

instance : ToString Scope := ⟨toString⟩
end Scope

/-- Type-safe scope attribute -/
def scope (s : Scope) : Attr := ⟨"scope", s.toString⟩

-- ============================================================================
-- Preload (for media)
-- ============================================================================

/-- Media preload values -/
inductive Preload where
  | none
  | metadata
  | auto
  deriving Repr, BEq

namespace Preload
def toString : Preload → String
  | .none => "none"
  | .metadata => "metadata"
  | .auto => "auto"

instance : ToString Preload := ⟨toString⟩
end Preload

/-- Type-safe preload attribute -/
def preload (p : Preload) : Attr := ⟨"preload", p.toString⟩

-- ============================================================================
-- Sandbox (for iframes)
-- ============================================================================

/-- Iframe sandbox permissions -/
inductive SandboxPermission where
  | allowForms
  | allowModals
  | allowOrientationLock
  | allowPointerLock
  | allowPopups
  | allowPopupsToEscapeSandbox
  | allowPresentation
  | allowSameOrigin
  | allowScripts
  | allowTopNavigation
  | allowTopNavigationByUserActivation
  deriving Repr, BEq

namespace SandboxPermission
def toString : SandboxPermission → String
  | .allowForms => "allow-forms"
  | .allowModals => "allow-modals"
  | .allowOrientationLock => "allow-orientation-lock"
  | .allowPointerLock => "allow-pointer-lock"
  | .allowPopups => "allow-popups"
  | .allowPopupsToEscapeSandbox => "allow-popups-to-escape-sandbox"
  | .allowPresentation => "allow-presentation"
  | .allowSameOrigin => "allow-same-origin"
  | .allowScripts => "allow-scripts"
  | .allowTopNavigation => "allow-top-navigation"
  | .allowTopNavigationByUserActivation => "allow-top-navigation-by-user-activation"

instance : ToString SandboxPermission := ⟨toString⟩
end SandboxPermission

/-- Type-safe sandbox attribute (empty = maximum restrictions) -/
def sandbox : Attr := ⟨"sandbox", ""⟩

/-- Type-safe sandbox attribute with specific permissions -/
def sandboxAllow (permissions : List SandboxPermission) : Attr :=
  ⟨"sandbox", String.intercalate " " (permissions.map SandboxPermission.toString)⟩

-- ============================================================================
-- HTMX Swap Modes
-- ============================================================================

/-- HTMX swap strategies -/
inductive HxSwap where
  | innerHTML
  | outerHTML
  | beforebegin
  | afterbegin
  | beforeend
  | afterend
  | delete
  | none
  deriving Repr, BEq

namespace HxSwap
def toString : HxSwap → String
  | .innerHTML => "innerHTML"
  | .outerHTML => "outerHTML"
  | .beforebegin => "beforebegin"
  | .afterbegin => "afterbegin"
  | .beforeend => "beforeend"
  | .afterend => "afterend"
  | .delete => "delete"
  | .none => "none"

instance : ToString HxSwap := ⟨toString⟩
end HxSwap

/-- Type-safe hx-swap attribute -/
def hxSwap (s : HxSwap) : Attr := ⟨"hx-swap", s.toString⟩

/-- Type-safe hx-swap with modifiers (e.g., "innerHTML swap:1s") -/
def hxSwapWith (s : HxSwap) (modifiers : String) : Attr :=
  ⟨"hx-swap", s!"{s.toString} {modifiers}"⟩

-- ============================================================================
-- HTMX Trigger Events
-- ============================================================================

/-- Common HTMX trigger events -/
inductive HxTriggerEvent where
  | click
  | change
  | submit
  | load
  | revealed
  | intersect
  | every (interval : String)
  deriving Repr, BEq

namespace HxTriggerEvent
def toString : HxTriggerEvent → String
  | .click => "click"
  | .change => "change"
  | .submit => "submit"
  | .load => "load"
  | .revealed => "revealed"
  | .intersect => "intersect"
  | .every interval => s!"every {interval}"

instance : ToString HxTriggerEvent := ⟨toString⟩
end HxTriggerEvent

/-- Type-safe hx-trigger attribute -/
def hxTrigger (e : HxTriggerEvent) : Attr := ⟨"hx-trigger", e.toString⟩

/-- Type-safe hx-trigger with modifiers -/
def hxTriggerWith (e : HxTriggerEvent) (modifiers : String) : Attr :=
  ⟨"hx-trigger", s!"{e.toString} {modifiers}"⟩

end Scribe
