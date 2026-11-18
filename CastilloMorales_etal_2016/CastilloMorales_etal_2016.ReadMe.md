Source

1. Go to Source: Article (Open Access, CC BY 4.0)
https://doi.org/10.1098/rsob.160132

2. The trait data are Table 1 of the paper itself (p. 3): brain volume,
neocortex volume, volume source (refs 84–99), neocortex ratio Nr,
encephalization index Ei and maximum lifespan for the 28 mammalian species
analysed. The publisher PDF is kept verbatim in this folder as the frozen
source (Castillo-Morales-2016-Neocortex_expansion.pdf, downloaded from
rsob.royalsocietypublishing.org).

3. The paper's only supplementary file is the gene-family results table,
hosted on figshare (doi:10.6084/m9.figshare.c.3489039), kept verbatim here
as rsob160132_si_001.csv. It contains NO trait data — Table 1 of the paper
is the trait source.

--> USE THIS FILE: Castillo-Morales-2016-Neocortex_expansion.pdf (Table 1)

Build: Table 1 was transcribed exactly as printed into the frozen
snapshot `CastilloMorales_etal_2016_Table1_snapshot.csv` before any
cleaning; `CastilloMorales_etal_2016_Table1.R` reads only that snapshot
and writes `CastilloMorales_etal_2016_Table1.csv` and the DOI-coded
public TSV. See `CastilloMorales_etal_2016_Table1.README.md` for the
data role (secondary compilation), caveats and table checks. Registry
row in `__ReadMe.xlsx` added 2026-11-18.

Quality Notes:

1. Every row's `Source` names the publication the authors compiled the
   volumes from (paper refs 84–99, itemised in
   `reference_tables/CastilloMorales_etal_2016_Table1_references.csv`).
   14 of the 16 sources are already Evo-M1 folders, so most rows can be
   checked directly against the primary compilations. The remaining
   sources were added to the repo on 2026-11-18: Beatty_Laughlin_2006
   (mouse), Roehrs__1986 (ferret), Kruska__1980 (alpaca); the Ei values
   rest on Gonzalez-Lagos et al. 2010 (ref 83) — see the
   GonzalezLagos_etal_2010 folder.

2. Suspected misprint in the source table: the dog row (Schleifenbaum
   1973) prints brain volume 458.273 cm3 and neocortex 177.753 cm3 for a
   poodle — both look 10x too large (Evo-M1's merged total for
   Canis lupus familiaris is 46.6 cm3). Nr (0.63) is unaffected because
   the factor cancels. Transcribed as printed; recorded as erratum
   CastilloMorales_etal_2016-E001 (proposed), not fixed.

3. Folder added 2026-11-18 by Muse (Buddy), Michael Proulx's AI
   assistant, at Michael Proulx's request; rebuilt to the snapshot-first
   form in `_skills/build-dataset-item` the same day.
