#!/usr/bin/env python3
"""
make_tip_crosswalk_seed.py -- seed __merging_trees/tree_tip_crosswalk.csv

Enumerates the CANDIDATE NAMES for each project species, in priority order, so
build_mammal_tree.{R,py} can resolve each species to a real tip in a published source
tree. It invents nothing and reads no tree file -- every candidate is a spelling that
already exists somewhere in _keys/.

The important column is `auto_match`:

  auto_match = TRUE   safe to match to a tip without human sign-off. The candidate is
                      the same taxon under a different generic assignment or a minor
                      orthographic variant (Galago demidoff = Galagoides demidoff;
                      Aotes = Aotus), or a subspecies falling back to its parent
                      species (a species-level tree has no subspecies tips).

  auto_match = FALSE  a DIFFERENT TAXON CONCEPT that happens to be linked in the
                      paper-scoped species key. Reported by the coverage report as an
                      available lead, never matched silently. e.g. Equus burchelli ->
                      Equus quagga is a real senior synonym worth adopting, but
                      Rattus norvegicus -> Rattus rattus and Avahi occidentalis ->
                      Avahi laniger are distinct species. Promote one by hand (set
                      auto_match TRUE and record who decided, mirroring the
                      status/decided_by discipline in _keys/reidentifications.csv).

Dropped entirely: common names ("Owl monkey", "Beagle Dog"), abbreviated genera
("C. mitis"), truncations ("Daubentonia madagas."), and sp./spp. lumps -- none is a
spelling of a species that could appear as a tip.

`sp.` / `spp.` placeholders in accepted_name yield NO candidates: they are genuinely
unresolvable to one tip and are reported as such.

Run from repo root:  python3 __merging_trees/make_tip_crosswalk_seed.py
"""

import csv
import os
import re
import sys

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(REPO, "__merging_trees", "tree_tip_crosswalk.csv")

NA = {"", "NA", "NaN", "N/A", "None", None}

# ---------------------------------------------------------------------------
# Curated tip bridges: project accepted_name -> (tree spelling, why)
#
# Same-taxon equivalences that are NOT recoverable from _keys/ -- either the
# generic reassignment is too recent for the species key, or the epithet differs
# by more than the orthographic test allows. Each was verified against the Upham
# DNA-only tree (the spelling on the right IS a tip) and each is a documented
# taxonomic act, not a guess.
#
# These live here, in the seeder, so re-seeding does not silently lose them.
# They deliberately do NOT go in _keys/species_display_aliases.csv: that file is a
# GLOBAL rename map applied by __ShinyApp/app.R, so adding "Mustela vison ->
# Neovison vison" there would rename the species everywhere in the project. That
# is a taxonomic decision for the curator; matching a tree tip is not.
# ---------------------------------------------------------------------------
TREE_TIP_BRIDGES = {
    "Mustela vison":            ("Neovison vison",         "Neovison split from Mustela (Wozencraft 2005); bridge already documented in Wilman_etal_2014 README"),
    "Mops pumilus":             ("Chaerephon pumilus",     "Mops/Chaerephon reassignment; bridge already documented in Wilman_etal_2014 README"),
    "Macronycteris commersoni": ("Hipposideros commersoni", "Macronycteris split from Hipposideros (Foley et al. 2017); bridge already documented in Wilman_etal_2014 README"),
    "Galictis vittatus":        ("Galictis vittata",       "gender agreement of the epithet; bridge already documented in Wilman_etal_2014 README"),
    "Equus burchelli":          ("Equus quagga",           "E. quagga is the senior synonym; bridge already documented in Wilman_etal_2014 README"),
    "Fukomys mechowii":         ("Fukomys mechowi",        "orthographic variant of the epithet; cf. Wilman_etal_2014 README (mechowii/mechowi)"),
    "Osphranter rufus":         ("Macropus rufus",         "Osphranter raised from Macropus subgenus (Celik et al. 2019); Upham predates the split"),
    "Tayassu tajacu":           ("Pecari tajacu",          "collared peccary moved to Pecari (Grubb 2005)"),
    "Chinchilla laniger":       ("Chinchilla lanigera",    "lanigera is the correct original spelling"),
    "Microgale mergulus":       ("Limnogale mergulus",     "web-footed tenrec; Limnogale sunk into Microgale/Nesogale (Everson et al. 2016), Upham retains Limnogale"),
    "Galagoides demidoff":      ("Galagoides demidovii",   "orthographic variant of the epithet"),
}


def clean(x):
    if x is None:
        return ""
    x = x.replace("_", " ").replace("*", "")
    return re.sub(r"\s+", " ", x).strip()


def is_placeholder(name):
    return bool(re.search(r"\b(sp|spp|indet|cf)\.?$", name, flags=re.I))


def is_binomial(name):
    return len(name.split()) == 2 and not is_placeholder(name)


def is_trinomial(name):
    return len(name.split()) == 3 and not is_placeholder(name)


def lev(a, b):
    """Levenshtein distance -- small strings, so the simple DP is fine."""
    if a == b:
        return 0
    prev = list(range(len(b) + 1))
    for i, ca in enumerate(a, 1):
        cur = [i]
        for j, cb in enumerate(b, 1):
            cur.append(min(prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + (ca != cb)))
        prev = cur
    return prev[-1]


def same_epithet_concept(e1, e2):
    """True if two epithets are orthographic variants of one another, not two taxa.

    Covers latinisation noise the classical literature is full of:
    burchelli/burchellii, lagotricha/lagothricha, mulata/mulatta, trivirgatua.
    Deliberately conservative: a 1-2 character difference on a stem that already
    agrees, never a different word.
    """
    if e1 == e2:
        return True
    # -i / -ii and -us / -a style endings on an identical stem
    for a, b in ((e1, e2), (e2, e1)):
        if a == b + "i" or a == b + "ii" or a == b + "e":
            return True
    d = lev(e1, e2)
    if d == 0:
        return True
    # allow 1-2 edits, but only when the strings are long enough that 2 edits
    # cannot turn one real epithet into a different real one
    if d == 1 and min(len(e1), len(e2)) >= 5:
        return True
    if d == 2 and min(len(e1), len(e2)) >= 9:
        return True
    return False


def main():
    ref_path = os.path.join(REPO, "_keys", "species_reference.csv")
    ali_path = os.path.join(REPO, "_keys", "species_display_aliases.csv")
    key_path = os.path.join(REPO, "_keys", "Stephan", "species_key.csv")
    tax_path = os.path.join(REPO, "_keys", "species_taxonomy.csv")

    with open(ref_path, newline="", encoding="utf-8-sig") as f:
        ref = list(csv.DictReader(f))

    # ---- known mammal genera, used to reject common names and abbreviations ----
    genera = set()
    for path, col in ((tax_path, "Species"), (ref_path, "accepted_name")):
        if os.path.exists(path):
            with open(path, newline="", encoding="utf-8-sig") as f:
                for r in csv.DictReader(f):
                    n = clean(r.get(col))
                    if n and n not in NA:
                        g = n.split()[0]
                        if re.fullmatch(r"[A-Z][a-z]{2,}", g):
                            genera.add(g)

    def plausible(name):
        """Reject common names, abbreviated genera, and truncated epithets."""
        parts = name.split()
        if len(parts) != 2:
            return False
        g, e = parts
        if g not in genera:
            return False                       # "Owl", "Beagle", "C."
        if not re.fullmatch(r"[a-z][a-z-]{2,}", e):
            return False                       # "madagascar." , "m."
        return True

    def truncation_of(name, acc):
        """True if `name` is an abbreviation of `acc` (shared genus, prefix epithet)."""
        ng, ne = name.split()
        ag, ae = acc.split()[0], acc.split()[-1]
        return ng == ag and ne != ae and (ae.startswith(ne) or ne.startswith(ae))

    # ---- display aliases, usable both directions ----
    alias = {}
    if os.path.exists(ali_path):
        with open(ali_path, newline="", encoding="utf-8-sig") as f:
            for r in csv.DictReader(f):
                v, c = clean(r.get("variant")), clean(r.get("canonical"))
                if v and c:
                    alias.setdefault(v, set()).add(c)
                    alias.setdefault(c, set()).add(v)

    # ---- invert the paper-scoped species key: accepted_name -> {variant spellings} ----
    variants = {}
    if os.path.exists(key_path):
        with open(key_path, newline="", encoding="utf-8-sig") as f:
            for r in csv.DictReader(f):
                a, v = clean(r.get("accepted_name")), clean(r.get("variant_name"))
                if not a or not v or is_placeholder(v) or not is_binomial(v):
                    continue
                if v.lower() != a.lower():
                    variants.setdefault(a, set()).add(v)

    rows = []
    st = {"species": 0, "placeholder": 0, "auto": 0, "review": 0, "dropped": 0}

    for r in ref:
        acc = clean(r.get("accepted_name"))
        if not acc or acc in NA:
            continue
        st["species"] += 1
        fam = clean(r.get("Family_resolved")) or clean(r.get("Family_MDD"))
        order = clean(r.get("Order_resolved")) or clean(r.get("Order_MDD"))

        if is_placeholder(acc):
            st["placeholder"] += 1
            rows.append({
                "accepted_name": acc, "candidate_name": "", "candidate_rank": "",
                "candidate_source": "none_possible", "auto_match": "FALSE",
                "family_expected": fam, "order_expected": order,
                "note": "genus-level placeholder: no single species tip can represent it",
            })
            continue

        acc_bi = " ".join(acc.split()[:2]) if is_trinomial(acc) else acc
        acc_g, acc_e = (acc_bi.split() + ["", ""])[:2]

        seen, cands = set(), []

        def add(name, source, auto=None, note="", trusted=False):
            # `trusted` bypasses the plausibility/truncation heuristics. Those exist to
            # sift the machine-inverted species key; a hand-verified TREE_TIP_BRIDGES
            # entry needs no sifting, and would often fail `plausible()` anyway because
            # its genus (Neovison, Pecari, Limnogale, Chaerephon...) is by definition
            # one the project does not use.
            name = clean(name)
            if not name or name in NA or is_placeholder(name):
                return
            if name.lower() in seen:
                return
            if trusted:
                seen.add(name.lower())
                cands.append((name, source, True, note))
                return
            if name != acc and not plausible(name):
                st["dropped"] += 1
                return
            if name != acc and is_binomial(name) and is_binomial(acc_bi) \
                    and truncation_of(name, acc_bi):
                st["dropped"] += 1
                return
            # classify same-taxon vs different-taxon
            if auto is None:
                g, e = name.split()
                if g == acc_g and same_epithet_concept(e, acc_e):
                    auto, note = True, note or "orthographic variant"
                elif g != acc_g and same_epithet_concept(e, acc_e):
                    auto, note = True, note or f"same epithet, generic reassignment ({g} <-> {acc_g})"
                else:
                    auto = False
                    note = note or ("different epithet in same genus -- distinct taxon "
                                    "concept unless verified as a senior synonym"
                                    if g == acc_g else
                                    "different genus and epithet -- verify before use")
            seen.add(name.lower())
            cands.append((name, source, bool(auto), note))

        add(acc, "accepted_name", auto=True, note="")
        add(r.get("mdd_accepted_name"), "mdd_accepted_name", auto=True,
            note="Mammal Diversity Database name; Upham 2019 tips follow MDD")
        for a in sorted(alias.get(acc, ())):
            add(a, "display_alias", auto=True, note="unified name from species_display_aliases.csv")
        if is_trinomial(acc):
            add(acc_bi, "subspecies_parent", auto=True,
                note="subspecies -> parent species: a species-level tree has no subspecies tip")
        if acc in TREE_TIP_BRIDGES:
            bn, bwhy = TREE_TIP_BRIDGES[acc]
            add(bn, "verified_bridge", auto=True, note=bwhy, trusted=True)
        for v in sorted(variants.get(acc, ())):
            add(v, "species_key_variant")
        for name, _, _, _ in list(cands):
            for a in sorted(alias.get(name, ())):
                add(a, "display_alias", auto=True,
                    note="unified name from species_display_aliases.csv")

        for i, (name, source, auto, note) in enumerate(cands, start=1):
            st["auto" if auto else "review"] += 1
            rows.append({
                "accepted_name": acc, "candidate_name": name, "candidate_rank": i,
                "candidate_source": source, "auto_match": "TRUE" if auto else "FALSE",
                "family_expected": fam, "order_expected": order, "note": note,
            })

    cols = ["accepted_name", "candidate_name", "candidate_rank", "candidate_source",
            "auto_match", "family_expected", "order_expected", "note"]
    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, "w", newline="", encoding="utf-8") as f:
        w = csv.DictWriter(f, fieldnames=cols, quoting=csv.QUOTE_MINIMAL,
                           lineterminator="\n")
        w.writeheader()
        w.writerows(rows)

    print(f"wrote {os.path.relpath(OUT, REPO)}")
    print(f"  species                    : {st['species']}")
    print(f"  genus placeholders         : {st['placeholder']} (no candidates)")
    print(f"  auto_match candidates      : {st['auto']}")
    print(f"  review-only candidates     : {st['review']}")
    print(f"  dropped (common/truncated) : {st['dropped']}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
