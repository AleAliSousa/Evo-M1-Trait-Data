# github.com/seanfw/macaque-receptor-gradients — provenance copy

Named in the Code availability statement of Froudist-Walsh et al. 2023 (article PDF p. 17: "Code used for data
integration and analysis in this study is available on GitHub (github.com/seanfw/macaque-receptor-gradients and
github.com/seanfw/genemapper)").

Checked 2026-11-16 via the GitHub API at the head of the default branch `main`, commit
`57d2538dacd0c1cb5651e3842fb07522134f9ab9` (last push 2023-05-29). **The repository contains a single file, `README.md`
(2992 bytes) — no data files and no code.** Its README describes the analyses the code would cover and points to the
data elsewhere:
- Julich Brain Macaque Maps and surface representations: BALSA study W336 (the paper's Data availability names study P2Nql);
- "Receptor per neuron data (table format)": EBRAINS KG instance e39a0407-a98a-480e-9c63-4a2225ddfbe4 (the paper names doi:10.25493/5HK3-S8M);
- HCP, Allen Human Brain Atlas, NeuroQuery for the other analyses.

Consequently **no per-mg-protein receptor table and no neuron-density table could be downloaded from GitHub**; the
per-neuron tables in this folder's two items come from the Supplementary Information PDF only, and the fmol/mg protein
source values remain unavailable in the repo. The EBRAINS and BALSA deposits were not downloaded (provenance pointers
only; EBRAINS download would need the data-proxy bucket of dataset 5HK3-S8M).

| file | what it is | units | per-mg-protein source of the per-neuron table? |
|---|---|---|---|
| `README.md` | the repository's README at commit `57d2538` | — | no (text only) |

`download_manifest.csv` records repo_path, raw URL, bytes, sha256, commit and download date (same columns as
`Hansen_etal_2022/github_hansen_receptors/download_manifest.csv`). Not an item; nothing here is built.
