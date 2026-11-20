#!/usr/bin/env python3
"""
make_tip_crosswalk_seed.py -- seed __merging_trees/tree_tip_crosswalk.csv

Enumerates the CANDIDATE NAMES for each name in the species universe, in priority
order, so the tree builds can resolve each to a real tip in a published source
tree. It reads no tree file. Every candidate is a spelling recorded either in
_keys/ or in the Mammal Diversity Database (MDD) names extract.

2026-11 CHANGE: the species list is no longer _keys/species_reference.csv alone.
It is __merging_trees/species_universe.csv (build_species_universe.py): every
Species label the app loads plus the curated reference list. Names that are out
of scope for a mammal tree (non-mammals, common names, placeholders, fossils) get
ONE row with candidate_source = "out_of_scope" and are never matched.

The important column is `auto_match`:

  auto_match = TRUE   safe to match to a tip without human sign-off: the same
                      taxon under a different generic assignment, an orthographic
                      or gender-agreement variant, a synonym MDD lists under
                      exactly one living species, or a subspecies falling back to
                      its parent species.

  auto_match = FALSE  a DIFFERENT TAXON CONCEPT, or an ambiguous one. Reported by
                      the coverage report as a lead, never matched silently:
                      Rattus norvegicus -> Rattus rattus (species-key link between
                      distinct species); a pre-split name that now covers several
                      species; an epithet shared with another genus in the family.
                      Promote one by hand (set auto_match TRUE and record who
                      decided, mirroring _keys/reidentifications.csv), or move it
                      into TREE_TIP_BRIDGES so a re-seed cannot lose it.

candidate_source values
  accepted_name              the name itself
  mdd_accepted_name          hand-entered MDD name in species_reference.csv
  mdd_current_name           MDD's current name for a name MDD records as the
                             Checklist-of-Mammals (CMW 2020) or MSW3 (2005) name
  mdd_cmw_name / mdd_msw3_name
                             the CMW / MSW3 name MDD records for the species --
                             Upham et al. 2019 tips follow a 2018-19 taxonomy, so
                             these older names are usually the tip spelling
  mdd_generic_reassignment   same epithet, genus is one MDD records for the species
                             (current, CMW, MSW3 or original combination)
  mdd_nominal_synonym        a junior synonym MDD lists under exactly one species
  mdd_orthographic           spelling / gender variant of exactly one MDD name in
                             the same genus
  mdd_same_epithet_in_family REVIEW ONLY: epithet occurs once in the family, under
                             another genus
  taxonomy_genus             the genus _keys/species_taxonomy.csv files the label under,
                             with the label's own epithet (Chroeomys andinus -> Abrothrix
                             andinus); auto only when MDD knows that name
  display_alias, subspecies_parent, verified_bridge, species_key_variant
                             as before

Dropped entirely: common names ("Owl monkey"), abbreviated genera ("C. mitis"),
truncations ("Daubentonia madagas."), and sp./spp. lumps.

Paths: reads from $EVOM1_REPO (default: the repo this file sits in) and writes
under $EVOM1_OUT (default: the same repo).

Run from repo root:  python3 __merging_trees/build_species_universe.py
                     python3 __merging_trees/make_tip_crosswalk_seed.py
"""

import csv
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.environ.get("EVOM1_REPO") or os.path.dirname(HERE)
OUT_ROOT = os.environ.get("EVOM1_OUT") or REPO
OUT = os.path.join(OUT_ROOT, "__merging_trees", "tree_tip_crosswalk.csv")
MDD = os.path.join(HERE, "reference_tables", "mdd_names_extract.csv")

NA = {"", "NA", "NaN", "N/A", "None", "nan", None}

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

# ---------------------------------------------------------------------------
# Never-bridge list: (accepted_name, candidate) pairs that must stay
# auto_match = FALSE whatever any rule or database says. A curator decision
# outranks MDD's synonymy; record the basis so the next reader can revisit it.
# ---------------------------------------------------------------------------
NEVER_BRIDGE = {
    ("Marmosa mitis", "Marmosa robinsoni"):
        "curator decision (tree-layer handoff, 2026-08): Marmosa mitis must not be bridged "
        "to M. robinsoni, although MDD lists 'mitis' in the synonymy of M. robinsoni",
    ("Rattus norvegicus", "Rattus rattus"):
        "distinct species linked only by the paper-scoped species key",
    ("Avahi occidentalis", "Avahi laniger"):
        "distinct species linked only by the paper-scoped species key",
}


def clean(x):
    if x is None:
        return ""
    x = x.replace("_", " ").replace("*", "").replace("\u00a0", " ")
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


_GENDER = ("us", "a", "um", "is", "e", "er", "ra", "rum", "ris", "re")


def _stem(e):
    for suf in sorted(_GENDER, key=len, reverse=True):
        if e.endswith(suf) and len(e) - len(suf) >= 4:
            return e[: -len(suf)]
    return e


def same_epithet_concept(e1, e2):
    """True if two epithets are orthographic variants of one another, not two taxa.

    Covers latinisation noise the classical literature is full of:
    burchelli/burchellii, lagotricha/lagothricha, mulata/mulatta, trivirgatua --
    and gender agreement of an adjectival epithet (vittatus/vittata, niger/nigra),
    which the Code requires to change when a species moves genus.
    Deliberately conservative: a 1-2 character difference on a stem that already
    agrees, never a different word.
    """
    if e1 == e2:
        return True
    # -i / -ii and -us / -a style endings on an identical stem
    for a, b in ((e1, e2), (e2, e1)):
        if a == b + "i" or a == b + "ii" or a == b + "e":
            return True
    if _stem(e1) == _stem(e2) and _stem(e1) != e1 and _stem(e2) != e2:
        return True                         # gender agreement
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


def strict_same_epithet(e1, e2):
    """Identical, -i/-ii, or gender agreement -- never a Levenshtein near-miss.

    Used where one side is not known to be a scientific name at all: a common
    name joined to a genus ("American marten" -> "Martes marten") must not be
    allowed to drift onto a real epithet one edit away ("Martes martes").
    """
    if e1 == e2:
        return True
    for a, b in ((e1, e2), (e2, e1)):
        if a == b + "i" or a == b + "ii":
            return True
    return _stem(e1) == _stem(e2) and _stem(e1) != e1 and _stem(e2) != e2


# ---------------------------------------------------------------------------
# Mammal Diversity Database name index
# ---------------------------------------------------------------------------
class MddIndex:
    """Lookups over reference_tables/mdd_names_extract.csv (see its README)."""

    def __init__(self, path):
        self.cur = {}            # current name -> row
        self.old_to_cur = {}     # CMW / MSW3 name -> {current names}
        self.nominal = {}        # (genus, epithet) -> {current names}
        self.by_genus = {}       # genus -> {(epithet, name)} over current + old names
        self.by_family_epithet = {}   # (FAMILY, epithet) -> {current names}
        self.genera = set()
        if not os.path.exists(path):
            sys.exit(f"MDD names extract not found: {path}")
        with open(path, newline="", encoding="utf-8-sig") as f:
            for r in csv.DictReader(f):
                cur = clean(r["sciName"])
                if not is_binomial(cur):
                    continue
                g, e = cur.split()
                row = {"cur": cur, "family": (r.get("family") or "").upper(),
                       "cmw": "", "msw3": ""}
                self.cur[cur] = row
                gset = {g}
                cmw = clean(r.get("CMW_sciName"))
                if cmw not in NA and is_binomial(cmw):
                    row["cmw"] = cmw
                    gset.add(cmw.split()[0])
                    if cmw != cur:
                        self.old_to_cur.setdefault(cmw, set()).add(cur)
                msw = clean(r.get("MSW3_sciName"))
                if msw not in NA and is_binomial(msw) \
                        and (r.get("MSW3_matchtype") or "") != "unmatched":
                    row["msw3"] = msw
                    gset.add(msw.split()[0])
                    if msw != cur:
                        self.old_to_cur.setdefault(msw, set()).add(cur)
                orig = clean(r.get("originalNameCombination")).split()
                if orig and re.fullmatch(r"[A-Z][a-z]{2,}", orig[0]):
                    gset.add(orig[0])
                self.genera |= gset
                epithets = {e}
                for item in (r.get("nominalNames") or "").split("|"):
                    item = item.strip()
                    if not item or re.search(r"misidentif|partim|in part", item, flags=re.I):
                        continue
                    tok = item.split()[0]
                    if re.fullmatch(r"[a-z][a-z-]{2,}", tok):
                        epithets.add(tok)
                for gg in gset:
                    for ee in epithets:
                        self.nominal.setdefault((gg, ee), set()).add(cur)
                for nm in {cur, row["cmw"], row["msw3"]} - {""}:
                    ng, ne = nm.split()
                    self.by_genus.setdefault(ng, set()).add((ne, nm))
                self.by_family_epithet.setdefault((row["family"], e), set()).add(cur)

    def _older(self, cur, exclude):
        """CMW / MSW3 names of a current species, with the 1:1 test applied."""
        out = []
        row = self.cur[cur]
        for key, src, label in (("cmw", "mdd_cmw_name", "Checklist of Mammals of the World (2020)"),
                                ("msw3", "mdd_msw3_name", "MSW3 (2005)")):
            old = row[key]
            if not old or old == cur or old in exclude:
                continue
            n = len(self.old_to_cur.get(old, ()))
            if n <= 1 and old not in self.cur:
                out.append((old, src, True, f"{label} name of {cur} per MDD"))
            elif n <= 1:
                out.append((old, src, False,
                            f"{label} placed {cur} under {old}, which MDD still "
                            "recognises as a separate species -- split, not a synonym"))
            else:
                out.append((old, src, False,
                            f"{label} name {old} now covers {n} MDD species "
                            f"including {cur} -- split, verify before use"))
        return out

    def candidates(self, name, family=""):
        """Ordered [(candidate, source, auto, note)] for a binomial `name`."""
        if not is_binomial(name):
            return []
        g, e = name.split()
        out = []
        if name in self.cur:                                   # A. current name
            return self._older(name, {name})
        if name in self.old_to_cur:                            # B. older name
            targets = sorted(self.old_to_cur[name])
            for s in targets:
                nominotypical = same_epithet_concept(s.split()[1], e)
                if len(targets) == 1:
                    out.append((s, "mdd_current_name", True,
                                f"MDD current name; {name} is its CMW/MSW3 name"))
                elif nominotypical:
                    out.append((s, "mdd_current_name", True,
                                f"MDD current name of the nominotypical species; {name} "
                                f"formerly also covered {len(targets) - 1} species since split"))
                else:
                    out.append((s, "mdd_current_name", False,
                                f"{name} formerly included {s}, now a separate species"))
                if len(targets) == 1 or nominotypical:
                    out += self._older(s, {name})
            return out
        hits = sorted(self.nominal.get((g, e), ()))            # C. nominal names
        if hits:
            for s in hits:
                same = same_epithet_concept(s.split()[1], e)
                src = "mdd_generic_reassignment" if same else "mdd_nominal_synonym"
                if len(hits) == 1:
                    note = (f"same epithet; MDD records genus {g} for {s}" if same else
                            f"MDD lists '{e}' as a synonym of {s} only")
                    out.append((s, src, True, note))
                    out += self._older(s, {name})
                else:
                    out.append((s, src, False,
                                f"'{g} {e}' is a nominal name under {len(hits)} MDD species "
                                f"({'; '.join(hits)}) -- ambiguous"))
            return out
        variants = sorted({nm for ee, nm in self.by_genus.get(g, ())   # D. spelling
                           if ee != e and same_epithet_concept(ee, e)})
        species = sorted({v if v in self.cur else next(iter(sorted(self.old_to_cur.get(v, {v}))))
                          for v in variants})
        if len(species) == 1:
            for v in variants:
                out.append((v, "mdd_orthographic", True,
                            f"spelling / gender variant of {v}, the only such name in {g}"))
                if v in self.cur:
                    out += self._older(v, {name})
                elif len(self.old_to_cur.get(v, ())) == 1:
                    s = next(iter(self.old_to_cur[v]))
                    out.append((s, "mdd_current_name", True,
                                f"MDD current name; {v} is its CMW/MSW3 name"))
            return out
        for v in variants:
            out.append((v, "mdd_orthographic", False,
                        f"{len(species)} MDD species in {g} have an epithet this close -- ambiguous"))
        fam = (family or "").upper()                            # E. review lead only
        if fam:
            for s in sorted(self.by_family_epithet.get((fam, e), ())):
                out.append((s, "mdd_same_epithet_in_family", False,
                            f"epithet '{e}' occurs once in {fam.title()}, under {s.split()[0]}; "
                            "possible generic reassignment -- verify before use"))
        return out


def main():
    csv.field_size_limit(10 ** 9)
    uni_path = os.path.join(OUT_ROOT, "__merging_trees", "species_universe.csv")
    if not os.path.exists(uni_path):
        uni_path = os.path.join(REPO, "__merging_trees", "species_universe.csv")
    if not os.path.exists(uni_path):
        sys.exit("species_universe.csv not found -- run build_species_universe.py first")
    ref_path = os.path.join(REPO, "_keys", "species_reference.csv")
    ali_path = os.path.join(REPO, "_keys", "species_display_aliases.csv")
    key_path = os.path.join(REPO, "_keys", "Stephan", "species_key.csv")
    tax_path = os.path.join(REPO, "_keys", "species_taxonomy.csv")

    with open(uni_path, newline="", encoding="utf-8-sig") as f:
        universe = list(csv.DictReader(f))
    with open(ref_path, newline="", encoding="utf-8-sig") as f:
        ref = {clean(r.get("accepted_name")): r for r in csv.DictReader(f)}

    mdd = MddIndex(MDD)

    # ---- known mammal genera, used to reject common names and abbreviations ----
    genera = set(mdd.genera)
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
    st = {"names": 0, "in_scope": 0, "out_of_scope": 0, "placeholder": 0,
          "auto": 0, "review": 0, "dropped": 0}

    for u in universe:
        acc = clean(u.get("accepted_name"))
        if not acc or acc in NA:
            continue
        st["names"] += 1
        r = ref.get(acc, {})
        fam = clean(r.get("Family_resolved")) or clean(r.get("Family_MDD")) or clean(u.get("family"))
        order = clean(r.get("Order_resolved")) or clean(r.get("Order_MDD")) or clean(u.get("order"))
        fam = "" if fam in NA else fam
        order = "" if order in NA else order
        in_ref = (u.get("in_species_reference") == "TRUE")

        # genus-level placeholders in the curated list keep their own status
        if is_placeholder(acc) and in_ref:
            st["placeholder"] += 1
            rows.append({
                "accepted_name": acc, "candidate_name": "", "candidate_rank": "",
                "candidate_source": "none_possible", "auto_match": "FALSE",
                "family_expected": fam, "order_expected": order,
                "note": "genus-level placeholder: no single species tip can represent it",
            })
            continue
        if u.get("scope") != "in_scope_mammal":
            st["out_of_scope"] += 1
            rows.append({
                "accepted_name": acc, "candidate_name": "", "candidate_rank": "",
                "candidate_source": "out_of_scope", "auto_match": "FALSE",
                "family_expected": fam, "order_expected": order,
                "note": f"{u.get('scope')}: {u.get('scope_basis')}",
            })
            continue
        st["in_scope"] += 1

        acc_bi = " ".join(acc.split()[:2]) if is_trinomial(acc) else acc
        acc_g, acc_e = (acc_bi.split() + ["", ""])[:2]

        seen, cands = {}, []

        def add(name, source, auto=None, note="", trusted=False):
            # `trusted` bypasses the plausibility/truncation heuristics. Those exist to
            # sift the machine-inverted species key; a hand-verified TREE_TIP_BRIDGES
            # entry or an MDD-recorded name needs no sifting.
            name = clean(name)
            if not name or name in NA or is_placeholder(name):
                return
            if (acc, name) in NEVER_BRIDGE:
                if name.lower() not in seen:
                    seen[name.lower()] = len(cands)
                    cands.append((name, source, False, NEVER_BRIDGE[(acc, name)]))
                return
            if name.lower() in seen:
                # A review-only lead recorded earlier (e.g. an MDD "same epithet in
                # family" hint) must not shadow a later rule that vouches for the
                # same name (e.g. the curated species key): upgrade it in place.
                i = seen[name.lower()]
                if not cands[i][2] and (trusted and auto):
                    cands[i] = (name, source, True, note)
                elif not cands[i][2] and not trusted and auto is None and is_binomial(name) \
                        and plausible(name) and same_epithet_concept(name.split()[1], acc_e):
                    g = name.split()[0]
                    cands[i] = (name, source, True,
                                "orthographic variant" if g == acc_g else
                                f"same epithet, generic reassignment ({g} <-> {acc_g})")
                return
            if trusted:
                seen[name.lower()] = len(cands)
                cands.append((name, source, bool(auto), note))
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
            seen[name.lower()] = len(cands)
            cands.append((name, source, bool(auto), note))

        def add_mdd(name, suffix=""):
            for cand, src, auto, note in mdd.candidates(name, fam):
                add(cand, src, auto=auto, note=note + suffix, trusted=True)

        add(acc, "accepted_name", auto=True, note="")
        mdd_ref = clean(r.get("mdd_accepted_name"))
        add(mdd_ref, "mdd_accepted_name", auto=True,
            note="Mammal Diversity Database name; Upham 2019 tips follow MDD")
        if is_binomial(acc):
            add_mdd(acc)
        tg = clean(u.get("taxonomy_genus"))
        if tg and tg not in NA and tg != acc_g and acc_e:
            tname = f"{tg} {acc_e}"
            known = mdd.candidates(tname, fam)
            if tname in mdd.cur or tname in mdd.old_to_cur:
                add(tname, "taxonomy_genus", auto=True, trusted=True,
                    note=f"species_taxonomy.csv files this label under {tg}; MDD knows {tname}")
                add_mdd(tname)
            else:
                for cand, src, auto, note in known:
                    if src != "mdd_orthographic":
                        continue
                    strict = strict_same_epithet(cand.split()[1], acc_e)
                    add(cand, "taxonomy_genus", auto=bool(auto and strict), trusted=True,
                        note=(f"species_taxonomy.csv files this label under {tg}; {note}"
                              if strict else
                              f"species_taxonomy.csv files this label under {tg}; nearest "
                              f"MDD name is {cand} -- not a gender/-i variant, verify"))
                    if auto and strict:
                        add_mdd(cand)
        if mdd_ref and mdd_ref not in NA and is_binomial(mdd_ref):
            add_mdd(mdd_ref)
        for a in sorted(alias.get(acc, ())):
            add(a, "display_alias", auto=True, note="unified name from species_display_aliases.csv")
        if is_trinomial(acc):
            add(acc_bi, "subspecies_parent", auto=True,
                note="subspecies -> parent species: a species-level tree has no subspecies tip")
            for cand, src, auto, note in mdd.candidates(acc_bi, fam):
                add(cand, "subspecies_parent", auto=auto,
                    note=f"subspecies -> parent species {acc_bi}; {note}", trusted=True)
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

    print(f"wrote {os.path.relpath(OUT, OUT_ROOT)}")
    print(f"  universe names             : {st['names']}")
    print(f"  in scope (mammal species)  : {st['in_scope']}")
    print(f"  out of scope               : {st['out_of_scope']}")
    print(f"  genus placeholders         : {st['placeholder']} (no candidates)")
    print(f"  auto_match candidates      : {st['auto']}")
    print(f"  review-only candidates     : {st['review']}")
    print(f"  dropped (common/truncated) : {st['dropped']}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
