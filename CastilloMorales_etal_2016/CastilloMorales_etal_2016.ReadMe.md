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

Build: `CastilloMorales_etal_2016_Table1.R` transcribes Table 1 to
`CastilloMorales_etal_2016_Table1.csv` and to the DOI-coded public TSV.
See `CastilloMorales_etal_2016_Table1.README.md` for the data role
(secondary compilation), caveats, checks, and the registry step that is
still pending.

Quality Notes:

1. Every row's `Source` names the publication the authors compiled the
   volumes from (paper refs 84–99). 14 of the 16 sources are already
   Evo-M1 folders, so most rows can be checked directly against the
   primary compilations. Not in the repo when this item was built:
   Beatty_Laughlin_2006 (mouse), Roehrs__1986 (ferret), Kruska__1980
   (alpaca); the Ei values rest on Gonzalez-Lagos et al. 2010 (ref 83),
   also not in the repo.

2. Suspected misprint in the source table: the dog row (Schleifenbaum
   1973) prints brain volume 458.273 cm3 and neocortex 177.753 cm3 for a
   poodle — both look 10x too large (Evo-M1's merged total for
   Canis lupus familiaris is 46.6 cm3). Nr (0.63) is unaffected because
   the factor cancels. Transcribed as printed; flagged here, not fixed.

3. Folder added 2026-11-18 by Muse (Buddy), Michael Proulx's AI
   assistant, at Michael Proulx's request; registry row in `__ReadMe.xlsx`
   and any merge ingestion remain owner steps.
