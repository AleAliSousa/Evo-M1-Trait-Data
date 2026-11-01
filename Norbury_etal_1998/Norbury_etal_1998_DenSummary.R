
## Norbury et al. (1998) derived den-occupancy mean -- count-frequency CSV -> one summary row
##
## Depends on Norbury_etal_1998_DenCensus.csv (run Norbury_etal_1998_DenCensus.R first).
## Daytime occupancy of dens SELECTED because a radio-collared ferret was in them: not a random
## sample, not necessarily independent animals, and distinct from stable social-group size. The
## November telemetry pair is outside this denominator.

options(scipen = 999)

## ---- 0. Paths: self-locating, so it runs from any working directory ----
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  of <- tryCatch(sys.frames()[[1]]$ofile, error = function(e) NULL)
  if (is.character(of) && length(of) == 1L && nzchar(of)) return(normalizePath(of))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open it in RStudio and click Source.", call. = FALSE)
})
item_dir <- dirname(.sp)
root <- local({
  d <- item_dir
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (!file.exists(file.path(d, "__ReadMe.xlsx"))) stop("No __ReadMe.xlsx found above ", item_dir, call. = FALSE)
  d
})
folder    <- basename(item_dir)              # species_key source_publication for this paper
item_name <- sub("\\.R$", "", basename(.sp))
csv_path  <- file.path(item_dir, paste0(item_name, ".csv"))
invisible(Sys.setlocale("LC_CTYPE", "en_US.UTF-8"))

## ---- species guard: every printed name must resolve through this paper's key rows ----
source(file.path(root, "_keys", "resolve_species.R"))
check_species <- function(printed) {
  key <- utils::read.csv(file.path(root, "_keys", "General", "species_key.csv"), stringsAsFactors = FALSE,
                         check.names = FALSE, encoding = "UTF-8")
  if (sum(trimws(key$source_publication) == folder) == 0L)
    stop("No rows for '", folder, "' in _keys/General/species_key.csv", call. = FALSE)
  rs <- resolve_species(printed, source_publication = folder)
  if (any(rs$unresolved))
    stop("printed names that do not resolve: ", paste(unique(printed[rs$unresolved]), collapse = ", "), call. = FALSE)
  invisible(rs)
}

cen <- utils::read.csv(file.path(item_dir, paste0(folder, "_DenCensus.csv")), stringsAsFactors = FALSE,
                       check.names = FALSE, encoding = "UTF-8")
n_dens  <- sum(cen$number_of_excavated_dens)
n_shared <- sum(cen$number_of_excavated_dens[cen$occupants_per_den > 1])
final.dataframe <- data.frame(
  Species            = "Mustela furo",
  mean_den_occupancy = sum(cen$occupants_per_den * cen$number_of_excavated_dens) / n_dens,
  n_examined_dens    = n_dens,
  n_shared_dens      = n_shared,
  mean_formula       = paste0("(", paste(sprintf("%d*%d", cen$number_of_excavated_dens, cen$occupants_per_den),
                                         collapse = " + "), ")/", n_dens),
  shared_fraction    = n_shared / n_dens,
  setting            = "Feral ferrets; South Island New Zealand pastoral short-tussock habitat",
  statistic          = "derived mean occupants per excavated occupied den",
  role               = "primary",
  age_scope          = "Collared animals subadult/adult; shared pairs adult males",
  quality_flag       = paste("Dens selected because collared ferrets present; repeated animals possible;",
                             "not independent social groups. Later telemetry sharing excluded from this denominator."),
  stringsAsFactors = FALSE)

## ---- write the analysis CSV ----
utils::write.csv(final.dataframe, csv_path, row.names = FALSE, na = "", fileEncoding = "UTF-8")

## ---- public TSV: Item encoded from the live __ReadMe.xlsx, by Item name ----
## Unregistered items are built anyway: the CSV is written and the TSV waits for a registry row
## (an "NA.tsv" would be worse than none).
filecodes <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1")
nfc <- function(x) if (requireNamespace("stringi", quietly = TRUE)) stringi::stri_trans_nfc(x) else x
item_encoded <- filecodes$`Item encoded`[match(nfc(item_name), nfc(filecodes$`Item name`))]
if (length(item_encoded) != 1L || is.na(item_encoded) || !nzchar(item_encoded) || grepl("_$", item_encoded)) {
  message("No 'Item encoded' in __ReadMe.xlsx for ", item_name, " -- CSV written, public TSV skipped.")
} else {
  tsv_path <- file.path(root, "__Public", "comparative-data", paste0(item_encoded, ".tsv"))
  utils::write.table(final.dataframe, tsv_path, sep = "\t", row.names = FALSE, na = "", fileEncoding = "UTF-8")
  message(item_name, " -> ", tsv_path)
}
message(item_name, ": ", nrow(final.dataframe), " rows written to ", basename(csv_path))
