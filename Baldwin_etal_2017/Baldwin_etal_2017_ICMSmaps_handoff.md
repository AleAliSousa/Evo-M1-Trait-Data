# Baldwin et al. 2017 ICMS map figure digitization handoff

The exact open [PMC PDF](https://pmc.ncbi.nlm.nih.gov/articles/PMC6075024/pdf/bhv329.pdf) is now held as `Baldwin-2017-Intracortical-microstimulation-maps.pdf`. Tables 2, 3 and 4 are built separately. The following primary map information remains visible only as colored and sized graphical marks, without a published site-level numeric file. Do not turn the area means in Table 4 into site thresholds.

| Figure | PDF page | Case and panels | Required figure-derived item |
| --- | ---: | --- | --- |
| 6 | 7 | 14–88; C 50 ms, D 500 ms movement map, E 50:500 threshold ratio | Site coordinates and colored movement category/series; ratio color class with legend; 2 mm scale |
| 7 | 8 | 14–89; B 50 ms, C 500 ms movement map, D 50:500 and E 500:800 threshold ratios | Same, preserving train duration and ratio direction |
| 11 | 11 | 14–39 A/C, 14–124 B/D; movement/threshold maps | Movement category and site coordinates; threshold circle class/size in μA only where the printed legend supports it |
| 12 | 12 | 14–36 A/C, 14–93 B/D; movement/threshold maps | Same |

White circles mark movement sites, gray Xs no movement; B and R mark bilateral and repeated movements; stripes indicate combined movements. Figures 11–12 use **larger black circles for lower thresholds**; the printed legend gives reference sizes at 25, 100, 200, 300, 400 and 500 μA, but many individual circles are intermediate. Record an interval or visual class if exact μA is not printed; do not invent numeric thresholds. Preserve panel, case, original image coordinates, scale calibration, cortical area outlines, train duration, and multi-category hatching. Manual inspection against the printed figure is required because lines and labels overlap marks.

For each extracted figure dataset, follow repository `AGENTS.md`: create its own `<Item>_replot.R`, read the extracted item table directly, save `<Item>_replot.png`, inspect against the source, and record the command and omissions in its item README. The current PDF and this handoff do not constitute a built figure dataset or human visual signoff.

A simple connected-component pilot on Figure 6D identified only 25 candidate white site markers, whereas Table 3 reports 32 movement-eliciting sites for Case 14–88. Some markers merge with pale areas or cross hatched/outlined regions. That incomplete machine detection was not published as data. Use a checked manual or hybrid trace and reconcile site counts where the figure and table refer to the same train/case.
