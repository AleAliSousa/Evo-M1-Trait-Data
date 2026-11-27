# Hopkins et al. 2011 Table 2

Source: `Hopkins_etal_2011.pdf`, Handedness distribution for each great ape species, PDF p. 18. The frozen
snapshot retains the four source taxon rows and printed columns. Run
`Rscript Hopkins_etal_2011/Hopkins_etal_2011_Table2.R` from the repo root to rebuild
the four-row analysis CSV. The PDF page and snapshot were compared on
2026-11-26; no human visual signoff is claimed.

The paper combines previously tested apes with newly tested individuals.
The methods identify orangutans as *Pongo pygmaeus*, gorillas as *Gorilla
gorilla*, chimpanzees as *Pan troglodytes*, and bonobos as *Pan paniscus*.
These are source labels, not a modern specimen-level taxonomy crosswalk.
Do not count the old cohort as independent of earlier Hopkins data.

Adult and subadult classifications together sum to 777. The printed
orangutan adult R:L ratio is `0.38`, while its printed adult counts give
7/16 = 0.4375. Both values and a mismatch flag are retained; the
source ratio is not silently corrected.

Main-registry registration and public TSV remain pending; see
`Hopkins_etal_2011_Table2_registry_row.xlsx`.
