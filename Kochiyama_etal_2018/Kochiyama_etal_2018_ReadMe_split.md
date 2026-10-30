# Kochiyama et al. (2018) — Figure 3 split into separate items

Scientific Reports 8:6296, DOI 10.1038/s41598-018-24331-0.

This ReadMe is shared by the two Figure 3 items. The data, snapshots, public TSVs,
and R scripts are split so Figure 3A and Figure 3B are treated as separate items.

## Items

| Item | What it is | Files |
|---|---|---|
| `Kochiyama_etal_2018_Figure3A` | Figure 3(a): NT/EH/MH relative volumes from the bar graphs for the 13 parcellated regions. MH = 1.0 by construction. | `Kochiyama_etal_2018_Figure3A_snapshot.csv`, `Kochiyama_etal_2018_Figure3A.csv`, `Kochiyama_etal_2018_Figure3A.R`, `10.1038%2Fs41598-018-24331-0_Figure3A.tsv` |
| `Kochiyama_etal_2018_Figure3B` | Figure 3(b): digitized absolute left/right cerebellar volumes, in cc, for Ce A and Ce P by group. | `Kochiyama_etal_2018_Figure3B_snapshot.csv`, `Kochiyama_etal_2018_Figure3B.csv`, `Kochiyama_etal_2018_Figure3B.R`, `10.1038%2Fs41598-018-24331-0_Figure3B.tsv` |

## Figure 3A columns

- `Region_code`: Kochiyama parcel label from the figure.
- `Structure`: broader anatomical grouping.
- `Subregion`: textual expansion of the parcel.
- `NT_rel`: Neanderthal relative volume.
- `EH_rel`: early Homo sapiens relative volume.
- `MH_rel`: modern Homo sapiens relative volume, fixed to 1.0.
- `source`: source paper key.
- `note`: extraction note.

## Figure 3B columns

- `Region_code`: Kochiyama cerebellar parcel label from the figure.
- `Structure`: broader anatomical grouping.
- `Subregion`: textual expansion of the parcel.
- `Group_code`: NT, EH, or MH.
- `Group`: expanded group label.
- `Hemisphere`: Left or Right.
- `Volume_cc`: digitized volume in cubic centimeters.
- `source`: source paper key.
- `note`: extraction note.

## Notes

- Figure 3A and Figure 3B are no longer combined in a single snapshot, CSV, TSV, or R script.
- Values are figure-digitized estimates from the published figure.
- This shared ReadMe is intentionally the only shared file between the two items.
