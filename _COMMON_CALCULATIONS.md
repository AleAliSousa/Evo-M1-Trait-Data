# Common calculations and conversion constants

Standard conversions that recur across the source papers in this repository,
collected in one place so that a paper folder's `reference_tables/` definitions
or README can point here instead of re-deriving (or silently assuming) them.
When a source paper uses one of these conversions, record it in that paper's
definitions (a `Method:` row) and, for brain-size columns, in
`_keys/brain_size_basis.csv` via `_keys/build_brain_size_basis.py`.

## 1. Brain mass <-> brain volume: specific gravity of brain tissue

`mass (g) = volume (cm3) x rho` ; `volume (cm3) = mass (g) / rho`

A converted value is an **estimate**, not a measurement. Record the direction
of the conversion and the value of rho used; never back-convert a converted
value to recover the other quantity (see `__merging_brain_mass/README__merging.md`).

| rho (g/cm3) | Source | Basis | Used in this repo by (examples) |
|---|---|---|---|
| 1.036 | Stephan (1960); standardised in Stephan, Frahm & Baron (1981), *Folia Primatologica* 35:1-29, "New and revised data on volumes of brain structures in insectivores and primates" | Specific gravity of fresh brain tissue, from the insectivore/primate comparative programme | Stephan series (weights -> volumes, incl. Stephan et al. 1991 BrV = BrW/1.036); Pirlot (1981); Pirlot & Nelson (1978); Ebinger (1974); Hofman (1985) (citing Frahm 1982); Bauernfeind et al. (2013) (mass -> "preprocessed volume"); Patzke et al. (2015) (Vb = Mb/1.036); McGuire & Ratcliffe (2011) (volume = mass/1.036); Boddy et al. (2012) (endocranial volume -> estimated mass, within a compilation); DeCasien et al. (2017) (volume -> mass, part of a compilation); DeCasien & Higham (2019) (appendix sources: BV = fresh weight/1.036); Sherwood et al. (2009) (Bush & Allman 2004 volumes -> mass); Seymour et al. (2015, 2017, 2019) (documented downstream derivation, values kept as printed volumes); Herberstein et al. (2022) (volume -> standardised mass); MacLean et al. (2014); Kverkova et al. (2018) (mass -> volume, FIXED tissue at the same value) |
| 1.032 | Zilles (1972) | Mean specific mass of 78 adult HUMAN brains | Zilles-school human volumetrics; contrasted with 1.036 in MacLeod et al. (2010), whose human volumes were shrinkage-corrected at 1.032 rather than 1.036 |
| 1.033 | Kretschmann & Wingert (1971) | Human brains | Amunts et al. (2005) human cytoarchitectonic volumes |
| 1.000 (1 g = 1 cm3) | Convention, not a measurement | Simplification adopted by Isler & van Schaik (2009) and Burger et al. (2019) | Burger et al. (2019) endocranial-volume -> mass estimates; Baker, Barton & Venditti (2025) |

Notes:
- The 1.036 figure is routinely cited as "Stephan et al. (1981)"; the value
  itself is cited to Stephan (1960). The Stephan et al. (1970) text in this
  repo states the specific gravity of fresh brains was found to be close to
  1.036 g/cm3.
- 1.036 is a FRESH-tissue value in the Stephan tradition. Kverkova et al.
  (2018) apply the same number to perfusion-FIXED tissue (their Methods give
  "fixed brain tissue density (1.036 g/cm3)") - same constant, different
  preparation state; the basis key records the state separately.
- Human-specific estimates (1.032, 1.033) differ from the comparative-mammal
  standard (1.036) by ~0.3-0.4%: immaterial for cross-species work, but the
  value a human study used should still be the one recorded for it.

## 2. Shrinkage correction (histological volumes)

Stephan-series and Zilles-school volumes are corrected for histological
shrinkage before comparison with fresh volumes; Stephan et al. (1981) list
fixation-specific correction factors. A shrinkage-corrected volume is recorded
in the basis key as `volume_shrinkage_corrected`; the uncorrected printed
value and the factor belong in the paper's definitions/README. Bauernfeind
et al. (2013) is the worked example in this repo: their "preprocessed brain
volume" (fresh mass / 1.036) is the numerator of their shrinkage correction,
not an independent volume measurement.

## 3. How to record a conversion in a paper folder

1. Definitions (`reference_tables/<item>_definitions.csv`): add a `Method:` row,
   e.g. `Method:brain_mass, brain mass (g) = brain volume (ml) x 1.036 (brain-tissue density, Stephan 1960; see _COMMON_CALCULATIONS.md)`.
2. README: state the direction ("Vb = Mb / 1.036, per the table footnote") and
   whether printed values were kept as printed (house rule: they are).
3. Brain-size columns: the basis in `_keys/build_brain_size_basis.py` must say
   the value is derived (e.g. `mass_or_volume_mixed`, `volume_from_mass`), with
   the paper's own statement quoted in `SOURCE_STATEMENTS` where available.
4. If the paper's value is computed from ANOTHER paper's printed data, add a
   row to `_keys/source_relationships.csv` (`computed_from`).

---
Draft prepared 2026-11-17 (M. Proulx / Muse). Citations to Stephan (1960),
Zilles (1972) and Kretschmann & Wingert (1971) are as given in the citing
literature (MacLeod et al. 2010; de Sousa & Wood 2007; Amunts et al. 2005);
the originals were not re-inspected for this note.
