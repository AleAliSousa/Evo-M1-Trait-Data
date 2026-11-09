#!/usr/bin/env python3
"""
classify_unclassified_labels.py -- give every app variable that has no row in
_keys/variable_domain.csv a domain, a measure class and (where the quantity recurs)
a poolable_family / poolable_group, by RULE, so a rebuilt merge is re-classified the
same way rather than needing hand-typed rows.

    Rscript __ShinyApp/list_unclassified.R unclassified.csv     # what the app reports
    python3 _keys/classify_unclassified_labels.py unclassified.csv
    Rscript _keys/build_variable_definitions.R
    Rscript __ShinyApp/build_data.R

Conventions (see __ShinyApp/AUDIT_app_variable_organization.md):
  * a NUMBER (.N, count, mean count/subject) is not a trait, it is a feature of one:
    the class names what is counted (sociality, mirror_behaviour_counts), never "number".
  * poolable_family  = the quantity (candidate estimates of the same thing);
    poolable_group   = the quantity as measured (method / denominator / source).
    The Plot tab warns when family matches and group differs.
  * labels that differ ONLY by individual, test condition, month or hemisphere are one
    trait: they share family AND group (no warning among them).
  * a label with an unmatched pattern is an ERROR, not a default.
Idempotent: only labels absent from variable_domain.csv are appended; the few
EXISTING rows named in EXISTING_UPDATES get family/group filled in iff blank.
"""
import csv, re, sys, io, os

HERE = os.path.dirname(os.path.abspath(__file__))
VD = os.path.join(HERE, "variable_domain.csv")
SRC = "_keys/classify_unclassified_labels.py"
MONTHS = "Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec"

def split_unit(label):
    m = re.match(r"^(.*) \(([^()]*)\)$", label)
    if m: return m.group(1), m.group(2)
    m = re.match(r"^(.*)\.([^.]+)$", label)
    return (label, m.group(2)) if m else (label, "")

def R(domain, cls, family="", group="", structure="", measure=None, unit=None, note="", label=None):
    return dict(domain=domain, cls=cls, family=family, group=group, structure=structure,
                measure=measure, unit=unit, note=note)

BEH, SENS, METAB, BRAIN, LIFE = ("behaviour & cognition", "sensory performance", "metabolism",
                                 "brain structure & size", "life history")

def classify(label, dataset, vd_by_label):
    base, unit = split_unit(label)
    # ---- brain-structure volumes ---------------------------------------------------
    m = re.match(r"^(.+)_Vol\.mm3$", label)
    if m and dataset == "Brain-structure volumes":
        st = m.group(1)
        return R(BRAIN, "structure_volume", structure=st, measure="Vol.mm3", unit="mm3",
                 note="Structure volume; sub-region label as printed by the source.")
    # ---- cerebral metabolic rate / perfusion --------------------------------------
    m = re.match(r"^(.+)_(CBF|CMRO2|CMRgl) \((.+)\)$", label)
    if m and dataset == "Cerebral metabolic rate":
        sib = next((r for l, r in vd_by_label.items()
                    if l.endswith("_" + m.group(2) + " (" + m.group(3) + ")")
                    and r["dataset"] == dataset), None)
        if sib is None: raise SystemExit("no sibling row to template %s" % label)
        return R(METAB, sib["measure_class"], structure=m.group(1), measure=sib["Measure"],
                 unit=sib["Unit"], note=sib["note"])
    # ---- cortical surface areas ----------------------------------------------------
    m = re.match(r"^(.+)_Surface_Area\.(mm2|pct_Neocortex|pct_VisualCortex)$", label)
    if m and dataset == "Cortical areas & surfaces":
        reg, kind = m.groups()
        g = {"mm2": "absolute_mm2", "pct_Neocortex": "pct_neocortex",
             "pct_VisualCortex": "pct_visual_cortex"}[kind]
        return R(BRAIN, "cortical_surface", family=reg + "_surface", group=reg + "_surface__" + g,
                 measure=label, unit="mm2" if kind == "mm2" else "pct",
                 note="Regional cortical surface; absolute (mm2) and relative (% of a stated denominator) "
                      "are separate methods of the same quantity. See __merging_cortical_areas/README__merging.md.")
    if label == "CorticalBuriedSurface_Area.mm2":
        return R(BRAIN, "cortical_surface", "cortical_surface_in_fissures",
                 "cortical_surface_in_fissures__absolute_mm2", measure=label, unit="mm2",
                 note="Cortical surface within fissures (subset of total sheet).")
    if label == "CorticalSurfaceInFissures.pct":
        return R(BRAIN, "cortical_surface", "cortical_surface_in_fissures",
                 "cortical_surface_in_fissures__pct_total_surface", measure=label, unit="pct",
                 note="Cortical surface within fissures as % of total surface.")
    # ---- claustrum & cerebellar anatomy (Smaers) ------------------------------------
    cer = {"Cerebrocerebellum_volume_Smaers2011 (mm3)": ("Cerebrocerebellum", "lateral_cerebellum_volume", "Smaers2011_partition"),
           "Spinocerebellum_volume_Smaers2011 (mm3)": ("Spinocerebellum", "medial_cerebellum_volume", "Smaers2011_partition"),
           "Flocculonodular_lobe_volume_Smaers2011 (mm3)": ("Flocculonodular_lobe", "flocculonodular_lobe_volume", "Smaers2011_partition"),
           "Left_PCH_volume_Smaers2013 (mm3)": ("PCH_left", "PCH_volume", "Smaers2013"),
           "Right_PCH_volume_Smaers2013 (mm3)": ("PCH_right", "PCH_volume", "Smaers2013")}
    if label in cer:
        st, fam, meth = cer[label]
        return R(BRAIN, "structure_volume", fam, fam + "__" + meth, structure=st, unit="mm3",
                 note="Cerebellar partition volume. Same family as the Smaers 2018 compiled "
                      "lateral/medial cerebellum where one exists, but the partition boundaries "
                      "differ (values disagree for shared species), so the group differs.")
    # ---- social composition -------------------------------------------------------
    m = re.match(r"^Adult_(females|males)\.N \(N\)$", label)
    if m:
        fam = "adult_%s_per_group" % m.group(1)
        return R(BEH, "sociality", fam, fam + "__Carnes2011_Lindenfors2007", measure=base, unit="N",
                 note="Number of adult %s in the group (a count of group members, not a sample size)." % m.group(1))
    if label in ("Breeding_season.d (d)", "Estrus_duration.d (d)", "Expected_overlap (proportion)", "Seasonality_r (index)"):
        return R(LIFE, "life_history", note="Reproductive timing (Carnes et al. 2011 Table S1).")
    # ---- play / grooming time budgets ----------------------------------------------
    m = re.match(r"^Groom_time\.pct_(%s)_Bartlett2003_digitized \(percent\)$" % MONTHS, label)
    if m:
        return R(BEH, "sociality", "grooming_time_pct_all_activity",
                 "grooming_time_pct_all_activity__digitized_monthly",
                 note="Monthly graph reading (digitized, +/-0.2 pct points); month is a feature of the trait.")
    m = re.match(r"^Play_time\.pct_(%s)_Bartlett2003_digitized \(percent\)$" % MONTHS, label)
    if m:
        return R(BEH, "play", "play_time_pct_all_activity", "play_time_pct_all_activity__digitized_monthly",
                 note="Monthly graph reading (digitized, +/-0.2 pct points); month is a feature of the trait.")
    if label == "Play_time_all_activity_Kerney2017 (percent)":
        return R(BEH, "play", "play_time_pct_all_activity", "play_time_pct_all_activity__time_budget",
                 note="Play as a percentage of the whole activity budget.")
    if re.match(r"^Play_share_of_social_activity_(adult|immature|juvenile)_Bartlett2003 \(percent\)$", label):
        return R(BEH, "play", "play_share_of_social_activity", "play_share_of_social_activity__Bartlett2003",
                 note="Play as a share of social activity; age class is a feature of the trait.")
    if re.match(r"^(Mother-infant|Social|Solitary)_play_share_of_play_time_infants_Mallavarapu2001 \(percent\)$", label):
        return R(BEH, "play", note="Component of infant play time (denominator = play time); the components "
                                   "are different quantities and are not pooled.")
    # ---- mirror tests ---------------------------------------------------------------
    if label.startswith("Mirror_"):
        fam = None
        m = re.match(r"^(Mirror_mark_result)_.+_(Suarez1981) \(category\)$", label)
        if m: fam = "%s_%s" % (m.group(1), m.group(2)); cls = "mirror_mark_test"
        m = re.match(r"^Mirror_(Pretest|Test)_(brow|wrist)_.+_(Suarez1981) \(count\)$", label)
        if m: fam = "Mirror_%s_%s_%s" % m.groups(); cls = "mirror_mark_test"
        m = re.match(r"^(Mirror_.+)_(Covered|Marked|Uncovered)_(count_Xebo_Posada2007) \(count\)$", label)
        if m: fam = "%s_%s" % (m.group(1), m.group(3)); cls = "mirror_behaviour_counts"
        m = re.match(r"^(Mirror_.+_Chang20(?:15|17))_(?:control|trained) \(mean count/subject\)$", label)
        if m: fam = m.group(1); cls = "mirror_behaviour_counts"
        m = re.match(r"^(Mirror_mark_response_Gallup1970)_(?:experimental|naive_controls) \(category\)$", label)
        if m: fam = m.group(1); cls = "mirror_mark_test"
        if fam:
            return R(BEH, cls, fam, fam, note="Mirror test. Individual, test condition (covered/marked/uncovered; "
                     "control/trained) and the count itself are features of one trait, so they share a family and group.")
        if re.search(r"(pass_fraction|orientation_session_fraction|mark_response|mark_result|self_directed_behaviour|"
                     r"head_touches|mark_touches|sham_touches)", label):
            return R(BEH, "mirror_mark_test", note="Mirror mark-test outcome or touch count; a single study, "
                                                   "protocol-specific, not pooled.")
        return R(BEH, "mirror_behaviour_counts", note="Mirror-directed behaviour count; protocol-specific.")
    # ---- taste -----------------------------------------------------------------------
    if dataset == "Taste performance":
        m = re.match(r"^(Fructose|Glucose|Lactose|Maltose|Sucrose)_(detection|preference)_threshold \(mM\)$", label)
        if m:
            fam = m.group(1).lower() + "_taste_threshold"
            return R(SENS, "taste_psychophysics", fam, fam + "__" + m.group(2),
                     note="Taste threshold; detection and preference are distinct endpoints.")
        m = re.match(r"^(.+)_avoidance_30mM_sucrose_background \(mM\)$", label)
        if m:
            t = m.group(1).lower(); fam = t + "_taste_threshold"
            return R(SENS, "taste_psychophysics", fam, fam + "__avoidance_in_30mM_sucrose",
                     note="Bitter avoidance threshold against a 30 mM sucrose background.")
        if label == "Quinine_HCl_legacy_threshold (mM)":
            return R(SENS, "taste_psychophysics", "quinine_hcl_taste_threshold",
                     "quinine_hcl_taste_threshold__legacy", note="Legacy quinine threshold (protocol differs from the 30 mM sucrose avoidance series).")
        m = re.match(r"^(MSG|NaCl)_Weber_ratio_across_tested_conditions \(ratio\)$", label)
        if m:
            fam = m.group(1).lower() + "_weber_ratio"
            return R(SENS, "taste_psychophysics", fam, fam, note="Weber ratio across tested conditions (reported as a range).")
        m = re.match(r"^Sucrose_at_citric_acid_(\d+)mM_preference_over_50mM_sucrose \(mM\)$", label)
        if m:
            return R(SENS, "taste_psychophysics", "sucrose_preference_in_citric_acid",
                     "sucrose_preference_in_citric_acid", note="Sour-mixture tolerance; citric acid concentration is a feature of the trait.")
        if label == "Tannic_acid_inhibition_threshold (mM)":
            return R(SENS, "taste_psychophysics", note="Tannic acid inhibition threshold.")
    return None

# existing rows whose family/group is filled in (iff blank) so they pair with the new rows
EXISTING_UPDATES = {
    "LateralCerebellum_Vol (mm3)": ("lateral_cerebellum_volume", "lateral_cerebellum_volume__Smaers2018_compilation"),
    "MedialCerebellum_Vol (mm3)": ("medial_cerebellum_volume", "medial_cerebellum_volume__Smaers2018_compilation"),
    "Adult_females_Kamilar2013 (count)": ("adult_females_per_group", "adult_females_per_group__Kamilar2013"),
    "Adult_males_Kamilar2013 (count)": ("adult_males_per_group", "adult_males_per_group__Kamilar2013"),
}
for _r in ("M1", "V1", "V2"):
    EXISTING_UPDATES[_r + "_Surface_Area.mm2"] = (_r + "_surface", _r + "_surface__absolute_mm2")

def main(path):
    raw = open(VD, encoding="utf-8", newline="").read()
    rows = list(csv.reader(io.StringIO(raw)))
    hdr, body = rows[0], rows[1:]
    ix = {c: i for i, c in enumerate(hdr)}
    recs = [dict(zip(hdr, r)) for r in body]
    by_label = {r["label"]: r for r in recs}
    todo = list(csv.DictReader(open(path, encoding="utf-8", newline="")))
    todo = [t for t in todo if t["label"] not in by_label]
    new, bad = [], []
    for t in todo:
        c = classify(t["label"], t["dataset"], by_label)
        if c is None: bad.append(t["label"]); continue
        base, unit = split_unit(t["label"])
        new.append({"label": t["label"], "dataset": t["dataset"], "domain": c["domain"],
                    "measure_class": c["cls"], "Structure": c["structure"], "canonical_structure": c["structure"].replace("_", " "),
                    "Measure": c["measure"] or base, "Unit": c["unit"] if c["unit"] is not None else unit,
                    "structure_qualifier": "", "structure_source": SRC if c["structure"] else "",
                    "is_measurement": "True", "note": c["note"], "poolable_group": c["group"],
                    "poolable_family": c["family"]})
    if bad:
        raise SystemExit("UNMATCHED (%d) -- add a rule, do not default:\n  %s" % (len(bad), "\n  ".join(bad)))
    # fill family/group on named existing rows (blank only), and on pre-existing siblings
    upd = 0
    for l, (fam, grp) in EXISTING_UPDATES.items():
        r = by_label.get(l)
        if r and not r["poolable_family"] and not r["poolable_group"]:
            r["poolable_family"], r["poolable_group"] = fam, grp; upd += 1
    out = io.StringIO()
    w = csv.writer(out, lineterminator="\n")
    w.writerow(hdr)
    for r in recs: w.writerow([r[c] for c in hdr])
    for r in new: w.writerow([r[c] for c in hdr])
    open(VD, "w", encoding="utf-8", newline="").write(out.getvalue())
    print("appended %d rows; filled family/group on %d existing rows" % (len(new), upd))

if __name__ == "__main__":
    main(sys.argv[1])
