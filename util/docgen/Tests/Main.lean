/-
  Docgen Tests - Main entry point
-/
import Crucible
import Docgen
-- Integration tests
import Tests.Integration.Helpers
import Tests.Integration.StapleTests
import Tests.Integration.ChronosTests

namespace Tests.Unit

open Crucible

testSuite "Docgen.Core.Types"

test "ItemKind.toString returns correct string" := do
  (Docgen.ItemKind.def_.toString) ≡ "def"
  (Docgen.ItemKind.theorem_.toString) ≡ "theorem"
  (Docgen.ItemKind.structure_.toString) ≡ "structure"

test "ItemKind.cssClass returns correct class" := do
  (Docgen.ItemKind.def_.cssClass) ≡ "def"
  (Docgen.ItemKind.class_.cssClass) ≡ "class"

test "DocItem.shortName extracts last component" := do
  let item : Docgen.DocItem := {
    name := `Foo.Bar.baz
    kind := .def_
    signature := "Nat → Nat"
  }
  item.shortName ≡ "baz"

test "DocItem.anchorId replaces dots with dashes" := do
  let item : Docgen.DocItem := {
    name := `Foo.Bar.baz
    kind := .def_
    signature := "Nat → Nat"
  }
  item.anchorId ≡ "Foo-Bar-baz"

testSuite "Docgen.Core.Config"

test "Config.getTitle returns title if set" := do
  let config : Docgen.Config := {
    projectRoot := "."
    title := some "My Project"
  }
  config.getTitle ≡ "My Project"

test "Config.shouldIncludeName filters internal names" := do
  let config : Docgen.Config := {
    projectRoot := "."
    includeInternal := false
  }
  config.shouldIncludeName `_private_foo ≡ false

testSuite "Docgen.Render.Search"

test "itemToSearchEntry creates correct entry" := do
  let mod : Docgen.DocModule := {
    name := `Test.Module
    moduleDoc := none
    items := #[]
  }
  let item : Docgen.DocItem := {
    name := `Test.Module.myFunc
    kind := .def_
    signature := "Nat → Nat"
    docString := some "A test function"
  }
  let entry := Docgen.Render.itemToSearchEntry mod item
  entry.name ≡ "myFunc"
  entry.module ≡ "Test.Module"
  entry.kind ≡ "def"



end Tests.Unit

open Crucible

def main : IO UInt32 := do
  IO.println "Docgen Tests"
  IO.println "============"
  runAllSuites
