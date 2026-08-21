# Dos Santos et al. (2020) — authors' UNPUBLISHED data (USE THIS, not the published Table 1)

Dos Santos, S. E., et al. (2020). Similar Microglial Cell Densities across Brain Structures and
Mammalian Species. *J Neurosci* 40(24), 4622-4643. https://doi.org/10.1523/JNEUROSCI.2339-19.2020

## Why this exists / why it is used instead of the published Table 1

The published Table 1 (main PDF) contains transcription/typographical errors in several cell-count
values, some physically impossible (neurons or microglia exceeding total cells; e.g.
*Tragelaphus strepsiceros* whole-brain cells ~1000× too small). The authors supplied this updated
**unpublished** spreadsheet, which independent checks show is internally consistent and agrees with
older publications (e.g. Herculano-Houzel et al. 2015). It is therefore used **in place of the
published Table 1** in the merged cell-counts dataset.

- Checks (now in the private repo Evo-M1-Traits-Data-restricted, `restricted_checks/_cross_table/DosSantos_2020_published_vs_authors_unpublished/`): `DosSantos_etal_2020_Table1_check.R` (systematic published-vs-unpublished comparison +
  internal-consistency scan + broader cross-check against other HH-team papers).
- Reports (same folder there): `DosSantos_etal_2020_comparison_report.csv` (published vs unpublished),
  `DosSantos_etal_2020_crosssource_check.csv` (vs other papers); summary `DosSantos_etal_2020_comparison_summary.md`.
- **Broader validation:** for the 32 DS2020 species also reported in Herculano-Houzel et al. 2015
  (afrotherians/artiodactyls/primates), Dos Santos et al. 2017 (marsupials) and Jardim-Messeder et al.
  2017 (carnivores), the unpublished whole-brain and cerebellum neuron/cell counts match those
  independent papers almost exactly (median difference 0%), and they resolve the published typos
  (e.g. *Procavia* cerebellum, *Tragelaphus* whole brain). The unpublished data is the same underlying
  data as the rest of the HH-team corpus.

## Source / provenance

Raw unpublished spreadsheet `2020-PublishedDataMammalsMicroglia - cópia.xlsx` — held in the private repo Evo-M1-Traits-Data-restricted, `unpublished_data/____Unpublished__DosSantos_microglia_2024/`, because it is the authors' unpublished data. The build reaches it via `_helpers/restricted_data.R`. Received by email:

- From: Alex W. Tikky \<alex.tikky@gmail.com\>, Fri 22 Mar 2024 — to Orlin S. Todorov \<tdrvorlin@gmail.com\>
- Forwarded: Orlin S. Todorov → Alexandra de Sousa \<alexandraallisonsousa@gmail.com\>, 21 Mar 2024

## Pipeline

**Data readable.** Fixed formatting in R; summarised the raw per-section rows to one value per
animal × structure; extracted the **microglia/cell ratio (I/C = `%Iba1+`)** per structure and pivoted
wide → `DosSantos_etal_2020_unpublished.csv` (**USE THIS**).

**What it contributes to the merge.** The microglia/cell ratio (standardised as `*_I.p.C`), which is the
unpublished file's unique, reliable measure. Cell **numbers** (C, N, I) for these species come from older
primary sources already in the merge (e.g. Herculano-Houzel et al. 2015), not from this paper's Table 1.

**Online database.** TSV copy named with DOI added to https://github.com/r03ert0/comparative-data
(`10.1523%2FJNEUROSCI.2339-19.2020%0A_unpublished.tsv`).
