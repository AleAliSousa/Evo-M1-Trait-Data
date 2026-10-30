Brain mass / volume provenance audit -- 2026-10-29

Scope
All 2,868 records currently harvested into Brain_Mass_mass_or_volume:
Burger 2019: 1,552; DeCasien 2017: 662; Boddy 2012 Table S1: 630;
Herculano-Houzel 2015 sleep paper Table 1: 24.
There are 1,615 current harvested species labels (1,611 after the current
Python harvest's name-key mapping). Counts below use the harvested labels.
The older 1,553-species statement in the repository README is stale.

No source data, production keys, merge outputs, app code or deployment changed.
Run: python3 _checks/brain_basis_audit_20261029/audit.py
The script reads current files and rewrites only the audit outputs here.

The quoted five entries
Species: Trachypithecus francoisi.

DeCasien2017 102.1: MASS, adult male, n=1, Sherwood collection.
DeCasien2017  86.7: MASS, adult female, n=1, Sherwood collection.
DeCasien2017  91.2: MASS, juvenile male, n=1, age 1 year 1 month in Boddy.
Burger2019   94.4: MASS, adult mean copied through Boddy2012.
Boddy2012    94.4: MASS, adult mean of the two original Sherwood adults.
(102.1 + 86.7) / 2 = 94.4. The juvenile is NOT part of that adult mean.

The original records are in Boddy_etal_2012/brain_body_database_v2.txt.
Boddy's own Data collection section (journal p.983) identifies CCS's 94
post-mortem specimens as original measured brain masses. This resolves the
measurement type; a separate Sherwood 2008 reference is not needed for that.
Do not describe the five entries as five independent estimates. Burger and
DeCasien reproduce the same underlying Sherwood data reported by Boddy.
For this collection, Boddy can be a primary publication. Its entire Table S1
cannot therefore be classified uniformly as either primary OR secondary.

The repository also already has a typed 102.1 g record from
Bauernfeind_etal_2013_Table1. Numerical equality does NOT establish specimen
identity; this audit does not assume that it is an independent animal.

Results and limits
The individual record audit assigns:
  501 mass records;
   29 brain-tissue volume records;
  493 endocranial-volume records;
    4 volume-derived records whose volume subtype still needs checking;
    5 known composites combining measurements of different types;
1,836 unresolved records needing additional source/aggregation checking.
Thus 1,032 records have a resolved physical basis, including identified
composites. An identified composite is not a mysterious measurement: unpack
the component measurements instead of assigning the average to a single type.

The five composite records belong to Hylobates lar (Boddy and Burger),
Pan paniscus (Boddy and Burger), and Notamacropus rufogriseus (Boddy).
Their adult raw-record averages reproduce the published means but combine
mass and volume-derived components. Other means may have the same problem;
the audit does not classify a mean that it cannot reproduce numerically.

1,012 harvested labels already have a typed alternative in the checked
repository sources or merges, or have a resolved current mixed record.
For these species, keeping an ambiguous fallback as the preferred size is
unnecessary. The alternative's preparation, inclusions, age and specimen
identity still matter; availability here is not a blanket pooling endorsement.

603 labels have no typed alternative established by THIS audit; 581 of those
have only one distinct numeric value in the mixed harvest. These are a
reference-chase queue, NOT proof that no clear measurement exists anywhere.
Unresolved means not established here, not intrinsically unknowable.
No currently harvested entry lacks a source citation after matching it back
to its source table. Some citations lead to further compilations. This is
unfinished provenance resolution, not a demonstrably citation-free number.
The audit cannot yet certify any species as an unavoidable ambiguous fallback.

Do not equate brain-tissue volume and endocranial volume. The latter includes
the cranial cavity, and a conversion to grams does not change what was
originally measured. DeCasien and Boddy use 1.036 g/cm3 for conversions;
Burger's own methods use 1 cm3 = 1 g. Do not globally undo one conversion on
all records: some Burger values were already converted in an earlier source.

Reference priorities
See reference_chase.csv for the complete queue with species lists. Its
species_without_typed_alternative count ranks the entries by coverage benefit;
counts across rows overlap and must not be added.

Mace 1981 (169 affected labels for this exact source-label group):
  Mace GM, Harvey PH, Clutton-Brock TH. Brain size and ecology in small
  mammals. Journal of Zoology 193:333-354.
  https://doi.org/10.1111/j.1469-7998.1981.tb03449.x
  Need full methods and source table/notes, then follow its original citations
  if it also combines measurement types. The journal PDF returned HTTP 403.
  Boddy documents subtracting 0.59 g from Mace rodent weights. That documented
  correction alone does not prove how every original value was measured.

Isler & van Schaik 2012 (121 affected labels):
  Allomaternal care, life history and brain size evolution in mammals.
  Journal of Human Evolution 63:52-63.
  https://doi.org/10.1016/j.jhevol.2012.03.009
  Need SupplementaryData.xls and SupplementaryInfo.pdf, particularly per-row
  brain-size sources and measurement/conversion flags. Main-text access via
  the indexed journal page failed (HTTP 403). This is itself a compilation.

Jones & MacLarnon 2004 (63 affected labels):
  Affording larger brains: testing hypotheses of mammalian brain evolution
  on bats. American Naturalist 164:E20-E31.
  https://doi.org/10.1086/421334
  Need full methods and both data-file supplements to trace remaining values
  to Baron/Stephan or other original weights. Abstract alone is insufficient.
  Many bats already have typed alternatives, so they are lower priority for
  coverage even though 301 Burger records still need their exact lineage.

Next groups: Perez-Barberia et al. 2007 (37 affected labels), Stankowich's
source labelled 2016 (30; Burger's reference list gives Stankowich & Romero
2017), Bininda-Emonds 2000 (27), Mace & Eisenberg 1982 (22). Bibliographic
year/label mismatches must be resolved before a source-level blanket rule.

Sources checked that resolve volumes
Isler et al. 2008: endocranial capacities.
Ashwell 2008 / Weisbecker et al. 2013: endocranial capacities plus revised
body masses, not independent brain weights.
  https://pubmed.ncbi.nlm.nih.gov/18230970/
  https://doi.org/10.1159/000348647
Mateju et al. 2016: endocranial cavity filled with lead shot, calibrated to
volume; original methods explicitly establish the quantity.
  https://pmc.ncbi.nlm.nih.gov/articles/PMC4822454/
Gittleman 1986: the column says brain weight, but journal p.29 states that
the estimates came from skull capacities measured using 2 mm glass beads.
  https://repository.si.edu/server/api/core/bitstreams/b5f0eb7a-3b42-44f2-b896-e692c2da9055/content
Haug 1987 and Rilling & Insel 1999: brain-tissue volumes. The paired original
volume / converted-mass fields in Boddy/DeCasien preserve the conversion.
Herculano-Houzel 2015 sleep Table 1: per-cell references separate four
Hofman 1985 brain volumes from twenty isotropic-fractionator mass values.

Additional production issues exposed, not changed here
1. Basis is assigned to an entire (paper, column), which explains why clearly
   identifiable measurements land in mass_or_volume. It needs row-level
   classification and source ancestry, not simply a renamed pooled column.
2. The DeCasien harvest uses Genus+Species and omits 169 source records with
   those fields blank despite a valid KEY: all 147 Isler ECV records and all
   22 Hartwig mass records. Those source records were nevertheless included
   when this audit searched for typed alternatives.
3. Age and provenance independence need explicit gates. A juvenile specimen
   appears among the five quoted app contributors, and team labels currently
   make successive compilations look independent.
4. Raw-adult mean reconstruction sometimes differs from Boddy Table S1.
   Those rows remain unresolved here; neither the cause nor the original
   measurement type is guessed from numerical resemblance.

Files
row_audit.csv: every harvested mixed record, matched source-record locator,
  physical quantity, evidence, original reference, age/sex, and remaining chase.
species_audit.csv: every harvested species label, typed alternatives and action.
species_needing_reference.csv: the 603 labels without a typed alternative
  established by the checked data.
reference_chase.csv: references ranked by affected coverage, with species lists.
summary.json: machine-readable counts and the five example records.

Verification
The script asserts one audit row for every mixed input row, a matched
source-record locator and a citation for every row, no typed alternative in
the chase-only subset, five mass assignments for the quoted species, and the
94.4 g adult-mean arithmetic. No production builder was run.
