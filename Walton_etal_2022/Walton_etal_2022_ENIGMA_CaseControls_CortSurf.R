# Born-digital source -> analysis CSV + public TSV. No source values are hardcoded.
.sp <- local({
  frames <- sys.frames()
  for (i in rev(seq_along(frames))) if (!is.null(frames[[i]]$ofile))
    return(normalizePath(frames[[i]]$ofile))
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  stop("Run with Rscript or source().")
})
folder <- dirname(.sp)
base <- dirname(folder)
item_name <- tools::file_path_sans_ext(basename(.sp))
options(stringsAsFactors = FALSE)
doi <- "10.1016/j.biopsych.2022.04.022"
raw <- read.csv(file.path(folder,paste0(item_name,"_snapshot.csv")), check.names=FALSE, na.strings=c("","NA"))
names(raw) <- trimws(names(raw))
stopifnot(nrow(raw)==68, !anyDuplicated(raw$Structure), all(grepl("^[LR]_",raw$Structure)))
final.dataframe <- data.frame(
  species="Homo sapiens", study="Walton_etal_2022", condition="anorexia",
  contrast_source=raw[[1]], metric="surface_area", atlas="Desikan-Killiany",
  hemisphere=substr(raw$Structure,1,1), region=sub("^[LR]_","",raw$Structure), structure_source=raw$Structure,
  adjustment="none", covariates="age + age^2; site-level scanner indicators; random-effects meta-analysis", effect_type="Cohen_d",
  effect=raw$d_icv, se=raw$se_icv, ci_low=raw$low_ci_icv, ci_high=raw$up_ci_icv,
  n_cases=raw$n_patients, n_reference=raw$n_controls,
  n=raw$n_patients+raw$n_controls, n_basis="source ROI counts",
  p=raw$pobs, p_fdr=suppressWarnings(as.numeric(raw$fdr_p)), p_fdr_source=as.character(raw$fdr_p), source_row=seq_len(nrow(raw))+1,
  source_file="anorexia_case-controls_CortSurf.csv", doi=doi, note="Published adjusted group contrast; no new test or spatial null. Generic d_icv header does not define covariates; metric comes from file name and loader.", check.names=FALSE)

bad_fdr <- !is.na(raw$fdr_p) & is.na(final.dataframe$p_fdr)
final.dataframe$note[bad_fdr] <- paste(final.dataframe$note[bad_fdr], "Malformed source FDR field retained in p_fdr_source; numeric p_fdr left missing. See Walton_etal_2022-E001.")

write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), row.names=FALSE, na="NA")
# Resolve the live registry by name. A new item has a prepared registry packet;
# use its explicitly provisional DOI code until the owner pastes that packet.
filecodes <- as.data.frame(readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet="Sheet1"))
idx <- match(item_name, filecodes[["Item name"]])
item_encoded <- if (!is.na(idx)) filecodes[["Item encoded"]][idx] else NA_character_
if (is.na(item_encoded) || !nzchar(item_encoded)) {
  item_encoded <- paste0(URLencode(doi, reserved=TRUE), "_", sub(paste0(basename(folder), "_"), "", item_name, fixed=TRUE))
  message("Registry pending; provisional TSV code: ", item_encoded)
}
stopifnot(!endsWith(item_encoded,"_"))
write.table(final.dataframe, file.path(base,"__Public","comparative-data",paste0(item_encoded,".tsv")),
            sep="\t", row.names=FALSE, quote=TRUE, na="NA")
message(item_name, ": ", nrow(final.dataframe), " rows")
