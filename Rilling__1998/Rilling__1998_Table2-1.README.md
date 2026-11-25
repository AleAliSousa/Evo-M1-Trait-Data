# Rilling 1998 dissertation, Table 2-1

## Source and scope

James Kelly Rilling, *Comparative Neuroanatomy of Anthropoid Primates Using Magnetic Resonance Imaging: insights into human and non-human primate brain evolution* (Emory University PhD dissertation, **1998**, UMI 9901872). The title page dates the dissertation to 1998; a 1996 source for this table was not found. Local source: `rilling.pdf`, PDF page 95 (Table 2-1, following printed page 69). The table gives a roster of 44 living MRI subjects from 11 anthropoid species. The scientific names used in the analysis file come from the dissertation's Subjects paragraph (printed page 32); the table's common labels remain in `species_as_published`.

The local PDF is byte-identical to the attachment in the user's EndNote library (`References.Data/PDF/3492077144/rilling.pdf`). The EndNote record for this dissertation is dated 1998 (record 8007); no Rilling 1996 record with this title was found.

## Files and build

- `Rilling__1998_Table2-1_snapshot.csv` is a frozen hand transcription of the seven printed columns in source order. OCR was used only to locate the page; the values were checked against the rendered PDF page. Printed strings such as `55.4 (6/14)`, `20.6 (8/19)`, and `9.4 (6/26)` are deliberately retained without guessing missing year digits.
- `Rilling__1998_Table2-1.R` reads that snapshot and writes the analysis CSV and `__Public/comparative-data/UMI9901872_Table2-1.tsv`. Run from the repository root with `Rscript Rilling__1998/Rilling__1998_Table2-1.R`.
- `reference_tables/Rilling__1998_Table2-1_definitions.csv` defines the output columns. Body mass is converted from kg to g. Dates are kept as printed strings; no date repair or age recalculation is applied.
- `reference_tables/Rilling__1998_Table2-1_identity_links.csv` records candidate specimen links to the existing MacLeod et al. 2003 Yerkes MRI individual table. `reference_tables/Rilling__1998_Table2-1_cohort_comparison.csv` compares the roster's counts and mean body mass with Rilling & Insel 1998 and 1999 Table 1. These are provenance aids, not extra data items or independent cohorts.

## Cross-paper interpretation

Rilling & Insel 1998 and 1999 both report 44 subjects from 11 species, but their tables publish **species means rather than subject identifiers**. The dissertation roster is therefore a cohort-level candidate for those articles, not a printed one-to-one article crosswalk. MacLeod et al. 2003 Table 1 names Yerkes MRI subjects and provides individual brain volumes: 36 dissertation subjects match its name/code directly, seven links are probable (six anonymized humans matched through the unique sex and brain-volume sequence in dissertation Table 5-1, plus `Bosanjo`/`Bosandjo`), and `RJe-1` is unmatched. The human volume matches are useful but do not turn MacLeod's numbered labels into proven institutional accessions. `Sunny (734 I)` is linked to MacLeod's *Sunny* by name; it is **not** equated with Schenker's distinct `736_IL` code. Pre-split *Pongo pygmaeus* remains a broad taxon concept.

The cohort comparison shows important source inconsistencies. Table 2-1 prints 27 males and 17 females, whereas the dissertation's Subjects summary says 26 and 18. Its rhesus rows are 3M/1F, while both journal Table 1s say 2M/2F; the 1999 journal table also says 2M/2F for mangabeys against Table 2-1's 3M/1F. The 1998 article's gorilla and mangabey body-weight means and brain-volume means differ from the 1999 article and the roster-derived body means. These differences are preserved; they prevent asserting that every article measurement belongs to a specific Table 2-1 subject.

Dissertation Table 5-1 is useful for the six human brain-volume fingerprints, but its lower rows visibly shift macaque and mangabey values under later species labels and omit most squirrel-monkey values. It was **not** ingested as a volume dataset or used to repair Table 2-1. A separate source review is needed before building Table 5-1.

## Checks

The snapshot has 44 unique subject labels and 11 source taxon labels; the R script checks 27M/17F and parses all printed body-weight numbers. The frozen snapshot was compared by AI with the PDF page on 2026-11-24. Human visual signoff remains pending. No figure-derived data were added, so no figure replot is required.
