# Cross-publication value-match — Smaers et al. 2017 Table S1 (volumes)

`crosspub_value_match.R` matched every Smaers-2017 cortical-area volume against the merged
per-source values **by value** (species- and unit-agnostic). Smaers 2017 is a **compilation**;
its supplement (Suppl. Exp. Procedures → Data) states the sources, and the value-match confirms
each one against the raw data in this repo.

| Smaers 2017 column | Smaers 2017 cites | Value-match result | Role in 2017 |
|---|---|---|---|
| `primary_visual_gray` / `_white` | de Sousa et al. 2010 **[S6]** | **= Frahm et al. 1984 area-striata grey/white, EXACT** (14 spp, 0.0%) | **secondary** (de Sousa 2010 re-used Frahm 1984; same Vogt specimens) |
| `prefrontal_gray` / `_white` | Smaers 2010 **[S1]** + Smaers 2011 **[S2]** | **= Smaers 2011 Suppl. Table 2** (anterior section-5, summed L+R; human = mean of 8), 19/11 spp within 2% | primary (Smaers' own) |
| `frontal_motor_gray` / `_white` | Smaers 2010 [S1] + Smaers 2011 [S2] | **no consistent public match** (only scattered coincidences) — the *posterior* section-5 was **never published**, so it is not reproducible from any public table | primary (Smaers' own), **unverifiable** |
| `other_association_gray` / `_white` | (derived) | no single-source match — it is **neocortex − frontal lobe − primary visual** (per the 2017 supplement), i.e. a derived residual built from de Sousa 2010 + Stephan 1981 | **secondary / derived** |

Supplement text (verbatim): *"Prefrontal and frontal motor data was taken from Smaers et al. [S1, S2]
and Brodmann [S3]… Data on primary visual cortex was taken from de Sousa et al. [S6]. Other brain data
was taken from Stephan et al. [S7]. All data … are derived from the same specimens housed at the C&O
Vogt Institute [S8]."* (refs: S1 = Smaers 2010 PLoS ONE; S2 = Smaers 2011 BBE; S6 = de Sousa 2010
Cereb Cortex; S7 = Stephan, Frahm & Baron 1981.)

## Consequences for `merging_volumes`
- **Do NOT add Smaers 2017 `primary_visual` to the merge** — it is Frahm 1984's area striata (already
  in Tier 1). Adding it (even via de Sousa) would double-count the same Vogt-specimen measurement.
- Smaers 2017 `prefrontal` duplicates **Smaers 2011 Suppl. Table 2** (already the raw source) — use the
  2011 raw, not the 2017 compilation.
- `frontal_motor` is the only genuinely 2017-unique numeric column, but it is **not publicly verifiable**
  and is a biased anterior/posterior proxy (not the true premotor border) — flag before any use.
- `other_association` is a derived residual — recompute from primaries, don't import.

Net: Smaers 2017 Table S1 contributes **no new primary volume** to merge that isn't already present as
its primary source (Frahm 1984, Smaers 2011, de Sousa 2010, Stephan 1981). It is kept as a *secondary/
compilation* reference, flagged as such.
