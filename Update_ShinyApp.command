#!/bin/bash
# =============================================================================
# Update the Evo-M1 Shiny app — macOS one-click launcher.
#
#   • DOUBLE-CLICK this file in Finder, or run:  bash Update_ShinyApp.command
#
# It just hands off to update_shinyapp.R (which does build -> push -> deploy).
# Pass options straight through, e.g.:  bash Update_ShinyApp.command --no-deploy
#
# First time only: Finder may say the file "can't be opened". Right-click it ->
# Open -> Open, or run once:  chmod +x Update_ShinyApp.command
# =============================================================================
set -euo pipefail

# repo root = the folder this launcher lives in (handles spaces in the path)
cd "$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
echo "Repo: $(pwd)"

if ! command -v Rscript >/dev/null 2>&1; then
  echo "❌ Rscript not found. Install R from https://cran.r-project.org, then re-run."
  echo "   (Press Return to close.)"; read -r _ || true; exit 1
fi

Rscript "./update_shinyapp.R" "$@"
status=$?

echo
if [ "$status" -eq 0 ]; then echo "✅ Finished."; else echo "❌ Finished with errors (see above)."; fi
echo "(Press Return to close this window.)"
read -r _ || true
exit "$status"
