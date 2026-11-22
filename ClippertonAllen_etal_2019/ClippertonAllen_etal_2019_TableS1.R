## Read only this item's frozen snapshot; write analysis CSV and public TSV.
me <- "ClippertonAllen_etal_2019_TableS1.R"
script_path <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a) && basename(sub("^--file=", "", a[1])) == me)
    return(normalizePath(sub("^--file=", "", a[1])))
  hits <- list.files(getwd(), pattern = paste0("^", me, "$"), recursive = TRUE, full.names = TRUE)
  if (length(hits) != 1L) stop("Cannot locate script: ", me)
  normalizePath(hits)
})
folder <- dirname(script_path)
item_name <- tools::file_path_sans_ext(basename(script_path))
root <- folder
while (!file.exists(file.path(root, "__ReadMe.xlsx")) && dirname(root) != root) root <- dirname(root)
if (!file.exists(file.path(root, "__ReadMe.xlsx"))) stop("Repository root not found")
snap <- readxl::read_excel(file.path(folder, paste0(item_name, "_snapshot.xlsx")), col_names=FALSE, col_types="text", .name_repair="minimal")
stopifnot(ncol(snap) == 23L)
section <- ""
records <- list()
for (i in seq_len(nrow(snap))) {
  z <- as.character(unlist(snap[i, ], use.names=FALSE)); z[is.na(z)] <- ""
  if (z[1] %in% c("Forebrain", "Midbrain", "Hindbrain", "Ventricles", "Lateral Forebrain Bundle", "Medial Forebrain Bundle", "Cranial Nerves", "Cerebellum")) { section <- z[1]; next }
  if (!(z[1] %in% c("GM", "WM", "VTR")) || !nzchar(z[2])) next
  for (age in c("P7", "P60")) {
    off <- if (age == "P7") 0L else 5L
    if (!nzchar(z[3 + off]) && !nzchar(z[4 + off])) next
    records[[length(records)+1L]] <- data.frame(
      Species="Mus musculus", species_as_published="mouse", source_row=i,
      section_as_published=section, category_as_published=z[1], Structure_as_published=z[2],
      age=age, control_genotype="Pten+/+", condition_genotype="Pten+/-",
      Control_AbsoluteVolume.mm3=as.numeric(z[3+off]),
      Condition_AbsoluteVolume.mm3=as.numeric(z[4+off]),
      AbsoluteVolume_pct_difference_reported=as.numeric(z[5+off]),
      AbsoluteVolume_p_reported=z[6+off], AbsoluteVolume_FDR_reported=z[7+off],
      Control_RelativeVolume.pct=as.numeric(z[13+off]),
      Condition_RelativeVolume.pct=as.numeric(z[14+off]),
      RelativeVolume_pct_difference_reported=as.numeric(z[15+off]),
      RelativeVolume_p_reported=z[16+off], RelativeVolume_FDR_reported=z[17+off],
      Figure_crossref=z[23], check.names=FALSE, stringsAsFactors=FALSE)
  }
}
final.dataframe <- do.call(rbind, records)
stopifnot(nrow(final.dataframe) > 100L, all(!is.na(final.dataframe$Control_AbsoluteVolume.mm3)))

utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), row.names=FALSE, na="", fileEncoding="UTF-8")
reg <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet="Sheet1")
hit <- which(reg[["Item name"]] == item_name)
if (length(hit) != 1L) stop("Expected one registry row for ", item_name)
item_encoded <- as.character(reg[["Item encoded"]][hit])
if (is.na(item_encoded) || !nzchar(item_encoded) || endsWith(item_encoded, "_")) stop("Invalid Item encoded")
public <- file.path(root, "__Public", "comparative-data")
dir.create(public, recursive=TRUE, showWarnings=FALSE)
utils::write.table(final.dataframe, file.path(public, paste0(item_encoded, ".tsv")), sep="\t", row.names=FALSE, na="", fileEncoding="UTF-8")
cat(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe), " columns\n", sep="")
