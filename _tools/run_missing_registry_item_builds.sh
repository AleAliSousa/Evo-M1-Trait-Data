#!/usr/bin/env bash
# Re-run registered item readers that have an item CSV but lack their public TSV.
# The existing CSV is the reference: if a reader changes it, restore it and
# discard that run's TSV. Source-only rows, holds without a CSV, and naming
# mismatches without an exact item script are not selected.
#
# Usage:
#   bash _tools/run_missing_registry_item_builds.sh --list
#   bash _tools/run_missing_registry_item_builds.sh

set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
cd "$root"
mode="${1:-run}"
if [[ "$mode" != run && "$mode" != --list ]]; then
  echo "Usage: bash _tools/run_missing_registry_item_builds.sh [--list]" >&2
  exit 2
fi

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT
manifest="$tmp_dir/items.tsv"

Rscript --vanilla - "$root" > "$manifest" <<'RS'
args <- commandArgs(trailingOnly = TRUE)
root <- args[[1]]
suppressPackageStartupMessages(library(readxl))
reg <- read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1")
for (i in seq_len(nrow(reg))) {
  pub <- as.character(reg[["Publication name"]][i])
  item <- as.character(reg[["Item name"]][i])
  code <- as.character(reg[["Item encoded"]][i])
  if (any(is.na(c(pub, item, code))) || !nzchar(code) || grepl("_$", code)) next
  script <- file.path(root, pub, paste0(item, ".R"))
  csv <- file.path(root, pub, paste0(item, ".csv"))
  public <- file.path(root, "__Public", "comparative-data", paste0(code, ".tsv"))
  if (!file.exists(script) || !file.exists(csv) || file.exists(public)) next
  source <- readLines(script, warn = FALSE)
  if (!any(grepl("__Public|comparative-data", source))) next
  cat(script, csv, public, sep = "\t")
  cat("\n")
}
RS

selected="$(wc -l < "$manifest" | tr -d ' ')"
echo "Eligible item scripts: $selected"
if [[ "$mode" == --list ]]; then
  cut -f1 "$manifest" | sed "s|^$root/||"
  exit 0
fi

log="$root/_checks/run_missing_registry_item_builds_$(date +%Y%m%d_%H%M%S).log"
printf 'Registry item build run: %s\nSelected: %s\n' "$(date -u '+%Y-%m-%d %H:%M:%S UTC')" "$selected" > "$log"
success=0
failure=0
index=0
while IFS=$'\t' read -r script csv public; do
  index=$((index + 1))
  item="$(basename "$script" .R)"
  backup="$tmp_dir/$index.csv"
  cp -p "$csv" "$backup"
  echo "Running $item"
  printf '\n## %s\n' "$item" >> "$log"
  if Rscript --vanilla "$script" >> "$log" 2>&1; then
    if ! cmp -s "$backup" "$csv"; then
      cp -p "$backup" "$csv"
      rm -f "$public"
      echo "DRIFT: restored existing CSV; discarded TSV for $item" | tee -a "$log"
      failure=$((failure + 1))
    elif [[ ! -s "$public" ]]; then
      echo "MISSING: reader did not create the public TSV for $item" | tee -a "$log"
      failure=$((failure + 1))
    elif ! python3 - "$csv" "$public" <<'PY'
import csv
import sys
with open(sys.argv[1], newline='', encoding='utf-8-sig') as fh:
    local = list(csv.reader(fh))
with open(sys.argv[2], newline='', encoding='utf-8-sig') as fh:
    public = list(csv.reader(fh, delimiter='\t'))
sys.exit(0 if local == public else 1)
PY
    then
      rm -f "$public"
      echo "MISMATCH: discarded TSV that differs from the existing CSV for $item" | tee -a "$log"
      failure=$((failure + 1))
    else
      echo "OK: CSV unchanged; public TSV present for $item" | tee -a "$log"
      success=$((success + 1))
    fi
  else
    cp -p "$backup" "$csv"
    rm -f "$public"
    echo "FAILED: reader exited with an error for $item" | tee -a "$log"
    failure=$((failure + 1))
  fi
done < "$manifest"

echo "Completed: $success succeeded, $failure need attention. Log: $log"
[[ "$failure" -eq 0 ]]
