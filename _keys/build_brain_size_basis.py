#!/usr/bin/env python3
"""build_brain_size_basis.py -- author _keys/brain_size_basis.csv.

One row per (paper, whole-brain-size column) that exists anywhere in the repo,
recording WHAT PHYSICAL QUANTITY the column is and WHAT IS INCLUDED in it, so
that "which of these may be pooled or plotted against each other" is a lookup
rather than a judgement call. Cranial capacity is not brain weight; a brain
volume may or may not include the meninges; a mass converted from a volume at
1 cm3 = 1 g is not a weighed mass.

THE RULE OBSERVED HERE: an inclusion is recorded as yes/no ONLY where the
source's own definitions file says so. Everything else is `unknown`. Nothing is
inferred from what is conventional in the field, because the whole point of the
key is to separate what the sources state from what a reader assumes.

Fields
  paper, column, unit_as_printed   the harvested identity
  quantity        mass | volume | endocranial_volume | sum_of_structure_volumes
                  | residual | log_mass
  basis           the finer measurement basis (see BASIS_NOTES below)
  state           fresh | fixed | shrinkage_corrected | unknown
  includes_olfactory_bulb / includes_meninges / includes_ventricles_csf
                  yes | no | unknown   (quoted evidence only)
  poolable_group  columns sharing a group may be pooled; across groups they may
                  not, and the app warns
  is_size         FALSE for residuals and logged copies - not a size at all
  role            primary | secondary | info, from _keys/variable_catalog.csv
  definition_quoted / definition_source / basis_evidence
                  quoted = the source states the basis; unstated = it does not

Run: python3 _keys/build_brain_size_basis.py
"""
import csv, glob, os, re, sys, unicodedata
from collections import defaultdict

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.dirname(HERE)
PUB = os.path.join(REPO, "__Public", "comparative-data")

BASIS_NOTES = {
    "mass_fresh": "weighed fresh (unfixed) brain, stated as such by the source",
    "mass_fixed": "weighed after fixation (perfusion and/or immersion), stated as such",
    "mass_fresh_or_fixed_mixed": "the source's own specimens are a mix of fresh and fixed "
                                 "weights, stated as such and not distinguishable per row",
    "mass_compilation_unspecified": "a mass compiled from other publications, whose fixation "
                                    "state the compiler does not report",
    "mass_from_volume_or_ecv": "not a weighed mass: computed from a measured brain volume, or "
                               "from an endocranial volume, via a conversion factor",
    "mass_unspecified": "a weighed brain mass with no fixation or derivation stated",
    "mass_excl_olfactory_bulb": "weighed brain mass explicitly excluding the olfactory bulbs",
    "mass_or_volume_mixed": "compilation in which some values are weighed masses and others are "
                            "volumes converted at 1 cm3 = 1 g, not distinguishable per row",
    "mass_specimen": "mass of one named specimen, not a species mean",
    "sum_of_structure_volumes": "whole-brain figure obtained by summing measured sub-structures",
    "volume_fresh": "volume of the fresh brain",
    "volume_shrinkage_corrected": "measured (fixed/sectioned) volume corrected for shrinkage",
    "volume_net": "brain volume after removing ventricles and remaining non-brain parts",
    "volume_mri": "volume segmented from MR images of a living brain: in vivo, no fixation "
                  "or sectioning shrinkage",
    "volume_histological": "volume measured on fixed, embedded, serially sectioned tissue; "
                           "carries fixation and sectioning shrinkage unless corrected",
    "volume_mri_or_histological_mixed": "one dataset combining in vivo MRI volumes with "
                                        "histological section volumes, not distinguishable per row",
    "volume_unspecified": "a brain volume with no fixation or inclusion stated",
    "endocranial_volume": "capacity of the braincase: brain plus meninges, CSF and vessels",
    "residual": "residual from a brain-body regression - a relative measure, not a size",
    "log_mass": "logged copy of a brain mass carried for provenance",
}

# ---------------------------------------------------------------------------
# The assignment table. Keyed by (paper folder, column as harvested).
#   (quantity, basis, state, ob, meninges, csf, poolable_group, is_size,
#    basis_evidence, definition_source)
# `definition_quoted` is filled from _keys/variable_catalog.csv where present.
# ---------------------------------------------------------------------------
D = "reference_tables definitions file"
F = "folder definitions file"
C = "_keys/variable_catalog.csv"
P = "paper methods (PDF in the paper folder)"
T = "source table caption/headers (PDF in the paper folder)"
A = ("mass", "mass_unspecified", "unknown", "unknown", "unknown", "unknown",
     "mass_measured", True, "unstated", C)

# Basis statements read out of the sources themselves, for columns whose definitions file is
# silent. Each entry is (verbatim text, where it came from). The text is quoted, not paraphrased:
# `verify_source_statements.py` re-extracts each paper's PDF and fails if a statement attributed
# to a paper's own prose does not occur in it. Do not add an inference here -- if the source does
# not say it, the column stays basis-unstated.
#
# Only statements about the tabulated SIZE COLUMN count. A paper's histology fixation protocol
# says nothing about the basis of a brain-mass column its authors compiled from the literature
# (Sherwood 2003 and deSousa 2013 are exactly that trap), and a paper whose specimens came from
# several places may not describe them uniformly (Young et al. 2013: galago and New World monkey
# brains perfused, macaque and baboon brains purchased, with no statement of what the tabulated
# mass is -- so that column stays unstated).
PAPER_PROSE = "the paper's own prose (PDF in the paper folder)"
TABLE_TEXT = "the source table's caption and column headers (PDF in the paper folder)"
FOLDER_NOTE = "folder definitions file, Note column"

SOURCE_STATEMENTS = {
    "Stephan_etal_1970": ("The latter can be found by dividing the weight of the fresh brain by "
                          "the specific brain weight.", PAPER_PROSE),
    # the PDF prints "et a1." (OCR of "et al."), so the quote stops before it
    "Frahm_etal_1998": ("Brain weight; data taken from STEPHAN", TABLE_TEXT),
    "Armstrong__1979": ("The brain weights were 1,890 gm (after fixation in 10% formalin) and "
                        "1,200 gm (fresh) respectively.", PAPER_PROSE),
    "Schleifenbaum__1973": ("Waehrend das Sammlungsmaterial in 4% Formol fixiert wurde, zog ich "
                            "fuer das frischpraeparierte Pudelmaterial eine AFE-Fixierung vor",
                            PAPER_PROSE),
    "Olkowicz_etal_2016": ("Brains were removed, postfixed for an additional 7-21 d, and "
                           "dissected into the cerebral hemispheres, cerebellum, diencephalon, "
                           "tectum, and brainstem.", PAPER_PROSE),
    "Turner_etal_2016": ("All brains were perfused with 0.9% phosphate-buffered saline (PBS) "
                         "and 2% paraformaldehyde.", PAPER_PROSE),
    "Collins_etal_2016": ("After postfixing in 4% (wt/vol) paraformaldehyde for 2 wk, each sheet "
                          "was cut into small pieces", PAPER_PROSE),
    "Kverkova_etal_2018": ("Brains were dissected and weighed immediately after perfusion. "
                            "The volume of the perfused brain was calculated by dividing the "
                            "brain mass by the fixed brain tissue density (1.036 g/cm3).",
                            PAPER_PROSE),
    # Lewitus_etal_2012 Table S1A brain mass: the supplement footnotes Jones et al.
    # (2009) for body mass and gestation only; the brain weights are the recorded
    # weights of the authors' own specimen sample (see the ASSIGN entry below).
    "Lewitus_etal_2012": ("The recorded brain weights in our sample, nonetheless, do not show "
                          "significant deviations from species-typical average fresh weights.",
                          PAPER_PROSE),
    "Weaver__2001": ("from measured brain volume (extant) or endocranial volume via Ruff et al. "
                     "1997 (fossils)", FOLDER_NOTE),
    "Changizi_Shimojo_2005": ("Brain mass information is used throughout the paper, and these "
                              "data are averages from animals measured in Hrdlicka [1907], Von "
                              "Bonin [1937], Crile and Quiring [1940], Stephan et al.",
                              PAPER_PROSE),
    "Manger__2006": ("Brain mass, body mass, encephalisation quotients, and water temperatures "
                     "used in the analyses included in the present study", TABLE_TEXT),
    "Baron_etal_1996": ("Average body weights (BoW) and brain weights (BrW) of 342 species "
                        "and/or subspecies of bats.", TABLE_TEXT),
    "Finlay_etal_2006": ("Brain weights were obtained from various sources", PAPER_PROSE),
    "Garwicz_etal_2009": ("All data were obtained from the literature (see Table S2).",
                          PAPER_PROSE),
    "Ashwell__2020": ("Intervals between sections were used to calculate volumes and areas "
                      "across the rostrocaudal extent of the forebrain by Cavalieri's basic "
                      "estimator", PAPER_PROSE),
    "Semendeferi_Damasio_2000": ("we applied a non-invasive imaging technique (magnetic "
                                 "resonance) on living human, great ape and lesser ape subjects",
                                 PAPER_PROSE),
    "Semendeferi_etal_1998": ("Imaging techniques were used to characterize and quantify the "
                              "microstructural organization of the area, and stereological tools "
                              "were applied for estimates of the volume", PAPER_PROSE),
    "Semendeferi_etal_2001": ("The volume of the cortical gray of area 10 was obtained from "
                              "histological sections with the use of stereological techniques",
                              PAPER_PROSE),
    "MacLeod_etal_2003": ("incorporating data from both magnetic resonance scans and "
                          "histological sections for a total sample size of 97 specimens",
                          PAPER_PROSE),
    "Smaers_etal_2011": ("differences in section inclination relative to the longitudinal axis "
                         "across species inherent to the histological process", PAPER_PROSE),
    "Smaers_etal_2018": ("collected additional data using both histological sections (using "
                         "similar delineation criteria as MacLeod et al. 2003] and MRI images",
                         PAPER_PROSE),
    "deSousa_etal_2010": ("Measurements were taken on histological sections from a total of 29 "
                          "brains representing seven hominoid species", PAPER_PROSE),
}

ASSIGN = {
    # ---- weighed mass, fresh state stated ---------------------------------
    ("Stephan_etal_1981", "Brain_weight"):
        ("mass", "mass_fresh", "fresh", "unknown", "unknown", "unknown",
         "mass_measured", True, "quoted", C),
    ("Ebinger__1974", "brain_mass_mg"):
        ("mass", "mass_fresh", "fresh", "unknown", "unknown", "unknown",
         "mass_measured", True, "quoted", C),
    ("deSousa_etal_2010", "brain_mass_g"):
        ("mass", "mass_fresh", "fresh", "unknown", "unknown", "unknown",
         "mass_measured", True, "quoted", C),
    ("deSousa_etal_2009", "brain_mass_mg"):
        ("mass", "mass_fresh", "fresh", "unknown", "unknown", "unknown",
         "mass_measured", True, "quoted", C),
    ("Zilles_etal_2011", "brain_weight_fresh_mg"):
        ("mass", "mass_fresh", "fresh", "unknown", "unknown", "unknown",
         "mass_measured", True, "quoted", T),
    ("Zilles_etal_2011", "brain_weight_fresh_g"):
        ("mass", "mass_fresh", "fresh", "unknown", "unknown", "unknown",
         "mass_measured", True, "quoted", T),
    ("Lewitus_etal_2013", "brain_weight_g"):
        ("mass", "mass_fresh", "fresh", "unknown", "unknown", "unknown",
         "mass_measured", True, "quoted", D),
    # ---- weighed mass, nothing further stated -----------------------------
    ("Stephan_etal_1970", "brain_weight_mg"): A,
    ("Pirlot__1981", "brain_weight_mg"): A,
    ("Frahm_etal_1998", "brain_weight_mg"): A,
    ("deSousa_etal_2013", "brain_weight_mg"): A,
    ("Brodmann__1913", "BrainWeight.g"): A,
    ("Nudo_etal_1995", "Brain_Mass.mg"): A,
    ("Weaver__2001", "Brain_Mass.mg"): A,
    ("Schleifenbaum__1973", "brain_mass_mg"): A,
    ("Bauernfeind_etal_2013", "brain_mass_mg"): A,
    ("Changizi_Shimojo_2005", "brain_mass_g"): A,
    ("Finlay_etal_2006", "brainweight_g"): A,
    ("Olkowicz_etal_2016", "whole_brain_mass_g"): A,
    ("Sherwood_etal_2003", "brain_weight_g"): A,
    ("Lewitus_etal_2014", "Brain_weight_g"): A,
    ("Lewitus_etal_2013", "Brain_weight_g"): A,
    # NB: key was "brain_mass_g" until the harvested column was confirmed to be
    # "brain_mass_mg" (the project-unit column; see reference_tables definitions
    # file -- "printed in g; x1000 in the .R for the project unit"), so the old
    # key never matched and this basis silently never fired. Fixed 2026-09-19.
    ("Manger__2006", "brain_mass_mg"): A,
    ("Garwicz_etal_2009", "Absolute Brain Mass (g)"): A,
    ("Armstrong__1979", "brain_mass_g"): A,
    ("Stimpson_etal_2015", "brain_mass_g"): A,
    ("Baron_etal_1996", "brain_weight_mg"): A,
    ("Young_etal_2013", "brain_weight_g"): A,
    ("Turner_etal_2016", "brain_weight_g"): A,
    ("Collins_etal_2016", "brain_mass_g"): A,
    ("MacLeod__2000", "brain_weight_g"):
        ("mass", "mass_unspecified", "unknown", "unknown", "no", "unknown",
         "mass_measured", True, "quoted", F),
    ("Krompecher_Lipak_1966", "brain_weight_g"): A,
    ("MangoldWirz__1966", "brain_weight_g"): A,
    # ---- weighed mass of ONE specimen -------------------------------------
    ("Karl_etal_2024", "Brain mass (g)"):
        ("mass", "mass_specimen", "fresh", "unknown", "unknown", "unknown",
         "mass_measured_specimen", True, "quoted", C),
    ("Jacobs_etal_2018", "brain_mass_mg"):
        ("mass", "mass_specimen", "unknown", "unknown", "unknown", "unknown",
         "mass_measured_specimen", True, "quoted", C),
    # ---- weighed mass, olfactory bulbs EXCLUDED (isotropic-fractionator) --
    ("HerculanoHouzel_etal_2015", "Brain mass, g"):
        ("mass", "mass_excl_olfactory_bulb", "unknown", "no", "unknown", "unknown",
         "mass_measured_excl_ob", True, "quoted", F),
    ("Kazu_etal_2014", "WholeBrain_Mass.g"):
        ("mass", "mass_excl_olfactory_bulb", "unknown", "no", "unknown", "unknown",
         "mass_measured_excl_ob", True, "quoted", C),
    ("Kazu_etal_2015", "WholeBrain_Mass.g"):
        ("mass", "mass_excl_olfactory_bulb", "unknown", "no", "unknown", "unknown",
         "mass_measured_excl_ob", True, "quoted", C),
    ("AvelinodeSouza_etal_2025", "Whole brain_Mass, g"):
        ("mass", "mass_excl_olfactory_bulb", "unknown", "no", "unknown", "unknown",
         "mass_measured_excl_ob", True, "quoted", F),
    # Herculano-Houzel et al. 2020 (bats), Table 1: the header is abbreviated to
    # "MBRAIN, g", which the merge's BRAIN_RX column scan cannot see, so the
    # builders carry the file in a COLUMN_OVERRIDE (see build_brain_mass_merge.py).
    # Same fractionator convention as the 2015 entry above: the paper's Methods
    # state the reported total brain mass excludes the olfactory bulbs.
    ("HerculanoHouzel_etal_2020", "MBRAIN, g"):
        ("mass", "mass_excl_olfactory_bulb", "unknown", "no", "unknown", "unknown",
         "mass_measured_excl_ob", True, "quoted", "paper methods (PDF in the paper folder)"),
    # ---- mass and volume mixed, unresolvable per row ----------------------
    # Baker et al. 2025 (Nat Commun) Supplementary Data 1: a compilation whose
    # per-row Source names the original publication; endocranial volumes were
    # converted to mass at 1 g = 1 cm3 where only volumes were available and
    # the per-row basis is not flagged (folder definitions file). Same
    # situation as Burger_etal_2019 SD1 below: mass_or_volume_mixed, so the
    # values enter the audited harvest and the review file, unpooled, until
    # row-level decisions (brain_mass_row_basis.csv) split them by source.
    ("Baker_etal_2025_b", "Brain_mass_g"):
        ("mass", "mass_or_volume_mixed", "unknown", "unknown", "unknown", "unknown",
         "mass_or_volume_mixed", True, "quoted", D),
    ("Burger_etal_2019", "Mean_brain_mass_g"):
        ("mass", "mass_or_volume_mixed", "unknown", "unknown", "unknown", "unknown",
         "mass_or_volume_mixed", True, "quoted", D),
    # The supplement mixes reported masses with masses calculated from its
    # Brain Vol column (for example 59.070213... cm3 * 1.036 = 61.196741... g).
    # The row-level provenance does not distinguish the original measurement
    # basis beyond the paired columns, so it belongs with the other mixed
    # mass/volume compilations rather than with weighed masses.
    ("DeCasien_etal_2017", "Brain Mass"):
        ("mass", "mass_or_volume_mixed", "unknown", "unknown", "unknown", "unknown",
         "mass_or_volume_mixed", True, "quoted", T),
    # A literature compilation whose underlying database mixes reported brain
    # masses with rows converted from volumes (the row Notes retain conversions
    # such as the Ashwell values at 1.036 g/cm3).
    ("Boddy_etal_2012", "Brain Mass (g)"):
        ("mass", "mass_or_volume_mixed", "unknown", "unknown", "unknown", "unknown",
         "mass_or_volume_mixed", True, "quoted", D),
    ("HerculanoHouzel__2015", "brain.mass..g.or.cm3."):
        ("mass", "mass_or_volume_mixed", "unknown", "no", "unknown", "unknown",
         "mass_or_volume_mixed", True, "quoted", C),
    # ---- whole brain as a sum of measured sub-structures ------------------
    ("Kverkova_etal_2018", "Brain_Mass.g"):
        ("sum_of_structure_volumes", "sum_of_structure_volumes", "unknown", "yes",
         "unknown", "unknown", "sum_of_parts_incl_ob", True, "quoted", F),
    # ---- volumes ----------------------------------------------------------
    ("Ebinger__1974", "total_brain_volume_mm3"):
        ("volume", "volume_fresh", "fresh", "unknown", "unknown", "yes",
         "volume_fresh", True, "quoted", C),
    ("Schleifenbaum__1973", "total_brain_volume_mm3"):
        ("volume", "volume_fresh", "fresh", "unknown", "unknown", "yes",
         "volume_fresh", True, "quoted", C),
    ("Ebinger__1974", "pure_brain_volume_mm3"):
        ("volume", "volume_net", "fresh", "unknown", "no", "no",
         "volume_net", True, "quoted", C),
    ("Bauernfeind_etal_2013", "brain_volume_mm3"):
        ("volume", "volume_shrinkage_corrected", "shrinkage_corrected", "unknown",
         "unknown", "unknown", "volume_net", True, "quoted", C),
    ("Ashwell__2020", "brain_volume_mm3"):
        ("volume", "volume_unspecified", "unknown", "unknown", "unknown", "unknown",
         "volume_unspecified", True, "unstated", C),
    ("MacLeod_etal_2003", "brain_volume_cm3"):
        ("volume", "volume_unspecified", "unknown", "unknown", "unknown", "unknown",
         "volume_unspecified", True, "unstated", C),
    ("Semendeferi_Damasio_2000", "WholeBrain_Vol.mm3"):
        ("volume", "volume_unspecified", "unknown", "unknown", "unknown", "unknown",
         "volume_unspecified", True, "unstated", C),
    ("Semendeferi_etal_1998", "brain_volume_mm3"):
        ("volume", "volume_unspecified", "unknown", "unknown", "unknown", "unknown",
         "volume_unspecified", True, "unstated", C),
    ("Semendeferi_etal_2001", "brain_volume_mm3"):
        ("volume", "volume_unspecified", "unknown", "unknown", "unknown", "unknown",
         "volume_unspecified", True, "unstated", C),
    ("Smaers_etal_2011", "total_brain_volume_cm3"):
        ("volume", "volume_unspecified", "unknown", "unknown", "unknown", "unknown",
         "volume_unspecified", True, "unstated", C),
    ("Smaers_etal_2018", "Brain_Vol.mm3"):
        ("volume", "volume_unspecified", "unknown", "unknown", "unknown", "unknown",
         "volume_unspecified", True, "unstated", C),
    ("deSousa_etal_2010", "brain_volume_cm3"):
        ("volume", "volume_unspecified", "unknown", "unknown", "unknown", "unknown",
         "volume_unspecified", True, "unstated", C),
    # ---- endocranial volume / cranial capacity ----------------------------
    ("Seymour_etal_2015", "Brain_volume_ml"):
        ("endocranial_volume", "endocranial_volume", "unknown", "yes", "yes", "yes",
         "endocranial_volume", True, "quoted", C),
    ("Seymour_etal_2017", "Brain_volume_cm3"):
        ("endocranial_volume", "endocranial_volume", "unknown", "yes", "yes", "yes",
         "endocranial_volume", True, "quoted", C),
    ("Seymour_etal_2019", "ECV_ml"):
        ("endocranial_volume", "endocranial_volume", "unknown", "yes", "yes", "yes",
         "endocranial_volume", True, "quoted", C),
    ("Heldstab_etal_2016", "ECV_ml"):
        ("endocranial_volume", "endocranial_volume", "unknown", "yes", "yes", "yes",
         "endocranial_volume", True, "quoted", C),
    ("Caspar_etal_2022", "female_endocranial_volume_ml"):
        ("endocranial_volume", "endocranial_volume", "unknown", "yes", "yes", "yes",
         "endocranial_volume", True, "quoted", C),
    # ---- not a size at all ------------------------------------------------
    ("Iwaniuk_etal_2001", "Brain Size"):
        ("residual", "residual", "unknown", "unknown", "unknown", "unknown",
         "not_a_size", False, "quoted", C),
    ("Burger_etal_2019", "Brain.resid"):
        ("residual", "residual", "unknown", "unknown", "unknown", "unknown",
         "not_a_size", False, "quoted", C),
    ("Heuer_etal_2023", "LogBrainWeight_source"):
        ("log_mass", "log_mass", "unknown", "unknown", "unknown", "unknown",
         "not_a_size", False, "quoted", C),
    # ---- weighed mass, no fixation/inclusion stated ------------------------
    # Ridgway__1990_Table1 ("Brain and Body Size of Adult Bottlenose Dolphins"): printed
    # BrnW (kg) per animal; neither the table nor its definitions file states fixation
    # state or olfactory-bulb inclusion -- default "unstated" tuple A, per the rule that
    # nothing is inferred beyond what the source itself says.
    ("Ridgway__1990", "brain_weight_kg"): A,
    # Jacobs_etal_2015_Table4 ("Mean Brain mass (g)"): a cross-species compilation table
    # (columns "Species", "Source Ref", multiple non-giraffe taxa per row, each citing a
    # lettered reference) -- the brain-mass values are not this paper's own measurements on
    # its giraffe specimens, and the table gives no fixation state for the compiled values
    # (the "Fixation method" column describes each cited specimen's histology preparation,
    # not necessarily the brain-mass determination) -- same compilation-table pattern as
    # Sherwood_etal_2003 / deSousa_etal_2013 above.
    ("Jacobs_etal_2015", "Mean Brain mass (g)"):
        ("mass", "mass_compilation_unspecified", "unknown", "unknown", "unknown",
         "unknown", "mass_measured", True, "quoted", T),
    # Graham 2011 TABLE I footnote b attributes the brain-size values to Barton
    # (1999); Graham did not measure them or state their fixation basis.
    ("Graham__2011", "brain_mass_g"):
        ("mass", "mass_compilation_unspecified", "unknown", "unknown", "unknown",
         "unknown", "mass_measured", True, "quoted", T),
    # Table 1 mixes literature values with one brain measurement from this
    # study; fixation and included tissue are not stated for the column.
    ("Barrickman_Lin_2010", "brain_mass_g"): A,
    # Bahney & von Bartheld 2018 TABLES 3-4 republish brain weights from cited
    # sources; the rows do not identify a common fixation basis.
    ("Bahney_vonBartheld_2018", "brain_mass_mg"):
        ("mass", "mass_compilation_unspecified", "unknown", "unknown", "unknown",
         "unknown", "mass_measured", True, "quoted", T),
    # HrvojMihic_etal_2026_SD (Dataset S1/S2): per-individual necropsy brain weight for 601
    # adult great apes; neither dataset states fixation state or olfactory-bulb inclusion --
    # default "unstated" tuple A.
    ("HrvojMihic_etal_2026", "brain_weight_mg"): A,
    # ---- 2026-11-17: the 34 (paper, column) groups a fresh harvest used to
    # abort on, classified from each folder's definitions file / item README /
    # paper (verified by running the merge builder against a local replica).
    # Bahney TABLES 3-4 printed columns: the same compilation of published
    # brain weights as this folder's brain_mass_mg above, in as-printed form;
    # they are the only Bahney brain-mass columns that reach the harvest.
    ("Bahney_vonBartheld_2018", "brain_mass_printed"):
        ("mass", "mass_compilation_unspecified", "unknown", "unknown", "unknown",
         "unknown", "mass_measured", True, "quoted", D),
    ("Bahney_vonBartheld_2018", "brain_weight_printed"):
        ("mass", "mass_compilation_unspecified", "unknown", "unknown", "unknown",
         "unknown", "mass_measured", True, "quoted", D),
    # Coto et al. 2026 Fig 7: literature brain masses for 7 mammals (plus one
    # ant row that also harvests); definitions state literature values.
    ("Coto_etal_2026", "brain_mass_g"):
        ("mass", "mass_compilation_unspecified", "unknown", "unknown", "unknown",
         "unknown", "mass_measured", True, "quoted", C),
    # Elia 1992 organ-weight tables: compiled reference values (TABLE 1 human
    # reference subjects; TABLE 3 the Brody-lineage 11-animal table).
    ("Elia__1992", "Brain_Mass.mg"):
        ("mass", "mass_compilation_unspecified", "unknown", "unknown", "unknown",
         "unknown", "mass_measured", True, "quoted", C),
    ("Elia__1992", "brain_mass.g"):
        ("mass", "mass_compilation_unspecified", "unknown", "unknown", "unknown",
         "unknown", "mass_measured", True, "quoted", C),
    # Elia 1997 TABLE 8: brain weights printed for model scenarios (12-month
    # child, normal and marasmic) -- compiled reference values, not specimens.
    ("Elia__1997", "Brain_Mass.mg"):
        ("mass", "mass_compilation_unspecified", "unknown", "unknown", "unknown",
         "unknown", "mass_measured", True, "quoted", C),
    # Filiminoff 1932: whole-brain weights of the authors' human specimens;
    # the folder definitions read them as fresh weights before alcohol
    # fixation (stated there as a presumption, carried in the quote).
    ("Filiminoff__1932", "brain_weight_g"):
        ("mass", "mass_fresh", "fresh", "unknown", "unknown", "unknown",
         "mass_measured", True, "quoted", D),
    # Garey 2006 Table 4: Brodmann 1909 brain weights via the English
    # translation; definitions mark the item secondary throughout.
    ("Garey__2006", "BrainWeight.g"):
        ("mass", "mass_compilation_unspecified", "unknown", "unknown", "unknown",
         "unknown", "mass_measured", True, "quoted", C),
    # Glendenning & Masterton 1998 Table 1: weighed brain masses, 53 spp;
    # the folder's errata concern blank cells, not the basis.
    ("Glendenning_Masterton_1998", "brain_mass_mg"):
        ("mass", "mass_unspecified", "unknown", "unknown", "unknown",
         "unknown", "mass_measured", True, "quoted", C),
    # Herberstein et al. 2022 (Animalia trait database): the folder
    # definitions state the column includes volume-derived estimates, so it
    # sits with the other mixed compilations: harvest and review, unpooled.
    ("Herberstein_etal_2022", "Brain_Mass.mg"):
        ("mass", "mass_or_volume_mixed", "unknown", "unknown", "unknown",
         "unknown", "mass_or_volume_mixed", True, "quoted", D),
    # Herculano-Houzel et al. 2007 Table 1: species means of whole brains
    # dissected by the authors; olfactory-bulb handling not stated (the
    # definitions file flags exactly that), so OB fields stay unknown.
    ("HerculanoHouzel_etal_2007", "brain_mass_g"):
        ("mass", "mass_unspecified", "unknown", "unknown", "unknown",
         "unknown", "mass_measured", True, "quoted", D),
    # Holliday et al. 1967 Table III: Brody 1945 weighed masses reprinted.
    ("Holliday_etal_1967", "brain_mass_mg"):
        ("mass", "mass_compilation_unspecified", "unknown", "unknown", "unknown",
         "unknown", "mass_measured", True, "quoted", C),
    # Huttenlocher 1979 Figure 6: human total brain weights digitised from
    # the figure (individual brains plus Adult/Aged group means).
    ("Huttenlocher__1979", "Brain_mass.mg"):
        ("mass", "mass_unspecified", "unknown", "unknown", "unknown",
         "unknown", "mass_measured", True, "quoted", C),
    # Jacobs & Spencer 1994: Dipodomys mean brain masses; the definitions
    # file states fixed tissue.
    ("Jacobs_Spencer_1994", "brain_mass_mean_mg"):
        ("mass", "mass_fixed", "fixed", "unknown", "unknown", "unknown",
         "mass_measured", True, "quoted", D),
    # Kruska & Rohrs 1974: the definitions file describes the column as
    # fresh/fixed brain weight -- the mixed-state basis, pooled as measured.
    ("Kruska_Rohrs_1974", "brain_weight_g"):
        ("mass", "mass_fresh_or_fixed_mixed", "fresh_or_fixed", "unknown", "unknown",
         "unknown", "mass_measured", True, "quoted", D),
    # Lewitus et al. 2012 Table S1A: species means of the recorded brain
    # weights of the authors' own specimen sample (paper Methods, quoted in
    # SOURCE_STATEMENTS); the supplement footnotes Jones et al. (2009) for
    # body mass and gestation only. Stored as back-transformed log10 means.
    # Weighed masses, so mass_unspecified rather than a compilation basis.
    ("Lewitus_etal_2012", "brain_mass_g"):
        ("mass", "mass_unspecified", "unknown", "unknown", "unknown",
         "unknown", "mass_measured", True, "quoted", P),
    # Lewitus et al. 2012 Evolution paper (folder Lewitus_etal_2012_b)
    # Table S2: recorded specimen brain weights per its definitions file.
    # The merge builder keys the column under Lewitus_etal_2012 by its
    # folder tie-break, so the entry lives here.
    ("Lewitus_etal_2012", "brain_mass_mg"):
        ("mass", "mass_unspecified", "unknown", "unknown", "unknown",
         "unknown", "mass_measured", True, "quoted", D),
    # MacLarnon 1996 Table 1: literature compilation of brain weights with
    # per-row references (item ReadMe, incl. erratum E001 confirming the
    # values are brain weights).
    ("MacLarnon__1996", "Brain weight (mg)"):
        ("mass", "mass_compilation_unspecified", "unknown", "unknown", "unknown",
         "unknown", "mass_measured", True, "quoted", F),
    # Manger et al. 2012 Table 1: compiled brain masses; part of the values
    # are attributed in the definitions file to Pillay & Manger 2007 and
    # Zilles et al. 1989; fresh/fixed not given.
    ("Manger_etal_2012", "brain_mass_g"):
        ("mass", "mass_compilation_unspecified", "unknown", "unknown", "unknown",
         "unknown", "mass_measured", True, "quoted", C),
    # Meyer 1981 Table I: the definitions note states fixed brain masses,
    # not fresh volumes.
    ("Meyer__1981", "brain_mass_mg"):
        ("mass", "mass_fixed", "fixed", "unknown", "unknown", "unknown",
         "mass_measured", True, "quoted", D),
    # Mink et al. 1981 Table 1: printed brain weights compiled from the
    # literature across vertebrates.
    ("Mink_etal_1981", "brain_weight.g"):
        ("mass", "mass_compilation_unspecified", "unknown", "unknown", "unknown",
         "unknown", "mass_measured", True, "quoted", C),
    # Munger et al. 2022 Table 1: present-study individuals; the folder
    # documents 23 of 25 printed values as measured specimens (one
    # hemisphere-extrapolated, one a Robson & Wood 2008 species average,
    # told apart per row by the folder's brain_weight_basis column).
    ("Munger_etal_2022", "brain_weight_printed"):
        ("mass", "mass_unspecified", "unknown", "unknown", "unknown",
         "unknown", "mass_measured", True, "quoted", D),
    # Patzke et al. 2015 Table 1: published brain masses (source_key 5 is
    # the present study, the rest secondary; sample types differ, but no
    # volume conversion is documented for any source).
    ("Patzke_etal_2015", "brain_mass_mg"):
        ("mass", "mass_compilation_unspecified", "unknown", "unknown", "unknown",
         "unknown", "mass_measured", True, "quoted", C),
    # Pirlot & Kamiya 1982: brain weights of the authors' own specimens.
    ("Pirlot_Kamiya_1982", "brain_weight_g"):
        ("mass", "mass_unspecified", "unknown", "unknown", "unknown",
         "unknown", "mass_measured", True, "quoted", D),
    # Reep & O'Shea 1990: manatee brain weights, formaldehyde/embedded
    # specimens, measured -- fixed.
    ("Reep_OShea_1990", "brain_weight_g"):
        ("mass", "mass_fixed", "fixed", "unknown", "unknown", "unknown",
         "mass_measured", True, "quoted", C),
    # Riddell & Corl 1977: E values joined from cited secondary sources.
    ("Riddell_Corl_1977", "Brain_Mass.g"):
        ("mass", "mass_compilation_unspecified", "unknown", "unknown", "unknown",
         "unknown", "mass_measured", True, "quoted", C),
    # Sawaguchi 1988 Appendix: E (brain weight) compiled for primates,
    # mean of female and male adults.
    ("Sawaguchi__1988", "brain_weight_g"):
        ("mass", "mass_compilation_unspecified", "unknown", "unknown", "unknown",
         "unknown", "mass_measured", True, "quoted", C),
    # Sherwood et al. 2009 Table 1 ONLY: specimen masses measured at the
    # zoo/lab. The x1.036 Bush & Allman-derived values sit in a different
    # table whose public TSV carries no brain-mass column, so they cannot
    # inherit this entry.
    ("Sherwood_etal_2009", "brain_mass_g"):
        ("mass", "mass_unspecified", "unknown", "unknown", "unknown",
         "unknown", "mass_measured", True, "quoted", D),
    # Shoshani et al. 2006 Table 1: one printed column mixing the authors'
    # weighed elephant brains, literature values and extinct-proboscidean
    # endocast estimates (weights also include dura fragments and variable
    # brain stem) -- not separable per row, so mixed: harvest and review.
    ("Shoshani_etal_2006", "brain_mass_g_printed"):
        ("mass", "mass_or_volume_mixed", "unknown", "unknown", "unknown",
         "unknown", "mass_or_volume_mixed", True, "quoted", C),
    # Soria et al. 2021 (COMBINE): adult brain mass as published; the
    # folder definitions file does not transcribe a per-row basis and no
    # volume conversion is documented in the repo, so it follows the other
    # large mass compilations. Largest single judgement call in this set:
    # parking it as mixed instead would hold 1,836 rows in review.
    ("Soria_etal_2021", "adult_brain_mass_g"):
        ("mass", "mass_compilation_unspecified", "unknown", "unknown", "unknown",
         "unknown", "mass_measured", True, "quoted", D),
    # Weisbecker & Goswami 2010 Table S6: marsupial compilation whose
    # definitions file leaves the basis (fresh/fixed/endocast) unstated --
    # endocast is explicitly open, so mixed: harvest and review, unpooled.
    ("Weisbecker_Goswami_2010", "brain_mass_g"):
        ("mass", "mass_or_volume_mixed", "unknown", "unknown", "unknown",
         "unknown", "mass_or_volume_mixed", True, "quoted", D),
    # West & Gundersen 1990: human brain masses at autopsy.
    ("West_Gundersen_1990", "brain_mass_mg"):
        ("mass", "mass_unspecified", "unknown", "unknown", "unknown",
         "unknown", "mass_measured", True, "quoted", C),
    # West & Schwerdtfeger 1985 Table I: reported brain weights, own and
    # compiled (catalogue role "both"); no basis statement found.
    ("West_Schwerdtfeger_1985", "brain_mass_mg"):
        ("mass", "mass_compilation_unspecified", "unknown", "unknown", "unknown",
         "unknown", "mass_measured", True, "unstated", C),
    # Zilles et al. 1989 Table 1: E (brain weight) for nonhuman primates,
    # a Stephan-collection compilation. The folder definitions file advises
    # conservative merge exclusion because the values largely duplicate
    # the Stephan tables; classified here as a secondary compilation so
    # the harvest can run -- exclusion remains available at any time via
    # the merge builder's SKIP list.
    ("Zilles_etal_1989", "Brain_Mass.mg"):
        ("mass", "mass_compilation_unspecified", "unknown", "unknown", "unknown",
         "unknown", "mass_measured", True, "quoted", D),
}

# quoted inclusion evidence that lives in a FOLDER definitions file rather than
# in variable_catalog.csv, so the key can cite the exact wording
FOLDER_QUOTES = {
    ("Zilles_etal_2011", "brain_weight_fresh_mg"):
        "brain_weight_fresh_mg -- supplementary table header explicitly identifies fresh brain weight",
    ("Zilles_etal_2011", "brain_weight_fresh_g"):
        "brain_weight_fresh_g -- supplementary table header explicitly identifies fresh brain weight",
    ("Lewitus_etal_2013", "brain_weight_g"):
        "Brain weight -- Table A1 footnote a attributes these values to Stephan et al. (1981), "
        "whose source definition records fresh brain weight",
    ("Baker_etal_2025_b", "Brain_mass_g"):
        "Brain_mass_g -- species mean whole-brain mass (g); compilation: masses "
        "reported excluding the olfactory bulb were excluded by the paper, and "
        "endocranial volumes were converted to mass at 1 g = 1 cm3 where only "
        "volumes were available; per-row basis not flagged (folder definitions file)",
    ("Bahney_vonBartheld_2018", "brain_mass_printed"):
        "Brain mass cell as printed (unit not printed; g assumed, as Table 3) -- "
        "compilation of published brain weights (folder definitions file)",
    ("Bahney_vonBartheld_2018", "brain_weight_printed"):
        "Brain weight (g) cell as printed -- compilation of published brain "
        "weights (folder definitions file)",
    ("Filiminoff__1932", "brain_weight_g"):
        "Hirngewicht as printed (unit not printed; grams presumed); whole fresh "
        "brain weight before alcohol fixation (presumed) (folder definitions file)",
    ("Herberstein_etal_2022", "Brain_Mass.mg"):
        "Brain mass in milligrams, including volume-derived estimates "
        "(folder definitions file)",
    ("HerculanoHouzel_etal_2007", "brain_mass_g"):
        "Brain mass, g (species mean); whole brain as dissected by the authors; "
        "olfactory-bulb handling is not stated in Table 1 (folder definitions file)",
    ("Jacobs_Spencer_1994", "brain_mass_mean_mg"):
        "mean brain mass, mg; fixed tissue (folder definitions file)",
    ("Kruska_Rohrs_1974", "brain_weight_g"):
        "Fresh/fixed brain weight in grams (folder definitions file)",
    ("Lewitus_etal_2012", "brain_mass_g"):
        "Brain mass, g -- species means of the recorded brain weights of the "
        "authors' own specimen sample (paper Methods: 'The recorded brain "
        "weights in our sample ... do not show significant deviations from "
        "species-typical average fresh weights'); the supplement footnotes "
        "Jones et al. (2009) for body mass and gestation only, not brain mass",
    ("Lewitus_etal_2012", "brain_mass_mg"):
        "Brain mass, mg -- recorded specimen brain weights per Methods "
        "(Lewitus_etal_2012_b Table S2 definitions file; the merge builder "
        "keys this column under Lewitus_etal_2012 by its folder tie-break)",
    ("MacLarnon__1996", "Brain weight (mg)"):
        "Brain weight (mg) -- literature compilation with per-row references "
        "(Table 1, p. 73; item ReadMe, incl. erratum E001 confirming the "
        "values are brain weights)",
    ("Meyer__1981", "brain_mass_mg"):
        "Mean brain mass, mg; fixed brain masses, not fresh volumes "
        "(folder definitions file)",
    ("Munger_etal_2022", "brain_weight_printed"):
        "brain weight in grams exactly as printed; 23 of the 25 printed "
        "values are measured specimens of the present study (folder "
        "definitions file; item README, brain_weight_basis)",
    ("Pirlot_Kamiya_1982", "brain_weight_g"):
        "Brain weight of the individual specimen in grams "
        "(folder definitions file)",
    ("Sherwood_etal_2009", "brain_mass_g"):
        "Brain mass of the specimen, g; measured at the zoo/lab except the "
        "giant anteater (76 g, see footnote a) (folder definitions file)",
    ("Soria_etal_2021", "adult_brain_mass_g"):
        "Trait column as published in COMBINE; full definition in Soria "
        "et al. 2021 (not transcribed here) (folder definitions file); "
        "per-row basis not documented",
    ("Weisbecker_Goswami_2010", "brain_mass_g"):
        "Brain weight, g; compilation; basis (fresh/fixed/endocast) not "
        "stated (folder definitions file)",
    ("Zilles_etal_1989", "Brain_Mass.mg"):
        "Brain weight E converted from grams to milligrams; the folder "
        "definitions file advises conservative merge exclusion (the values "
        "largely duplicate the Stephan-collection tables)",
    ("Burger_etal_2019", "Mean_brain_mass_g"):
        "Mean brain mass -- compilation; 1 g = 1 cm3 conversion used when volumes reported "
        "(per source methods)",
    ("DeCasien_etal_2017", "Brain Mass"):
        "Brain Mass -- compiled mass values mixed with values calculated from the paired "
        "Brain Vol column using 1.036 g/cm3 (as shown by the supplementary workbook)",
    ("Boddy_etal_2012", "Brain Mass (g)"):
        "Brain Mass (g) -- literature compilation; source-row notes identify brain masses "
        "calculated from volumes as well as reported brain weights",
    ("HerculanoHouzel_etal_2015", "Brain mass, g"):
        "whole brain (both sides), NOT including the olfactory bulbs "
        "[Herculano-Houzel whole-brain definition, per AvelinodeSouza_etal_2025 definitions]",
    ("AvelinodeSouza_etal_2025", "Whole brain_Mass, g"):
        "whole brain (both sides), NOT including the olfactory bulbs",
    ("HerculanoHouzel_etal_2020", "MBRAIN, g"):
        "MBRAIN, g -- total brain mass; 'reported total brain mass and numbers of "
        "brain neurons exclude the olfactory bulbs, following our practice since "
        "2006' (paper Methods)",
    ("Kverkova_etal_2018", "Brain_Mass.g"):
        "Brain_Mass.g -- Table S1 species mean brain mass (folder definitions code "
        "Mass.g: 'mass in grams'); brains dissected and weighed immediately after "
        "perfusion (paper Methods). The definitions file's 'sum of 14 structures' "
        "wording describes the Fig3 whole-brain VOLUME, not this mass column.",
    ("MacLeod__2000", "brain_weight_g"):
        "uses the estimated brain weight when a row prints both a with-meninges weight and an "
        "estimated weight (e.g. A375)",
}

# ---------------------------------------------------------------------------
# Resolved from the papers themselves (PAPER_QUOTES above). These override the
# entries in ASSIGN, which had them as basis-unstated because the definitions
# files are silent.
#
# poolable_group: fresh, fixed, mixed-fresh/fixed and compiled masses all stay in
# `mass_measured` -- they are all a mass put on a balance, and the `state` column
# is where the fresh-vs-fixed difference is recorded. Weaver 2001 does NOT: its
# "brain mass" is computed from a volume (extant) or from an endocranial volume
# (fossils), so it gets its own group and its own app variable. Cranial capacity
# is not brain weight, and neither is a mass back-calculated from one.
# ---------------------------------------------------------------------------
RESOLVED = {
    ("Stephan_etal_1970", "brain_weight_mg"):
        ("mass", "mass_fresh", "fresh", "unknown", "unknown", "unknown",
         "mass_measured", True, "quoted", P),
    ("Frahm_etal_1998", "brain_weight_mg"):
        ("mass", "mass_fresh", "fresh", "unknown", "unknown", "unknown",
         "mass_measured", True, "quoted", T),
    ("Armstrong__1979", "brain_mass_g"):
        ("mass", "mass_fresh_or_fixed_mixed", "fresh_or_fixed", "unknown", "unknown",
         "unknown", "mass_measured", True, "quoted", P),
    ("Schleifenbaum__1973", "brain_mass_mg"):
        ("mass", "mass_fresh_or_fixed_mixed", "fresh_or_fixed", "unknown", "unknown",
         "unknown", "mass_measured", True, "quoted", P),
    ("Olkowicz_etal_2016", "whole_brain_mass_g"):
        ("mass", "mass_fixed", "fixed", "unknown", "unknown", "unknown",
         "mass_measured", True, "quoted", P),
    ("Turner_etal_2016", "brain_weight_g"):
        ("mass", "mass_fixed", "fixed", "unknown", "unknown", "unknown",
         "mass_measured", True, "quoted", P),
    ("Collins_etal_2016", "brain_mass_g"):
        ("mass", "mass_fixed", "fixed", "unknown", "unknown", "unknown",
         "mass_measured", True, "quoted", P),
    # Kverkova_etal_2018 Table S1, Brain_Mass.g: the ASSIGN entry took the folder
    # definitions file's Fig3 "Brain" description (a total brain VOLUME, approx.
    # sum of 14 structures) as the basis of this MASS column. The paper's Methods
    # state the brains were dissected and weighed immediately after perfusion,
    # and that the perfused-brain volume was derived FROM the mass (mass /
    # 1.036 g/cm3) -- the mass is the primary measurement. Weighed whole brain,
    # olfactory bulbs included (the brain was weighed before dissection into
    # compartments), so it pools as a measured fixed mass.
    ("Kverkova_etal_2018", "Brain_Mass.g"):
        ("mass", "mass_fixed", "fixed", "yes", "unknown", "unknown",
         "mass_measured", True, "quoted", P),
    ("Weaver__2001", "Brain_Mass.mg"):
        ("mass", "mass_from_volume_or_ecv", "derived", "unknown", "unknown", "unknown",
         "mass_from_volume_or_ecv", True, "quoted", F),
    ("Changizi_Shimojo_2005", "brain_mass_g"):
        ("mass", "mass_compilation_unspecified", "unknown", "unknown", "unknown",
         "unknown", "mass_measured", True, "quoted", P),
    ("Manger__2006", "brain_mass_mg"):
        ("mass", "mass_compilation_unspecified", "unknown", "unknown", "unknown",
         "unknown", "mass_measured", True, "quoted", T),
    ("Baron_etal_1996", "brain_weight_mg"):
        ("mass", "mass_compilation_unspecified", "unknown", "unknown", "unknown",
         "unknown", "mass_measured", True, "quoted", T),
    ("Finlay_etal_2006", "brainweight_g"):
        ("mass", "mass_compilation_unspecified", "unknown", "unknown", "unknown",
         "unknown", "mass_measured", True, "quoted", P),
    ("Garwicz_etal_2009", "Absolute Brain Mass (g)"):
        ("mass", "mass_compilation_unspecified", "unknown", "unknown", "unknown",
         "unknown", "mass_measured", True, "quoted", P),
    ("Sherwood_etal_2003", "brain_weight_g"):
        ("mass", "mass_compilation_unspecified", "unknown", "unknown", "unknown",
         "unknown", "mass_measured", True, "quoted", C),
    # secondary column: table footnote states these species averages were not measured in
    # this study but taken from Marino et al. (2004) and Hof et al. (2005) -- a compilation
    # of unstated fixation state, same class as the other mass_compilation_unspecified rows.
    ("Butti_etal_2009", "brain_mass_mg"):
        ("mass", "mass_compilation_unspecified", "unknown", "unknown", "unknown",
         "unknown", "mass_measured", True, "quoted", D),
    # Table 12-1 "Brain and Body Weights from Literature" compiles orang-utan values from
    # multiple 19th/20th-century sources; the chapter text explicitly flags uncertainty
    # about whether the compiled brain weights are fresh -- textbook case for "unspecified".
    ("Zilles_Rehkämper_1988", "Brain_weight_g"):
        ("mass", "mass_compilation_unspecified", "unknown", "unknown", "unknown",
         "unknown", "mass_measured", True, "quoted", P),
    # ---- volume columns ---------------------------------------------------
    ("Ashwell__2020", "brain_volume_mm3"):
        ("volume", "volume_shrinkage_corrected", "shrinkage_corrected", "unknown",
         "unknown", "unknown", "volume_histological", True, "quoted", P),
    ("Semendeferi_Damasio_2000", "WholeBrain_Vol.mm3"):
        ("volume", "volume_mri", "in_vivo", "unknown", "unknown", "unknown",
         "volume_mri", True, "quoted", P),
    ("Semendeferi_etal_1998", "brain_volume_mm3"):
        ("volume", "volume_histological", "fixed_sectioned", "unknown", "unknown",
         "unknown", "volume_histological", True, "quoted", P),
    ("Semendeferi_etal_2001", "brain_volume_mm3"):
        ("volume", "volume_histological", "fixed_sectioned", "unknown", "unknown",
         "unknown", "volume_histological", True, "quoted", P),
    ("deSousa_etal_2010", "brain_volume_cm3"):
        ("volume", "volume_histological", "fixed_sectioned", "unknown", "unknown",
         "unknown", "volume_histological", True, "quoted", P),
    ("Smaers_etal_2011", "total_brain_volume_cm3"):
        ("volume", "volume_histological", "fixed_sectioned", "unknown", "unknown",
         "unknown", "volume_histological", True, "quoted", P),
    ("MacLeod_etal_2003", "brain_volume_cm3"):
        ("volume", "volume_mri_or_histological_mixed", "in_vivo_or_fixed", "unknown",
         "unknown", "unknown", "volume_mri_or_histological_mixed", True, "quoted", P),
    ("Smaers_etal_2018", "Brain_Vol.mm3"):
        ("volume", "volume_mri_or_histological_mixed", "in_vivo_or_fixed", "unknown",
         "unknown", "unknown", "volume_mri_or_histological_mixed", True, "quoted", P),
    # ---- items added 2026-11-18, classified 2026-11-18 for the merge wiring ----
    # Roehrs 1986 Table 1: species-mean brain weights (Hirngewicht, HG) of the
    # author's own mustelid sample (196 individuals; three species' values after
    # Drescher 1977). Weighed masses; the paper does not state fresh vs fixed,
    # so mass_unspecified on the Lewitus S1A precedent. Primary.
    ("Röhrs__1986", "Brain_mass_g"):
        ("mass", "mass_unspecified", "unknown", "unknown", "unknown", "unknown",
         "mass_measured", True, "quoted", D),
    # Kruska 1980 Tabelle 1: FRESH brain weight per specimen, weighed before
    # fixation (the same table prints the fixation shrinkage %). Primary.
    ("Kruska__1980", "Fresh_brain_weight_g"):
        ("mass", "mass_fresh", "fresh", "unknown", "unknown", "unknown",
         "mass_measured", True, "quoted", D),
    # Kruska 1980 Tabelle 2 prints the SAME seven camelid specimens' fresh
    # weights again as the basis of its volume table (values identical to
    # Tabelle 1, specimen by specimen). The basis is a genuine fresh mass,
    # but the seven rows are kept out of the pool by row-basis decisions in
    # __metadata/curation/brain_mass_row_basis.csv so each specimen is
    # counted once, from Tabelle 1.
    ("Kruska__1980", "Brain_mass_g_fresh"):
        ("mass", "mass_fresh", "fresh", "unknown", "unknown", "unknown",
         "mass_measured", True, "quoted", D),
    # Gonzalez-Voyer et al. 2016 (Dryad): a literature compilation of brain
    # masses whose underlying sources mix weighed masses with values converted
    # from endocranial volumes (the per-row References name the sources).
    # Parked with the other mixed compilations (Baker, Boddy, Burger) until
    # row-basis decisions split it by source.
    ("GonzalezVoyer_etal_2016", "Brain_mass_g"):
        ("mass", "mass_or_volume_mixed", "unknown", "unknown", "unknown", "unknown",
         "mass_or_volume_mixed", True, "quoted", D),
}
ASSIGN.update(RESOLVED)

# macOS and CSV sources do not agree on whether accented folder names use NFC
# or decomposed Unicode (notably Rehkamper). Canonicalize keys before emitting
# the CSV so the R merge's folder basename can resolve the recorded basis.
ASSIGN = {(unicodedata.normalize("NFC", paper), col): value
          for (paper, col), value in ASSIGN.items()}
FOLDER_QUOTES = {(unicodedata.normalize("NFC", paper), col): value
                 for (paper, col), value in FOLDER_QUOTES.items()}

# ---- pull role + quoted definition out of variable_catalog.csv --------------
cat_def, cat_role = {}, {}
with open(os.path.join(HERE, "variable_catalog.csv"), newline="", encoding="utf-8") as fh:
    for r in csv.DictReader(fh):
        k = (r["paper"], r["Code"])
        if k not in cat_def:
            cat_def[k] = r["Definition"]
            cat_role[k] = r["role"]

# ---- how much each column contributes to the brain-mass merge --------------
contrib = defaultdict(lambda: [0, set()])
bmu_path = os.path.join(REPO, "__merging_brain_mass", "brain_mass_unfiltered.csv")
BRAIN_RX = re.compile(r"brain.{0,3}(mass|weight|wt)", re.I)
EXCLUDE = ["neonat", "fetal", "cerebel", "cortex", "cortic", "olfact", "rest of brain",
           "diencephal", "mesencephal", "pons", "medulla", "hemisphere", "white", "grey",
           "gray", "region", "residual", "resid", "net", "ratio", "source", "ref", "note",
           "_sd", " sd", ": data", "%", "index", "relative",
           "printed", "_min", "_max", "estimated"]


def pick_column(headers):
    """the brain-mass merge's own column picker (brain_mass_compiled.R)."""
    n = lambda h: h.strip().strip('"').lower()
    cand = [h for h in headers if BRAIN_RX.search(n(h))]
    cand = [h for h in cand if not any(e in n(h) for e in EXCLUDE)]
    cand = [h for h in cand if not re.match(r"^n[ _]", n(h)) and "sample_size" not in n(h)]
    if not cand:
        return None
    if any("whole" in n(h) for h in cand):
        cand = [h for h in cand if "whole" in n(h)]
    return cand[0]


# Tables whose whole-brain-mass column pick_column() cannot see because the
# header carries no mass/weight token the BRAIN_RX scan recognises
# (HerculanoHouzel et al. 2020 Table 1 abbreviates it to "MBRAIN, g"). Mirrors
# COLUMN_OVERRIDE in __merging_brain_mass/build_brain_mass_merge.py and
# brain_mass_compiled.R; keep the three in step.
COLUMN_OVERRIDE = {"10.1002%2Fcne.24985_TABLE1.tsv": "MBRAIN, g"}

file_col = {}
for p in glob.glob(os.path.join(PUB, "*.tsv")):
    with open(p, encoding="utf-8", errors="replace") as fh:
        hdr = [h.strip('"') for h in fh.readline().rstrip("\n").split("\t")]
    c = COLUMN_OVERRIDE.get(os.path.basename(p)) or pick_column(hdr)
    if c:
        file_col[os.path.basename(p)] = c

# paper folder for an (author, year) pair, using the repo's folder naming
folders = sorted(d for d in os.listdir(REPO) if os.path.isdir(os.path.join(REPO, d))
                 and not d.startswith((".", "_")))


def folder_of(author, year, col):
    """Resolve (author, year) to a repo folder. Several authors have two folders for
    the same year (HerculanoHouzel__2015 vs HerculanoHouzel_etal_2015;
    Young_etal_2013 vs Young_etal_2013_b), so prefer the candidate that actually
    carries this column in the assignment table or the variable catalog."""
    a, y = (author or "").lower(), str(year or "")
    hits = [f for f in folders if f.lower().startswith(a) and y in f]
    if len(hits) > 1:
        for h in hits:
            if (h, col) in ASSIGN or (h, col) in cat_def:
                return h
    return hits[0] if hits else ""


if os.path.exists(bmu_path):
    with open(bmu_path, newline="", encoding="utf-8") as fh:
        for r in csv.DictReader(fh):
            col = file_col.get(r["Source"])
            fol = folder_of(r.get("first_author"), r.get("Year"), col)
            if col and fol:
                c = contrib[(fol, col)]
                c[0] += 1
                c[1].add(r["Species"])

# ---- emit -------------------------------------------------------------------
COLS = ["paper", "column", "quantity", "basis", "state", "includes_olfactory_bulb",
        "includes_meninges", "includes_ventricles_csf", "poolable_group", "is_size",
        "role", "in_brain_mass_merge", "merge_rows", "merge_species",
        "definition_quoted", "definition_source", "basis_evidence", "basis_note",
        "basis_statement", "basis_statement_source"]
out = []
for (paper, col), v in sorted(ASSIGN.items()):
    (quantity, basis, state, ob, men, csf, grp, is_size, ev, dsrc) = v
    quoted = FOLDER_QUOTES.get((paper, col)) or cat_def.get((paper, col), "")
    n, sps = contrib.get((paper, col), (0, set()))
    out.append(dict(paper=paper, column=col, quantity=quantity, basis=basis, state=state,
                    includes_olfactory_bulb=ob, includes_meninges=men,
                    includes_ventricles_csf=csf, poolable_group=grp,
                    is_size="TRUE" if is_size else "FALSE",
                    role=cat_role.get((paper, col), ""),
                    in_brain_mass_merge="TRUE" if n else "FALSE",
                    merge_rows=n, merge_species=len(sps),
                    definition_quoted=quoted, definition_source=dsrc,
                    basis_evidence=ev, basis_note=BASIS_NOTES[basis],
                    basis_statement=SOURCE_STATEMENTS.get(paper, ("", ""))[0],
                    basis_statement_source=SOURCE_STATEMENTS.get(paper, ("", ""))[1]))
with open(os.path.join(HERE, "brain_size_basis.csv"), "w", newline="", encoding="utf-8") as fh:
    w = csv.DictWriter(fh, fieldnames=COLS)
    w.writeheader()
    w.writerows(out)

grp_n = defaultdict(lambda: [0, 0])
for r in out:
    g = grp_n[r["poolable_group"]]
    g[0] += 1
    g[1] += r["merge_rows"]
print(f"{len(out)} whole-brain-size columns across {len({r['paper'] for r in out})} papers",
      file=sys.stderr)
for g in sorted(grp_n):
    print(f"  {g:26s} {grp_n[g][0]:2d} columns, {grp_n[g][1]:5d} rows in the brain-mass merge",
          file=sys.stderr)
attributed = sum(r["merge_rows"] for r in out)
n_bmu = sum(1 for _ in csv.DictReader(open(bmu_path, newline="", encoding="utf-8")))
print(f"  attributed {attributed} of {n_bmu} brain-mass merge rows", file=sys.stderr)
missing = [r for r in out if r["in_brain_mass_merge"] == "TRUE" and not r["definition_quoted"]]
print(f"  merge contributors with no quoted definition: {len(missing)}"
      f" {[r['paper'] for r in missing]}", file=sys.stderr)
