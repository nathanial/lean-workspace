/-
  Docgen.Render.Search - Search index generation
-/
import Docgen.Core.Types
import Lean.Data.Json

namespace Docgen.Render

open Lean

/-- A search index entry -/
structure SearchEntry where
  /-- Display name -/
  name : String
  /-- Fully qualified name -/
  fullName : String
  /-- Module name -/
  module : String
  /-- Item kind -/
  kind : String
  /-- First 200 chars of doc -/
  summary : String
  /-- URL to the item -/
  url : String
  deriving Repr

instance : ToJson SearchEntry where
  toJson e := Json.mkObj [
    ("name", e.name),
    ("fullName", e.fullName),
    ("module", e.module),
    ("kind", e.kind),
    ("summary", e.summary),
    ("url", e.url)
  ]

/-- Generate a search entry from a DocItem -/
def itemToSearchEntry (mod : DocModule) (item : DocItem) : SearchEntry := {
  name := item.shortName
  fullName := item.name.toString
  module := mod.name.toString
  kind := item.kind.toString
  summary := item.docString.getD "" |>.take 200 |>.replace "\n" " "
  url := s!"{mod.toFilePath}#{item.anchorId}"
}

/-- Generate search index for a project -/
def generateSearchIndex (project : DocProject) : Array SearchEntry := Id.run do
  let mut entries := #[]

  for mod in project.modules do
    -- Add module itself as searchable
    entries := entries.push {
      name := mod.shortName
      fullName := mod.name.toString
      module := mod.name.toString
      kind := "module"
      summary := mod.moduleDoc.getD "" |>.take 200 |>.replace "\n" " "
      url := mod.toFilePath
    }

    -- Add all items
    for item in mod.items do
      entries := entries.push (itemToSearchEntry mod item)

  return entries

/-- Render search index as JSON string -/
def renderSearchIndex (project : DocProject) : String :=
  let entries := generateSearchIndex project
  let jsonArray := Json.arr (entries.map toJson)
  jsonArray.pretty

/-- Generate minimal JavaScript for client-side search -/
def searchJs : String := "
// Simple client-side search for docgen
(function() {
  let searchIndex = [];

  // Load search index
  fetch('search-index.json')
    .then(r => r.json())
    .then(data => { searchIndex = data; })
    .catch(e => console.error('Failed to load search index:', e));

  // Setup search input
  const input = document.getElementById('search-input');
  if (!input) return;

  let resultsDiv = document.createElement('div');
  resultsDiv.className = 'search-results';
  resultsDiv.style.display = 'none';
  input.parentNode.appendChild(resultsDiv);

  input.addEventListener('input', function() {
    const query = this.value.toLowerCase().trim();
    if (query.length < 2) {
      resultsDiv.style.display = 'none';
      return;
    }

    const results = searchIndex
      .filter(e => e.name.toLowerCase().includes(query) ||
                   e.fullName.toLowerCase().includes(query))
      .slice(0, 10);

    if (results.length === 0) {
      resultsDiv.innerHTML = '<div class=\"no-results\">No results</div>';
    } else {
      resultsDiv.innerHTML = results.map(r =>
        `<a href=\"${r.url}\" class=\"search-result\">
          <span class=\"kind-badge kind-${r.kind}\">${r.kind}</span>
          <span class=\"result-name\">${r.name}</span>
          <span class=\"result-module\">${r.module}</span>
        </a>`
      ).join('');
    }
    resultsDiv.style.display = 'block';
  });

  // Hide results on click outside
  document.addEventListener('click', function(e) {
    if (!input.contains(e.target) && !resultsDiv.contains(e.target)) {
      resultsDiv.style.display = 'none';
    }
  });
})();
"

end Docgen.Render
