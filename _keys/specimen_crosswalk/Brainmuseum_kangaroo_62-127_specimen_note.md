# Brain Museum gray kangaroo accession collision

## Core problem

The [Brain Museum western gray kangaroo page](https://brainmuseum.org/specimens/diprotodontia/graykangaroo/index.html) and the [Heuer et al. 2023 author image](https://github.com/neuroanatomy/comp-cb-folding/blob/8b603fb0bf711ece57ddb658d39d3fd5e01ff20e/data/raw/img/cb/graykangaroo_cor_cell.json.cb-50%25.png) both display `62-127` for *Macropus fuliginosus*. [Fobbs & Johnson 2011 Table S2](../../Fobbs_etal_2011/Fobbs_etal_2011_TableS2.csv) instead lists `62-127` as a little brown bat (row 12) and `62-167` as a kangaroo (row 128). The bat and kangaroo cannot be joined merely because one accession string is shared.

## Registry treatment

The Heuer image is registered as `BRAINMUSEUM-KANGAROO-62-127`. The Fobbs bat remains `FOBBS-WELKER-62-127`; Fobbs kangaroo `FOBBS-WELKER-62-167` remains separate. The Heuer source-image audit flags the collision. Do not substitute `62-167` for the visible `62-127` without inspecting the original slide or museum accession records.

The next check is an institutional slide or catalog record that reconciles the two numbers and the Fobbs species labels. No taxonomic order or species identity was changed from this accession conflict.
