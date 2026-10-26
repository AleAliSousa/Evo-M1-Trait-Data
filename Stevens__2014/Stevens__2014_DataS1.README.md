# Stevens__2014_DataS1

Stevens, J. R. (2014). Evolutionary pressures on primate intertemporal choice. Proceedings of the Royal Society B: Biological Sciences, 281, 20140499. https://doi.org/10.1098/rspb.2014.0499

Untouched author CSV `rspb20140499supp2.csv`: all 941 records for 13 primate species. It contains 96 delay-choice records, plus body mass, endocranial volume, lifespan, home range and group size. All measurements are secondary to the studies named in `reference`; Stevens 2014 is a synthesis, not a new independent behavioral cohort.

The output retains subject identifiers, common-name qualifiers, n, SD, exact source keys and notes. `species` uses the printed Latin name and `common_name` preserves the original common-name field. Only ECV is rescaled (cm³ ×1000 to mm³); raw values and raw SD remain for audit. Read `measure`, `unit`, `n`, `notes` and `reference` together. The source `type` field is a common-name qualifier (e.g. Rhesus), not a statistical-summary label. Records mix individuals, groups/populations, means, medians and other published summaries; n=1 was sometimes assigned when sample size was unavailable. They must not be indiscriminately averaged or counted as independent specimens.

Indifference points are delays in seconds, sometimes estimated from discount functions. Rhesus macaques received liquid rewards; other species received solid food, with differing adjusting procedures. These methodological differences remain relevant for comparison. ECV traces to Isler et al. (2008), already represented elsewhere, so it is not ingested again as primary volume data.

The item references lookup preserves all 148 source keys, including source spelling variants. Exact or clearly matching bibliography entries are supplied; ambiguous/absent citations remain explicitly unresolved rather than invented. Counts, measurement-unit mapping and complete reference-key joins are checked. No printed additive total is applicable.

The author CSV is copied byte-for-byte; no PDF transcription check applies.

Rebuild with `Rscript Stevens__2014_DataS1.R` from any directory. The frozen source is read locally; the live registry supplies the encoded public TSV name. Published taxon labels are retained. No new global species key or unsupported bilateral conversion is introduced.
