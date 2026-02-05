/-
  Docgen.Render.Html - HTML page templates using Scribe
-/
import Scribe
import Staple
import Docgen.Core.Types
import Docgen.Core.Config

namespace Docgen.Render

open Scribe

/-- Build a name from components -/
private def nameFromComponents (components : List Lean.Name) : Lean.Name :=
  components.foldl (init := Lean.Name.anonymous) fun acc n => acc ++ n

/-- Embedded CSS (compile-time) -/
def stylesCss : String := include_str% "../../assets/style.css"

/-- Base HTML layout -/
def layout (pageTitle : String) (projectName : String)
    (sidebar : HtmlM Unit) (content : HtmlM Unit) : HtmlM Unit := do
  doctype
  html [lang_ "en"] do
    head [] do
      meta_ [⟨"charset", "utf-8"⟩]
      meta_ [name_ "viewport", ⟨"content", "width=device-width, initial-scale=1"⟩]
      meta_ [name_ "generator", ⟨"content", "docgen"⟩]
      title s!"{pageTitle} - {projectName}"
      style [] stylesCss
    body [] do
      div [class_ "container"] do
        aside [class_ "sidebar"] do
          div [class_ "search-box"] do
            input [type_ "text", placeholder_ "Search...", id_ "search-input"]
          sidebar
        main [class_ "content"] content

/-- Render kind badge -/
def kindBadge (kind : ItemKind) : HtmlM Unit := do
  span [class_ s!"kind-badge kind-{kind.cssClass}"] do
    HtmlM.text kind.toString

/-- Render a doc item -/
def renderItem (item : DocItem) (config : Config) : HtmlM Unit := do
  article [class_ "doc-item", id_ item.anchorId] do
    -- Header with kind badge and name
    div [class_ "item-header"] do
      kindBadge item.kind
      h3 [class_ "item-name"] do
        code [] do
          HtmlM.text item.shortName

      -- Source link if available
      match item.sourceFile, item.sourceLine with
      | some file, some line =>
        match config.buildSourceUrl file line with
        | some url =>
          a [class_ "source-link", href_ url, target_ "_blank"] do
            HtmlM.text "[source]"
        | none => pure ()
      | _, _ => pure ()

    -- Type signature
    div [class_ "signature"] do
      pre [] do
        code [class_ "language-lean"] do
          HtmlM.text item.signature

    -- Doc comment
    match item.docString with
    | some doc =>
      div [class_ "doc-comment"] do
        -- Simple rendering - treat as preformatted for now
        -- TODO: Add markdown rendering
        for para in doc.splitOn "\n\n" do
          p [] do HtmlM.text para.trim
    | none => pure ()

/-- Render table of contents -/
def renderToc (items : Array DocItem) : HtmlM Unit := do
  if items.isEmpty then return ()
  nav [class_ "toc"] do
    h2 [] do HtmlM.text "Contents"
    ul [] do
      for item in items do
        li [] do
          a [href_ s!"#{item.anchorId}"] do
            span [class_ s!"kind-badge kind-{item.kind.cssClass}"] do
              HtmlM.text item.kind.toString
            HtmlM.text " "
            HtmlM.text item.shortName

/-- Render module page -/
def renderModulePage (mod : DocModule) (project : DocProject) (config : Config)
    (sidebar : HtmlM Unit) : HtmlM Unit := do
  layout mod.name.toString project.name sidebar do
    -- Breadcrumb
    nav [class_ "breadcrumb"] do
      a [href_ "index.html"] do HtmlM.text project.name
      let components := mod.name.components
      for i in [:components.length] do
        span [] do HtmlM.text " / "
        let partialName := nameFromComponents (components.take (i + 1))
        if i < components.length - 1 then
          a [href_ s!"{partialName.toString.replace "." "/"}.html"] do
            HtmlM.text components[i]!.toString
        else
          HtmlM.text components[i]!.toString

    -- Module title
    h1 [] do HtmlM.text mod.name.toString

    -- Module doc
    match mod.moduleDoc with
    | some doc =>
      div [class_ "module-doc"] do
        for para in doc.splitOn "\n\n" do
          if !para.trim.isEmpty then
            p [] do HtmlM.text para.trim
    | none => pure ()

    -- Table of contents
    renderToc mod.items

    -- All items
    for item in mod.items do
      renderItem item config

/-- Render index page -/
def renderIndexPage (project : DocProject) (config : Config)
    (sidebar : HtmlM Unit) : HtmlM Unit := do
  layout project.name project.name sidebar do
    h1 [] do HtmlM.text project.name

    match project.version with
    | some v => p [] do HtmlM.text s!"Version: {v}"
    | none => pure ()

    h2 [] do HtmlM.text "Modules"
    ul [] do
      for mod in project.modules do
        if mod.hasItems then
          li [] do
            a [href_ mod.toFilePath] do
              HtmlM.text mod.name.toString
            match mod.moduleDoc with
            | some doc =>
              -- Show first line of doc
              let summary := doc.splitOn "\n" |>.head? |>.getD ""
              if !summary.isEmpty then
                span [class_ "module-summary"] do
                  HtmlM.text s!" - {summary.take 100}"
            | none => pure ()

/-- Build HTML string from HtmlM -/
def buildPage (m : HtmlM Unit) : String :=
  HtmlM.render m

end Docgen.Render
