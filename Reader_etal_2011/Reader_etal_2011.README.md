# Reader lineage — primate behavioural innovation & technical intelligence

Source folder for the **technical-innovation** compilation seeded into the behaviour merge, starting
from Simon Reader's classic primate cognition dataset (per curator direction, 2026-07-31).

## Source (freeze this before any cleaning — golden rule)

- **Classic / origin:** Reader, S. M., & Laland, K. N. (2002). *Social intelligence, innovation, and
  enhanced brain size in primates.* PNAS 99(7):4436–4441. DOI **10.1073/pnas.062041299**.
  The original compilation — innovation, social learning and tool-use report frequencies across
  **116 primate species**, corrected for research effort.
- **Machine-readable extension used as the frozen source:** Reader, S. M., Hager, Y., & Laland, K. N.
  (2011). *The evolution of primate general and cultural intelligence.* Phil Trans R Soc B
  366(1567):1017–1027. DOI **10.1098/rstb.2010.0342**. Adds **extractive foraging** and **tactical
  deception** to the above for **62 primate species**.
  - **Archived data (digital-native → the download IS the frozen copy):** Dryad
    **doi:10.5061/dryad.t0q94**, file `Data_ReaderHagerLalandPhilTrans2011.csv` (+ its ReadMe).
    Also mirrored on the Laland Lab site (St Andrews) "Primate Dataset" page.

**Why Reader and not Navarrete et al. 2016:** curator wants Reader's own data as the source of record.
Navarrete descends from the same lineage; if ever added it is **citation-dependent → never averaged**.

## Get the frozen source (could not be done in the authoring session)

The org network policy blocked Dryad at the egress proxy in the session that scaffolded this
(`connect_rejected 403` for `datadryad.org`), and no R runtime was available. Do this locally:

1. Download `Data_ReaderHagerLalandPhilTrans2011.csv` from Dryad (doi:10.5061/dryad.t0q94). Keep it
   **verbatim** in this folder as the frozen source — do not edit it (digital-native invariant).
2. Write the DOI-coded public TSV to `__Public/comparative-data/` as required by invariant 2. Using
   the article DOI, %2F-encoded, matching the Wilman/Granatosky pattern:
   `10.1098%2Frstb.2010.0342_Data.tsv`  (tab-separated copy of the frozen CSV, journal species name
   preserved). If you prefer to key on the Dryad DOI, use `10.5061%2Fdryad.t0q94_Data.tsv` and set
   `item_encoded` in the reader to match.

## Build steps

1. Reader script: `____EvoM1_TraitTable/EvoM1_read_innovation_reader.R` (already scaffolded).
   Open the CSV, **confirm the exact column headers** (species column; the innovation / social
   learning / tool use / extractive foraging / tactical deception count columns — the 2011 file ships
   both raw counts and effort-corrected values; expose the **raw** counts), and fix the two
   `TODO(curator)` mappings. Run it → writes `____EvoM1_TraitTable/innovation_reader.xlsx`.
2. Data dictionary: `reference_tables/Reader_etal_2011_definitions.csv` (already written; adjust
   column names to the confirmed headers).
3. Register in `__ReadMe.xlsx` (`Sheet1`): add a row with
   `Item name = Reader_etal_2011_Data`, `Item encoded = 10.1098%2Frstb.2010.0342_Data`,
   `Data role (primary/secondary/both) = primary`, `Main Trait(s) = behavioural innovation / technical
   intelligence`, `Taxon group = Primates`, `Team = Reader`. (Kept out of the binary xlsx by the
   scaffolding session on purpose — you own that master file.)

## Wire into the behaviour merge (`__merging_behaviour/behaviour_compiled.R`)

Do this **only after** `innovation_reader.xlsx` exists, otherwise the merge errors on a missing file.

- Add `Reader = "Reader"` to the `TEAM` vector.
- Add `grab()` lines (one per exposed measure), e.g.:
  ```r
  grab("innovation_reader.xlsx","Innovation","Innovation","reader"),
  grab("innovation_reader.xlsx","Extractive_foraging","ExtractiveForaging_freq","reader"),
  grab("innovation_reader.xlsx","Tool_use","ToolUse_freq","reader"),
  grab("innovation_reader.xlsx","Social_learning","SocialLearning_freq","reader"),
  grab("innovation_reader.xlsx","Tactical_deception","TacticalDeception_freq","reader"),
  ```
- Add matching `META` rows (all `mclass = "cognition"`, `Units = "reports (effort-corrected)"`,
  single-source `list(c("reader","primary"))`).

### Construct note — do NOT silently pool with Heldstab

Heldstab 2016 already supplies **categorical** `Extractive_foraging` and `Tool_use` (presence /
complexity). Reader's are **report-frequency counts** — a different construct. Per house rule (§10)
different constructs are never pooled into one value. Keep Reader's as **distinct measures**
(`ExtractiveForaging_freq`, `ToolUse_freq` as above), not as extra sources on Heldstab's categorical
rows. `Innovation` is a genuinely new measure with no existing source. Confirm this split with the
curator before merging if in doubt.

## Checks

- No comparison script needed unless you audit against a second curated copy (§7). If both the 2002
  classic and the 2011 file are ingested, they are the **same lineage** → resolve, never average
  (2011 supersedes 2002 on shared species).
- After running, re-run `behaviour_compiled.R` and confirm the new measures appear in
  `behaviour_long.csv` with `Teams = Reader`, and species resolve against `_keys/species_reference.csv`.
