#!/usr/bin/env bash
# lock_sources.sh -- make source/snapshot spreadsheets read-only so Excel/OneDrive autosave cannot
# change them by accident (an accidental edit shows as "read-only" instead of silently saving).
#
#   _tools/lock_sources.sh status     # default: counts + how many are currently writable
#   _tools/lock_sources.sh lock       # chmod a-w on every in-scope file
#   _tools/lock_sources.sh unlock     # chmod u+w  (do this before re-running an extract/snapshot script on purpose)
#   _tools/lock_sources.sh list       # print the in-scope files
#
# SCOPE (spreadsheets only: .xlsx .xlsm .xls .ods):
#   * frozen evidence:  <Item>_snapshot.*  and  <Item>_<word>_snapshot.*
#   * raw downloads:    any other spreadsheet inside a paper folder (journal supplements, author files)
# NOT locked (working files that people edit on purpose or that tools rewrite):
#   __ReadMe.xlsx, *registry_row*, anything in ____*/, _checks/, _tools/, _keys/, _archive/, __merging_*/,
#   __Public/, __ShinyApp/, .git/, .claude/, files starting "~$", and the root-level candidate lists.
# Only the owner write bit is changed; no chflags/uchg, because OneDrive's file provider cannot
# replace an immutable file when a newer version arrives from another machine.
set -euo pipefail
cd "$(dirname "$0")/.."
mode="${1:-status}"
scope() {
  find . \( -path ./.git -o -path ./.claude -o -path ./_checks -o -path ./_tools -o -path ./_keys \
            -o -path ./_archive -o -path ./__Public -o -path ./__ShinyApp -o -path './____*' -o -path './__merging_*' \) -prune -o \
       -type f ! -regex '\./[^/]*' \( -iname '*.xlsx' -o -iname '*.xlsm' -o -iname '*.xls' -o -iname '*.ods' \) \
       ! -name '~$*' ! -iname '*registry_row*' ! -name '__ReadMe*.xlsx' -print
}
case "$mode" in
  list)   scope ;;
  status) total=$(scope | wc -l | tr -d ' '); wr=$(scope | while read -r f; do if [ -w "$f" ]; then echo "$f"; fi; done | wc -l | tr -d ' ')
          echo "in scope: $total spreadsheets; currently writable: $wr; read-only: $((total-wr))" ;;
  lock)   scope | while read -r f; do chmod a-w "$f"; done; echo "locked (read-only): $(scope | wc -l | tr -d ' ') files" ;;
  unlock) scope | while read -r f; do chmod u+w "$f"; done; echo "unlocked (owner-writable): $(scope | wc -l | tr -d ' ') files" ;;
  *) echo "usage: $0 [status|list|lock|unlock]" >&2; exit 2 ;;
esac
