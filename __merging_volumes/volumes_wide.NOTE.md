# `volumes_wide.csv` — hemisphere methodology note

`volumes_wide.csv` reports **whole-structure, both-hemisphere volumes** (mm³, one row per
species). How each both-hemisphere value was obtained (see also README__merging.md
"Hemispheres", and the per-row audit in `volumes_flags.csv`):

1. **Already both-sides at source** — most papers report a both-hemisphere (or
   one-hemisphere-doubled) total; that value is used directly.
2. **Both sides measured separately → SUM (left + right).**
   - *Bauernfeind 2013 insula* (granular / dysgranular / agranular / FI / total): left from
     the paper's **Table 1**, right from **Table 2**. Where both hemispheres were measured
     (humans + great apes) the both-hemisphere volume is `left + right`.
3. **Only one side measured → ESTIMATE as 2× (assume symmetry), flagged.**
   - *Bauernfeind 2013 insula*, species with left only → `2 × left`.
   - *Stephan 1981 vestibular complex / nuclei* (one side only per Baron 1988), species with
     no bilateral source → `2 × unilateral`.
   - Every such estimate is recorded in `volumes_flags.csv` with
     `flag = estimated_bilateral_from_unilateral`. The one-side value is **kept** as its own
     `…_unilateral_Vol.mm3` / `…_left_Vol.mm3` / `…_right_Vol.mm3` column and is never
     overwritten.
4. **Real both-sides beats an estimate.** Where a structure has both a genuine both-sides
   measurement and a one-side measurement for the same species (e.g. *Complexus vestibularis*:
   Baron 1988 bilateral vs Stephan 1981 unilateral), the genuine both-sides value is used and
   **no** doubled estimate is generated.

Side-specific columns (`…_left_`, `…_right_`, `…_unilateral_`) are retained alongside the
both-hemisphere columns for traceability.
