# Name-soundness audit — 2026-08-30

Scope: every paper folder ↔ `__ReadMe.xlsx` (Publication name / Item name) ↔ its main R
script(s); all 26 `__merging_*` compile scripts; alignment with `Evo-M1-Trait-Data-restricted`.
Settles the nine folders the 2026-08-29 underscore audit deferred as "separate questions".
Registry state read fresh: 352 named rows, 168 paper folders, 233 paper-folder R scripts.

## Verdicts on the nine deferred folders
| Folder | Verdict |
|---|---|
| `Schultz_Dunbar_2010` | Folder was the TYPO (the row's own citation prints "Shultz, S., & Dunbar"). Empty folder **renamed → `Shultz_Dunbar_2010`** this pass. Row `Shultz_Dunbar_2010_` still needs its Item number. |
| `Weaver__2005` | NOT a misname: a **separate 2005 Weaver paper** (PDF + note; the dissertation build lives in `Weaver__2001`, whose rows you already fixed). Needs its own registry row when adopted; currently a stub. |
| `VanEssen_Drury_1997` | Folder name is right (two authors). The REGISTRY side is off: pub/item say `VanEssen_etal_1997` and the citation contains a reference-manager artifact author — "…Drury, H. A., **& New Collective, A.**". Fix in Excel: citation, Publication name, Item name → `VanEssen_Drury_1997_Table1` (verify in EndNote first, per the house lesson). |
| `Mota_etal_2015` | OK by design — documented `registry_item_name` override (`Mota_Herculano-Houzel_2015_TableS1`). |
| `Zilles_Rehkämper_1988` | OK by design — ASCII folder vs umlaut registry, documented; script overrides internally. |
| `Hutsler_etal_2005` | 4 built products, still zero rows (top of the registration queue; the cortical-layers merge already reads its CSV directly). |
| `Deaner_etal_2007` | Folder now correctly named (you renamed it); needs a row. |
| `Reader_Laland_2002` | PDF + definitions stub; needs a row when adopted. |
| `Changizi_He_2005` | PDF-only stub (Changizi & He 2005 — a real separate paper, not the Shimojo one); zero rows; candidate. |

## Other folder/script ↔ registry findings
- **Todorov key mismatch:** your new row is `Todorov_etal_2019_rspb20191712si001` but the
  script and all products are `Todorov_etal_2019_dimorphdata` (and no TSV exists under either
  key). Align one side — the script's registry lookup fails as-is.
- **Stephan_etal_1987_Table2**: built (R + CSV + snapshot) but only Table1 is registered.
- **Case-style drift, harmless but untidy:** registry prints `TABLE` where scripts/folders print
  `Table` for Stephan 1970 (×6, plus the `Stephan_Pirlot_1970_` stub row for the same book),
  Stephan 1988, Bush_Allman_2004_b, Semendeferi 1998/2001. The volumes merges tolerate this by
  design (`norm()` case-insensitive match + documented `enc_override`), and Stephan-1970 build
  scripts hardcode their encoded names — so nothing breaks; normalize at leisure.
- **HH 2013 script filenames** are hyphenated (`Herculano-Houzel_…`) while the registry items
  are not; the scripts set `item_name` explicitly to the registry spelling — cosmetic only.
- Multi-item builders whose script name is not itself an Item name (BarbeitoAndres, Capellini,
  Sherwood 2004-I, Karbowski S1–S23, Stephan 1970 umbrella, deJager) — all fine; their items exist.
- In-progress rows `Chaplin_etal_2013_` and `Veilleux_Kirk_2014_` have blank Item numbers
  (trailing-underscore keys) — fine mid-entry, must be filled before any build references them.
- Folder-convention deviation: `Sherwood_etal_2004_I` (established, keep).

## __merging scripts (all 26 scanned)
Every registry-item reference in every merge script resolves to a row AND a TSV on disk, with
two known exceptions, both already tracked: `DeCasien_…_BrainRegion` (registered, product not
yet built — decasien-volume-merge-update skill territory) and the cortical-layers merge's
direct read of the unregistered Hutsler CSV. The Kaufman/Karbowski/HH-2015/MacLeod label fixes
from the 2026-08-29 underscore pass are in place. No stale item names anywhere else.

## Restricted repo alignment — CLEAN
- Every `restricted_checks/<Paper>` folder has an exact-name public counterpart (the
  `Zilles__Rehkamper` double-underscore was fixed 2026-08-29); none empty.
- No hardcoded OneDrive paths remain in restricted check scripts.
- `unpublished_data/` folder names consistent; `restricted_source_registry.csv`'s
  `public_routes` uses its own PUB_* token scheme (by design, not registry Item names).
- `_paths.R` / `_helpers/restricted_data.R` resolution layouts match the real disk layout
  (private repo at the OneDrive root, public under `Species/`).

## Owner queue distilled (Excel edits, in one sitting)
1. Register: Hutsler ×4, Stephan_etal_1987_Table2, Deaner_etal_2007, (when adopted:
   Reader_Laland_2002, Weaver__2005, Changizi_He_2005).
2. Fix VanEssen row (citation artifact + name → VanEssen_Drury_1997_Table1).
3. Align Todorov item key with the dimorphdata products (or rename the products).
4. Item numbers for Shultz_Dunbar_2010_, Stephan_Pirlot_1970_, Chaplin_etal_2013_,
   Veilleux_Kirk_2014_.
5. Olkowicz figshare/PNAS key decision (see `_checks/script_repairs_20260829.md`).
