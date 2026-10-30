# Jacobs et al. 2018 — gigantopyramidal (Betz) and M1 pyramidal neuron morphology

**⚠️ This folder replaces the `Betz_cells_M1/` scaffold. Corrected 2026-08-04.**

`Betz_cells_M1/` was a *compile-from-literature* placeholder built on the premise that "no single
comparative table of per-species Betz counts exists". That premise was wrong: **Jacobs et al. 2018 is
exactly that table**, and it was in the EndNote library with a PDF the whole time. The scaffold also
invented a source identity — `Betz_cells_M1_compilation`, `Team = Betz_compilation`,
`Betz_cells_M1_snapshot.xlsx` — for a paper that has a real author, year and DOI. All of that is gone;
this folder is a normal one-publication folder.

**"Betz cell" as anatomy is real and stays.** Vladimir Betz (1834–1894) described the giant layer-V
pyramids, and both Jacobs et al. 2018 and Nolan et al. 2024 use the term. What did not exist was a
*source* called "Betz". Jacobs calls the cell class **gigantopyramidal** across mammals and reserves
**Betz** for primates; this folder follows the paper's usage.

## Source

Jacobs, B., Garcia, M. E., Shea-Shumsky, N. B., Tennison, M. E., Schall, M., Saviano, M. S.,
Tummino, T. A., Bull, A. J., Driscoll, L. L., Raghanti, M. A., Lewandowski, A. H., Wicinski, B.,
Ki Chui, H., Bertelsen, M. F., Walsh, T., Bhagwandin, A., Spocter, M. A., Hof, P. R.,
Sherwood, C. C., & Manger, P. R. (2018). *Comparative morphology of gigantopyramidal neurons in
primary motor cortex across mammals.* **J Comp Neurol 526(3):496–536.**
DOI **10.1002/cne.24349** · PMID **29088505** · EndNote `[4950]`.

## What is built

| File | Contents |
|---|---|
| `Jacobs_etal_2018_Table3_snapshot.xlsx` + `_Table3.README.md` | **Unbiased stereology.** 20 species (11 carnivore + 9 primate), layer V pyramidal **and** gigantopyramidal soma length / area / volume, with body and brain mass |
| `Jacobs_etal_2018_Table5_snapshot.xlsx` + `_Table5.README.md` | **Golgi morphology.** 19 species / 7 orders × 3 neuron types (superficial layer III, deep layer V, gigantopyramidal), 617 traced neurons: soma size and depth, dendritic volume, length, segment length, segment count, spine number, spine density |
| `Jacobs_etal_2018_extract_snapshot.py` | the capture script (both tables print rotated 90°; no R in this environment) |
| `reference_tables/*_definitions.csv` | data dictionaries |

Both snapshots verified against statistics the paper states independently — the traced-neuron totals
(**617 = 233 superficial + 203 deep + 181 gigantopyramidal**), the feliform and primate mean soma
sizes (2,847 and 987 μm²), and the gigantopyramidal/pyramidal soma ratios (1.64 area, 2.30 volume) all
reproduce exactly. See the per-table READMEs.

## Regional M1 — never pooled with whole-cortex counts

These belong with `__merging_cellcounts` as a **regional (M1-only) sub-trait**, analogous to how
`M1_Surface_Area.mm2` sits apart from whole-cortex surface in `__merging_cortical_areas`
(`trait_class = regional`). They must **never** be pooled with whole-cortex neuron counts. Sits beside
`Young_etal_2013_Table1` (M1 cell count / surface area / mass) — checked 2026-08-04, no species or
measure collision with Young.

`neuron_class` must stay an explicit column. All three neuron types are measured in the same cortex of
the same animal; collapsing them would average a Betz cell with an ordinary layer III pyramid.
Stereology (Table 3) and Golgi 2-D tracing (Table 5) are **not interchangeable** — flag `method` per
datum, as the cellcount lineage does.

## Nolan et al. 2024 is the review entry point, not a data source

Nolan, M., Scott, C., Hof, P. R., & Ansorge, O. (2024). *Betz cells of the primary motor cortex.*
**J Comp Neurol 532(1), e25567.** DOI **10.1002/cne.25567** · PMID **38289193** · EndNote `[9629]`.
PDF filed here.

It is a narrative review with **no per-species quantitative table** — its three tables are Betz-cell
transcriptomic terminology, Betz-cell neuropathology by disease, and unanswered questions. Every
number is quoted from a primary. Cite it as the entry point in source notes, **never as the `Source`
of a datum** — and it demonstrably misquotes: it gives the feliform mean gigantopyramidal soma size as
**2874 μm²** where Jacobs Table 5 says **2,847 μm²** (a digit transposition; the built snapshot
reproduces 2,847 exactly from the four feliform values).

Values it quotes, and where each must be verified:

| Datum | Value as quoted | Primary |
|---|---|---|
| Human total Betz per hemisphere | 25,000–40,000 (early); **125,290** (mean of 6 brains, stereology) | Campbell 1904; Lassek 1940; Scheibel et al. 1977; **Rivara et al. 2003** |
| Human Betz as fraction of layer Vb | ≈ **10%** | **Rivara et al. 2003** |
| Human Betz soma size | 60 × 120 μm²; 53 × 106 μm²; cell-body volume 86,685 μm³ | Betz 1874; Brodmann 1909; Rivara et al. 2003 |
| Feliform vs primate soma | ~~2874~~ → **2,847 μm²** vs **987 μm²** | **Jacobs et al. 2018** ✅ verified here |
| *Panthera* soma volume | 12.25× other layer-V neurons | **Jacobs et al. 2018** |
| Upper-third-of-area-4 share | ~75% human vs **52%** macaque; arm region 20% vs 33% | Lassek 1940; Rivara et al. 2003 |
| Presence / absence | absent in rodents and wallaby; clusters ≤ 4 in giraffe and sheep; present in cetaceans | Jacobs et al. 2018 ✅; Ashwell et al. 2005; Badlangana et al. 2007; Ebinger 1975; Kojima 1951 |

The three human soma figures are **incommensurable stats** (2-D axes vs area vs volume) — do not
average them.

## Remaining primaries — EndNote audit (2026-08-04)

| Primary | What it adds beyond this folder | In EndNote |
|---|---|---|
| **Sherwood et al. 2003**, *Evolution of specialized pyramidal neurons in primate visual and motor cortex*, Brain Behav Evol 61(1):28–44, DOI 10.1159/000068879 | Stereological Betz + adjacent infragranular pyramidal soma volumes in **23 primates + 2 non-primates** (*Tupaia glis*, *Pteropus poliocephalus*) — far more primate species than Jacobs. Source of the kinkajou and patas-monkey outliers. **Caution:** also reports Meynert cells (V1) — different region, keep out of any M1 trait | ✅ `[5508]`, PDF |
| **Rivara et al. 2003**, *Stereologic characterization and spatial distribution patterns of Betz cells in the human primary motor cortex*, Anat Rec Part A 270(2):137–151, DOI 10.1002/ar.a.10015 | The entire human row — the 125,290 count, the ~10% layer-Vb proportion, the 86,685 μm³ soma volume | ❌ **absent** — needs sourcing |
| **Lassek & Wheatley 1945**, *The pyramidal tract. An enumeration of the large motor cells of area 4 and the axons in the pyramids of the chimpanzee*, J Comp Neurol 82:299–302 | An area-4 large-motor-cell **enumeration for chimpanzee** — a second species for a total-count trait. Not cited by Nolan | ✅ `[6767]`, PDF |
| **Nguyen et al. 2019**, *Comparative neocortical neuromorphology in felids*, J Comp Neurol | Lion / leopard / cheetah — the *Panthera* end of the feliform comparison | ✅ `[7780]`, PDF |
| Ashwell et al. 2005 (wallaby); Badlangana et al. 2007 (giraffe); Ebinger 1975 (sheep) | Presence/absence and cluster-size rows | ❌ absent |

Every row's `Source` must be the primary that measured the value, with `method` flagged.

## Open for the curator

Jacobs gives **soma morphology**, not **counts**. The human and chimpanzee *total Betz per hemisphere*
values (Rivara 2003; Lassek & Wheatley 1945) have no home in either definitions file — a count trait
(`Betz_count_M1`, total per hemisphere, `stat = point`, `method` flagged) would need adding.
**Not added — pending sign-off.**
