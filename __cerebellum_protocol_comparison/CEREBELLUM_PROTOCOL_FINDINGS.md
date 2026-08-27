# Findings — cerebellum protocol pooling

Produced by `cerebellum_protocol_comparison.R`. All inputs public and in this
repo; see the [ReadMe](cerebellum_protocol_comparison.ReadMe.md) for the
three-protocol background.

---

## F1. Both compilations pool incompatible cerebellum protocols in one column

| dataset | cited source | implied protocol | species | median % from Stephan raw | median % from MacLeod |
|---|---|---|---|---|---|
| DeCasien & Higham 2019 | Stephan et al. 1981 (ref 24) | with pons + peduncles | 40 | **0.0** | 14.3 |
| DeCasien & Higham 2019 | MacLeod et al. 2003 (ref 61) | *sensu stricto* | 15 | 9.6 | **3.5** |
| DeCasien & Higham 2019 | other refs | unstated | 13 | 16.1 | 4.2 |
| Smaers et al. 2018 | MacLeod et al. 2003 | *sensu stricto* | 17 | 9.6 | **3.5** |
| Smaers et al. 2018 | Maseko et al. 2012 | unstated | 25 | 7.7 | — |
| Smaers et al. 2018 | Smaers et al. 2011 | unstated | 8 | 13.6 | — |

The 0.0 / 3.5 diagonal confirms the attributions are honest: rows citing Stephan
reproduce Stephan's pons-inclusive figures (24 of 24 within 2%), rows citing
MacLeod sit near MacLeod. **The problem is that both land in the same column.**

DeCasien is explicit about doing this — its own "Brain Region Data Notes" sheet,
note A: *"Removed cerebellum, replaced with measurement from [61]"*, ref 61
being MacLeod et al. 2003. So the substitution is documented per row; what is
not flagged is that the substituted values are measured to a **different
anatomical boundary** than the rows they sit beside.

## F2. Six species carry *both* protocols inside DeCasien

The clearest demonstration — same species, same column, two protocols:

| species | Stephan-cited row | MacLeod-cited row | Stephan 1981 | MacLeod 2003 |
|---|---|---|---|---|
| *Macaca mulatta* | 8965 | 8085.7 | 8965 | 7233.3 |
| *Saimiri sciureus* | 2260 | 2000 | 2260 | 2050 |
| *Aotus trivirgatus* | 1873 | 1750 | 1873 | — |
| *Erythrocebus patas* | 8738 | 7900 | 8738 | — |
| *Alouatta seniculus* | 5699 | 4150 | — | — |
| *Lophocebus albigena* | 10726 | 11700 | — | — |

Any analysis treating this column as one measurement compares a
pons-and-peduncle-inclusive volume against a *sensu stricto* one, with the
protocol difference absorbed into whatever biological effect is being tested.

## F3. 7 of 17 Smaers rows attributed to MacLeod are for species MacLeod's table does not contain

MacLeod et al. 2003 Table 1 covers **11** species, all apes plus a few
anthropoid comparators. Smaers et al. 2018 attributes cerebellum values to
MacLeod 2003 for 17, including *Alouatta seniculus*, *Ateles paniscus*,
*Cebus albifrons*, *Cercocebus torquatus*, *Lophocebus albigena*,
*Aotus trivirgatus*, and *Erythrocebus patas* — none of which appear in that
table as built here. DeCasien shows the same pattern (7 of 15).

Two readings, not distinguishable from the public tables: the values may come
from a MacLeod source other than Table 1 (the 2000 dissertation, or unpublished
Düsseldorf material), or the attribution may be inherited from an intermediate
compilation. Either way the citation as printed cannot be checked against the
cited table, and these rows should be treated as unverified provenance rather
than as MacLeod-protocol values.

## F4. The published justification for pooling has the size gradient backwards

MacLeod et al. 2003, and MacLeod 2000 p. 57, both justify comparison with the
Stephan dataset on the grounds that pontine volume is a very small part of
cerebellar volume (citing Matano et al. 1985a), with the 2003 paper adding that
volumes are comparable *"especially in the larger brained primates."*

Testing that against Stephan et al. 1981 cerebellum vs Matano et al. 1985b
ventral pons, 34 species in common:

- ventral pons = **5.1%** of Stephan cerebellar volume at the median, range
  **0.8%–11.7%**
- the fraction **increases** with cerebellum size: Spearman ρ = **0.86**
  (p ≈ 8e-11); allometric slope of log pons on log cerebellum = **1.32**
  [95% CI 1.24–1.40], significantly greater than 1
- median by cerebellum-size quartile: **3.1% → 5.0% → 6.7% → 8.1%**
- hominoid median **9.1%**: *Hylobates* 9.7%, *Pan* 9.1%, *Gorilla* 7.8%;
  Zilles & Rehkämper's independently measured *Pongo* agrees at 4300/47200 =
  **9.1%**

So the discrepancy is smallest in small-brained species and **largest in the
apes** — the opposite of the stated qualifier, and the apes are MacLeod's entire
sample. A ~9% offset is also not small relative to the effects these datasets
are used to test.

Pooling may still be defensible for some questions, but not on this
justification and not without stating the offset. The correct transformation is
available: subtract Matano ventral pons from the Stephan cerebellum. MacLeod
2000 p. 57 notes Matano performed exactly this subtraction but never published
the resulting volumes.

## F5. Caveat on the correction itself

MacLeod 2000 p. 90 reports that Matano's lateral cerebellar nucleus and
principal inferior olive volumes run consistently higher than hers, attributing
this to Matano's ventral pons measurements using only 5–9 sections per structure
— below the minimum Zilles et al. (1982) determined for statistical reliability
— and diverging most in hominoids, where those nuclei are hardest to delineate.

That matters here because Matano 1985b **is** the subtrahend in F4. The
correction carries its own documented uncertainty, largest in exactly the
hominoid range where the correction is most needed. The direction of F4 does not
depend on it (Zilles' independent *Pongo* measurement gives the same 9.1%), but
the precise per-species offset does.

---

## Recommendations

1. **Split the standardized term.** `Cerebellum` currently absorbs three
   compositions. Suggest `Cerebellum_with_pons_and_peduncles` (Stephan series),
   `Cerebellum_with_peduncles` (Zilles), `Cerebellum_sensu_stricto` (MacLeod),
   with any canonical `Cerebellum` derived explicitly and documented.
2. **Record composition in `definitions.csv`.** Of 43 variables mapped to
   `Cerebellum` across this repo, **3 state whether pons/brachium is included;
   40 are silent.** No definitions file mentions "peduncle" at all.
3. **Flag the pooled columns.** DeCasien's and Smaers' cerebellum columns are
   mixed-protocol and should carry a per-row protocol field, not just a citation.
4. **Treat the 7 unverifiable MacLeod attributions as open provenance** until
   the intended MacLeod source is identified.
5. **Fix a malformed definitions row.** In
   `Ashwell__2020/Ashwell__2020_definitions.csv`, the standardized-term column
   for `pn_rttg_volume_mm3` (basilar + reticulotegmental pontine nuclei) holds a
   fragment of the description (`" in cubic millimetres"`) instead of a term, so
   an automated reader cannot find Ashwell's pons variable. Ashwell is otherwise
   the model case: corpus cerebelli measured with the pontine nuclei kept
   separate and therefore addable back.
