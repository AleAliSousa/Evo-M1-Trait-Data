#!/usr/bin/env python3
"""
build_species_universe.py -- the list of names the tree layer has to place.

Until 2026-11 the tree was pruned to the curated list in _keys/species_reference.csv
as it stood in August (214 names). The app's data has since grown to thousands of
species, so that list became a ceiling: every species added to a merge afterwards
was dropped from PGLS however good its data. This script replaces the ceiling with
the UNION of

  * every Species label in the tables __ShinyApp/app.R actually loads (the rows of
    _keys/app_feeds.csv with evo_m1_app = TRUE, which is where app.R takes its
    table paths from, so a table added to the app is picked up here
    without editing this file), after the app's own display aliases
    (_keys/species_display_aliases.csv, variant -> canonical) are applied, and
  * every accepted_name in _keys/species_reference.csv (the curated core).

Each name gets a `scope`:

  in_scope_mammal                  a mammal species or subspecies name; goes to the crosswalk
  out_of_scope_non_mammal          bird, reptile, fish, invertebrate ... no mammal tree can hold it
  out_of_scope_not_a_species_name  common name, abbreviation, sp./cf. placeholder, hybrid, note text.
                                   A two-word label ("Honey possum", or a fossil or misspelt
                                   genus) gets name_form = unrecognised_first_word and is out of
                                   scope when its first word is not a genus MDD records AND
                                   species_taxonomy.csv files it under a different genus whose
                                   species do not include the second word.
  out_of_scope_no_order            no order on record, and genus not in the mammal checklist
  out_of_scope_fossil              taxon_type fossil / fossil_group / hypothesis in species_reference

Out-of-scope names are listed, never silently dropped, and are NOT reported as
"missing from the tree".

INPUT   _keys/app_feeds.csv, the tables it names, _keys/species_display_aliases.csv,
        _keys/species_taxonomy.csv, _keys/species_reference.csv,
        __merging_trees/reference_tables/mdd_names_extract.csv (genus list only)
OUTPUT  __merging_trees/species_universe.csv

Paths: reads from $EVOM1_REPO (default: the repo this file sits in) and writes
under $EVOM1_OUT (default: the same repo).

Run from repo root:  python3 __merging_trees/build_species_universe.py
"""
import csv
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from make_tip_crosswalk_seed import MddIndex, strict_same_epithet  # noqa: E402

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.environ.get("EVOM1_REPO") or os.path.dirname(HERE)
OUT_ROOT = os.environ.get("EVOM1_OUT") or REPO
OUT = os.path.join(OUT_ROOT, "__merging_trees", "species_universe.csv")
MDD = os.path.join(HERE, "reference_tables", "mdd_names_extract.csv")

# Orders of living mammals, current and legacy spellings seen in the keys.
MAMMAL_ORDERS = {
    "Afrosoricida", "Artiodactyla", "Carnivora", "Cetacea", "Cetartiodactyla",
    "Chiroptera", "Cingulata", "Dasyuromorphia", "Dermoptera", "Didelphimorphia",
    "Diprotodontia", "Erinaceomorpha", "Eulipotyphla", "Hyracoidea", "Insectivora",
    "Lagomorpha", "Macroscelidea", "Microbiotheria", "Monotremata",
    "Notoryctemorphia", "Paucituberculata", "Peramelemorphia", "Perissodactyla",
    "Pholidota", "Pilosa", "Pinnipedia", "Primates", "Proboscidea", "Rodentia",
    "Scandentia", "Sirenia", "Soricomorpha", "Tubulidentata",
}
NA = {"", "NA", "NaN", "N/A", "None", "nan"}


def clean(x):
    if x is None:
        return ""
    x = str(x).replace("_", " ").replace("\u00a0", " ")
    return re.sub(r"\s+", " ", x).strip()


def name_form(n):
    p = n.split()
    if re.search(r"\b(sp|spp|ssp|indet|cf|aff|spec)\.?( |$|\?)", n, flags=re.I):
        return "placeholder"
    if re.search(r"[\u00d7+)(\u00a7/,;?]| x ", n) or len(n) > 60:
        return "non_taxon_label"
    genus_ok = bool(p) and re.fullmatch(r"[A-Z][a-z]{2,}", p[0]) is not None
    epi = lambda q: re.fullmatch(r"[a-z][a-z-]{2,}", q) is not None
    if len(p) == 2 and genus_ok and epi(p[1]):
        return "binomial"
    if len(p) == 3 and genus_ok and epi(p[1]) and epi(p[2]):
        return "trinomial"
    if len(p) == 1 and genus_ok:
        return "single_word"
    return "other_label"


def app_tables():
    """Relative paths of the long tables app.R loads (_keys/app_feeds.csv, evo_m1_app = TRUE)."""
    with open(os.path.join(REPO, "_keys", "app_feeds.csv"), newline="", encoding="utf-8-sig") as f:
        paths = [r["path"].strip() for r in csv.DictReader(f)
                 if (r.get("evo_m1_app") or "").strip().upper() == "TRUE"
                 and (r.get("path") or "").strip().endswith("_long.csv")]
    if len(paths) < 10:
        sys.exit(f"only {len(paths)} *_long.csv tables with evo_m1_app = TRUE in _keys/app_feeds.csv -- "
                 "the feed list has changed; fix app_tables()")
    return paths


def main():
    csv.field_size_limit(10 ** 9)
    alias = {}
    with open(os.path.join(REPO, "_keys", "species_display_aliases.csv"),
              newline="", encoding="utf-8-sig") as f:
        for r in csv.DictReader(f):
            v, c = clean(r.get("variant")), clean(r.get("canonical"))
            if v and c:
                alias[v] = c

    tables, variants = {}, {}
    for rel in app_tables():
        path = os.path.join(REPO, rel)
        if not os.path.exists(path):
            sys.exit(f"_keys/app_feeds.csv names {rel}, which does not exist")
        tag = os.path.basename(rel).replace("_long.csv", "")
        with open(path, newline="", encoding="utf-8-sig", errors="replace") as f:
            rd = csv.DictReader(f)
            col = next((c for c in rd.fieldnames if c.lower() == "species"), None)
            if col is None:
                sys.exit(f"{rel} has no Species column")
            seen = set()
            for r in rd:
                raw = clean(r.get(col))
                if not raw or raw in NA or raw in seen:
                    continue
                seen.add(raw)
                acc = alias.get(raw, raw)
                tables.setdefault(acc, set()).add(tag)
                if acc != raw:
                    variants.setdefault(acc, set()).add(raw)

    ref = {}
    with open(os.path.join(REPO, "_keys", "species_reference.csv"),
              newline="", encoding="utf-8-sig") as f:
        for r in csv.DictReader(f):
            a = clean(r.get("accepted_name"))
            if a and a not in NA:
                # a reference name the app renames (an alias VARIANT) never reaches a
                # plot under that spelling; carry it as a variant of its canonical
                c = alias.get(a, a)
                if c != a:
                    variants.setdefault(c, set()).add(a)
                ref.setdefault(c, r)
                tables.setdefault(c, set())

    tax = {}
    with open(os.path.join(REPO, "_keys", "species_taxonomy.csv"),
              newline="", encoding="utf-8-sig") as f:
        for r in csv.DictReader(f):
            s = clean(r.get("Species"))
            if s and s not in tax:
                tax[s] = (clean(r.get("Order")), clean(r.get("Family")),
                          clean(r.get("Genus")))

    mdd = MddIndex(MDD)
    mammal_genera = mdd.genera          # current, CMW, MSW3 and original-combination genera

    def genus_has_epithet(genus, epithet):
        return any(strict_same_epithet(e, epithet) for e, _ in mdd.by_genus.get(genus, ()))

    rows = []
    for acc in sorted(tables):
        order = family = tax_genus = ""
        for k in [acc] + sorted(variants.get(acc, ())):
            if k in tax and tax[k][0] not in NA:
                order, family, tax_genus = tax[k]
                break
        tax_genus = "" if tax_genus in NA else tax_genus
        r = ref.get(acc)
        if r is not None:
            order = order or clean(r.get("Order_resolved")) or clean(r.get("Order_MDD"))
            family = family or clean(r.get("Family_resolved")) or clean(r.get("Family_MDD"))
        order = "" if order in NA else order
        family = "" if family in NA else family
        form = name_form(acc)
        first = acc.split()[0]
        if form == "binomial" and first not in mammal_genera and tax_genus \
                and tax_genus != first and order in MAMMAL_ORDERS \
                and not genus_has_epithet(tax_genus, acc.split()[1]):
            form = "unrecognised_first_word"
        ttype = (r.get("taxon_type") or "").strip() if r is not None else ""
        basis = "order from species_taxonomy.csv / species_reference.csv"
        if ttype in ("fossil", "fossil_group", "hypothesis"):
            scope = "out_of_scope_fossil"
        elif not order:
            if form in ("binomial", "trinomial") and acc.split()[0] in mammal_genera:
                scope = "in_scope_mammal"
                basis = "no order on record; genus is in the Mammal Diversity Database"
            else:
                scope = "out_of_scope_no_order"
                basis = "no order in species_taxonomy.csv or species_reference.csv"
        elif order not in MAMMAL_ORDERS:
            scope = "out_of_scope_non_mammal"
        elif form not in ("binomial", "trinomial"):
            scope = "out_of_scope_not_a_species_name"
            if form == "unrecognised_first_word":
                basis = (f"first word is not a recognised mammal genus; "
                         f"species_taxonomy.csv files the label under {tax_genus}")
        else:
            scope = "in_scope_mammal"
        rows.append({
            "accepted_name": acc, "scope": scope, "scope_basis": basis,
            "name_form": form, "order": order, "family": family,
            "taxonomy_genus": tax_genus,
            "mdd_current": "TRUE" if " ".join(acc.split()[:2]) in mdd.cur
                           and form == "binomial" else "FALSE",
            "n_tables": len(tables[acc]), "tables": ";".join(sorted(tables[acc])),
            "alias_variants": ";".join(sorted(variants.get(acc, ()))),
            "in_species_reference": "TRUE" if acc in ref else "FALSE",
        })

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0]), lineterminator="\n")
        w.writeheader()
        w.writerows(rows)

    counts = {}
    for r in rows:
        counts[r["scope"]] = counts.get(r["scope"], 0) + 1
    print(f"wrote {os.path.relpath(OUT, OUT_ROOT)}: {len(rows)} names")
    for k in sorted(counts, key=counts.get, reverse=True):
        print(f"  {counts[k]:6d}  {k}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
