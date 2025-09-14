#!/usr/bin/env bash
set -euo pipefail

# Generate DocC static documentation for GitHub Pages or local preview.
# Usage:
#   bash make_doc.sh                      # emits to ./docs with base path (repo name by default)
#   bash make_doc.sh local                # emits to ./docs without base path (for local preview)
#   bash make_doc.sh --base-path NAME     # override hosting base path (e.g., repo name)
#   bash make_doc.sh --local              # same as 'local'

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT="$SCRIPT_DIR"
OUT_DIR="$REPO_ROOT/docs"
# Base path used by GitHub Pages (project pages).
# Defaults to the repo folder name; can be overridden via CLI flag or DOCS_BASE_PATH env var.
BASE_PATH_DEFAULT=$(basename "$REPO_ROOT")
BASE_PATH="${DOCS_BASE_PATH:-$BASE_PATH_DEFAULT}"   # e.g., 'SwiftyStats'

mkdir -p "$OUT_DIR"

EXTRA_ARGS=("--disable-indexing")

# Parse args
IS_LOCAL=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    local|--local)
      IS_LOCAL=true
      shift
      ;;
    --base-path|-b)
      if [[ $# -lt 2 ]]; then
        echo "Error: --base-path requires a value" >&2
        exit 1
      fi
      BASE_PATH="$2"
      shift 2
      ;;
    --help|-h)
      sed -n '1,40p' "$0"
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      echo "Use --help for usage." >&2
      exit 2
      ;;
  esac
done

if $IS_LOCAL; then
  # Local preview without a base path prefix
  EXTRA_ARGS+=("--transform-for-static-hosting")
else
  # GitHub Pages: transform and set hosting base path
  EXTRA_ARGS+=("--transform-for-static-hosting" "--hosting-base-path" "$BASE_PATH")
fi

# Generate static docs using the swift-docc-plugin
swift package \
  --allow-writing-to-directory "$OUT_DIR" \
  generate-documentation \
  --target SwiftyStats \
  --output-path "$OUT_DIR" \
  "${EXTRA_ARGS[@]}"

# Copy additional images used by articles (if present)
mkdir -p "$OUT_DIR/img"
cp -f "$REPO_ROOT/SwiftyStats/help/img"/*.png "$OUT_DIR/img" 2>/dev/null || true

echo "DocC static site generated at: $OUT_DIR"
if $IS_LOCAL; then
  echo "Serve locally, e.g.: python3 -m http.server --directory '$OUT_DIR' 8000"
  echo "Open: http://localhost:8000/documentation/swiftystats"
else
  echo "Push the 'docs' folder to gh-pages or enable 'main/docs' as Pages source."
  echo "Hosted path example: https://<user>.github.io/$BASE_PATH/documentation/swiftystats/"
  echo "Override base path via: --base-path YourRepoName or DOCS_BASE_PATH=YourRepoName"
fi
