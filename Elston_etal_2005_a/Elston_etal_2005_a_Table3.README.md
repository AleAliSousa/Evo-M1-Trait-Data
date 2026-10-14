# Elston_etal_2005_a_Table3 — prepared Table 3 package

**Prepared only. R is absent: NOT RUN R. Public TSV withheld; no shared repository upload, registry/key/merge edit, or FINISHED claim.**

## Confirmed publication and source identity

Elston, G. N., Benavides-Piccione, R., Elston, A., DeFelipe, J., & Manger, P. R. (2005). Specialization in pyramidal cell structure in the sensory-motor cortex of the vervet monkey (Cercopethicus pygerythrus). *Neuroscience, 134*, 1057–1068. https://doi.org/10.1016/j.neuroscience.2005.04.054

The printed title is **SPECIALIZATION IN PYRAMIDAL CELL STRUCTURE IN THE SENSORY-MOTOR CORTEX OF THE VERVET MONKEY (CERCOPETHICUS PYGERYTHRUS)**. The confirmed source, `Elston-2005-Specialization in pyramidal cell s.pdf`, is currently held in the misfiled **Elston_etal_2005_b** source folder. The PDF currently in **Elston_etal_2005_a** is instead the chacma-baboon article, DOI 10.1002/ar.a.20217. Neither original has been moved or changed. Use printed article identity, not the source-folder suffix. No source PDFs or page renders accompany this package.

The exact existing registry item is `Elston_etal_2005_a_Table3`, but its citation, resolved DOI and Item encoded currently use **.056**, not the printed **.054**. All six a rows need **owner-only citation proposals** to .054; column C stays blank/default. No registry correction is applied here. Generated B/E:L and human-curation fields must not be overwritten/cleared. Do not export under the stale .056 code. Public release remains held for owner source-placement/identity review and actual R validation, even if the owner later corrects the registry.

## Frozen evidence versus analysis preview

- `Elston_etal_2005_a_Table3_snapshot.csv`: the printed Table 3, p.1064 (PDF page 8), in its **six stacked published panels**, VM1 then VM2; each case has three panels, each retains area rows 7, 5, 1/2, 4, 6 and ten distance columns. Caption, μm bounds, original decimal strings, ±SEM and standalone zeros are preserved. Multiline distance headings stay multiline. This is not a flattened long analysis dataframe.
- CSV cannot store a font weight: a clearly labelled nonprinted annotation explains that `**mean**` marks only the mean characters actually bold in the PDF. The ± and SEM are not bold, as in the page. Ten markers were recovered from actual ArialMT-Bold glyphs and checked on the rendered page, **not inferred from numerical maxima**. Any peak ties remain evidence, not a trigger to add formatting.
- `Elston_etal_2005_a_Table3.R`: self-locating reader; reads the frozen CSV and item context, strips explicit bold markers, reshapes panels, parses mean and SEM, retains literal cell strings/bounds/order and converts contextual kg to g. It never regenerates the frozen table or embeds its numerical cells.
- `Elston_etal_2005_a_Table3.csv`: **Python-generated numerical analysis preview**, 300 rows × 27 columns. It is not R-executed output, a public TSV or proof of a completed repository build.
- `reference_tables/Elston_etal_2005_a_Table3_context_snapshot.csv`: 10 join-ready case-area records constructed from source methods/Results and the Table 4 note, **not printed in Table 3**. Join many-to-one on `Reference + Case + Cortical_area_as_published`.
- `reference_tables/Elston_etal_2005_a_Table3_definitions.csv`: exact ten-column schema, one definition for every analysis column plus explicit method/observation notes. Metadata Measure fields are blank.

Snapshot transcription/extraction by GitHub Copilot on 2026-10-10 from the actual PDF text layer with typographic glyph inspection; verified by the AI against the actual rendered page, the supplied text aid, and 300 coordinate-backed literal-cell checks. This is AI source checking, **not human visual curation**. A private full verification manifest is retained separately; no audit code, private JSON, scratch paths or source images are scientific-package dependencies.

## Measurement and sampling scope

The table gives **spines per 10 μm basal-dendritic segment**, by distance from the cell body to distal tips, **mean±SEM**. It is not spines/mm² cortex, a tissue-volume density or whole-neuron spine count. Distance bins are exactly 0–10, 11–20, … 291–300 μm. No interpolation, summing to whole-neuron estimates, cortical-surface conversion or hemisphere doubling is performed.

There are **two adult male vervet monkeys**, VM1 (6.1 kg) and VM2 (5.6 kg), with tissue sampled from the **left hemisphere, layer III**. Source Tissue preparation is pp.1057–1058 (PDF1–2); Morphological analyses pp.1059–1060 (PDF3–4). Flat-mounted, paraformaldehyde-fixed tangential 250 μm sections were intracellularly filled with Lucifer Yellow and processed to DAB; morphology was reconstructed in two dimensions. Spines were drawn using ×100 oil immersion (NA1.25). Only spiny cells with an unambiguous apical dendrite were analysed; only dendrites issuing from the soma were reconstructed and **apical collaterals were excluded**. This item has no apical-collateral data.

Methods state **20 horizontally-projecting dendrites of different neurones in each cortical area**. This is a **study-method quantity**, not an established count of 20 per case. Results p.1060 report data according to the animal from which sampled, and Table 3 explicitly labels its panels VM1/VM2; however, the assignment of those 20 method dendrites to cases/panels is **not stated**. Do not assume 20 PER CASE. Table 3 does **not** print case-area sample n or distance-bin contributor n, and the method sentence does not establish complete 20-dendrite coverage at every distance or distal endpoint. Keep case allocation of the protocol count and endpoint contributor n unknown. Do not assign biological n=20/300, populate endpoint n=20, infer n from SEM, or convert SEM to SD. The 300 records are case × area × distance-bin published summaries, **not 300 animals or independent observations**.

A separate printed technical-cell-count inconsistency is retained: Table 1 cell n sum to **274**, whereas Table 5 cell n sum to **273** and Results print **273** analysed cells. Specifically, VM2 area 6 has **n=41 in Table 1** but **n=40 in Table 5**. These are technical cell samples, not independent animal n, nor Table 3 spine-bin contributor counts. No printed value is repaired or borrowed as an endpoint denominator.

The combined label **1/2** is retained. The Table 4 note on p.1064 says VM1 was sampled more anteriorly, probably area 1; VM2 more posteriorly, probably area 2. This is a caveat, not a definitive anatomical crosswalk. Methods call the table's area 7 sampling area 7b; the printed 7 is not silently relabelled. The sampled representation was likely hindlimb, not definitively established.

Methods print **Cercopithecus pygerythrus**; the title prints the genus typo **Cercopethicus** (uppercase in the title). Both historical spellings survive with provenance. Accepted taxonomy is pending the appropriate collection key; no inline mapping or shared taxonomy edit is supplied. Primary source status does not authorize automatic pooling or merge entry.

## Literal and numerical checks

All **300 printed cell strings** match the source, including their original decimal precision. There are **199 mean±SEM cells** and **101 literal standalone zeros**. Every standalone zero remains numeric mean 0 with **missing/unspecified SEM**, never fabricated zero uncertainty. There are no blank published measurement cells in Table 3; no zero is reclassified as missing or as proof no dendrite reached that bin. Every case/panel/area/bin sequence and bound, all 199 SEM strings, all 101 zeros and all ten actual bold mean markers were checked. The long preview has 300 unique case-area-bin keys and no generated index column. Context joins resolve once per record.

Python source/numerical checks and static R review passed for this preparation. **NOT RUN R**: no R parse, clean-session run, R package check, canonical audit/dry-run/build/validation or executed CSV/TSV parity claim. The original folder wrapper's first-file behavior cannot validate every item; a later R-enabled check must execute this exact saved Table3 reader and validate its explicit outputs.

## Later owner/R-enabled operation — not performed here

Place this item-scoped package in the correct publication folder in a private complete repository copy; reconcile originals/registry identity as an owner operation without deleting sources. Use a clean R session with the exact script, not a first-file wrapper. The reader inspects `source()` frame `ofile` **and** `sys.source()` frame `file` before the wrapper `--file` fallback, and uses `utils::` CSV/TSV I/O for a `baseenv()` parent.

By default it writes only the local analysis CSV. It resolves the current registry row by its own filename-derived `item_name` and reads the **actual Item encoded**, never a cached row position. Missing/mismatching registry identity leaves public export withheld. An explicitly requested export additionally requires `options(evom1.publish=TRUE, evom1.owner_source_review=TRUE, evom1.R_validated=TRUE)` after those real reviews; these flags do not themselves constitute validation. The fresh exact-name lookup must match once, citation DOI and resolved DOI must equal the printed .054, Item encoded must equal its DOI plus Table3 suffix, C must remain blank/default, and the canonical public directory must exist. Any preexisting TSV blocks replacement pending owner reconciliation. Current .056 identity therefore fails the release gate. No export or upload has been attempted here.
