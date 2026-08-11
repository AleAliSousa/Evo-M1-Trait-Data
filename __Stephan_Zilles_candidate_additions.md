# Stephan / Zilles collection — candidate additions audit

Result of auditing the Stephan/Frahm/Baron/Zilles Düsseldorf histological brain-volume
collection against what is already ingested. Generated 2026-07-31.

**Headline:** the collection is essentially complete. The numbered *J. Hirnforsch.* series
**"Comparison of brain structure volumes in Insectivora and Primates" is fully present at
I–IX** (there is no Part X). The genuine in-scope gaps are two **Matano cerebellar-complex
primaries** — 1986 (vestibular) and 1992 (inferior olive); everything else is either a
scope decision (bats) or superseded/secondary. (Matano & Ohta 1999 is a secondary re-report
of already-published data — do **not** ingest; see §1.)

---

## Already complete — the numbered series (all present ✅)

| Part | Structure | Repo folder |
|---|---|---|
| I Neocortex | `Frahm_etal_1982` | ✅ |
| II Accessory olfactory bulb | `Stephan_etal_1982` | ✅ |
| III Main olfactory bulb | `Baron_etal_1983` | ✅ |
| IV Non-cortical visual (LGN/optic) | `Stephan_etal_1984` | ✅ |
| V Area striata | `Frahm_etal_1984` | ✅ |
| VI Paleocortical components | `Baron_etal_1987` | ✅ |
| VII Amygdaloid components | `Stephan_etal_1987` | ✅ |
| VIII Vestibular complex | `Baron_etal_1988` | ✅ |
| IX Trigeminal complex | `Baron_etal_1990` | ✅ |

Also present: `Stephan_etal_1970`, `Stephan_etal_1981` (New and revised data,
10.1159/000155963), `Stephan_etal_1988` (book chapter), Matano cerebellar
`Matano_etal_1985_a` / `_b` + `Matano__2001`, `Zilles__Rehkamper_1988`,
`Frahm_Zilles_1994` (hippocampus), `Frahm_etal_1997` (Spalax), `Frahm_etal_1998` (MT),
and downstream re-reporting papers (`deSousa_etal_2010`/`2013`, `MacLeod_etal_2003`,
`Sherwood_etal_2004_I`/`2005`, `Smaers_*`, `Semendeferi_*`).

---

## Candidate additions (where to put each)

### 1. Matano cerebellar-complex primaries — the two the repo is MISSING
The Matano cerebellar-complex dataset was published as a set of **primary** papers on the
Stephan collection. Two are already ingested; two are not:

| Paper | Structure | Citation | In repo? |
|---|---|---|---|
| Matano, Stephan & Baron 1985 | ventral pons | Folia Primatol. 44:171–181 | ✅ `Matano_etal_1985_b` |
| Matano, Baron, Stephan & Frahm 1985 | cerebellar nuclei (MCN/ICN/LCN) | Folia Primatol. 44:182–203 | ✅ `Matano_etal_1985_a` |
| **Matano 1986** | vestibular complex *(title needs confirmation)* | Folia Primatol. 47:189–203 | ❌ **missing** |
| **Matano 1992** | inferior olivary nuclei | J. Anthropol. Soc. Nippon 100(1):69–82 | ❌ **missing** |

The two missing primaries (1986 vestibular, 1992 inferior olive) are the genuine gaps —
they are the primary source for those structures. Before ingesting, verify each structure
isn't already covered by another primary (vestibular also appears in `Baron_etal_1988` and
`Stephan_etal_1981`) — check for specimen overlap / double-counting.

> **Matano & Ohta (1999)** *Volumetric comparisons on some nuclei in the cerebellar complex
> of prosimians* (Am. J. Primatol. 48(1):31–45, DOI
> `10.1002/(SICI)1098-2345(1999)48:1<31::AID-AJP3>3.0.CO;2-Y`, PMID 10326769) is a
> **SECONDARY re-report — DO NOT ingest.** Per the authors, its raw data were already
> reported in the four primaries above (1985a, 1985b, 1986, 1992), so ingesting it would
> double-count. The scaffold that briefly existed at `Matano_etal_1999/` was removed for
> this reason.

### 2. Baron, Stephan & Frahm (1996), *Comparative Neurobiology in Chiroptera* — SCOPE DECISION
- **Landing folder:** `Baron_etal_1996_Chiroptera/` (parked; README explains prerequisites).
- 3-vol Birkhäuser monograph, ~10,000 measurements on up to 336 bat species — the bat
  counterpart to the 1981 dataset. Large and high-value, but **bats** = outside the current
  insectivore/primate scope. Needs the `Class`-axis work in
  `SCOPING_backbone_traits_and_taxonomy.md` first.

### 3. Older foundational Stephan–Andy / Bauchot–Stephan papers — NOT recommended (superseded)
No folders created; documented here for provenance. Their raw structure values were rolled
into the 1970 and 1981 compilations already held (the 1981 paper explicitly supersedes
them), so marginal data value is low. Add only if a specific early structure breakdown is
needed.

| Paper | Citation | Note |
|---|---|---|
| Stephan & Andy (1969) | Ann. NY Acad. Sci. 167:370–387 | phylogenetic interpretation; qualitative + early volumes |
| Andy & Stephan (1976) | J. Comp. Neurol. 178:157–170 | septal nuclei volumes |
| Bauchot & Stephan (1966) | Mammalia 30:160–196 | encephalisation indices (Insectivora/Prosimii) |
| Bauchot & Stephan (1969) | Mammalia 33:225–275 | encephalisation indices (Simiens) |
| Stephan (1975) "Allocortex" | Handbuch d. mikr. Anatomie IV/9, Springer | allocortical volumes monograph |

---

## Notes
- The *J. Hirnforsch.* papers have **no DOIs** (journal predates DOI assignment); they are
  PMID-anchored, matching how the repo already keys them.
- Parts IV and V are two distinct 1984 papers and are correctly kept separate in the repo.
