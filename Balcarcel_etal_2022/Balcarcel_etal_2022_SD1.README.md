# Balcarcel et al. 2022 — SD1 (cranial measurements and endocranial volume estimates, 253 specimens)

Balcarcel AM, Geiger M, Clauss M, Sánchez-Villagra MR (2022). *The
mammalian brain under domestication: Discovering patterns after a
century of old and new analyses.* Journal of Experimental Zoology
Part B 338: 460–483. doi:10.1002/jez.b.23105

**SD1 ("Main data")** — the authors' own cranial measurements of
**253 museum specimens**: South American camelids (*Lama guanicoe*
86, *Lama glama* 18, *Vicugna vicugna* 21, *Vicugna pacos* 14), pigs
(*Sus scrofa* 29, *Sus domesticus* 22) and goats (*Capra aegagrus*
22, *Capra aegagrus hircus* 41); 158 wild and 95 domestic specimens.
Columns: braincase length / width / height, foramen magnum breadth
and full skull length (all mm), and **log10(EV)**, the log10
endocranial volume estimated from the braincase dimensions.

## Source → Snapshot → Data readable → Online database

- **Source:** the publisher's supplementary file
  `jezb23105-sup-0001-sd1_data_for_cams_pigs_goats.xlsx` (Wiley,
  supporting information for doi:10.1002/jez.b.23105).
- **Snapshot:** none — the file is digital-native. It is kept verbatim
  in this folder under its original name, is listed in the registry
  (the item's "Snapshot filename" field in `__ReadMe.xlsx`), and the
  build script reads it directly. Nothing was re-saved or converted.
- **Data readable:** `Balcarcel_etal_2022_SD1.R` reads **only** that
  file (the measurements are stored as text in it and are typed by
  the script), names the sheet's unheaded museum-name column, adds
  `species_sci` (printed Genus + species), and writes
  `Balcarcel_etal_2022_SD1.csv` (253 rows) and the public TSV.
- **Definitions:** `reference_tables/Balcarcel_etal_2022_SD1_definitions.csv`.
- **Online database:** public TSV `10.1002%2Fjez.b.23105_SD1.tsv` in
  `__Public/comparative-data/`; registry row in `__ReadMe.xlsx`
  (Item name `Balcarcel_etal_2022_SD1`).

## Table checks

SD3 states the model behind the printed log10(EV): ln(EV) = −6.1834
− 0.384·ln(BCH) + 1.3182·ln(BCL) + 1.4892·ln(BCW) (Finarelli 2011,
all-artiodactyl model), converted to log10. The reader recomputes it
from the printed dimensions for all 253 specimens (build HOWTO §7a):
**all 253 pass** within a tolerance of 5×10⁻⁴ in log10 (largest
difference 2.3×10⁻⁴ — the printed dimensions are rounded, the authors
computed from unrounded values). Nothing was adjusted to make a
check pass.

## Data role and caveats

- **Primary.** The linear measurements are the authors' own
  measurements of the specimens (landmarks as defined in Balcarcel
  et al. 2021, *Journal of Mammalogy* 102:220–235; see SD2 Figure S1,
  kept in this folder). log10(EV) is the authors' model estimate from
  those measurements — an estimate, not a measured volume — and is
  flagged `derived` in the definitions.
- SD3's ANCOVA sample sizes differ slightly from SD1's row counts
  (guanaco 83 vs 86 rows; alpaca 13 vs 14; bezoar 23 vs 22): the
  analyses evidently used subsets. SD1 as published is the item here.
- Names as printed: the domestic pig is printed as *Sus domesticus*
  and the domestic goat as *Capra aegagrus hircus*; both are kept
  verbatim in `species_sci`.
- This dataset is the modern counterpart of the historical camelid
  material in `Kruska__1980` (whose specimens Balcarcel et al. 2021
  also re-compiled): Kruska's are brain-part volumes from serial
  sections; these are cranial measurements with modelled endocranial
  volumes. The two are complementary, not duplicates.
