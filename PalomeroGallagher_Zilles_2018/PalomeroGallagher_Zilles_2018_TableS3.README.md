# PalomeroGallagher_Zilles_2018 — GLI, Broca-homolog areas 44/45 (Supplementary Table S3)

## What this item is
Palomero-Gallagher & Zilles (2018) quantify layer-specific **grey level index (GLI)** — the
volume fraction of cell bodies + neuropil in a cytoarchitectonic layer, a stain-density measure —
in areas 44 and 45 (Broca-region homologs) of human, bonobo, chimpanzee, gorilla, orangutan,
gibbon, and macaque brains.

An earlier pass of this build attempted to digitize the values from the paper's summary bar chart
(Fig. 12) because the numeric supplementary tables referenced in the text (S1-S3) were believed
unavailable (not in the PDF, no PMC/Unpaywall/TDM copy found). That figure-digitized version has
been **replaced**: the journal's own supplementary Excel file
(`1-s2.0-S0010945218302958-mmc1.xlsx`, Elsevier "mmc1" naming for the Cortex article) was already
present in this folder and contains the exact numbers.

## Source (digital-native, frozen as-is)
`1-s2.0-S0010945218302958-mmc1.xlsx` has three sheets: Table S1 (GLI depth-profiles, area 44, Fig.
10), Table S2 (GLI depth-profiles, area 45, Fig. 11), and **Table S3** (per-specimen mean GLI over
all layers and by cortical stratum — supragranular/granular/infragranular — for areas 44 and 45;
"Data pertaining figure 12"). This build uses **Table S3** only, matching the original build scope
(species x area x stratum summary GLI). Per house rule for digital-native sources, the untouched
download is copy-renamed to `PalomeroGallagher_Zilles_2018_TableS3_snapshot.xlsx` (md5-verified
byte-identical) and never edited; the reformat script reads the "Table S3" sheet directly.

Tables S1/S2 (full depth profiles, ~105 depth points x specimen x area) are not built here — they
are a different granularity (continuous cortical-depth profile vs. per-stratum summary) and are
left for a future item if the profile-level data are needed.

## Granularity
Table S3 is already **per specimen**: human contributes 4 named specimens (B01, B06, B07, B10),
macaque contributes 2-3 (labelled "macaque 1/2/3"), and bonobo/chimpanzee/gorilla/orangutan/gibbon
are each a single specimen. No within-species averaging is performed in this build — species-level
means, if wanted, belong in the merge step.

## Data role
`data_role = primary` — this is the paper's own measured data, not a compiled or approximated
value.

## Cross-paper GLI context (not merged here)
The paper's Fig. 15 compares its own area-44/45 GLI against GLI reported elsewhere for other
areas: area 10 (Semendeferi et al. 2001), V1/V2 (de Sousa et al. 2010), area 13 (Semendeferi et
al. 1998), and area 4/M1 (Sherwood et al. 2004, plus this paper's own gibbon/bonobo data). Checked
against this repo: `Sherwood_etal_2004`, `deSousa_etal_2010`, `Semendeferi_etal_1998`, and
`Semendeferi_etal_2001` are already built here, but only for **volumetric** measures — none of
those built items carries a GLI column. A cross-source GLI reconciliation would require a further
extraction pass on each of those four papers; `__merging_GLI` is therefore founded on this item
alone (see its README).

## Source
`1-s2.0-S0010945218302958-mmc1.xlsx`, sheet "Table S3" ("Mean GLI ... over all cortical layers, as
well as in the supragranular, granular and infragranular strata of areas 44 and 45. Data
pertaining figure 12").
