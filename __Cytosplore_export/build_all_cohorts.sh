#!/usr/bin/env bash
# Build the Cytosplore export + source audit for EVERY cohort in
# _keys/species_cohorts.csv, at species-level and genus-level matching.
# Output: __Cytosplore_export/output/<cohort>/ and output/<cohort>_genus/
#   bash __Cytosplore_export/build_all_cohorts.sh            # all cohorts
#   bash __Cytosplore_export/build_all_cohorts.sh HMBA V1    # a subset
set -euo pipefail
HERE="$(cd "$(dirname "$0")" && pwd)"; REPO="$(dirname "$HERE")"
export LANG="${LANG:-en_US.UTF-8}"
if [ $# -gt 0 ]; then COHORTS=("$@"); else
  # cohorts in file order, deduplicated (column 1, header skipped)
  COHORTS=(); while IFS= read -r line; do [ -n "$line" ] && COHORTS+=("$line"); done < <(python3 -c "
import csv,sys
seen=[]
for r in csv.DictReader(open('$REPO/_keys/species_cohorts.csv',encoding='utf-8-sig')):
    c=r['cohort'].strip()
    if c and c not in seen: seen.append(c)
print('\n'.join(seen))")
fi
for c in "${COHORTS[@]}"; do
  for lvl in species genus; do
    echo "=== $c / $lvl ==="
    Rscript "$HERE/build_cytosplore_traits.R" "$c" "$lvl" 0.8 2>&1 | grep -E "wrote|species in cohort|NOTE|Error|error" || true
    python3 "$HERE/audit_cytosplore_variables.py" "$c" "$lvl" | grep -E "wrote|Error" || true
  done
done
python3 "$HERE/compare_cohorts.py"
[ "${SKIP_SCAN:-0}" = 1 ] || python3 "$HERE/scan_source_tables.py" | grep -E "wrote|targets:"   # SKIP_SCAN=1 to skip the ~3 min source scan
echo; echo "Summary (variables with data / core variables / cohort size):"
for c in "${COHORTS[@]}"; do for lvl in species genus; do
  p="$c"; [ "$lvl" = genus ] && p="${c}_genus"
  f="$HERE/output/$p/BUILD_INFO.txt"
  [ -f "$f" ] && printf "  %-14s %s | %s\n" "$p" "$(grep 'variables in wide:' "$f" | tr -s ' ')" "$(grep 'variables in wide_core' "$f" | tr -s ' ')"
done; done
