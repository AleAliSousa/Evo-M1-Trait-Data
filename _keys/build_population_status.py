#!/usr/bin/env python3
"""build_population_status.py -- seed and refresh _keys/population_status.csv.

The key answers one question per (source token, accepted species label): was the
animal measured a WILD population, a DOMESTIC one, a MIXED compilation, or UNKNOWN?
It is read-time only -- no merge consults it. The Cytosplore builder and the Shiny
app's Cohort coverage tab use it for the `domestic_evidence` pooling mode
(see _keys/README_population_status.md and _keys/README_species_pooling.md).

What this script does
  1. Reads the pooling groups in _keys/species_pooling.csv (axis = domestication) and
     takes every member label (wild and domestic forms) as a label of interest.
  2. Scans every __merging_*/*_long.csv and __ShinyApp/data/evom1_traits_long.csv for
     rows whose Species (or accepted_name) is one of those labels, and splits each
     row's provenance column into source tokens exactly as the app will see them
     (the same column the app carries as `Teams`; see PROV_COL).
  3. Writes one row per (source_table token, accepted_name). The population and its
     evidence come from DECISIONS below (hand-curated, with the evidence quoted from
     the source rows) or from the generic rule that a label which IS the domestic
     form is domestic. Anything else is `unknown`.
  4. Re-running preserves rows whose decided_by does not start with "auto" -- hand
     edits in the CSV survive; new tokens are appended as unknown.

Usage (from the repo root):  python3 _keys/build_population_status.py
"""
import csv, glob, io, os, sys, collections

csv.field_size_limit(10 ** 8)
KEYS = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(KEYS)
OUT = os.path.join(KEYS, "population_status.csv")
TODAY = "2026-10-20"
SESSION = "Claude Code session 2026-10-20, from source-row evidence (pending owner sign-off)"
AUTO = "auto-seeded 2026-10-20 (no decision)"
COLS = ["source_table", "printed_name", "accepted_name", "population", "evidence",
        "decided_by", "decided_date", "note", "merges_observed", "n_rows_observed"]
POPS = {"wild", "domestic", "mixed", "unknown"}

# provenance column per long file = the token vocabulary the app carries as `Teams`
# (app.R load_compiled(); keep the two in step)
PROV_COL = {
    "volumes_long.csv": "Teams", "cellcounts_long.csv": "Source", "evom1_traits_long.csv": "Source",
    "body_ecology_long.csv": "Teams", "brain_mass_long.csv": "Teams",
    "endocranial_volume_long.csv": "Teams", "behaviour_long.csv": "Teams",
    "behaviour_observations_long.csv": "Team", "cerebellar_folding_long.csv": "Teams",
    "cerebral_metabolic_rate_long.csv": "Compilations", "GLI_long.csv": "source",
    "GLI_species_area_stratum_comparison_qa_long.csv": "source",
    "cortical_areas_long.csv": "source", "cortical_layers_all_regions_long.csv": "source",
    "cortical_layers_m1_long.csv": "source", "cortical_layers_m1_species_long.csv": "source",
    "cell_morphology_long.csv": "source", "fossil_brain_glucose_long.csv": "Source",
    "gyrification_long.csv": "source", "sensory_long.csv": "Sources", "sleep_long.csv": "source",
    "supplementary_long.csv": "Teams", "weights_long.csv": "source",
}
PRINTED_COL = ["species_printed", "Species_printed", "species_as_published", "Species_as_printed"]


def tokens(s):
    return [t.strip() for t in str(s or "").split(";") if t.strip()]


# ---- the decisions -------------------------------------------------------------------
# (source token, accepted label) -> population, evidence, optional printed override, note.
# Evidence is what the SOURCE ROW shows; inferences say so.
D = {}
def dec(token, acc, pop, evidence, printed=None, note=""):
    for t in ([token] if isinstance(token, str) else token):
        D[(t, acc)] = dict(population=pop, evidence=evidence, printed=printed, note=note)

SUS, SSD, MUS, MPF = "Sus scrofa", "Sus scrofa domesticus", "Mustela putorius", "Mustela putorius furo"

# -- compilations (per their documentation; one status per source, so life-history
#    compilations that admit captive records are 'mixed' even where ecology fields are wild)
PANTHERIA = ("PanTHERIA (Jones et al. 2009) compiles wild-population ecology by design, but its "
             "life-history fields (longevity, sexual maturity, litter traits, neonate and weaning mass) "
             "admit captive records where no wild value exists, and the entry is not annotated per "
             "field. Ecology fields: wild; life history: mixed. One status per source, so mixed.")
AMNIOTE = ("Amniote life-history database (Myhrvold et al. 2015): values are means over AnAge, "
           "PanTHERIA and Ricklefs 2010 (its references file), which mix captive/domestic and wild "
           "records; its own common name for the entry is '{cn}'.")
ANAGE = ("AnAge (de Magalhães et al. 2024): the '{cn}' entry draws longevity and reproductive values "
         "from captive and domestic as well as wild sources, not separable per field.")
dec("Jones_etal_2009", SUS, "mixed", PANTHERIA, printed="Sus scrofa")
dec("Jones_etal_2009", MUS, "mixed", PANTHERIA, printed="Mustela putorius")
dec("Myhrvold_etal_2015", SUS, "mixed", AMNIOTE.format(cn="Wild Boar"), printed="Sus scrofa (Wild Boar)")
dec("Myhrvold_etal_2015", MUS, "mixed", AMNIOTE.format(cn="European Polecat"), printed="Mustela putorius (European Polecat)")
dec("deMagalhães_etal_2024", SUS, "mixed", ANAGE.format(cn="Sus scrofa (wild boar)"), printed="Sus scrofa")
dec("deMagalhães_etal_2024", MUS, "mixed", ANAGE.format(cn="Mustela putorius (European polecat)"), printed="Mustela putorius")
dec("Wilman", SUS, "wild", "EltonTraits (Wilman et al. 2014) describes the foraging ecology and body mass of wild populations by design.", printed="Sus scrofa")
dec("Wilman", MUS, "wild", "EltonTraits (Wilman et al. 2014) describes the foraging ecology and body mass of wild populations by design.", printed="Mustela putorius")
dec("Boddy", SUS, "mixed", "Boddy et al. 2012 brain-body database: Sus scrofa 169.8 g brain / 86,772.7 g body cited to Warncke 1908 and Silva & Downing 1995; no population stated.", printed="Sus scrofa")
dec("Burger", SUS, "mixed", "Burger et al. 2019 re-use Boddy 2012's Sus scrofa entry (Warncke 1908; Silva & Downing 1995); no population stated.", printed="Sus scrofa")
dec("Boddy", MUS, "wild", "Boddy et al. 2012 brainbodydatabasev2 prints the source names 'Putorius putorius' (Count 1947, 915 g / 7.87 g) and 'Putorius putor' (Warncke 1908) -- the European polecat; the ferret would be Putorius furo.", printed="Putorius putorius; Putorius putor")
dec("Burger", MUS, "wild", "Burger et al. 2019 re-use Boddy 2012's polecat entry (Count 1947, printed 'Putorius putorius' in Boddy's database).", printed="Mustela putorius")
dec("Lewitus et al. 2014 (glia, gyrification & life history)", SUS, "domestic",
    "The app's trait-table melt of Lewitus et al. 2014 Table S1 files the row printed 'Sus_scrofa_domesticus' under 'Sus scrofa' (Body_weight 133,600 g, Brain_weight 137.65 g, Neonate brain 28.3 g, Gestation 116.645 d -- identical to the domesticus row of the source); the species column of that melt predates the trinomial anchor.", printed="Sus scrofa (melt of 'Sus_scrofa_domesticus')", note="label error in ____EvoM1_TraitTable/glia_gyrification.xlsx rather than a population question; the merge-side copy (gyrification, body_ecology) is already under Sus scrofa domesticus")
dec("Lewitus", SUS, "domestic", "Lewitus et al. 2013 Table A1 prints 'Sus scrofa' with brain weight 137.65 g -- the value the same authors file under 'Sus scrofa domesticus' (137.65 g, body 133,600 g) in Lewitus et al. 2014 Table S1.", printed="Sus scrofa")
dec(["Lewitus", "Lewitus_etal_2014_TableS1"], MUS, "mixed", "Lewitus et al. 2013/2014 compile 'Mustela putorius' (809 g, 8.25 g, GI 1.75, life history) from the literature without a population statement.", printed="Mustela putorius")

# -- primaries printing a domestic animal under the wild binomial
dec("Genoud", SUS, "domestic", "Genoud et al. 2018 Table S2 sets Domestic = 1 on all four Sus scrofa BMR rows (Species_Genoud2018 'pig', 'sow & boar', 'swine'; Capstick & Wood 1922, Smuts 1935, Benedict 1938, Irving et al. 1956).", printed="Sus scrofa (pig; sow & boar; swine)")
dec("Genoud", MUS, "wild", "Genoud et al. 2018 Table S2 sets Domestic = 0 on the Mustela putorius row (Korhonen et al. 1983; 1,575 g, BMR 1,268 mL O2/h).", printed="Mustela putorius")
dec(["Heffner", "Heffner & Masterton 1975 (corticospinal tract)", "LASSEK, 1942", "VERHAART, 1970"], SUS, "domestic",
    "Heffner & Masterton 1975 Table I prints the animal as 'Hog (domestic)' (body weight 90 kg; fibre count Lassek 1942, fibre diameter Verhaart 1970 on the same row).", printed="Hog (domestic) / Sus scrofa")
dec(["Heffner", "Heffner & Masterton 1975 (corticospinal tract)", "NOORDUYN, 1959"], MPF, "domestic",
    "Heffner & Masterton 1975 Table I prints 'Ferret' / 'Putorius furo' (body weight 0.9 kg; fibre data Noorduyn 1959).", printed="Ferret / Putorius furo")
dec("Haarlem", SUS, "domestic", "Haarlem et al. 2026 CFF dataset prints the population as 'Landrace-Large white cross piglets' (Lansing et al. 2018).", printed="Sus scrofa (Landrace-Large white cross piglets)")
dec("Haarlem_etal_2026_CFFdataset", SUS, "domestic", "Haarlem et al. 2026 CFF dataset prints the population as 'Landrace-Large white cross piglets' (Lansing et al. 2018).", printed="Sus scrofa (Landrace-Large white cross piglets)")
# body_ecology_long.csv was written under a C locale, so its Teams token is the literal escaped
# string "MedinaGonz<c3><a1>lez"; register that spelling as well as the proper one.
MEDINA = ["MedinaGonzález", "MedinaGonz<c3><a1>lez", "Medina"]
dec(MEDINA, SUS, "domestic",
    "The one Medina-González 2026 record still printed 'Sus scrofa' (Record_ID 154, a video source) carries the Supplementary File 2 justification 'Domestic pigs are ground-based generalists ...'. The other five pig records print 'Sus scrofa domestica' and resolve to Sus scrofa domesticus since 2026-10-20.", printed="Sus scrofa")
dec(MEDINA, SSD, "domestic", "Medina-González 2026 prints 'Sus scrofa domestica' (five records; justification 'Domestic pigs ...').", printed="Sus scrofa domestica")
dec(["Veilleux", "Veilleux_Kirk_2014_SupplementalTable1"], SUS, "domestic",
    "Veilleux & Kirk 2014: the pig acuity is 'this study', computed from published pig retinal ganglion-cell data (their refs 16, 17); laboratory pig retinal material is domestic stock. Inference, recorded in _keys/taxon_clarity.csv (2026-09-30, medium confidence). Body mass from their refs 2, 9.", printed="Sus scrofa", note="inferred from study type, not stated by the source")
dec("Weibel", SUS, "domestic", "Weibel et al. 2004 Table A.1: 'Pigs', VO2max measured on a treadmill (Seeherman et al. 1981); the item's note column records strain/sex in the printed common name -- farmed domestic pigs.", printed="Sus scrofa (Pigs)")
dec("Wimberly", SUS, "unknown", "Wimberly et al. 2021 gait data: the recording source is not stated in the harvested table and the body mass is the PanTHERIA value (84,471.54 g).", printed="Sus scrofa")
dec(["HerculanoHouzel", "HerculanoHouzel__2015_Table1", "Herculano-Houzel 2015 (daily sleep)"], SUS, "domestic",
    "Herculano-Houzel 2015 (sleep) Table 1 prints 'Sus scrofa' with brain mass 64.18 g, identical to Kazu et al. 2015's domestic pig (Sus scrofa domesticus, brain mass excluding olfactory bulbs 64.18 g) from the same laboratory.", printed="Sus scrofa")
dec(["Brodmann", "Brodmann__1913_Table1"], SUS, "domestic", "Brodmann 1913 Table 1 prints 'Schwein (Sus)'; in German, Schwein is the domestic pig (the wild boar is Wildschwein). Brain weight 112 g.", printed="Schwein (Sus)")
dec(["Brodmann", "Brodmann__1913_Table1"], MUS, "wild", "Brodmann 1913 Table 1 prints 'Iltis (Putorius)', the German name of the wild European polecat (the ferret is Frettchen). Brain weight 10.7 g.", printed="Iltis (Putorius)")
dec("Kaufman__2004", SUS, "domestic",
    "Kaufman 2004 compiles anaesthetised laboratory swine studies under the genus label 'Sus' (Manohar 1986, microspheres under sevoflurane; Poulsen et al. 1997, PET under ketamine/midazolam); experimental swine are domestic stock. Inferred from study type, not stated.", printed="Sus", note="inferred from study type, not stated by the source")
dec("Heffner_Heffner_1992_a_TABLE1", SUS, "domestic", "Heffner & Heffner 1992a Table 1 common name 'pig' (code P); laboratory psychophysics and retinal anatomy on domestic pigs (R. Heffner & Heffner 1989, 1990a). See _keys/taxon_clarity.csv.", printed="Sus scrofa (pig)")
dec("Heffner_Heffner_1992_a_TABLE1", MUS, "domestic", "Heffner & Heffner 1992a Table 1 common name 'ferret' (code F); localization threshold from Kavanagh & Kelly 1987, a laboratory ferret study.", printed="Mustela putorius (ferret)")
dec("Koay_etal_1998_Figure6", SUS, "domestic", "Koay et al. 1998 Figure 6 common name 'pig' (R. S. Heffner & Heffner 1990a, behavioural audiogram of domestic pigs).", printed="Sus scrofa (pig)")
dec("Koay_etal_1998_Figure6", MUS, "domestic", "Koay et al. 1998 Figure 6 common name 'ferret' (Kelly, Kavanagh & Dalton 1986 ferret audiogram).", printed="Mustela putorius (ferret)")
dec("Zilles_etal_2013_Table1", MUS, "domestic", "Zilles et al. 2013 Table 1 common name 'Ferret' for Mustela putorius (GI 1.63, ref [7]).", printed="Mustela putorius (Ferret)")
dec("Zilles_etal_2013_Table1", SSD, "domestic", "Zilles et al. 2013 Table 1 prints 'Sus scrofa domestica', common name 'Domestic pig'.", printed="Sus scrofa domestica (Domestic pig)")
dec("Smaers_etal_2018", SUS, "unknown", "Smaers et al. 2018 cerebellar volumes from Maseko et al. 2012; specimen origin not stated in the harvested table.", printed="Sus scrofa")
dec("Smaers_etal_2018", MUS, "unknown", "Smaers et al. 2018 cerebellar volumes from Maseko et al. 2012; specimen origin not stated in the harvested table.", printed="Mustela putorius")
dec("deSousa_etal_2022", SUS, "domestic", "de Sousa et al. 2022 review dataset: Sus scrofa visual acuity 9.92 c/deg (anatomical, peak ganglion-cell density) is Veilleux & Kirk 2014's 'this study' pig value, i.e. the same domestic-pig retinal material (inference as for Veilleux).", printed="Sus scrofa", note="secondary compilation; inherits the Veilleux & Kirk inference")
dec("deSousa_etal_2022", MUS, "domestic", "de Sousa et al. 2022 review dataset: Mustela putorius visual acuity 3.57 c/deg is Veilleux & Kirk 2014's ferret value (Pontenagel & Schmidt 1980, a ferret retina study), which the sensory merge now files under Mustela putorius furo.", printed="Mustela putorius", note="secondary compilation")
dec("Winkler_Bryant_2021", MUS, "wild", "Winkler & Bryant 2021 list 'European polecat' (Poole 1966) and, as a separate row, 'Ferret/Domesticated polecat' under Mustela putorius furo, so the binomial row is the wild form by the source's own distinction.", printed="European polecat")
dec("Ashwell", MUS, "wild", "Ashwell 2020 supplementary table prints 'European polecat' (total brain 4,987 mm3); the same table prints the pig as 'Sus scrofa domesticus / Domestic pig', so the author distinguishes forms.", printed="Mustela putorius (European polecat)")
dec("Ashwell", SSD, "domestic", "Ashwell 2020 supplementary table prints 'Sus scrofa domesticus', common name 'Domestic pig'.", printed="Sus scrofa domesticus (Domestic pig)")
dec("Bush", MUS, "domestic", "Bush & Allman 2003 Table 1 prints 'Mustela putorius' for the specimen that Bush & Allman 2004a Table 2 prints as 'Mustela putorius furo', with the identical neocortex grey-matter volume 2,140 mm3 (_keys/taxon_clarity.csv, row Bush_Allman_2003).", printed="Mustela putorius")
dec(["Jacobs", "Jacobs_etal_2018_Table3"], MUS, "unknown", "Jacobs et al. 2018 Table 3 prints 'European polecat' (brain 8.3 g, body 1,100 g). The 8.3 g brain is ferret-sized and the specimen origin is not stated, so the row does not settle wild vs domestic.", printed="European polecat")
dec(["Falcone_etal_2019_TABLE1", "Falcone_etal_2019_TABLE2"], MUS, "unknown", "Falcone et al. 2019 interlaminar-astrocyte survey prints 'Mustela putorius'; the specimen source is not in the harvested tables.", printed="Mustela putorius")
dec("Raghanti_etal_2015_Table1", SSD, "domestic", "Raghanti et al. 2015 Table 1 prints 'Pig'.", printed="Pig")
dec("Heuer2023", SSD, "domestic", "Heuer et al. 2023 prints 'Sus scrofa domesticus' / 'Pig' (Brainmuseum specimen).", printed="Sus scrofa domesticus (Pig)")


def main():
    # 1. labels of interest from the pooling key
    pool_path = os.path.join(KEYS, "species_pooling.csv")
    with open(pool_path, encoding="utf-8", newline="") as fh:
        pools = [r for r in csv.DictReader(fh) if r["axis"].strip() == "domestication"]
    labels = {r["member"].strip() for r in pools}
    domestic_labels = {r["member"].strip() for r in pools if r["relation"].strip() == "domestic_form"}
    if not labels:
        sys.exit("no domestication pools in _keys/species_pooling.csv")

    # 2. scan the long files
    files = sorted(glob.glob(os.path.join(REPO, "__merging_*", "*_long.csv")))
    files.append(os.path.join(REPO, "__ShinyApp", "data", "evom1_traits_long.csv"))
    obs = collections.defaultdict(lambda: {"printed": set(), "merges": set(), "n": 0})
    for f in files:
        if not os.path.exists(f):
            continue
        fname = os.path.basename(f)
        merge = os.path.basename(os.path.dirname(f)).replace("__merging_", "")
        if fname == "evom1_traits_long.csv":
            merge = "ShinyApp/evom1_traits"
        with open(f, encoding="utf-8", newline="") as fh:
            rd = csv.DictReader(fh)
            cols = rd.fieldnames or []
            prov = PRov = PROV_COL.get(fname) or next((c for c in ("Teams", "Sources", "source", "Source", "Compilations", "Team", "items") if c in cols), None)
            if prov not in cols:
                print(f"  skip {merge}/{fname}: provenance column {prov!r} not present", file=sys.stderr)
                continue
            pcol = next((c for c in PRINTED_COL if c in cols), None)
            for r in rd:
                sp = (r.get("Species") or "").strip()
                acc = (r.get("accepted_name") or "").strip() or sp
                lab = sp if sp in labels else (acc if acc in labels else None)
                if lab is None:
                    continue
                printed = tokens(r.get(pcol)) if pcol else []
                for t in tokens(r.get(prov)):
                    o = obs[(t, lab)]
                    o["printed"].update(printed or [sp]); o["merges"].add(merge); o["n"] += 1

    # 3. existing hand edits survive
    existing = {}
    if os.path.exists(OUT):
        with open(OUT, encoding="utf-8", newline="") as fh:
            for r in csv.DictReader(fh):
                existing[(r["source_table"], r["accepted_name"])] = r

    rows = []
    n_dec = n_auto = n_kept = 0
    for (t, lab), o in sorted(obs.items(), key=lambda kv: (kv[0][1], kv[0][0].lower())):
        merges = "; ".join(sorted(o["merges"]))
        prev = existing.get((t, lab))
        if prev and not prev["decided_by"].startswith("auto"):
            row = dict(prev); row["merges_observed"] = merges; row["n_rows_observed"] = o["n"]
            rows.append(row); n_kept += 1; continue
        d = D.get((t, lab))
        printed_obs = "; ".join(sorted(o["printed"])) or lab
        if d:
            row = dict(source_table=t, printed_name=d["printed"] or printed_obs, accepted_name=lab,
                       population=d["population"], evidence=d["evidence"], decided_by=SESSION,
                       decided_date=TODAY, note=d["note"]); n_dec += 1
        elif lab in domestic_labels:
            row = dict(source_table=t, printed_name=printed_obs, accepted_name=lab, population="domestic",
                       evidence=f"The source prints the domestic form itself ({printed_obs}); the label is the domestic anchor.",
                       decided_by=SESSION, decided_date=TODAY, note="generic rule: printed domestic form"); n_dec += 1
        else:
            row = dict(source_table=t, printed_name=printed_obs, accepted_name=lab, population="unknown",
                       evidence="", decided_by=AUTO, decided_date=TODAY,
                       note="no population statement found in the source row; review"); n_auto += 1
        row["merges_observed"] = merges; row["n_rows_observed"] = o["n"]
        assert row["population"] in POPS, row
        rows.append(row)

    with open(OUT, "w", encoding="utf-8", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=COLS, lineterminator="\n"); w.writeheader(); w.writerows(rows)
    by = collections.Counter((r["accepted_name"], r["population"]) for r in rows)
    print(f"wrote {OUT}: {len(rows)} rows ({n_dec} decided here, {n_kept} kept from the file, {n_auto} unknown)")
    for lab in sorted(labels):
        print(f"  {lab:24} " + "  ".join(f"{p}={by[(lab, p)]}" for p in ("wild", "domestic", "mixed", "unknown")))
    unused = [k for k in D if k not in obs and k[0] not in ("MedinaGonzález", "MedinaGonz<c3><a1>lez")]
    if unused:
        print("  decisions with no matching rows (token or label not observed):", file=sys.stderr)
        for k in unused: print("   ", k, file=sys.stderr)


if __name__ == "__main__":
    main()
