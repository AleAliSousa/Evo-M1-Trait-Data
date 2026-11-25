# Turner 2017 Chapter 2 specimen

Source: Emily C. Turner, *Visual Neuroanatomy of Large-Brained Primates and Carnivores* (Vanderbilt dissertation, 2017), Chapter 2 Materials and Methods, printed p. 24 (PDF p. 39). `Turner__2017.pdf` is the local source.

The constructed `*_snapshot.csv` records the one adult female chimpanzee described in prose: estimated age 53 years, body weight 34.8 kg shortly before death, brain weight 344 g on arrival, Texas Biomedical source, right flattened neocortex and left hemisphere reserved for histology. Turner does **not** print the case code in this passage. The identity link to Miller's `11_38` and Collins et al. 2016 uses the previously documented public source bridge; it is not copied into the snapshot.

Run `Rscript Turner__2017/Turner__2017_Chapter2SpecimenText.R` from the repository root. The script reads only this frozen snapshot, converts kg to g, and writes the analysis CSV and `__Public/comparative-data/hdl1803-11720_Chapter2SpecimenText.tsv`. `reference_tables/Turner__2017_Chapter2SpecimenText_definitions.csv` defines output fields. This is one specimen, not a new independent chimpanzee sample relative to Miller/Collins. AI checked the snapshot against PDF p. 39 on 2026-11-24; human visual signoff is pending. No figure data were extracted.

The same 53-year-old Texas Biomedical chimpanzee appears in the already built `Collins_etal_2016_Table1`. Miller et al. 2014 (DOI 10.3389/fnana.2014.00036; PDF already in `Miller_etal_2014/`) reports V1 counts from both hemispheres and has an unbuilt method-specific Table 1. Compare methods and hemispheres before combining those measurements.
