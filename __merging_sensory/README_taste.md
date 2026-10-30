# Added taste, social, mirror, play and anatomical sources

Rebuild all registered items and domain outputs with `Rscript _tools/build_nick_fran_sources.R` from any working directory. Each domain also has its own `*_compiled.R` reader. The app reads the three canonical `*_long.csv` outputs directly; no duplicate app data copies are created.

`*_observations_long.csv` retains source item, source row, printed taxon, resolver identity, measurement code, reference keys, role, context, and the observation. `*_long.csv` selects one reporting value per species and protocol-specific measure. `n_sources=1` denotes the selected report, not an estimate of independent primary studies; `n_reports` counts retained reports. Alternative values and conflicts remain explicit. These views complement the established domain merges; they do not feed reprinted anatomy or body covariates back into those pools.

Sweet taste: direct primary intervals take precedence over compiled midpoints. Otherwise, the 2023 compilation has reporting priority over the 2019 compilation, with shared reports counted once. Conflicting secondary reports receive an unresolved text value, so they cannot silently enter numeric plots. Human detection, animal preference, bitter avoidance in 30 mM sucrose, sour-mixture tolerance, and Weber ratios are distinct endpoints.

Social composition: Carnes2011 has reporting priority where present; Lindenfors2007 supplies otherwise absent species. Differing reports are not averaged. These tables share source lineages and are not two independent replications or a recovered copy of Nunn2001.

Play: Kerney OnlineResource2 supplies time-budget data once; OnlineResource1 is its linked derivation. Bartlett age-class percentages use social activity as denominator, monthly graph readings use all activity, and Mallavarapu percentages use play time. They remain separate. Monthly Bartlett readings are approximate (±0.2 percentage points), not twelve independent studies.

Mirror: keep study, individual/cohort, training, test context, and response type. An untested or inconclusive response is not a failure. Suddendorf's Arjuna repeat does not add a second animal. Povinelli Table5 provides 30 subjects, with prior SR status distinct from mark-test outcome. Reiss's eight sessions are on one dolphin. Self-inspection and genital-related activity are not automatically coded as mark-test success. Reused literature rows in comparative mirror tables do not enter as independent primary evidence.

Anatomy: only current-study CC/SC/FL and PCH measurements enter from the Smaers tables; other columns are provenance. Smaers2013 PCH is kept left/right and averaged only across specimens within that source. Kowianski's fixed-tissue claustrum measurements remain explicitly labelled; the authors did NOT convert them to fresh-brain volumes. Neuron number is computed from optical-disector density times volume, not a second independent neuron-count experiment. No unilateral value is silently doubled. Common-name taxa without a stated species remain unspecified.

Reviews and Smith–Jungers secondary body masses are not ingested as new primary samples. The original Nunn2001 database remains unavailable. Constructed figure items generally contain exact published endpoints, not all points on response curves; each README identifies its coverage.
