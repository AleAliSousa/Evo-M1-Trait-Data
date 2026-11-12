# Primary-source provenance & comparison independence (Study-3 volume datasets)

Many of these datasets **mix the authors' own primary measurements with secondary values re-used
from other teams** — and several measured the **same physical brains** (Düsseldorf C&O Vogt =
Zilles/Stephan collection). So a "match" between two datasets can be trivial (shared primary source)
and a "diff" can be the only informative signal. This note records, per dataset, the primary-source
composition (from each paper's Methods), and classifies the cross-dataset comparisons.

## Per-dataset primary-source composition (from Methods)
| Dataset | Own (primary) | Secondary / re-used | Collection / team |
|---|---|---|---|
| Stephan/Frahm/Baron 1981–84 | all | — | Düsseldorf (Vogt) — the ROOT source for most "secondary" values |
| Bush & Allman 2003 (GM/WM) | all (own series) | — | own |
| Bush & Allman 2004 (V1) | Table 1 (21 spp) own | combined analysis set (37 spp) adds **Frahm 1984**, averaged on overlap | own + Frahm |
| Bush & Allman 2004_b (55 spp) | frontal (FrG/RoG) own | **neocortex = own + Frahm 1982**; **whole brain scaled to Stephan 1981** | own + Frahm + Stephan |
| de Sousa 2010 (J Hev) | hominoids + *M. fascicularis* (own) | non-hominoids (Supp T2) = **Stephan 1981/1988** | Zilles/Stephan + Yakovlev-Haleem/Welker/GWU |
| de Sousa 2013 (LGN) | all (own) | — | Zilles + Stephan (Vogt) + Yakovlev-Haleem/Welker/Mt Sinai |
| MacLeod 2003 (cerebellum) | all (own MRI+histo) | — | Yerkes + **Hirnforschung = Stephan brains** |
| Barger 2007 (amygdala) | all (own) | — | ape specimens = **same Hirnforschung/Stephan brains** |
| Smaers 2011 (frontal) | all (own) | — | Vogt/Zilles |
| Smaers 2017 ("Smaers dataset") | — | **compilation**: Smaers 2010/2011, de Sousa 2010 [S6], Brodmann | secondary |

## Comparison-independence classification
- **de Sousa 2013 LGN vs Stephan `LGN_Sousa`** → **SAME TEAM (de Sousa)**. Not independent validation;
  it is a version/consistency check. (17 spp agree within a few %; *Pan troglodytes* +36% = a
  specimen/version difference *within* de Sousa's own data, worth resolving.)
- **Bush 2004 V1 vs de Sousa V1** → split by clade (added to the comparison CSV):
  - **hominoids = INDEPENDENT** (Bush-own vs de Sousa-own) → the diffs are real (Pan +33%, Homo +6%, Hylobates +8%). **Choose one** for Study 3 (recommend de Sousa = your own primary, matched to the collection).
  - **monkeys/strepsirrhines = PARTLY SHARED** (both may incorporate Frahm 1984) → diffs reflect Bush's own-vs-Frahm averaging, not two independent teams.
- **Bush NeoG vs Frahm `NeoG_Frahm`** (2003 / 2004_b) → **PARTLY SHARED** (Bush neocortex = own + Frahm) →
  the consistent ~3–12% offset is the own/Frahm averaging, not independent disagreement.
- **Smaers 2017 primary-visual vs de Sousa V1** → for monkeys it **IS** de Sousa's data (exact match);
  for apes it diverges (different ape V1 source). Same-source for monkeys, see Smaers_etal_2017/primary_source_checks/.

## Same-specimen cluster (identical brains, multiple measurers)
de Sousa 2010/2013, MacLeod (Hirnforschung), Barger 2007, Smaers 2011, Semendeferi 1998/2001/2002 all
measured **overlapping/identical Düsseldorf (Zilles/Stephan) specimens** (matching catalogue IDs:
YN82-140, YN85-38, YN86-137, YN89-278, A375, 1203, Bathsheba, Zahlia, Disco, Harry, Briggs, SN382/81…).
Cross-checks *among these* test inter-rater / method consistency on the SAME brains — **not** independent
species sampling. When merging for Study 3, treat them as one collection: do not count the same brain
twice, and pick one measurement per structure.

## Rule of thumb for the merge
Prefer the **authors' own primary** value; never combine two datasets that both re-use the same
secondary source (e.g. Frahm 1984 V1 via both Bush and de Sousa) as if independent. Tag every merged
datapoint with `role` (primary/secondary) + `team` so the dependence structure stays visible.
