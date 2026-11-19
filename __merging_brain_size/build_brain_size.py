#!/usr/bin/env python3
"""Paired, broadly inclusive brain-size predictors; run after the upstream merges.

AnimalTraits conversion and arithmetic means, with the project's conservative
collection/source controls. This is a new derived view, not a reclassification of
any source measurement. See README.md for scope and weighting limitations.
"""
import csv
import hashlib
import math
import re
import sys
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = Path(__file__).resolve().parent
sys.dont_write_bytecode = True
sys.path.insert(0, str(ROOT / "_keys"))
from resolve_species import resolve_species

DENSITY = 1.036  # g/mL; Herberstein et al. 2022, Unit standardisation
MASS = "Brain mass (all usable sources)"
VOLUME = "Brain volume (all usable sources)"
NET_VOLUME = "Total_brain_net_volume_Vol.mm3"
MASS_MEASURES = {
    "Brain_Mass_measured", "Brain_Mass_estimated_from_brain_volume",
    "Brain_Mass_estimated_from_endocranial_volume", "Brain_Mass_estimated_from_volume",
}
# Authored sample-size adapters: these definitions describe individuals/brains,
# not cells, sections or behaviour trials. All other n-like fields stay unused.
N_SPECS = {
    "10.1093%2Fjmammal%2Fgyz043_SupplementaryDataSD1.tsv":
        ("Sample_size.brain", "Burger_etal_2019", "species", "genus"),
    "10.1038%2Fs41559-017-0112_BrainData.tsv": ("N", "DeCasien_etal_2017", "KEY", None),
    "PMID%3A9672110_Table1.tsv": ("n", "Frahm_etal_1998", "species", None),
    "10.1111%2Fj.1439-0469.1986.tb00624.x_Table1.tsv": ("n", "Röhrs__1986", "species_sci", None),
    "10.1159%2F000121776_TableI.tsv": ("n", "Meyer__1981", "species", None),
    "UMI%3A3017523_TableA-15.tsv": ("n", "Weaver__2001", "Species_binomial", None),
    "10.1159%2F000113584_Table1.tsv": ("n", "Jacobs_Spencer_1994", "species", None),
}
SORIA = "10.1002%2Fecy.3344_Traitdatareported.tsv"


def blocked_labels():
    statuses = {"non_taxon_label", "source_field_ambiguity", "missing_source_label", "unidentified_source_label"}
    return {r["Species"]: r for r in read("_keys/navigation_taxonomy_review.csv") if r["Status"] in statuses}


def read(path, delimiter=","):
    with (ROOT / path).open(encoding="utf-8-sig", newline="") as f:
        return list(csv.DictReader(f, delimiter=delimiter))


def write(path, rows, fields=None):
    with path.open("w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(f, fieldnames=fields or list(rows[0]))
        w.writeheader()
        w.writerows(rows)


def number(x):
    try:
        n = float(x)
        return n if math.isfinite(n) and n > 0 else None
    except (ValueError, TypeError):
        return None


def join(values):
    return "; ".join(sorted(set(str(x) for x in values if x)))


def pair(value, quantity, density=DENSITY):
    """A native volume stays unchanged; a native mass stays unchanged."""
    if quantity == "mass_g":
        return value, value / density
    if quantity == "volume_ml":
        return value * density, value
    raise ValueError(quantity)


def candidate(origin, row_number, row, value, quantity, basis, source, team,
              role, year="", n=None, n_basis="sample size unavailable", evidence=""):
    mass, volume = pair(value, quantity)
    return dict(
        report_id=f"{origin}:{row_number}", Species=row["Species"],
        species_printed=row.get("species_printed", row.get("Species_printed", row["Species"])),
        input_file=origin, input_row=row_number, Source=source, Team=team,
        role=role, Year=year, original_value=value, original_quantity=quantity,
        measurement_basis=basis, mass_g=mass, volume_ml=volume,
        density_g_ml=DENSITY,
        conversion=("mass_g = volume_ml * 1.036" if quantity == "volume_ml"
                    else "volume_ml = mass_g / 1.036"),
        conversion_note=("Reported volume retained; mass estimated using AnimalTraits density."
                         if quantity == "volume_ml" else
                         "Reported mass retained; volume is a density-equivalent estimate, not a recovered original volume."),
        source_evidence=evidence, sample_size=n or "", sample_size_basis=n_basis,
        weight=n or 1.0, included=False, exclusion_reason="", final_weight=0.0,
    )


def mass_sample_sizes(rows):
    """Only explicit, documented brain-specific n columns; no header guessing.

    Match accepted species + exact original numeric cell. Ambiguous source rows
    with different n are left unknown, rather than assigned by row order.
    """
    result = {}
    for source, (ncol, paper, scol, gcol) in N_SPECS.items():
        raw = read(Path("__Public/comparative-data") / source, "\t")
        # Burger uses Genus + epithet; DeCasien's populated identity is KEY.
        names = [(r[gcol] + " " + r[scol]) if gcol and " " not in r[scol].strip()
                 else r[scol] for r in raw]
        resolved = resolve_species(names, source_publication=paper)
        for col in {r["column"] for r in rows if r["Source"] == source}:
            groups = defaultdict(set)
            for r, sp in zip(raw, resolved.accepted_name):
                groups[(sp, number(r[col]))].add(number(r[ncol]))
            for (sp, value), ns in groups.items():
                if value and len(ns) == 1 and None not in ns:
                    result[(source, sp, col, value)] = (ns.pop(), f"source column {ncol}")
    return result


def harvest():
    records = []
    manifest = read("__ShinyApp/data/source_manifest.csv")
    by_file = {r["file"]: r for r in manifest}
    by_item = {r["item_name"]: r for r in manifest}
    path = "__merging_brain_mass/brain_mass_unfiltered.csv"
    mass_rows = read(path)
    ns = mass_sample_sizes(mass_rows)
    # Repair only an exact, unique source-row match for the known PHYLACINE
    # placeholder. No identity is inferred from numeric equality across papers.
    soria = read("__Public/comparative-data/" + SORIA, "\t")
    soria_missing = defaultdict(list)
    for r in soria:
        if r["phylacine_binomial"] == "Not recognised" and number(r["adult_brain_mass_g"]):
            soria_missing[number(r["adult_brain_mass_g"])].append(r["species"])
    for i, r in enumerate(mass_rows, 2):
        if r["measure_emitted"] not in MASS_MEASURES or r["pool_eligible"].lower() != "true":
            continue
        value = number(r["Value_g"])
        if value is None:
            continue
        if r["Source"] == SORIA and r["Species"] == "Not recognised":
            names = soria_missing[value]
            if len(names) == 1:
                r = dict(r)
                r["species_printed"] = names[0]
                r["Species"] = resolve_species(names, source_publication="Soria_etal_2021").accepted_name.iloc[0]
                r["basis_resolution_evidence"] += (
                    " Source-field repair: legacy Species='Not recognised' came from phylacine_binomial; "
                    "unique matching source row supplies species='" + names[0] + "'.")
        n, nb = ns.get((r["Source"], r["Species"], r["column"], number(r["raw_value"])),
                       (None, "sample size unavailable"))
        records.append(candidate(path, i, r, value, "mass_g", r["basis"],
                                 r["Source"], r["Team"], r["role"], r["Year"], n, nb,
                                 r["basis_resolution_evidence"]))

    # The volume merge's selected contributor set preserves its source/veto and
    # latest-Stephan-table decisions. Do not reintroduce the unselected rows.
    selected = {(r["Species"], s) for r in read("__merging_volumes/volumes_long.csv")
                if r["Variable"] == NET_VOLUME for s in r["Sources"].split("; ")}
    path = "__merging_volumes/volumes_unfiltered.csv"
    for i, r in enumerate(read(path), 2):
        if r["Variable"] != NET_VOLUME or (r["Species"], r["Source"]) not in selected:
            continue
        value = number(r["Value"])
        if value is None:
            continue
        meta = by_item.get(r["Source"], {})
        records.append(candidate(path, i, r, value / 1000, "volume_ml", "brain tissue volume",
                                 meta.get("file", r["Source"]), r["Team"],
                                 meta.get("role", "unknown"), r["Year"],
                                 evidence="Selected whole-brain net volume from the volumes merge; preparation state retained upstream."))

    # Apply the ECV builder's explicit upstream-team reprint flags. Combine sex
    # scopes, like AnimalTraits, but retain scope in the measurement basis.
    path = "__merging_endocranial_volume/endocranial_volume_unfiltered.csv"
    for i, r in enumerate(read(path), 2):
        value = number(r["Value"])
        if value is None:
            continue
        if r["Units"] != "mL":
            raise ValueError(f"Unexpected ECV unit: {r['Units']}")
        rec = candidate(path, i, r, value, "volume_ml",
                                 f"endocranial proxy; sex scope: {r['sex_scope']}",
                                 r["Source"], r["Team"], r["role"], r["Year"],
                                 evidence=r["source_of_value"])
        if r["upstream_team"]:
            rec["exclusion_reason"] = "ECV merge reprint exclusion: " + r["upstream_team"]
        records.append(rec)

    # AnimalTraits retains original observations and their sample sizes. Read a
    # single representation per observation, never both its volume and mass.
    at_file = by_item["Herberstein_etal_2022_Observations"]["file"]
    path = "__Public/comparative-data/" + at_file
    raw = [r for r in read(path, "\t") if number(r["brain size"])]
    resolved = resolve_species([r["species"] for r in raw], source_publication="Herberstein_etal_2022")
    for r, sp in zip(raw, resolved.accepted_name):
        row = dict(Species=sp, species_printed=r["species"])
        volume = number(r["Brain_Volume_original.mm3"])
        value, quantity = (volume / 1000, "volume_ml") if volume else (float(r["brain size"]) * 1000, "mass_g")
        rec = candidate(path, int(r["Source_row"]), row, value, quantity,
                        r["brain size - method"] or "reported mass; method unspecified",
                        at_file, "AnimalTraits: " + r["inTextReference"], "secondary", r["publicationYear"],
                        number(r["sampleSizeValue"]), "AnimalTraits sampleSizeValue",
                        r["fullReference"] + " | " + r["brain size - comments"])
        # Exact DOI linkage prevents a relay becoming an extra independent team.
        refs = r["fullReference"].lower()
        matches = {m["team"] or m["publication"] for m in manifest
                   if m["id_type"] == "DOI" and m["identifier"] and m["identifier"].lower() in refs}
        if len(matches) == 1:
            rec["Team"] = matches.pop()
        records.append(rec)
    return records


def pool(records):
    """Convert -> collapse collections -> arithmetic species mean.

    One source/representation per collection prevents mass, volume and relays of
    the same collection acquiring repeated weight. This is conservative source
    selection, not a claim that collection members are identical specimens.
    """
    by_species = defaultdict(list)
    for r in records:
        if r["exclusion_reason"]:
            continue
        if re.search(r"\b(?:sp|spp)\.?\b| and | / ", r["Species"]):
            r["exclusion_reason"] = "Unspecified or pooled taxon; retained in audit, not species plots"
        else:
            by_species[r["Species"]].append(r)
    output = []
    for sp, reports in sorted(by_species.items()):
        teams = defaultdict(list)
        for r in reports:
            teams[r["Team"]].append(r)
        chosen = []
        for team, rr in sorted(teams.items()):
            groups = defaultdict(list)
            for r in rr:
                groups[(r["Source"], r["input_file"], r["original_quantity"])].append(r)
            # Choose the best documented representation of this collection.
            # Primary wins, then known sample sizes, then native mass and recency.
            def rank(group):
                return (any(r["role"] == "primary" for r in group),
                        all(bool(r["sample_size"]) for r in group),
                        group[0]["original_quantity"] == "mass_g",
                        max(number(r["Year"]) or 0 for r in group),
                        len(group), group[0]["Source"])
            use = max(groups.values(), key=rank)
            for r in rr:
                if r not in use:
                    r["exclusion_reason"] = "Alternate report/representation of same source team; retained in audit"
            chosen.extend(use)
        # Same project safeguard as sibling merges: secondary-only sources fill
        # species gaps, rather than inflate a species' primary observations.
        if any(r["role"] == "primary" for r in chosen):
            for r in chosen:
                if r["role"] != "primary":
                    r["exclusion_reason"] = "Secondary fallback; primary source available for species"
            chosen = [r for r in chosen if r["role"] == "primary"]
        total = sum(r["weight"] for r in chosen)
        for r in chosen:
            r["included"] = True
            r["final_weight"] = r["weight"] / total
        mass = sum(r["mass_g"] * r["final_weight"] for r in chosen)
        volume = sum(r["volume_ml"] * r["final_weight"] for r in chosen)
        unknown = sum(not bool(r["sample_size"]) for r in chosen)
        common = dict(Species=sp, n_sources=len(chosen),
                      n_teams=len({r["Team"] for r in chosen}),
                      Teams=join(r["Team"] for r in chosen),
                      items=join(r["Source"] for r in chosen),
                      roles=join(r["role"] for r in chosen),
                      measurement_method=join(r["measurement_basis"] for r in chosen),
                      reports_with_unknown_n=unknown,
                      weighting="sample-size-weighted arithmetic mean; unknown n has weight 1",
                      conversion="M[g] = 1.036 * V[mL]; ECV retained as a proxy, not measured brain tissue",
                      contributor_ids=join(r["report_id"] for r in chosen))
        for label, unit, value, measure_class in [(MASS, "g", mass, "mass"),
                                                  (VOLUME, "mL", volume, "structure_volume")]:
            output.append(dict(common, Measure=label, Units=unit, Value=value, measure_class=measure_class))
    return output


def main():
    records = harvest()
    # Match the app's existing display aliases before pooling so it receives
    # one row per displayed species, with identical contributors in both units.
    aliases = {r["variant"]: r["canonical"] for r in read("_keys/species_display_aliases.csv")}
    blocked = blocked_labels()
    for r in records:
        r["Species_input"] = r["Species"]
        r["Species"] = aliases.get(r["Species"], r["Species"])
        issue = blocked.get(r["Species_input"])
        if issue:
            r["exclusion_reason"] = issue["Status"] + ": " + issue["Next_action"]
    long = pool(records)
    assert len(long) and len({(r["Species"], r["Measure"]) for r in long}) == len(long)
    write(OUT / "brain_size_long.csv", long)
    write(OUT / "brain_size_contributions.csv", records)
    wide = []
    for i in range(0, len(long), 2):
        m, v = long[i:i+2]
        assert m["Species"] == v["Species"] and m["contributor_ids"] == v["contributor_ids"]
        assert math.isclose(m["Value"], v["Value"] * DENSITY, rel_tol=1e-12)
        wide.append(dict(Species=m["Species"], Brain_mass_g=m["Value"], Brain_volume_ml=v["Value"],
                         n_reports=m["n_sources"], reports_with_unknown_n=m["reports_with_unknown_n"]))
    write(OUT / "brain_size_wide.csv", wide)
    # Input hashes make stale upstream products visible without modifying them.
    paths = sorted({r["input_file"] for r in records} | {
        "__merging_volumes/volumes_long.csv", "__ShinyApp/data/source_manifest.csv",
        "_keys/species_display_aliases.csv", "_keys/species_reference.csv",
        "_keys/species_grade_key.csv", "_keys/resolve_species.py",
        "_keys/navigation_taxonomy_review.csv", "__Public/comparative-data/" + SORIA,
    } | {"__Public/comparative-data/" + f for f in N_SPECS}
      | {str(p.relative_to(ROOT)) for p in (ROOT / "_keys").glob("*/species_key.csv")})
    write(OUT / "brain_size_inputs.csv", [dict(path=p, sha256=hashlib.sha256((ROOT / p).read_bytes()).hexdigest()) for p in paths])
    print(f"Paired brain-size traits: {len(wide)} taxa; {len(records)} candidate reports; "
          f"{sum(r['included'] for r in records)} contributing reports")


if __name__ == "__main__":
    main()
