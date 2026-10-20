# Bjugn__1993_TABLEIII — printed TABLE III

## Source
Bjugn, R. (1993). The use of the optical disector to estimate the number of neurons, glial and
endothelial cells in the spinal cord of the mouse — with a comparative note on the rat spinal
cord. Brain Research, 627(1), 25–33. https://doi.org/10.1016/0006-8993(93)90744-8. PMID 8293301.
This item is printed TABLE III, p.29 (PDF page 5). Unlike TABLE I/II (five-animal datasets), TABLE
III is a **single-animal worked example** — "Data from animal 1 showing how the coefficient of
error (CE) for the estimate of cell number in gray matter was calculated" — illustrating the
author's stereological CE formula on animal 1's 8 sampled slabs.

## What this item is
Eight rows (one per slab, 1–8), each carrying the printed Q- (cells counted in oblique sections),
F (fields counted), P (points on transverse sections), and the derived Xi = Q-·P/F, A = Xi·Xi,
B = Xi·Xi+1, C = Xi·Xi+2 — all exactly as printed, including the blank cells where a slab has no
successor (B blank for slab 8, C blank for slabs 7–8). The Sigma row's CE value (0.072, from
CE = sqrt((3A+C-4B)/12) / ΣXi = sqrt(84.3)/127.6) is carried as a constant column
(`CE_gray_matter_cell_number`) on every row rather than as a separate summary row, since it is one
value describing the whole slab series, not a ninth slab.

The table's own footnote is preserved verbatim in the snapshot: ΣQ-/ΣF · ΣP (= 131.6) is used for
the unbiased cell-number estimate, while Σ(Q-/F · P) (= 127.6, the value tabulated as ΣXi here) is
used only for the CE estimate — the two are not interchangeable, per the author's own note citing
ref. 32.

## Snapshot
`Bjugn__1993_TABLEIII_snapshot.csv` is a frozen printed-layout grid: caption, column-header
footnote, the 8 slab rows, the Σ row, the CE formula line, and the discrepancy note — all as
printed, losslessly, with blank cells preserved as blanks (not zero-filled or invented).

## Data role
`data_role = primary` throughout — these are the paper's own worked calculations on animal 1's
measured counts, not a compiled or derived value from elsewhere.

## Build status
Matches the conservative TABLE I/II pattern in this folder: `Bjugn__1993_TABLEIII.R` writes only
the analysis CSV by default and does not attempt a public TSV write. (TABLE IV/V in this same
folder use a different, already owner-approved script pattern that writes the public TSV
automatically — confirmed during this pass by re-running them: their R output is byte-identical to
the TSVs already committed in `__Public/comparative-data/`, so those two are in fact already
published, despite their README headers still saying "public export HOLD".) TABLE III's own public
export is left for the owner to enable via the same gate pattern, consistent with how it was first
staged for TABLE I/II.

## Source
`Bjugn-1993-The use of the optical disector to.pdf`, TABLE III, p.29 (PDF page 5).
