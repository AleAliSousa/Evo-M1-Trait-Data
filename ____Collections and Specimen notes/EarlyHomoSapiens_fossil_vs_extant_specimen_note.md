# Specimen / concept note: early *Homo sapiens* — fossil vs extant

## Purpose

This note tracks the identity problem in the hominin data: the label
"*Homo sapiens*" is used for **two things that must not be pooled** — Late
Pleistocene **fossil** individuals and **living** modern humans. It records how
the four early *H. sapiens* fossils (and the four Neanderthals alongside them)
are kept apart from the extant human mean in `_keys/specimen_crosswalk/`. It is
the fossil-vs-extant companion to the Pongo note (which is a *species-split*
case); the two look alike but are handled differently — see "How this differs
from Pongo".

## The core problem

Kochiyama et al. (2018) report cerebrum and cerebellum volumes for individually
dated fossils and treat them as **three separate grades**:

| group | n | what it is | measurement basis |
|---|---|---|---|
| EH | 4 | early (fossil) *Homo sapiens* | GM+WM reconstructed by deforming living MRI brains onto the endocast |
| NT | 4 | Neanderthal (*H. neanderthalensis*) | same reconstruction method |
| MH | 1185 | living modern humans | living soft-tissue brain MRI / MRA |

Seymour et al. (2015) and the living-collection sources (Stephan, Zilles, Bush,
Rilling & Insel) instead carry the **bare binomial "*Homo sapiens*"**, meaning
living humans. So across the corpus one label spans ~120 ka of fossils and a
living reference sample. If a merge keys on the species string alone, a fossil
endocast value can be averaged into the living-human mean.

The four early *H. sapiens* fossils:

| specimen | date (yBP) | Kochiyama cerebrum (cc) | Kochiyama cerebellum (cc) | also in Weaver A-15? |
|---|---|---|---|---|
| Qafzeh 9 | ~90,000–120,000 | 1075 | 147 | no |
| Skhul 5 | ~100,000–135,000 | 1053 | 146 | no |
| Mladeč 1 | ~35,000 | 1205 | 165 | no |
| Cro-Magnon 1 | ~32,000 | 1208 | 156 | yes (group 13-EMH) |

## How this differs from Pongo (why the mechanism is not the same)

The user's framing is the key insight: **these are fossils versus extant, not a
*sensu lato* species split.**

- **Pongo pygmaeus (s.l.)** is *one label over many individuals* whose
  composition is **unrecoverable** — an old pooled mean cannot be un-averaged
  into Bornean vs Sumatran. The risk is *promoting* a broad mean to a narrow
  modern species. `decomposable = FALSE`.
- **Early *Homo sapiens*** is *one label over several named, individually dated
  fossils*. A group mean here **is** decomposable — you can point to Qafzeh 9,
  Skhul 5, Mladeč 1, Cro-Magnon 1. The risk runs the **opposite way**: a fossil
  grade being *absorbed into* the living-human mean. `decomposable = TRUE`.

So this is a *temporal-grade* distinction within one species, encoded with
`sensu = NA` (it is not a *sensu lato* / *sensu stricto* split). The fossils are
still taxonomically *Homo sapiens*; what changes is the **grade and the
measurement basis**, and those are what the merge must keep separate.

## Database treatment

### Specimen level (`specimen_crosswalk.csv`)

Each fossil is one `canonical_specimen`, with one alias row per source label
(Kochiyama, and Weaver 2001 where present). `resolved_taxon` is the species
(*Homo sapiens* or *Homo neanderthalensis*); the fossil grade is carried by
`taxon_concept`. `taxon_conflict = FALSE` (sources agree on the taxon). Twelve
rows total: 4 EH + 4 NT specimens, with a second row for the four that also
appear in Weaver A-15.

All twelve rows now carry `specimen_kind = fossil_specimen`. This is the
authoritative filter: fossil status must not be guessed from `taxon`, because
early fossil and extant records can share the binomial *Homo sapiens*.

### Concept level (`taxon_concept_registry.csv`)

Three concepts added, all `sensu = NA`:

- `Homo sapiens (early/fossil)` — the EH grade; `decomposable = TRUE`;
  `modern_equivalent = NA` **deliberately**, so it is never auto-mapped to
  living humans.
- `Homo sapiens (living/extant)` — the referent of a bare "*Homo sapiens*" mean;
  `modern_equivalent = Homo sapiens`.
- `Homo neanderthalensis` — extinct sister species; `decomposable = TRUE`.

## The hard rule (for the merge / comparison)

```text
fossil grade value (EH / NT)   -> stays under its fossil concept; NEVER pooled
                                  into the extant 'Homo sapiens' species mean
bare 'Homo sapiens' mean       -> defaults to Homo sapiens (living/extant),
                                  UNLESS the source is a fossil source
                                  (Kochiyama EH, Weaver A-15)
```

This is the mirror image of the Pongo rule: there, do not *split* a pooled mean
downward to a modern species; here, do not *merge* a fossil grade upward into
the living-species mean.

## Where the values enter the merge

See `early_homo_sapiens_provenance_audit.csv`. Current state: the single
"*Homo sapiens*" row in `__merging_volumes/volumes_long.csv` pools only living
collections (Stephan, Zilles, Bush, Rilling & Insel) — correct as extant. The
Kochiyama fossil cerebrum/cerebellum values are **not** currently ingested into
`volumes_compiled.R`; the audit flags that if they ever are, they must enter as
`Homo sapiens (early/fossil)` and not be averaged into that row.

## What remains unresolved

- Whether any downstream analysis silently treats Seymour's bare "*Homo
  sapiens*" as taxon-agnostic and joins it to fossil rows (dormant path today).
- Method offset between Kochiyama (MRI-deformation) and Weaver (virtual
  endocast) cerebellum estimates for the shared specimens — quantified in
  `fossil_specimen_cerebellum_comparison.csv` (Koch/Weaver ratio ~1.18–1.40),
  not yet reconciled into a single preferred value per specimen.
- Precise dating of Forbes' Quarry 1 (no dating information in Kochiyama).

## Sources cited

- Kochiyama T, Ogihara N, Tanabe HC, et al. (2018), *Reconstructing the
  Neanderthal brain using computational anatomy*, Sci Rep 8:6296
  (`Kochiyama_etal_2018_FossilSpecimensText.csv`).
- Weaver TD (2001), Ph.D. dissertation — Table A-15
  (`Weaver__2001_TableA-15`; fossil groups 12-LAH, 13-EMH).
- Seymour RS, Angove SE, Snelling EP, Cassey P (2015), *Scaling of cerebral
  blood perfusion in primates and marsupials*, J Exp Biol 218:2631–2640
  (`Seymour_etal_2015_TableS1.csv`).
- `_keys/specimen_crosswalk/SCHEMA.md` — two-layer schema and merge consumer
  contract.
