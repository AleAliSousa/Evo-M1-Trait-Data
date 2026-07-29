# Smaers & Soligo 2013 — not built (no new extractable data table)

Smaers JB, Soligo C (2013). *Brain reorganization, not relative brain size, primarily characterizes
anthropoid brain evolution.* Proc. R. Soc. B 280:20130269. doi:10.1098/rspb.2013.0269.

## Decision: documented skip (like Weaver 2005) — no data files produced.

The main PDF in the folder is only an eLetter; the data lives in the three supplements, none of which
yields a raw, primary trait table:

1. **ESM 1** (`rspb20130269supp1.pdf`) — **principal-component scores** (PC1–PC4) per species plus
   eigenvalues. These are **derived** multivariate outputs, which per
   `__HOWTO_build_a_dataset_file.md` §7 are not transcribed (recomputed downstream, not captured).

2. **ESM 2** (`rspb20130269supp2.pdf`) — figures only (no tabular data; the extract is just
   download-watermark text).

3. **ESM 3** (`rspb20130269supp3.pdf`) — methods + the **sample description** (N=34 individuals from
   the C.&O. Vogt Institute / Düsseldorf collection, listed with collection numbers), then the
   reference list. The **raw structure volumes are not tabulated here** — the text states the brain
   data were "collected from the literature [1–7]", namely Smaers 2011, Smaers/Steele 2010/2012,
   Zilles 2011, **Stephan et al. 1981**, and **Frahm et al. 1982**. Stephan 1981 and Frahm 1982 are
   **already built in this repo**; the Düsseldorf collection is the same one behind MacLeod 2003 /
   Smaers 2011.

So there is no new primary table to build: the values are either derived (PCA) or drawn from sources
already represented. Building it would duplicate existing Düsseldorf-collection data.

## If the motor-cortex delineation is ever wanted
Smaers' bootstrap "frontal motor cortex" gray/white L/R volumes are methodologically distinctive, but
the supplements report only PCA scores over them, not the raw per-species volumes — so they are not
faithfully extractable from this paper. The underlying volumes would have to come from the Smaers
2011 / Zilles sources directly.
