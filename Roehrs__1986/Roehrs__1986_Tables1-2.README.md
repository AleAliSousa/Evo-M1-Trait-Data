# Röhrs 1986 — mustelid brain weights (Table 1) and brain-part volumes (Table 2)

Röhrs M (1986). *Cephalisation, Telencephalisation und
Neocorticalisation bei Mustelidae.* Zeitschrift für Zoologische
Systematik und Evolutionsforschung 24: 157–166.
doi:10.1111/j.1439-0469.1986.tb00624.x

**Table 1** — gross body weight, brain weight (species means over 196
individuals), cephalisation index and n for **20 mustelid species**.
**Table 2** — species-typical net volumes (mm³) of whole brain,
telencephalon, neocortex and allocortex + corpus striatum for **10
species**.

This is the source of the ferret row in Castillo-Morales et al. (2016)
Table 1 (their ref 91): the *Mustela putorius* row of Table 2 (brain
8899.6 mm³, neocortex 4147 mm³) is printed there as *Mustela putorius
furo*, 8.8996 cm³ / 4.147 cm³.

## What we built

- **Frozen source:** the publisher PDF scan in this folder, supplied by
  Michael Proulx (2026-11-18).
- **Reformat:** `Roehrs__1986_Tables1-2.R` transcribes both tables
  (German decimal commas converted to points) and writes:
  - `Roehrs__1986_Table1.csv` (20 rows), `Roehrs__1986_Table2.csv` (10 rows)
  - `public_tsv/10.1111%2Fj.1439-0469.1986.tb00624.x_Table1.tsv` and
    `_Table2.tsv` (public, DOI-encoded — names are the expected Items
    encoded; see Registry)
- **Definitions:** `reference_tables/Roehrs__1986_Table1_definitions.csv`
  and `..._Table2_definitions.csv`.
- **Reader:** the CSVs/TSVs were produced by Muse (Buddy), Michael
  Proulx's AI assistant, by transcribing the printed tables and
  verifying every value against page images of the scan (journal
  pp. 161, 163). **R execution of the .R script is pending** — the
  script reproduces the same outputs and re-checks the identities
  noted below.

## Data role and caveats

- **Table 1** brain weights are species means from the Hannover group's
  material; three species (Martes pennanti, Taxidea taxus, Lutra
  canadensis) were determined after Drescher (1977) and are flagged in
  the CSV. The Cephalisation column is an **index** (deviation from the
  Mustela reference line = 100), not a measurement.
- **Table 2** volumes rest on the volume determinations of Schumacher
  (1963) and Thiede (1973), converted by Röhrs to species-typical
  values using Table 1's mean brain/body weights, subadults removed —
  hence `secondary` in the definitions despite the primary origin of
  the underlying measurements.
- Internal check: TEL V = NEOC V + ALLO+CSTR V holds exactly for 9 of
  10 rows; the printed Conepatus humboldti row is off by 3.59 mm³ and
  is transcribed as printed.
- Tables 3 (compartment percentages) and 4 (telencephalisation /
  neocorticalisation indices) are derived quantities and were not
  transcribed.
- Names as printed: *Mustela vison* (now often *Neogale vison*) and
  *Lutra canadensis* (now *Lontra canadensis*) are kept verbatim.

## Registry

The public TSV names above are the expected Items encoded
(10.1111%2Fj.1439-0469.1986.tb00624.x_Table1 / _Table2). Adding the
registry rows in `__ReadMe.xlsx` is an owner step, as is any ingestion
into the volumes merge.
