# Pirlot & Kamiya 1985 — Table 1 (percentage composition of the Dugong brain)

Pirlot P, Kamiya T (1985). *Qualitative and quantitative brain morphology in the Sirenian
Dugong dugong Erxl.* Z Zool Syst Evolutionforsch 23(2):147–155.

## What this covers

Table 1 reports the volumetric composition of a single *Dugong dugong* (Sirenian) brain: absolute
volume (mm³), percentage of total brain, and — for the five telencephalic components only —
percentage of telencephalon, for 9 brain components (neocortex, rhinencephalon, septum,
diencephalon, striatum, hippocampus, mesencephalon, cerebellum, medulla oblongata). This is a
single specimen (n=1), the same as the companion Kamiya & Pirlot papers on other taxa
(`Kamiya_Pirlot_1980`, `Kamiya_Pirlot_1988`).

## Source → snapshot → CSV

- **Source:** `pirlot_kamiya_1985.pdf`, in this folder. The PDF's OCR text layer is essentially
  unusable (garbled to the point of no recognizable words in most paragraphs), so **the entire
  table was transcribed from a 200 dpi page-image render** (page 4 of 9, printed page 150).
- **Snapshot:** `Pirlot_Kamiya_1985_Table1_snapshot.csv` — journal-faithful layout, preserving the
  printed `-` for non-telencephalic components' `% telencephalon` cells.
- **Analysis CSV:** `Pirlot_Kamiya_1985_Table1.csv` — long format, one row per brain component,
  with `pct_of_telencephalon` left blank for the four non-telencephalic components rather than
  encoding the printed `-` as zero.

## Verification

- The 9 component volumes sum exactly to the printed total: 223002.14 mm³.
- The 9 `pct_of_total_brain` values sum exactly to 100.00.
- The 5 telencephalic `pct_of_telencephalon` values (N, RH, S, St, H) sum exactly to 100.00.

## Not registered as a separate item

The paper's **Table 2** ("Progression indices in the dugong and the dolphin") gives Stephan-method
progression indices for *Dugong* alongside comparison figures for *Platanista* — but the
*Platanista* column is not new data from this paper; it is copied from Kamiya & Pirlot (1980),
a different registry item. The *Dugong* progression indices are themselves derived from Table 1's
volumes (via the basal-insectivore reference method), not an independent measurement. Consistent
with this registry's convention (see `Pirlot_Kamiya_1982` for the identical situation), Table 2 is
kept as a reference-only file in `reference_tables/`, not a separate `__ReadMe.xlsx` Item. **Table 3**
(a few examples of encephalization indices for ungulates/cetaceans, pulled from the literature for
context) is likewise not this paper's own data and is not transcribed.
