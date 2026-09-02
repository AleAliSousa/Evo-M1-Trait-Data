#!/usr/bin/env Rscript
# restore_registry_rows.R
# -----------------------------------------------------------------------------
# Restore registry rows that have gone missing from __ReadMe.xlsx.
#
# Sheet1 has lost whole rows more than once. A lost row is quiet: the merges look
# an item name up with match(), get NA, and -- before the guards added on
# 2026-08-20 -- built the path __Public/comparative-data/NA.tsv, which really
# existed as a stale byte-identical duplicate of the Sherwood 2004 table. So the
# merge read the WRONG table rather than stopping.
#
# The tell that a row has been lost is an ORPHANED TSV: a file in
# __Public/comparative-data/ whose name appears in no row's "Item encoded".
# _checks/check_item_name_resolution.R reports these; this script puts the rows
# back. Found missing on 2026-08-20 (all six TSVs on disk, all six rows gone):
#
#   Item name                     Consequence of the loss
#   ---------------------------   ---------------------------------------------
#   Zilles_Rehkämper_1988_Tab...  halted volumes_compiled.R + _DeCasien.R
#   Zilles_etal_2013_Table1       gyrification_compiled.R read NA.tsv instead
#   Young_etal_2013_Table1        cortical_areas_compiled.R read NA.tsv instead
#   Young_etal_2013_b_Table1      the epileptic-baboon table became unreachable
#   Upham_etal_2019_DNAonlyMCC    the project's source phylogeny became unreachable
#   Winkler_Bryant_2021_Figure1   play-vocalisation cladogram became unreachable
#
# Plus one repair: the Zilles & Rehkämper ISBN was found stranded in the Johnson
# et al. 2016 row's column C -- the Johnson citation had been pasted over the old
# Zilles row and column C ("DOI if different") never cleared. Since column C
# overrides the DOI, Johnson resolved to ISBN%3A9780195043716_Table1 (does not
# exist) while its real TSV sat unused on disk.
#
# DIVISION OF LABOUR (the same one __register_cortical_layer_builds_20260815.R
# follows): this script writes only the hand-entered source/descriptive fields.
# _tools/file_list.R owns the E:M naming formula family and their cached
# values, and regenerates AUTO_Public_TSV_FileList. So:
#
#     Rscript _tools/restore_registry_rows.R         # put the rows back
#     Rscript _tools/file_list.R                     # fill E:M, refresh caches
#     Rscript _checks/check_item_name_resolution.R   # confirm, expect exit 0
#
# Until file_list.R runs, a restored row has no Item name and no merge can see
# it -- check_item_name_resolution.R reports exactly that as "rows with a
# citation but no Item name".
#
# Idempotent: rows already present are skipped, so this is safe to re-run after
# the next loss. Row numbers are never hard-coded -- Sheet1 re-sorts itself, so a
# cached row number goes stale; rows are appended after the last populated row
# and the Johnson row is located by its DOI.
#
# NOTE ON Young_etal_2013_b
#   Its README claims the registry Item name is Young_etal_2013_Table1, shared
#   with the M1 paper and "disambiguated by DOI". A merge cannot disambiguate by
#   DOI -- it holds only the Item name, and match() silently takes the first hit.
#   The build script itself already looks the row up as Young_etal_2013_b_Table1,
#   and column B ("sequence") is the sheet's own mechanism for exactly this case
#   (cf. Sherwood_etal_2004_I). So the row is restored with B = "b", which makes
#   the registry agree with the build script and with the folder's local file
#   names. The README's paragraph is now out of date.
# -----------------------------------------------------------------------------

suppressPackageStartupMessages({
  library(openxlsx)
  library(readxl)
})

# ---- Paths ------------------------------------------------------------------
.script_path <- local({
  argv <- commandArgs(FALSE)
  f <- sub("^--file=", "", argv[grep("^--file=", argv)])
  if (length(f) == 1L && nzchar(f)) return(normalizePath(f))
  sf <- tryCatch(normalizePath(sys.frames()[[1]]$ofile), error = function(e) NULL)
  if (!is.null(sf) && nzchar(sf)) return(sf)
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  normalizePath(getwd())
})
root_dir <- local({
  d <- if (file.exists(.script_path)) dirname(.script_path) else normalizePath(getwd())
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d
  else if (file.exists(.script_path)) dirname(.script_path) else normalizePath(getwd())
})
readme_xlsx <- file.path(root_dir, "__ReadMe.xlsx")
tsv_dir     <- file.path(root_dir, "__Public", "comparative-data")
sheet       <- "Sheet1"

# -----------------------------------------------------------------------------
# The rows to guarantee. `item_name` is not written -- file_list.R derives it
# from A, B and D -- it is recorded here so this script can tell whether the row
# is already present, and so the file documents what each row is FOR.
# -----------------------------------------------------------------------------
ROWS <- list(
  list(
    item_name = "Zilles_Rehkämper_1988_Table12-2",
    item_encoded = "ISBN%3A9780195043716_Table12-2",
    fields = list(
      `Citation (APA 7th-Annotated)` = paste0(
        "Zilles, K., & Rehkämper, G. (1988). The brain, with special reference to the ",
        "telencephalon. In J. H. Schwartz (Ed.), Orang-Utan Biology (pp. 157-176). ",
        "Oxford University Press."),
      `DOI if different from article or doi Alt` = "ISBN:9780195043716",
      `Item number` = "Table 12-2",
      `Item full original title` =
        "Table 12-2. Volumes of Brain Components and Their Percentages of Total Brain Volume",
      `Note about item` = paste0(
        "RESTORED: row had been lost; its ISBN survived only as a stray value in the Johnson ",
        "et al. 2016 row's column C. Structure-as-rows for a single species (Pongo), 18 ",
        "structures printed in cc3 (= cm3); the R step converts to mm3. Original source of the ",
        "orang-utan brain-structure volumes. On-disk files use the ASCII folder spelling ",
        "Zilles_Rehkämper_1988; the registry Item name keeps the umlaut, which is what the ",
        "volumes merges look up."),
      `Progress stage` = "FINISHED",
      Snapshot = "Zilles_Rehkämper_1988_Table12-2_snapshot.xlsx",
      `Data readable file, can use this` = "Zilles_Rehkämper_1988_Table12-2.csv",
      `Source Type` = "Book chapter",
      `Source format` = "PDF table")
  ),
  list(
    item_name = "Zilles_etal_2013_Table1",
    item_encoded = "10.1016%2Fj.tins.2013.01.006_Table1",
    fields = list(
      `Citation (APA 7th-Annotated)` = paste0(
        "Zilles, K., Palomero-Gallagher, N., & Amunts, K. (2013). Development of cortical ",
        "folding during evolution and ontogeny. Trends Neurosci, 36(5), 275-284. ",
        "https://doi.org/10.1016/j.tins.2013.01.006"),
      `Item number` = "Table 1",
      `Item full original title` = paste0(
        "Table 1. Brain size and gyrification index (GI) in various mammalian orders, ",
        "families, and species"),
      `Note about item` = paste0(
        "RESTORED: row had been lost, so Zilles_etal_2013_Table1.R could not resolve an Item ",
        "encoded and skipped its TSV, and gyrification_compiled.R resolved the item to NA and ",
        "silently read NA.tsv. 45 non-primate mammals, 10 orders; no primates in this table ",
        "(the paper's primate GI scaling is Figure 2)."),
      `Progress stage` = "FINISHED",
      Snapshot = "Zilles_etal_2013_Table1_snapshot.xlsx",
      `Data readable file, can use this` = "Zilles_etal_2013_Table1.csv",
      `Source Type` = "Journal article",
      `Source format` = "PDF table")
  ),
  list(
    item_name = "Young_etal_2013_Table1",
    item_encoded = "10.3389%2Ffncir.2013.00030_Table1",
    fields = list(
      `Citation (APA 7th-Annotated)` = paste0(
        "Young, N. A., Collins, C. E., & Kaas, J. H. (2013). Cell and neuron densities in the ",
        "primary motor cortex of primates [Original Research]. Front Neural Circuits, 7(30), ",
        "30. https://doi.org/10.3389/fncir.2013.00030"),
      `Item number` = "Table 1",
      `Item full original title` =
        "Table 1. Cell and neuron densities in the primary motor cortex (M1) of primates",
      `Note about item` = paste0(
        "RESTORED: row had been lost, so cortical_areas_compiled.R resolved this item to NA ",
        "and read NA.tsv (the Sherwood 2004 orofacial table) in its place. Supplies the ",
        "regional M1 surface area (M1_Surface_Area.mm2). Team Kaas (Vanderbilt). Distinct ",
        "from the epileptic-baboon paper in folder Young_etal_2013_b, registered separately ",
        "as Young_etal_2013_b_Table1."),
      `Progress stage` = "FINISHED",
      Snapshot = "Young_etal_2013_Table1_snapshot.xlsx",
      `Data readable file, can use this` = "Young_etal_2013_Table1.csv",
      `Source Type` = "Journal article",
      `Source format` = "PDF table")
  ),
  list(
    item_name = "Young_etal_2013_b_Table1",
    item_encoded = "10.1073%2Fpnas.1318894110_Table1",
    fields = list(
      `Citation (APA 7th-Annotated)` = paste0(
        "Young, N. A., Szabo, C. A., Phelix, C. F., Flaherty, D. K., Balaram, P., ",
        "Foust-Yeoman, K. B., Collins, C. E., & Kaas, J. H. (2013). Epileptic baboons have ",
        "lower numbers of neurons in specific areas of cortex. Proc Natl Acad Sci U S A, ",
        "110(47), 19107-19112. https://doi.org/10.1073/pnas.1318894110"),
      sequence = "b",
      `Item number` = "Table 1",
      `Item full original title` =
        "Table 1. Epileptic baboons have lower numbers of neurons in specific areas of cortex",
      `Note about item` = paste0(
        "RESTORED with B = 'b'. The README claims this shares the Item name ",
        "Young_etal_2013_Table1 with the M1 paper, disambiguated by DOI -- but a merge holds ",
        "only the Item name and match() silently takes the first hit, and the build script ",
        "already looks this row up as Young_etal_2013_b_Table1. Column B (sequence) is the ",
        "sheet's own disambiguator (cf. Sherwood_etal_2004_I). WITHIN-SPECIES DISEASE STUDY ",
        "(4 baboons, 2 normal / 2 epileptic) -- not comparative data; do not merge as such."),
      `Progress stage` = "FINISHED",
      Snapshot = "Young_etal_2013_b_Table1_snapshot.xlsx",
      `Data readable file, can use this` = "Young_etal_2013_b_Table1.csv",
      `Source Type` = "Journal article",
      `Source format` = "PDF table")
  ),
  list(
    item_name = "Upham_etal_2019_DNAonlyMCC",
    item_encoded = "10.1371%2Fjournal.pbio.3000494_DNAonlyMCC",
    fields = list(
      `Citation (APA 7th-Annotated)` = paste0(
        "Upham, N. S., Esselstyn, J. A., & Jetz, W. (2019). Inferring the mammal tree: ",
        "Species-level sets of phylogenies for questions in ecology, evolution, and ",
        "conservation. PLoS Biology, 17(12), e3000494. ",
        "https://doi.org/10.1371/journal.pbio.3000494"),
      `Item number` = "DNA only MCC",
      `Item full original title` = "MamPhy v1 DNA-only maximum clade credibility tree",
      `Note about item` = paste0(
        "RESTORED: row had been lost. This is the project's SOURCE PHYLOGENY, consumed by ",
        "__merging_trees/ as a tree rather than a species x trait table. Data via Dryad ",
        "doi:10.5061/dryad.tb03d03; author code and trees at github.com/n8upham/MamPhy_v1."),
      `Progress stage` = "FINISHED",
      `Data readable file, can use this` = "Upham_etal_2019_DNAonlyMCC.csv",
      `Source Type` = "Journal article",
      `Source format` = "phylogeny")
  ),
  list(
    item_name = "Winkler_Bryant_2021_Figure1",
    item_encoded = "10.1080%2F09524622.2021.1905065_Figure1",
    fields = list(
      `Citation (APA 7th-Annotated)` = paste0(
        "Winkler, S. L., & Bryant, G. A. (2021). Play vocalisations and human laughter: a ",
        "comparative review. Bioacoustics, 1-28. ",
        "https://doi.org/10.1080/09524622.2021.1905065"),
      `Item number` = "Figure 1",
      `Item full original title` =
        "Figure 1. Cladogram of species reported to produce play vocalisations",
      `Note about item` = paste0(
        "RESTORED: row had been lost. Comparative review; Table 1 lists 67 rows as printed ",
        "while the paper states N = 65 (the domesticated ferret is not shown separately in ",
        "Figure 1 and the human/ferret bookkeeping differs) -- see the folder ReadMe."),
      `Progress stage` = "FINISHED",
      `Data readable file, can use this` = "Winkler_Bryant_2021_Figure1.csv",
      `Source Type` = "Journal article",
      `Source format` = "figure")
  )
)

# Column A of the Johnson row carries a real DOI, so clearing C is the whole fix.
JOHNSON_DOI  <- "10.1002/cne.24022"
STRANDED_ISBN <- "ISBN:9780195043716"

# ---- What is already there? -------------------------------------------------
## readxl, not openxlsx, for reading: it is the call the merges make, so this
## sees what they see.
registry <- read_excel(readme_xlsx, sheet = sheet)
reg_name <- as.character(registry[["Item name"]])
reg_cite <- as.character(registry[[1]])
## Column C by position, not by name: its header carries a trailing space that
## readers trim inconsistently. Assert the position rather than trust it.
if (!grepl("DOI if different", names(registry)[3], fixed = TRUE))
  stop("column 3 is '", names(registry)[3], "', not the expected 'DOI if different ...'. ",
       "Check column alignment before writing.")
reg_doi <- as.character(registry[[3]])

norm <- function(x) tolower(gsub(" ", "", x))
present <- norm(reg_name[!is.na(reg_name) & nzchar(reg_name)])
missing <- Filter(function(r) !(norm(r$item_name) %in% present), ROWS)

## Sheet1 re-sorts itself, so never cache a row number -- find the Johnson row by
## its DOI, now, and only if column C still holds the stranded ISBN.
johnson <- which(!is.na(reg_cite) & grepl(JOHNSON_DOI, reg_cite, fixed = TRUE) &
                   !is.na(reg_doi) & trimws(reg_doi) == STRANDED_ISBN)
if (length(johnson) > 1L)
  stop("more than one row carries ", JOHNSON_DOI, " with the stranded ISBN; resolve by hand")

## Guarded rather than an early quit(): sourced interactively there is nothing to
## return from at top level, and falling through would call saveWorkbook() on a
## no-op. This workbook is fragile enough that an unnecessary openxlsx round-trip
## is itself a risk, so it is only ever rewritten when there is a change to make.
if (!length(missing) && !length(johnson)) {
  message(sprintf("nothing to do: all %d row(s) present, no stranded ISBN.", length(ROWS)))
} else {

# ---- Write ------------------------------------------------------------------
backup <- file.path(root_dir, "_checks",
                    sprintf("__ReadMe_backup_%s.xlsx", format(Sys.Date(), "%Y%m%d")))
if (!file.exists(backup)) file.copy(readme_xlsx, backup)
message("backup: ", sub(paste0(root_dir, "/"), "", backup, fixed = TRUE))

source(file.path(root_dir, "_helpers", "openxlsx_compat.R"))
wb <- loadWorkbook(openxlsx_compatible_copy(readme_xlsx))

headers <- read.xlsx(wb, sheet = sheet, rows = 1, colNames = FALSE,
                     skipEmptyCols = FALSE, skipEmptyRows = FALSE)
headers <- as.character(headers[1, ])
normalize_header <- function(x) tolower(gsub("[^[:alnum:]]", "", x))
find_col <- function(label) {
  ## NB "Source Type" (col U) and "Source type" (col AK) both normalize to
  ## "sourcetype"; match() takes the first, which is U -- the one wanted here.
  out <- match(normalize_header(label), normalize_header(headers))
  if (is.na(out)) stop("Registry column not found: ", label)
  out
}

## Append after the last row that has a citation, computed now rather than
## assumed. +1 for the header row.
next_row <- max(which(!is.na(reg_cite) & nzchar(trimws(reg_cite)))) + 1L

for (i in seq_along(missing)) {
  spec <- missing[[i]]
  row  <- next_row + i
  for (field in names(spec$fields))
    writeData(wb, sheet = sheet, x = spec$fields[[field]],
              startRow = row, startCol = find_col(field), colNames = FALSE)
  message(sprintf("  row %d  %-32s -> %s%s", row, spec$item_name, spec$item_encoded,
                  if (file.exists(file.path(tsv_dir, paste0(spec$item_encoded, ".tsv"))))
                    "" else "   (TSV NOT BUILT YET)"))
}

if (length(johnson)) {
  deleteData(wb, sheet = sheet, cols = find_col("DOI if different from article or doi Alt"),
             rows = johnson + 1L, gridExpand = FALSE)
  message(sprintf("  Sheet1 row %d: cleared the stranded %s; Johnson et al. 2016 now resolves ",
                  johnson + 1L, STRANDED_ISBN),
          "from its own DOI")
}

saveWorkbook(wb, readme_xlsx, overwrite = TRUE)

# ---- Verify ------------------------------------------------------------------
after <- read_excel(readme_xlsx, sheet = sheet)
written <- as.character(after[[1]])
for (spec in missing) {
  cite <- spec$fields[["Citation (APA 7th-Annotated)"]]
  if (!any(!is.na(written) & written == cite))
    stop("row did not survive the save: ", spec$item_name)
}

message(sprintf("\nrestored %d row(s).", length(missing)))
message("NEXT: Rscript _tools/file_list.R          # fills E:M and refreshes their caches")
message("THEN: Rscript _checks/check_item_name_resolution.R   # expect exit 0")

}  # end of the "there is something to do" guard
