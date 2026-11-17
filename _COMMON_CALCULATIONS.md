# Common calculations and conversion constants

Standard conversions that recur across the source papers in this repository,
collected in one place so that a paper folder's `reference_tables/` definitions
or README can point here instead of re-deriving (or silently assuming) them.
When a source paper uses one of these conversions, record it in that paper's
definitions (a `Method:` row) and, for brain-size columns, in
`_keys/brain_size_basis.csv` via `_keys/build_brain_size_basis.py`.

## Kinds of calculation - keep them distinct

Not everything in this file is the same kind of operation, and the dataset
treats them differently:

1. **Corrections of raw data** (section 2: shrinkage correction). The tissue
   physically changed during processing, so the printed value mis-states the
   quantity it claims to measure; the correction is *required* to recover the
   fresh quantity. A corrected value stands as the measurement.
2. **Conversions between measures of the same brain** (section 1: mass <->
   volume via specific gravity). One quantity was measured; the other is the
   same brain expressed the other way, via a constant. The converted figure
   is an estimate of that brain's other measure, and is labelled as derived.
3. **Estimates from a different structure** (section 4: endocranial volume ->
   brain mass). The target quantity was not measured at all; a proxy (the
   cavity that held the brain) stands in for it. These sit in their own
   poolable group and are the last resort in the combined trait.
4. **Indices** (section 5: EQ, EI, Nc). An index is not an estimate of any
   physical quantity - it is a comparative statistic computed from measured
   values. Indices are carried as printed, never pooled across definitions,
   and never substituted for a measurement.

The merges perform no arithmetic of kinds 1-3 themselves: corrections and
conversions arrive already applied inside the source papers. What the
brain-mass merge does is *select* among measured and converted values under
basis tiers - see the combined trait in section 4.

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

## 4. Brain mass estimated from endocranial volume (ECV)

Endocranial volume is the capacity of the braincase: brain + meninges +
extracerebral CSF + vessels. It is therefore NOT a brain volume. The
endocranial-volume merge itself converts nothing
(`__merging_endocranial_volume/README__merging.md`: "Cranial capacity is not
brain weight"), but the brain-mass side of the dataset IS deliberately
inclusive of converted values: the combined trait **Brain mass (measured or
estimated from volume)** selects one existing value per species - measured
mass first, then a brain-tissue-volume estimate, then an endocranial-volume
estimate, then an unresolved-volume estimate (1,277 species: 678 measured,
590 from endocranial volume). It creates no new values and averages nothing;
provenance (`selected_measure`, `measurement_method`, basis) is retained per
row, and the stricter separate traits remain available. The ECV-based values
it selects arrive pre-computed inside source papers, by one of these routes:

| Route | Used by (in this repo) | Note |
|---|---|---|
| ECV x 1.036 | Boddy et al. (2012) (>=273 values); Seymour et al. (2015, 2017, 2019) as a `Method:brain_mass` note | Applies the tissue density to the whole cavity, i.e. treats the non-brain contents as if they were brain; overestimates by the meningeal/CSF fraction |
| ECV at 1 g = 1 cm3 | Baker, Barton & Venditti (2025) ("where only endocranial volumes were available they were converted to mass at 1 g = 1 cm3") | Same shortcut, density set to 1 |
| Cranial capacity -> brain volume -> brain mass, Ruff et al. (1997) | Weaver (2001), Table A.15 (fossil hominins) | Two-step conversion with an explicit capacity-to-volume step; basis key code `mass_from_volume_or_ecv`. Weaver also takes fossil body masses from Ruff et al. (1997) |
| Meningeal correction first, then density | (literature standard for thick-meninges clades; e.g. Benoit 2015 for proboscideans: brain volume = 0.8877 x endocast volume - 2.9408, meninges ~14% of the cavity, then x 1.036) | No in-repo source currently uses a clade-specific meningeal regression; flagged here so a future one is recognised |

In the brain-mass merge all such values carry the poolable group
`Brain_Mass_estimated_from_endocranial_volume` and are selected only after
measured masses and brain-tissue-volume estimates.

## 5. Encephalization indices (several, mutually incompatible)

Papers print whichever index their tradition uses; the definitions record
which. Never pool across rows of this table.

| Index | Formula / reference line | Used by |
|---|---|---|
| Jerison EQ | EQ = brain (g) / (0.12 x body (g)^(2/3)) (Jerison 1973) | Shoshani et al. (2006) prints this form |
| Martin EQ | expected brain (g) = 11.22 x body (kg)^0.75 (Martin 1981); EQ after Martin (1981) / Ruff et al. (1997) | de Sousa (2008), de Sousa et al. (2009, 2010), Sherwood et al. (2003), Weaver (2001, as Martin 1990 CQ/EQ) |
| Stephan EI | observed brain weight / expected from the Tenrecinae reference line (log-log, slope 0.63) (Stephan et al. 1988) | Stephan et al. (1988); Deaner et al. (2007) derived indices |
| Changizi index | encephalization index after Changizi (2001b) | Changizi (2003) |
| Residuals | brain-size residuals from a fitted allometry | Nimchinsky et al. (2000) and many analysis papers |

Related derived index: **Jerison's extra cortical neurons Nc** (and Herschel's
index H) - Dunbar (1992), Riddell & Corl (1977); Sawaguchi (1988) prints the
working formulae (Jerison 1973 / Hofman 1982), e.g.
Nc = (E^(2/3) - (0.03 x P^(2/3))^(2/3)) x 8 x 10^7.

## 6. Other recurring derivations

- **Unilateral -> bilateral**: 2 x unilateral, and L + R sums, are recorded as
  `derives_from` relationships in `_keys/source_relationships.csv`, never as
  independent measurements.
- **Body mass from skeletal/dental measures** in fossil work: Auerbach & Ruff
  (2004, 2006) via Powell et al. (2024); Ruff et al. (1997) body masses in
  Weaver (2001).
- **Stereological overcounting correction** applied to raw profile counts
  (Nudo et al. 1995 `correction_term`).

---
Prepared 2026-11-17 (M. Proulx / Muse); sections 4-6 added the same day. Citations to Stephan (1960),
Zilles (1972) and Kretschmann & Wingert (1971) are as given in the citing
literature (MacLeod et al. 2010; de Sousa & Wood 2007; Amunts et al. 2005);
the originals were not re-inspected for this note.
