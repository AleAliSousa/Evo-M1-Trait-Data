# Rules for matching a printed identifier to a specimen

*Public methodology note. Derived by re-running the join pass under collection scoping, over the 601 matches that
survived tier review (605 retained by match rate, less the 4 `Ebinger__1974` rows rejected as
a section-series collision). Companion tables:
`identifier_join_collection_grouped.csv`, `identifier_join_collection_scoped.csv`.
This supersedes the unscoped matching in `IDENTIFIER_JOIN_PASS_README.md`.*

## The rule

**Never match on a code alone. Establish the collection first, then match the code within
it.** A code identifies a specimen *within a collection of brains*; it carries no meaning
outside one. Three identifier classes behave differently, and conflating them is the error
the first pass made.

| class | examples | scoping rule | handle rows |
|---|---|---|---|
| **Collection-scoped code** | `Art. Nr.`, `Tier Nr.`, curator working code, slide/box code, simple code, other code | valid **only** within its collection group | 602 |
| **Collection-independent name** | house name, studbook number | valid across collections, modalities, and the living animal | 36 |
| **Global fossil designation** | `La Ferrassie 1`, `Amud 1`, `Qafzeh 9` | globally unique by international convention; match without scoping | 8 specimens |

`printed_identifier` (553 rows) is not a class — it is whatever a paper printed, and must be
resolved to one of the three before use.

## Collection groups, because collections are not independent

Exact-string collection matching fails, and it fails for a substantive reason: **collections
that share a building or share brains produce different strings for the same material.**
Applying exact strings to the 601 matches gave 247 confirmed and 98 "conflicts" — and *all 98
conflicts were spurious*, arising from `Hirnforschung` (the institute) failing to equal
`Zilles` or `Stephan` (the collections inside it), and from Bauernfeind printing `Stephan`
for animals the catalog files under `Zilles from Stephan`.

Grouping co-located and specimen-sharing collections resolves this. The Düsseldorf group:

```
DUSSELDORF_HIRNFORSCHUNG = Stephan | Zilles | Zilles/Semendeferi | Semendeferi
                         | Hirnforschung | Zilles from Stephan | Frahm
```

Evidence for the grouping is in the repo's own collection strings, not assumed:
`Hirnforschung / Stephan-Zilles shared collection` and `Zilles from Stephan` appear as
literal values, and `Zilles/Semendeferi` records the shared sectioning of single brains.
Stephan and Zilles were physically adjacent, so a code can drift between them; Semendeferi
holds sections cut from Zilles brains, so the same animal exists in both under different
physical form. Separate groups: `WELKER_AFIP`, `YAKOVLEV`, `GWU`, `MOUNT_SINAI`, `GAAP`,
`UCSD`, `KAAS_VANDERBILT`, plus one group per fossil site.

**Yerkes is a source, not a holder.** It appears as `Zilles (ex Yerkes)` — the animal lived
at Yerkes and its brain went to Zilles. Treating Yerkes as a collection would merge two
distinct roles.

### Cross-group code ambiguity is rare but real

Of 1,076 collection-scoped handles, **2 appear in more than one group**: the bare values `1`
and `3`, held by both the Düsseldorf and Yakovlev-Haleem groups. Low, but the consequence of
ignoring scope is not proportional to the count — an unscoped match on `1` silently merges
two unrelated animals, and short handles are exactly what abbreviated tables print.

## Result of the scoped re-join

| verdict | matches |
|---|---:|
| **A — code confirmed within collection group** | 331 |
| **A — fossil global designation** | 7 |
| **B — collection unknown for the paper, needs provenance** | 228 |
| **B — handle's own record has no collection recorded** | 14 |
| **C — no match within group** | 21 |

**The largest bucket is not a match, it is a missing prerequisite.** 228 matches sit in
papers whose collection cannot be established from the data at all: only **3 of the 17
matched tables carry a genuine collection column** (`Bauernfeind_etal_2013.Collection`,
`deSousa_etal_2010.collection`, `MacLeod__2000.sample`). Every other table's `source` column
is the repo's own publication tag, not a collection. Paper-level collection is available for
6 papers from `_keys/team_grouping_crosswalk.csv`; for the remaining 9 it must come from the
publication's methods section.

So the honest position for `Collins_etal_2010` (166), `Smaers_etal_2010` (33),
`deSousa_etal_2009` (18), `Young_etal_2013_b` (8) and `Turner_etal_2016` (2) is **not
matched** — it is *unscopeable until the collection is recorded*. Reading five methods
sections converts them.

The 14 in the second B bucket are the inverse gap: the paper's collection is known, the
handle exists, but the catalog or crosswalk record holding that handle has an empty
collection field. Filling those fields is a repo-side fix, not a research question.

## Fossils are a separate regime

`Kochiyama_etal_2018` came back unscopeable in the first cut, which was wrong: its
identifiers are fossil designations, and a fossil designation is an international identifier
maintained outside any one collection. 7 of its 8 specimens match
`fossil_specimen_crosswalk.csv` directly with no collection scoping needed.

The reason this matters is reuse. The same fossil is measured by many teams, so a fossil
specimen accumulates studies in a way a brain-collection animal rarely does. Already visible
in the repo with only two fossil publications registered:

| fossil | studies |
|---|---|
| Cro-Magnon 1 | `Kochiyama_etal_2018`, `Weaver__2001` |
| Gibraltar 1 (Forbes' Quarry 1) | `Kochiyama_etal_2018`, `Weaver__2001` |
| La Chapelle-aux-Saints 1 | `Kochiyama_etal_2018`, `Weaver__2001` |
| La Ferrassie 1 | `Kochiyama_etal_2018`, `Weaver__2001` |
| Amud 1, Mladeč 1, Qafzeh 9, Skhul 5 | `Kochiyama_etal_2018` |

Four of eight already appear in both. This is the specimen class where the cross-project
overlap query pays off soonest, and where an external authority (a fossil hominin catalogue)
should be linked through `specimen_external_links.csv` the way the orangutan studbook is —
`match_status = matched`, because fossil designations are published and stable.

Two conventions to normalise: the same fossil is printed both `Forbes' Quarry 1` and
`Gibraltar 1`, and both `Skhul 5` and `Skhūl V`. These are alias rows, not separate
specimens.

## Names, codes, and the living animal

The class table above explains the pattern noticed earlier: the Zilles animals travel under
house names, the Stephan/Frahm animals under numbers. That is not inconsistency — it follows
from *when* the identifier was assigned.

- A **proper name** was given to the animal **while alive**, in research or husbandry
  records. It therefore survives death, transfer, sectioning, and division between
  collections, and it is what links a brain record to an MRI scan, a behavioural study, or a
  studbook entry.
- A **code** was assigned by a collection **to the specimen**, after accession. It is
  meaningful only inside that collection.

Consequence for cross-modality linkage: a brain in Düsseldorf and an MRI scan of the same
animal at Yerkes share no code, because the code was minted by one collection and the scan
predates the accession. **Only the name (or a studbook number) can bridge them** — which is
why the seven catalog animals carrying a house name and no other attribute are not incomplete
records but the only class of record that can be linked outward at all. Their catalog row ids
are restricted-layer identifiers and are listed in the restricted companion note.

## Practical sequence

1. For each paper, record the collection — from a collection column if present, else
   `team_grouping_crosswalk.csv`, else the methods section. Store it, don't re-derive it.
2. Match codes **within the collection group only**, never globally.
3. Match fossil designations globally, and expect many studies per specimen.
4. Use names and studbook numbers for anything crossing a collection, a modality, or the
   boundary between the living animal and the specimen.
5. Treat any code match whose collection is unknown as `match = unresolved`, not `probable` —
   the missing collection is the reason, and recording that reason is what makes it fixable.