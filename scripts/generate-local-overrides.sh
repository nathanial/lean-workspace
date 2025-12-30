#!/usr/bin/env bash
# Generate package-overrides.json for local development
# Places files in .lake/package-overrides.json for each project that needs local deps

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"

generate_override_entry() {
    local dep=$1
    local is_last=$2
    local comma=","
    if [ "$is_last" = "true" ]; then
        comma=""
    fi
    cat <<EOF
    {
      "type": "path",
      "name": "$dep",
      "dir": "../$dep",
      "configFile": "lakefile.lean",
      "manifestFile": "lake-manifest.json",
      "inherited": false,
      "scope": ""
    }$comma
EOF
}

generate_overrides_file() {
    local project=$1
    shift
    local deps=("$@")

    local project_dir="$WORKSPACE_DIR/$project"
    local lake_dir="$project_dir/.lake"
    local override_file="$lake_dir/package-overrides.json"

    # Create .lake directory if it doesn't exist
    mkdir -p "$lake_dir"

    # Start JSON
    echo '{' > "$override_file"
    echo '  "version": "1.1.0",' >> "$override_file"
    echo '  "packages": [' >> "$override_file"

    # Generate entries
    local count=${#deps[@]}
    local i=0
    for dep in "${deps[@]}"; do
        ((i++))
        if [ $i -eq $count ]; then
            generate_override_entry "$dep" "true" >> "$override_file"
        else
            generate_override_entry "$dep" "false" >> "$override_file"
        fi
    done

    echo '  ]' >> "$override_file"
    echo '}' >> "$override_file"

    echo "Generated: $override_file"
}

main() {
    echo "Generating package-overrides.json for local development..."
    echo ""
    echo "NOTE: With the new category folder structure, this script needs updating."
    echo "All dependencies now use GitHub references (per CLAUDE.md policy)."
    echo "Local development mode is deprecated."
    echo ""

    # These paths are now in category subfolders and relative path logic needs updating
    # generate_overrides_file "graphics/afferent" "trellis" "arbor"
    # generate_overrides_file "graphics/canopy" "arbor"
    # generate_overrides_file "graphics/chroma" "tincture" "trellis" "arbor" "afferent"
    # generate_overrides_file "apps/enchiridion" "terminus" "wisp"

    echo "Script disabled - all projects use GitHub-based dependencies."
    exit 0
}

main "$@"
