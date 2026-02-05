import Crucible
import AgentMail

open Crucible
open AgentMail

namespace AgentMailTests.Identity

testSuite "Identity"

open AgentMail.Tools.Identity in
test "generateSlug sanitizes paths" := do
  let slug1 := generateSlug "/Users/test/my-project"
  shouldSatisfy (slug1.find? "/" |>.isNone) "slug should not contain slashes"
  shouldSatisfy (!(slug1.startsWith "-")) "slug should not start with dash"
  shouldSatisfy (!(slug1.endsWith "-")) "slug should not end with dash"

open AgentMail.Tools.Identity in
test "generateSlug handles various inputs" := do
  let slug1 := generateSlug "/foo/bar/baz"
  slug1 ≡ "foo-bar-baz"
  let slug2 := generateSlug "simple"
  slug2 ≡ "simple"

end AgentMailTests.Identity
