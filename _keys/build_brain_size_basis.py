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
import csv, glob, os, re, sys
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
    # ---- weighed mass, nothing further stated -----------------------------
    ("Stephan_etal_1970", "brain_weight_mg"): A,
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
    ("Manger__2006", "brain_mass_g"): A,
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
    # ---- mass and volume mixed, unresolvable per row ----------------------
    ("Burger_etal_2019", "Mean_brain_mass_g"):
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
}

# quoted inclusion evidence that lives in a FOLDER definitions file rather than
# in variable_catalog.csv, so the key can cite the exact wording
FOLDER_QUOTES = {
    ("Burger_etal_2019", "Mean_brain_mass_g"):
        "Mean brain mass -- compilation; 1 g = 1 cm3 conversion used when volumes reported "
        "(per source methods)",
    ("HerculanoHouzel_etal_2015", "Brain mass, g"):
        "whole brain (both sides), NOT including the olfactory bulbs "
        "[Herculano-Houzel whole-brain definition, per AvelinodeSouza_etal_2025 definitions]",
    ("AvelinodeSouza_etal_2025", "Whole brain_Mass, g"):
        "whole brain (both sides), NOT including the olfactory bulbs",
    ("Kverkova_etal_2018", "Brain_Mass.g"):
        "Whole brain; appx. sum of 14 structures incl Olfactory bulbs",
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
    ("Weaver__2001", "Brain_Mass.mg"):
        ("mass", "mass_from_volume_or_ecv", "derived", "unknown", "unknown", "unknown",
         "mass_from_volume_or_ecv", True, "quoted", F),
    ("Changizi_Shimojo_2005", "brain_mass_g"):
        ("mass", "mass_compilation_unspecified", "unknown", "unknown", "unknown",
         "unknown", "mass_measured", True, "quoted", P),
    ("Manger__2006", "brain_mass_g"):
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
}
ASSIGN.update(RESOLVED)

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
           "_sd", " sd", ": data", "%", "index", "relative"]


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


file_col = {}
for p in glob.glob(os.path.join(PUB, "*.tsv")):
    with open(p, encoding="utf-8", errors="replace") as fh:
        hdr = [h.strip('"') for h in fh.readline().rstrip("\n").split("\t")]
    c = pick_column(hdr)
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
