# Qiu et al. 2022: recoverable population social-organization records

The evolution of marsupial social organization. DOI: https://doi.org/10.1098/rspb.2022.1589
Full archive: https://doi.org/10.5061/dryad.jwstqjqd8
Recovered author archive: https://github.com/JingyuQ/MarsupialSO (Model S5 Ancestral state of social organization of all marsupials.zip).
Published Word supplement: https://ndownloader.figshare.com/files/37886283

Retrieved 2026-10-23. The full Dryad workbook (Marsupial_SO_dataset_and_article_list.xlsx, 108982 bytes, advertised SHA256 07e912c2cfcdabb9b2704cb3e14b531e32b125ec940ed866ba0c36f1353cd116) could not be downloaded: public file links returned HTTP403 and API download HTTP401. This is NOT that workbook. The author S5.xlsx provides 111 modeled records plus 30 records excluded for missing covariates, spanning 65 printed species; the paper reports 149 populations. Source rows, sheets, duplicate rows and abbreviated references are retained. Missing population locations cannot be reconstructed from this subset.

These are SECONDARY classifications compiled from primary field studies. No claim that all original field papers have been checked. Codes describe adults only, exclude juveniles, and are not numerical group sizes. The merge takes the set of observed states, never an average or modal state. Source model exclusions for missing body mass/habitat do not alone invalidate social observations.

Held records: the excluded-sheet row11 for Macropus giganteus has SG (solitary + group), in conflict with the paper's statement that SG was absent. It stays in snapshots but is excluded from the merge. Ailurops melanotis (two rows) is retained in snapshots but held from merging pending an NCBI identity anchor; ITIS recognizes it as a distinct valid species (TSN709403), so it must not be collapsed into A. ursinus. The final merge includes 64 species, with partial coverage explicitly stated in the definition.

Next: acquire the full Dryad workbook to reconcile the eight-record count difference and recover exact population locations and full citations, then reconcile all rows by references and location. Do not append the full table to this subset as independent data. Rebuild with `_checks/social_variables/build_population_censuses.py`.

Source integrity: local Office copies acquired added custom metadata without changes to worksheet/document content. Authoritative original bytes are preserved inside ZIP archives; the rebuild reads the archived workbook. source_manifest.csv hashes the archives and other non-Office evidence, not mutable display copies.
