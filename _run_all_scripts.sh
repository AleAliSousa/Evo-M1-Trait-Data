#!/usr/bin/env bash
# run_all_scripts.sh -- run the repo's scripts from Terminal with one command (macOS bash 3.2+).
#
# It drives the existing runners, so their rules all apply: run_all_scripts_v2.R (R sweep:
# skip list, producers-before-consumers order, 300 s per-script timeout, frozen-snapshot guard,
# log in _checks/) and run_all_scripts_v3.py (R sweep + the four allowlisted Python checks).
# At the end it runs _tools/file_list.R so the public-TSV list in __ReadMe.xlsx is current.
#
#   bash run_all_scripts.sh                    everything: R sweep + Python checks, then file_list.R
#   bash run_all_scripts.sh --r-only           R sweep only, then file_list.R
#   bash run_all_scripts.sh Preuss_            only R scripts whose repo path matches (here the 15
#                                              Preuss items), then file_list.R
#   bash run_all_scripts.sh Preuss_etal_1999 Preuss_Coleman_2002
#                                              several patterns (joined with |; extended regex)
#   bash run_all_scripts.sh --list Preuss_     show what would run; runs nothing
#   bash run_all_scripts.sh --no-file-list ... skip the final file_list.R
#   bash run_all_scripts.sh --force ...        run even if the registry-row check below fails
#
# Pre-flight checks (stop with exit 2):
#   * __ReadMe.xlsx must not be open in Excel (~$__ReadMe.xlsx present): registry tools rewrite it.
#     Always enforced; close Excel and run again.
#   * With a pattern: every selected item script must have its row (Item name -> Item encoded) in
#     the local __ReadMe.xlsx. A missing row usually means OneDrive has not yet synced edits made
#     online; running file_list.R on a stale copy could overwrite those edits. (--force skips this.)
# Notes:
#   * A run with a pattern rewrites _checks/script_execution_log.csv with only the selected
#     scripts; the previous log is kept as _checks/script_execution_log.previous.csv.
#   * Frozen-snapshot overrides pass straight through, e.g.
#       EVOM1_UNFREEZE="Item_name" bash run_all_scripts.sh Item_name
#   * Item scripts' own messages (e.g. "public TSV NOT written") are not shown by the sweep; to read
#     them, run the item alone:  Rscript Preuss_etal_1999/Preuss_etal_1999_Fig2.R
# Exit status: 0 all ran; 1 a script failed or timed out; 2 usage or pre-flight problem; 130 interrupted.

set -uo pipefail

usage() { sed -n '2,32p' "$0" | sed 's/^# \{0,1\}//'; }

# ---- options ------------------------------------------------------------------------------------
pattern=""; r_only=0; list_only=0; do_file_list=1; force=0
while [ $# -gt 0 ]; do
  case "$1" in
    --r-only)            r_only=1 ;;
    --list|--dry-run)    list_only=1 ;;
    --no-file-list)      do_file_list=0 ;;
    --force)             force=1 ;;
    -h|--help)           usage; exit 0 ;;
    --)                  shift; while [ $# -gt 0 ]; do pattern="${pattern:+$pattern|}$1"; shift; done; break ;;
    -*)                  echo "Unknown option: $1 (see --help)" >&2; exit 2 ;;
    *)                   pattern="${pattern:+$pattern|}$1" ;;
  esac
  shift
done

# ---- repo root = nearest folder above this script that holds __ReadMe.xlsx ------------------------
here="$(cd "$(dirname "$0")" && pwd)"
root="$here"
while [ "$root" != "/" ] && [ ! -f "$root/__ReadMe.xlsx" ]; do root="$(dirname "$root")"; done
if [ ! -f "$root/__ReadMe.xlsx" ]; then
  echo "No __ReadMe.xlsx found in $here or any folder above it." >&2; exit 2
fi
cd "$root" || exit 2

# UTF-8 locale, so folder names with accents or umlauts survive grep, R and Python.
case "${LC_ALL:-${LANG:-}}" in
  *UTF-8*|*utf8*|*UTF8*) ;;
  *) for loc in en_US.UTF-8 en_GB.UTF-8 C.UTF-8; do
       if locale -a 2>/dev/null | grep -qx "$loc"; then export LANG="$loc" LC_ALL="$loc"; break; fi
     done ;;
esac

# ---- tools ----------------------------------------------------------------------------------------
RSCRIPT="$(command -v Rscript 2>/dev/null || true)"
if [ -z "$RSCRIPT" ]; then
  for p in /usr/local/bin/Rscript /opt/homebrew/bin/Rscript /Library/Frameworks/R.framework/Resources/bin/Rscript; do
    if [ -x "$p" ]; then RSCRIPT="$p"; break; fi
  done
fi
if [ -z "$RSCRIPT" ]; then echo "Rscript not found. Install R from https://cran.r-project.org/ first." >&2; exit 2; fi
export PATH="$(dirname "$RSCRIPT"):$PATH"     # run_all_scripts_v3.py looks for Rscript on PATH

for f in run_all_scripts_v2.R _tools/file_list.R; do
  if [ ! -f "$f" ]; then echo "Missing $f in $root" >&2; exit 2; fi
done

tmp_items="$(mktemp "${TMPDIR:-/tmp}/runall_items.XXXXXX")" || exit 2
trap 'rm -f "$tmp_items"' EXIT
trap 'echo; echo "Interrupted."; exit 130' INT

# Repo-relative .R paths, as the R sweep lists them (hidden folders excluded).
all_r()      { find . -type f -name '*.R' ! -path '*/.*' | sed 's|^\./||' | LC_ALL=C sort; }
selected_r() { all_r | grep -E -- "$pattern" || true; }
readme_open() { [ -e "$root/"'~$__ReadMe.xlsx' ]; }

# Item build scripts among the selection: <PaperFolder>/<Item>.R with <Item>.README.md (or .ReadMe.md)
# beside it; helper scripts (*compare*, *_extract_snapshot.R) and _/__ folders are not items.
list_items() {
  selected_r | while IFS= read -r p; do
    case "$p" in _*|*/*/*) continue ;; */*) ;; *) continue ;; esac
    d="$(dirname "$p")"; b="$(basename "$p" .R)"
    case "$b" in *compare*|*_extract_snapshot) continue ;; esac
    if [ -f "$d/$b.README.md" ] || [ -f "$d/$b.ReadMe.md" ]; then echo "$b"; fi
  done
}

# Item names (one per line in $1) that have no usable Item encoded in the local registry.
missing_registry_rows() {
  "$RSCRIPT" -e '
    a     <- commandArgs(trailingOnly = TRUE)
    nfc   <- function(x) if (requireNamespace("stringi", quietly = TRUE)) stringi::stri_trans_nfc(enc2utf8(x)) else enc2utf8(x)
    items <- nfc(readLines(a[2], encoding = "UTF-8", warn = FALSE))
    reg   <- suppressMessages(readxl::read_excel(a[1], sheet = "Sheet1"))
    enc   <- reg[["Item encoded"]][match(items, nfc(as.character(reg[["Item name"]])))]
    bad   <- items[is.na(enc) | !nzchar(enc) | grepl("_$", enc)]
    if (length(bad)) { cat(bad, sep = "\n"); quit(status = 3) }
  ' "$root/__ReadMe.xlsx" "$1"
}

summarise_log() {
  "$RSCRIPT" -e '
    f <- file.path("_checks", "script_execution_log.csv")
    if (!file.exists(f)) { cat("  (no R execution log found)\n"); quit(status = 0) }
    x  <- utils::read.csv(f, stringsAsFactors = FALSE)
    lv <- c("SUCCESS", "FAILED", "TIMEOUT", "SKIPPED", "NOT_RUN", "RUNNING")
    n  <- table(factor(x$status, levels = lv))
    cat(sprintf("  %-8s %d\n", lv, as.integer(n)), sep = "")
    rt <- paste0(normalizePath(getwd()), "/")
    rel <- ifelse(startsWith(x$script, rt), substring(x$script, nchar(rt) + 1L), x$script)
    bad <- which(x$status %in% c("FAILED", "TIMEOUT", "NOT_RUN", "RUNNING"))
    if (length(bad)) {
      cat("\nProblems (last lines of output; full text in _checks/script_failures_only.csv):\n")
      for (i in bad) {
        cat(sprintf("  [%s] %s\n", x$status[i], rel[i]))
        m <- strsplit(as.character(x$error[i]), "\n", fixed = TRUE)[[1]]
        m <- utils::tail(m[nzchar(trimws(m))], 3)
        if (length(m)) cat(paste0("      ", m), sep = "\n")
      }
      quit(status = 1)
    }
  '
}

# ---- what will run --------------------------------------------------------------------------------
echo "Repo:    $root"
echo "R:       $RSCRIPT"
if [ -n "$pattern" ]; then
  n_sel="$(selected_r | grep -c . || true)"
  echo "Scope:   R scripts matching '$pattern' ($n_sel found)"
  if [ "$n_sel" -eq 0 ]; then echo "Nothing matches '$pattern'." >&2; exit 2; fi
elif [ "$r_only" -eq 1 ]; then
  echo "Scope:   all R scripts (run_all_scripts_v2.R)"
else
  echo "Scope:   all R scripts + Python checks (run_all_scripts_v3.py)"
fi
[ "$do_file_list" -eq 1 ] && echo "Then:    _tools/file_list.R (refresh the public-TSV list in __ReadMe.xlsx)"

if [ "$list_only" -eq 1 ]; then
  echo
  if [ -n "$pattern" ]; then
    selected_r | sed 's/^/  /'
  elif [ "$r_only" -eq 0 ] && command -v python3 >/dev/null 2>&1; then
    python3 run_all_scripts_v3.py --dry-run
    echo "  ($(all_r | grep -c .) R scripts in the repo before the sweep's skip list)"
  else
    all_r | sed 's/^/  /'
  fi
  echo
  echo "Listing only: nothing was run. The sweep may still skip some of these (skip list, frozen snapshots)."
  exit 0
fi

# ---- pre-flight -------------------------------------------------------------------------------------
if readme_open; then
  echo "STOP: __ReadMe.xlsx is open in Excel (~\$__ReadMe.xlsx found). Close it, then run again: registry tools rewrite it." >&2
  exit 2
fi
problem=0
if [ -n "$pattern" ]; then
  list_items > "$tmp_items"
  if [ -s "$tmp_items" ]; then
    echo "Checking registry rows for $(grep -c . "$tmp_items") item script(s)..."
    missing="$(missing_registry_rows "$tmp_items")"; rc=$?
    if [ "$rc" -eq 3 ]; then
      echo "STOP: these items have no Item encoded in the local __ReadMe.xlsx (OneDrive still syncing, or row missing):" >&2
      echo "$missing" | sed 's/^/    /' >&2
      problem=1
    elif [ "$rc" -ne 0 ]; then
      echo "STOP: could not read __ReadMe.xlsx with readxl (is the readxl package installed?)." >&2
      problem=1
    fi
  fi
fi
if [ "$problem" -eq 1 ]; then
  if [ "$force" -eq 1 ]; then echo "--force given: continuing anyway." >&2; else exit 2; fi
fi

# Keep the Mac awake for the length of the run (macOS only; harmless elsewhere).
if command -v caffeinate >/dev/null 2>&1; then caffeinate -i -w $$ >/dev/null 2>&1 & fi

# ---- run --------------------------------------------------------------------------------------------
started="$(date '+%Y-%m-%d %H:%M:%S')"
echo
echo "Started $started"
status=0

if [ -n "$pattern" ]; then
  if [ -f _checks/script_execution_log.csv ]; then
    cp -p _checks/script_execution_log.csv _checks/script_execution_log.previous.csv
  fi
  EVOM1_ONLY="$pattern" "$RSCRIPT" run_all_scripts_v2.R || status=1
elif [ "$r_only" -eq 0 ] && command -v python3 >/dev/null 2>&1 && python3 -c 'import sys' >/dev/null 2>&1; then
  python3 run_all_scripts_v3.py || status=1
else
  [ "$r_only" -eq 0 ] && echo "python3 not available: running the R sweep only." >&2
  "$RSCRIPT" run_all_scripts_v2.R || status=1
fi

echo
echo "R sweep summary (_checks/script_execution_log.csv):"
summarise_log || status=1

if [ "$do_file_list" -eq 1 ]; then
  echo
  if readme_open; then
    echo "Skipped _tools/file_list.R: __ReadMe.xlsx is open in Excel. Close it, then run:  Rscript _tools/file_list.R" >&2
    status=1
  else
    echo "Running _tools/file_list.R ..."
    "$RSCRIPT" _tools/file_list.R || { echo "_tools/file_list.R failed." >&2; status=1; }
  fi
fi

echo
echo "Finished $(date '+%Y-%m-%d %H:%M:%S') (started $started; ${SECONDS}s)."
if [ "$status" -eq 0 ]; then echo "All scripts ran without failures."; else echo "Some steps failed: see above and _checks/."; fi
exit "$status"
