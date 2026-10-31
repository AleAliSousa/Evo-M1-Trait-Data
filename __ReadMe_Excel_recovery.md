# __ReadMe.xlsx — Excel content-recovery warning

Recorded 26 October 2026. Keep this note beside the main registry so it can be found by searching for “ReadMe”, “Excel”, “recovery”, or “locked”.

## The exact symptom

> We found a problem with some content in '__ReadMe.xlsx'. Do you want us to try to recover as much as we can? If you trust the source of this workbook, click Yes.

This is a **workbook-content warning**, not evidence that the file is locked. Do not start by changing permissions or removing lock files. Different structural problems can produce the same message; diagnose the current file rather than assuming every recurrence has the same cause.

## What happened in this chat

The assistant's registry-status update inserted cells in column O at the end of four XML rows, after column AH, instead of in column order. The affected rows were 780, 781, 783, and 784 in `xl/worksheets/sheet1.xml`. These row numbers describe this incident only.

The file was writable, there was no Excel owner-lock file, and there was no workbook or sheet protection. Its ZIP archive and XML parsed successfully. Those checks did **not** detect the out-of-order cells and were insufficient to establish Excel compatibility.

The repair sorted the existing cell elements within each affected row into numeric column order (A, B, …, Z, AA, AB, …). It did not recreate their contents or resave the workbook through a spreadsheet library. Every cell value, ordinary and array formula, cached result, and style was compared before and after; unchanged ZIP parts were preserved.

**Verification limit:** the structural repair and preservation checks passed. Reopening in desktop Excel was not verified by the assistant because computer-control permission was unavailable. The user's successful reopen is the final compatibility check; do not describe it as already verified.

## If it happens again

1. Preserve a timestamped copy of the current workbook before recovery or repair. If Excel already recovered a copy, save that separately and retain its recovery log. Do not overwrite the only unrecovered original.
2. Record the exact error and file path. Distinguish this content-recovery warning from a read-only, locked-for-editing, access-denied, or OneDrive-sync message.
3. Avoid concurrent edits: preserve any unsaved work and close this workbook in Excel before an external repair. Check for a build process or another session writing the same file.
4. Inspect the XLSX archive and worksheet XML. For each row, check that cell references are unique, match the row number, and are in **numeric column order**. Sorting the strings alphabetically is incorrect: AA must follow Z, not A. Also check row ordering and any errors identified by Excel's recovery log.
5. If unordered cells are the only confirmed defect, reorder those existing XML elements without changing their contents. Preserve namespaces, relationships, formulas, cached values, styles, and all unrelated archive parts. If another defect is found, repair that specific defect instead.
6. Compare every cell by coordinate before and after, including formulas, cached results, styles, and the 38 items added in this batch. A streaming reader can omit malformed out-of-order cells, so do not use streaming row output alone as the baseline. Array formulas must be compared by their attributes/text, not Python object identity.
7. Check that the on-disk original has not changed during the repair, then replace it with the validated repaired copy. Dismiss the old recovery prompt and reopen the file from disk in desktop Excel. Confirm it opens without recovery and that registry rows and calculated item names remain intact.

Do not blindly rebuild the workbook with `openpyxl.save()` or LibreOffice to silence the warning: that can change Excel-specific structures or discard formula caches. Never save a workbook loaded with `data_only=True` over the original; it would replace formulas with cached values.

## Prevention for future registry edits

- Insert new cells in column order, or explicitly sort the cell elements before writing worksheet XML.
- Validate cell ordering and uniqueness on every edited worksheet, not just ZIP integrity and XML parseability.
- Preserve existing formulas and their cached results when editing text-only notes.
- Check for concurrent changes before saving, and keep a timestamped backup outside the public repository.
- Verify opening in Excel when available. Clearly distinguish structural checks from an actual Excel-open test.
- The repository's `_tools/lock_sources.sh` intentionally excludes `__ReadMe.xlsx`; frozen-source locking is a separate mechanism.

## Where the evidence and backups are

Private audit directory, outside the public data repository:

`../../Evo-M1-Trait-Data-restricted/restricted_checks/Nick_Fran_build_2026-10-25/`

Relative paths from this note:

- [Workbook immediately before the cell-order repair](../../Evo-M1-Trait-Data-restricted/restricted_checks/Nick_Fran_build_2026-10-25/registry_before_cell_order_repair_20261025_223900.xlsx)
- [Workbook before the status-note update](../../Evo-M1-Trait-Data-restricted/restricted_checks/Nick_Fran_build_2026-10-25/registry_before_status_20261025_215745.xlsx)
- [Original registry before the 38-item batch](../../Evo-M1-Trait-Data-restricted/restricted_checks/Nick_Fran_build_2026-10-25/before/__ReadMe.xlsx)
- [Batch coverage and intentional exclusions](____TODO/Nick_Fran_sources_2026-10-24/build_status.csv)

These backups are evidence, not automatic restore targets: an older version can omit later legitimate edits. Preserve the current file and compare differences before restoring anything.

## Request to give a future assistant

“Read `__ReadMe_Excel_recovery.md` beside the registry. Excel shows the content-recovery warning again. Back up the current file, diagnose its actual structural defect, and repair it while preserving all registry data, formulas, cached results, and styles. Check cell ordering, but do not assume it is the cause this time. Verify reopening in Excel if available.”

## Recurrence on 31 October 2026: same warning, different cause

**Cause.** Cell order was fine this time. Between 23:58 on 30 October and 00:12 on 31 October (Pacific), a script updated 171 Sheet1 cells (status notes with a light-blue fill). It rewrote `xl/worksheets/sheet1.xml` and `xl/styles.xml` with Python's `xml.etree.ElementTree`. ElementTree renamed the namespace prefixes (`mc`, `xr`, `x14ac`, `r` became `ns1` to `ns4`) and dropped declarations it judged unused. The root `mc:Ignorable` value still listed `x14ac xr xr2 xr3` (sheet) and `x14ac x16r2 xr` (styles), but those prefixes were no longer declared. Excel therefore rejects the parts, and Excel for the web refused to open the file at all (unsupported workbook).

**Tell-tale signs.**
- `ns0:`/`ns1:`-style prefixes in a worksheet or styles part.
- An XML declaration in single quotes (`<?xml version='1.0' encoding='UTF-8'?>`).
- `standalone="yes"` missing from the XML declaration.

**Repair.** The repair changed those two parts only.
- It restored the original prefixes and namespace declarations, copied byte-for-byte from the pre-edit backup `_checks/__ReadMe_backup_20261031_pre_edit.xlsx`.
- It left all element names, attribute values and text, and the other 23 ZIP parts, unchanged.

**Checks.**
- The namespace-aware content is identical to the damaged file.
- All 32,334 cells on the three sheets are identical, including values, the 7,277 formulas (1,725 of them array formulas), cached results and styles.
- The 171 new cells are present.
- Excel for the web opened the repaired copy and returned every Sheet1 value in A1:AH943, matching the stored values.

The assistant's tools can change an Excel file only through Excel for the web, which could not open the damaged file. So the owner puts the repaired copy in place with an in-place overwrite, which keeps the same file and its version history. The owner's reopen in desktop Excel is the final check.

**Evidence (private):** `../../Evo-M1-Trait-Data-restricted/restricted_checks/ReadMe_recovery_2026-10-31/` contains:
- the damaged file before repair;
- the repaired file;
- a test copy of the damaged file;
- `RECOVERY_LOG_2026-10-31.md`, with hashes and the full list of checks.

**Add to step 4 of "If it happens again".** In every XML part, each prefix named in `mc:Ignorable` (or in an `mc:Choice Requires`) must be declared:

```
python3 - __ReadMe.xlsx <<'EOF'
import re, sys, zipfile
z = zipfile.ZipFile(sys.argv[1])
for n in z.namelist():
    if n.endswith(('.xml', '.rels')):
        t = z.read(n).decode('utf-8', 'replace')
        declared = set(re.findall(r'xmlns:([\w.-]+)=', t))
        for v in re.findall(r':Ignorable="([^"]*)"', t):
            missing = [p for p in v.split() if p not in declared]
            if missing:
                print(n, 'undeclared Ignorable prefixes:', missing)
EOF
```

**Prevention.** Scripts that edit registry XML must not re-serialise it with `xml.etree.ElementTree`. Use `lxml` (it keeps the original prefixes) or targeted text edits. Then run the check above, as well as the cell-order check, before the file syncs.
