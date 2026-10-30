#!/usr/bin/env python3
"""Read-only provenance audit of the current mixed brain-size harvest.

Writes audit files beside this script; never edits sources, keys, merge outputs or app.
Unknown means not established by this audit, NOT intrinsically unknowable.
An equal number in an unrelated publication is never used to assign provenance.
"""
import csv
import json
import math
import re
from collections import Counter, defaultdict
from pathlib import Path

OUT = Path(__file__).resolve().parent
REPO = OUT.parents[1]


def read(path, delimiter=","):
    with (REPO / path).open(encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f, delimiter=delimiter))


def write(name, rows):
    if not rows:
        return
    with (OUT / name).open("w", newline="") as f:
        w = csv.DictWriter(f, fieldnames=list(rows[0]))
        w.writeheader()
        w.writerows(rows)


def num(x):
    try:
        v = float(x)
        return v if math.isfinite(v) else None
    except (ValueError, TypeError):
        return None


def same(a, b, tolerance=1e-7):
    return a is not None and b is not None and abs(a-b) <= max(1e-7, abs(b)*tolerance)


def clean(x):
    return re.sub(r"\s+", " ", x.replace("_", " ").replace("*", "")).strip()


# Mirror the PRESENT Python harvest's name mapping solely to join audit records
# to its rows. This is not a new taxonomic crosswalk or a species-name repair.
variants = {}
for p in sorted((REPO / "_keys").rglob("*species_key.csv")):
    for r in read(p):
        a, v = r.get("accepted_name", "").strip(), r.get("variant_name", "").strip()
        if a and a.upper() != "NA" and v:
            variants.setdefault(v.lower(), a)
hub = {r["accepted_name"].lower(): r["accepted_name"] for r in read("_keys/species_reference.csv")}


def resolve(x):
    x = clean(x)
    return hub.get(x.lower()) or variants.get(x.lower()) or x


def indexed(path, species, delimiter=","):
    result = defaultdict(list)
    for i, r in enumerate(read(path, delimiter), 2):
        r = dict(r, source_file=str(path), source_line=str(i), audit_species=resolve(species(r)))
        result[r["audit_species"]].append(r)
    return result


RAW = "Boddy_etal_2012/brain_body_database_v2.txt"
RAW_SPECIES = "Updated Species Name (from Wilson & Reeder Mammal Species of the World)"
boddy_raw = indexed(RAW, lambda r: r[RAW_SPECIES], "\t")
boddy_s1 = indexed("__Public/comparative-data/10.1111%2Fj.1420-9101.2012.02491.x_TableS1.tsv", lambda r: r["Species Name"], "\t")
decasien = indexed("__Public/comparative-data/10.1038%2Fs41559-017-0112_BrainData.tsv", lambda r: r["Genus"] + " " + r["Species"], "\t")
burger = indexed("__Public/comparative-data/10.1093%2Fjmammal%2Fgyz043_SupplementaryDataSD1.tsv", lambda r: r["species_sci"], "\t")

BODDY_METHODS = "Boddy_etal_2012/Boddy-2012-Comparative analysis.pdf, Data collection, journal p.983"
# Only explicit measurement evidence is used. Other named sources remain in the
# chase list, even if their values are printed in a column called Brain Mass.
MASS_EVIDENCE = {
    "Sherwood data/this study": BODDY_METHODS + "; original post-mortem collection masses (CCS, n=94)",
    "Sherwood": BODDY_METHODS + "; same original collection, reprinted through Boddy",
    "Stephan 1981": "_keys/brain_size_basis.csv: Stephan_etal_1981 / Brain_weight = fresh weighed mass",
    "Crile & Quiring 1940": "Crile_Quiring_1940/reference_tables/Crile_Quiring_1940_Table1_definitions.csv: brain_g, organ weights",
    "Bronson 1981": "https://onlinelibrary.wiley.com/doi/abs/10.1002/ajpa.1330560109 : necropsy brain weights",
    "Hartwig et al 2011": "https://anatomypubs.onlinelibrary.wiley.com/doi/10.1002/ar.21515 : Table 1 and Appendix 1 brain weights from necropsies",
    "Spitzka 1903": "https://embryology.med.unsw.edu.au/embryology/index.php?title=Journal_of_Comparative_Neurology_13_%281903%29 : original Table I, fresh brain weights; separate preserved weights",
}
VOLUME_SUBTYPE = {
    "Isler et al 2008": "endocranial_volume",
    "Ashwell 2007": "endocranial_volume",
    "Hafner 1984": "endocranial_volume",
    "Iwaniuk 2001": "endocranial_volume",
    "Silcox 2009": "endocranial_volume",
    "Haug 1987": "brain_volume",
    "Rilling 1999": "brain_volume",
}


def raw_type(r, volume_col="Brain Volume", mass_col="Brain Mass (g)"):
    source = r["Source"]
    vol, mass = num(r.get(volume_col)), num(r.get(mass_col))
    if vol is not None and vol > 0 and same(mass, vol * 1.036):
        subtype = VOLUME_SUBTYPE.get(source, "volume_subtype_unchecked")
        return subtype, "paired volume and mass: mass = volume * 1.036; " + source
    if source in MASS_EVIDENCE and mass is not None and mass > 0:
        return "mass", MASS_EVIDENCE[source]
    # Silcox's DeCasien row omits the volume, but the exact Boddy antecedent
    # preserves it. A blank volume is not evidence of a weighed mass.
    for old in boddy_raw[r["audit_species"]]:
        if source == old["Source"] and same(mass, num(old["Brain Mass (g)"])):
            ov = num(old["Brain Volume"])
            if ov is not None and ov > 0 and same(mass, ov * 1.036):
                return VOLUME_SUBTYPE.get(source, "volume_subtype_unchecked"), "exact cited antecedent: " + RAW + ":" + old["source_line"]
    return "unresolved", "primary measurement method not established here: " + source


def aggregate_boddy(s):
    # Reconstruct only where the actual adult source-row average reproduces S1.
    # No nearest-value matching, no assumed allocation of a heterogeneous mean.
    adults = [r for r in boddy_raw[s["audit_species"]]
              if r["Age Class"] == "Adult" and (num(r["Brain Mass (g)"]) or 0) > 0
              and "emaciat" not in r["Notes"].lower()]
    if not adults:
        return "unresolved", "no matched adult raw records", s["Reference"], ""
    mean = sum(num(r["Brain Mass (g)"]) for r in adults) / len(adults)
    if not same(mean, num(s["Brain Mass (g)"])):
        return "unresolved", "adult raw mean does not reproduce Table S1; subset/taxonomy/aggregation needs checking", s["Reference"], ""
    typed = [raw_type(r) for r in adults]
    kinds = {t[0] for t in typed}
    basis = next(iter(kinds)) if len(kinds) == 1 else "known_composite" if "unresolved" not in kinds else "unresolved"
    return basis, "adult raw mean reproduced; " + " | ".join(sorted({t[1] for t in typed})), "; ".join(sorted({r["Source"] for r in adults})), ";".join(r["source_line"] for r in adults)


hh_ref15 = {"Erinaceus europaeus", "Oryctolagus cuniculus", "Bos taurus", "Tupaia sp."}
HH_MASS = {"Aotus trivirgatus", "Callithrix sp.", "Cebus apella", "Saimiri sciureus", "Macaca mulatta", "Macaca radiata", "Papio cynocephalus", "Homo sapiens", "Blarina brevicauda", "Condylura cristata", "Scalopus aquaticus", "Cavia porcellus", "Mesocricetus auratus", "Mus musculus", "Rattus norvegicus", "Dendrohyrax sp.", "Loxodonta Africana", "Procavia sp.", "Giraffa camelopardalis", "Sus scrofa"}
hh = indexed("HerculanoHouzel__2015/HerculanoHouzel__2015_Table1.csv", lambda r: r["species"])

harvest = read("__merging_brain_mass/brain_mass_unfiltered.csv")
mixed = [r for r in harvest if r["poolable_group"] == "mass_or_volume_mixed"]
audit = []
for i, h in enumerate(mixed, 1):
    sp, paper, value = h["Species"], h["paper"], num(h["Value_g"])
    join_sp = resolve(sp)
    basis, evidence, source, lines, age, sex, chase = "unresolved", "", "", "", "", "", ""
    if paper == "DeCasien_etal_2017":
        matched = [r for r in decasien[join_sp] if same(num(r["Brain Mass"]), value)]
        types = [raw_type(r, "Brain Vol", "Brain Mass") for r in matched]
        kinds = {t[0] for t in types}
        if len(kinds) == 1:
            basis = next(iter(kinds))
        evidence = " | ".join(sorted({t[1] for t in types}))
        source = "; ".join(sorted({r["Source"] for r in matched}))
        lines = ";".join(r["source_line"] for r in matched)
        age = "; ".join(sorted({r["Age"] for r in matched}))
        sex = "; ".join(sorted({r["Sex"] for r in matched}))
        chase = source
    elif paper == "Boddy_etal_2012":
        matched = [r for r in boddy_s1[join_sp] if same(num(r["Brain Mass (g)"]), value)]
        if len(matched) == 1:
            basis, evidence, source, lines = aggregate_boddy(matched[0])
            age = "adult mean"
            chase = source
    elif paper == "Burger_etal_2019":
        matched = [r for r in burger[join_sp] if same(num(r["Mean_brain_mass_g"]), value)]
        if len(matched) == 1:
            r = matched[0]
            source = r["BrainReference1"] + " | " + r["BrainReference2"]
            lines, sex, age = r["source_line"], r["Sex"], "adult mean (Burger inclusion policy)"
            ref = r["BrainReference1"]
            chase = ref
            if ref == "Boddy2012":
                prior = [s for s in boddy_s1[join_sp] if abs(num(s["Brain Mass (g)"]) - value) <= 0.0050001]
                if len(prior) == 1:
                    basis, evidence, chase, _ = aggregate_boddy(prior[0])
                    evidence = "cited Boddy S1 value agrees within Burger rounding (<=0.005 g); " + evidence
            elif ref in {"islerPrim2008", "islerPrim2008/Amniote", "islerPrim2008/Pantheria"}:
                basis, evidence = "endocranial_volume", "Isler 2008 ECV source; Amniote/Pantheria are body-data citations; Burger methods: 1 cm3 to 1 g"
            elif ref in {"Ashwell2008", "Ashwell2008/Weisbecker.etal.2013"}:
                basis, evidence = "endocranial_volume", "https://pubmed.ncbi.nlm.nih.gov/18230970/ ; https://doi.org/10.1159/000348647 (body masses accompany Ashwell ECVs)"
            elif ref == "Gittleman1986":
                basis, evidence = "endocranial_volume", "https://repository.si.edu/server/api/core/bitstreams/b5f0eb7a-3b42-44f2-b896-e692c2da9055/content : journal p.29, braincase volumes measured using 2 mm glass beads"
            elif ref in {"Mateju2016", "Mateju2016/Pantheria"}:
                basis, evidence = "endocranial_volume", "https://pmc.ncbi.nlm.nih.gov/articles/PMC4822454/ : Methods, lead-shot measurements of skull cavity"
    elif paper == "HerculanoHouzel__2015":
        matched = [r for r in hh[join_sp] if same(num(r["brain.mass..g.or.cm3."]), value)]
        if len(matched) == 1:
            r = matched[0]
            lines = r["source_line"]
            if r["species"] in hh_ref15:
                basis, source = "brain_volume", "Hofman 1985, Table I (HH2015 ref.15)"
                evidence = "HH2015 printed Table 1 per-cell citation; Hofman Table I explicitly brain_volume_cm3"
            elif r["species"] in HH_MASS:
                basis, source = "mass", "HH2015 printed Table 1 refs.18/19/22/23/24/25/26/27/28"
                evidence = "Table 1 per-cell citations to isotropic-fractionator weights; olfactory bulbs excluded; original data must take precedence"
    audit.append(dict(audit_row=i, Species=sp, current_name_key=join_sp, publication=paper, value_as_app_g=h["Value_g"],
                      original_quantity=basis, resolved=basis != "unresolved", original_reference=source,
                      source_records=" | ".join(r["source_file"] + ":" + r["source_line"] for r in matched),
                      antecedent_or_matched_data_lines=lines, age_scope=age, sex=sex, evidence=evidence,
                      reference_to_chase=chase if basis == "unresolved" else "",
                      harvested_source=h["Source"], current_role=h["role"]))

# Existing typed alternatives. Regional volumes never qualify. ECV is kept
# explicitly distinct from brain-tissue volume; no numeric cross-basis pooling.
alternatives = defaultdict(set)
for r in harvest:
    if r["poolable_group"] != "mass_or_volume_mixed" and (num(r["Value_g"]) or 0) > 0:
        alternatives[resolve(r["Species"])].add(r["measure_emitted"] + ": " + r["paper"])
for r in read("__merging_volumes/volumes_long.csv"):
    if r["Variable"] == "Total_brain_net_volume_Vol.mm3" and (num(r["Value"]) or 0) > 0:
        alternatives[resolve(r["Species"])].add("brain tissue net volume: " + r["Teams"])
for r in read("__merging_endocranial_volume/endocranial_volume_long.csv"):
    if (num(r["Value"]) or 0) > 0:
        alternatives[resolve(r["Species"])].add("endocranial volume: " + r["Teams"])
for r in audit:
    if r["original_quantity"] in {"mass", "brain_volume", "endocranial_volume", "volume_subtype_unchecked"} and "Juvenile" not in r["age_scope"]:
        alternatives[resolve(r["Species"])].add("resolved current mixed record, " + r["original_quantity"] + ": " + r["original_reference"])

# Source data can provide a typed alternative even when the merge omitted it
# or its published species mean could not be numerically reconstructed.
for sp, records in boddy_raw.items():
    for r in records:
        if r["Age Class"] == "Adult" and "emaciat" not in r["Notes"].lower() and raw_type(r)[0] not in {"unresolved", "known_composite"}:
            alternatives[sp].add("typed adult raw Boddy record, " + raw_type(r)[0] + ": " + r["Source"])
for r in read("DeCasien_etal_2017/DeCasien_etal_2017_BrainData.csv"):
    sp = resolve(r["KEY"])
    r["audit_species"] = sp
    kind, _ = raw_type(r, "Brain Vol", "Brain Mass")
    if r["Age"] == "Adult" and kind != "unresolved":
        alternatives[sp].add("typed adult DeCasien source record (KEY), " + kind + ": " + r["Source"])
for path, sp_col, value_col in [
    ("Hofman__1985/Hofman__1985_TableI.csv", "species", "brain_volume_cm3"),
    ("Haug__1987/Haug__1987_TABLE2.csv", "species_sci", "Brain_Vol.mm3"),
    ("Rilling_Insel_1999/Rilling_Insel_1999_Table1.csv", "Species", "brain_volume_cc_mean"),
]:
    for r in read(path):
        if (num(r[value_col]) or 0) > 0:
            alternatives[resolve(r[sp_col])].add("explicit brain-tissue volume in " + path)

species = []
by_sp = defaultdict(list)
for r in audit:
    by_sp[r["Species"]].append(r)
for sp, rows in sorted(by_sp.items()):
    unresolved = [r for r in rows if not r["resolved"]]
    alt = sorted(alternatives[resolve(sp)])
    action = "use_typed_records" if alt else "disaggregate_known_composite" if any(r["original_quantity"] == "known_composite" for r in rows) else "reference_needed_before_typed_use"
    species.append(dict(Species=sp, mixed_rows=len(rows), distinct_current_numbers=len({num(r["value_as_app_g"]) for r in rows}),
                        quantities_found="; ".join(sorted({r["original_quantity"] for r in rows})),
                        unresolved_rows=len(unresolved), typed_alternative_available=bool(alt),
                        action=action, typed_alternatives=" | ".join(alt),
                        references_to_chase=" | ".join(sorted({r["reference_to_chase"] for r in unresolved})),
                        current_numbers="; ".join(sorted({r["value_as_app_g"] for r in rows}, key=float))))

need = {r["Species"] for r in species if r["action"] == "reference_needed_before_typed_use"}
refs = defaultdict(list)
for r in audit:
    if not r["resolved"]:
        refs[r["reference_to_chase"] or "unmatched provenance"].append(r)
chase = [dict(reference=k, unresolved_rows=len(v), species=len({r["Species"] for r in v}),
              species_without_typed_alternative=len({r["Species"] for r in v} & need),
              priority_species="; ".join(sorted({r["Species"] for r in v} & need))) for k, v in refs.items()]
chase.sort(key=lambda r: (-r["species_without_typed_alternative"], -r["species"], r["reference"]))

write("row_audit.csv", audit)
write("species_audit.csv", species)
write("reference_chase.csv", chase)
write("species_needing_reference.csv", [r for r in species if r["Species"] in need])
summary = dict(harvested_mixed_rows=len(audit), mixed_species=len(species),
               row_quantities=dict(Counter(r["original_quantity"] for r in audit)),
               species_actions=dict(Counter(r["action"] for r in species)),
               species_with_only_one_distinct_number_and_no_typed_alternative=sum(r["Species"] in need and r["distinct_current_numbers"] == 1 for r in species),
               example=[r for r in audit if r["Species"] == "Trachypithecus francoisi"])
assert len(audit) == len(mixed)
assert all(r["source_records"] and r["original_reference"] for r in audit), "Unmatched input record"
assert all(not r["typed_alternative_available"] for r in species if r["Species"] in need)
example = summary["example"]
assert len(example) == 5 and all(r["original_quantity"] == "mass" for r in example)
assert same((102.1 + 86.7) / 2, 94.4)
(OUT / "summary.json").write_text(json.dumps(summary, indent=2) + "\n")
print(json.dumps({k:v for k,v in summary.items() if k != "example"}, indent=2))
