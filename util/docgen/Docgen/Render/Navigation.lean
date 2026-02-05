/-
  Docgen.Render.Navigation - Sidebar and navigation rendering
-/
import Scribe
import Docgen.Core.Types

namespace Docgen.Render

open Scribe

/-- Group modules by top-level namespace -/
def groupModulesByNamespace (modules : Array DocModule) : Array (String × Array DocModule) := Id.run do
  let mut groups : Std.HashMap String (Array DocModule) := {}

  for mod in modules do
    let topLevel := match mod.name.components.head? with
      | some n => n.toString
      | none => "Other"
    let existing := groups.getD topLevel #[]
    groups := groups.insert topLevel (existing.push mod)

  -- Convert to sorted array
  groups.toArray.qsort (fun a b => a.1 < b.1)

/-- Render sidebar for a project -/
def renderSidebar (project : DocProject) (currentModule : Option Lean.Name := none) : HtmlM Unit := do
  div [class_ "sidebar-header"] do
    a [href_ "index.html", class_ "project-name"] do
      h2 [] do HtmlM.text project.name

  let grouped := groupModulesByNamespace project.modules

  for (namespace_, mods) in grouped do
    h2 [] do HtmlM.text namespace_
    ul [] do
      for mod in mods do
        if mod.hasItems then
          let isActive := currentModule == some mod.name
          let activeClass := if isActive then " active" else ""
          li [] do
            a [href_ mod.toFilePath, class_ s!"sidebar-link{activeClass}"] do
              HtmlM.text mod.shortName

/-- Build a name from components -/
private def nameFromComponents (components : List Lean.Name) : Lean.Name :=
  components.foldl (init := Lean.Name.anonymous) fun acc n => acc ++ n

/-- Render breadcrumb navigation -/
def renderBreadcrumb (project : DocProject) (moduleName : Lean.Name) : HtmlM Unit := do
  nav [class_ "breadcrumb"] do
    a [href_ "index.html"] do HtmlM.text project.name

    let components := moduleName.components
    for i in [:components.length] do
      span [class_ "separator"] do HtmlM.text " / "
      let partialName := nameFromComponents (components.take (i + 1))
      if i < components.length - 1 then
        -- Link to parent module
        let href := partialName.toString.replace "." "/" ++ ".html"
        a [href_ href] do HtmlM.text components[i]!.toString
      else
        -- Current module (no link)
        span [class_ "current"] do HtmlM.text components[i]!.toString

/-- Render a flat module list (simpler than tree) -/
def renderModuleList (modules : Array DocModule) (currentModule : Option Lean.Name := none) : HtmlM Unit := do
  ul [class_ "module-list"] do
    for mod in modules do
      if mod.hasItems then
        let isActive := currentModule == some mod.name
        let activeClass := if isActive then " active" else ""
        li [] do
          a [href_ mod.toFilePath, class_ s!"module-link{activeClass}"] do
            HtmlM.text mod.name.toString

end Docgen.Render
