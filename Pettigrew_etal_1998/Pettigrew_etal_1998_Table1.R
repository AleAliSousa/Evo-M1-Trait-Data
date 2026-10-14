## Pettigrew et al. (1998), Table 1: frozen printed layout -> analysis CSV.
## Reader: Microsoft Copilot AI assistant, 2026-10-10 (America/Los_Angeles).
## R execution and canonical build/validate remain pending; not FINISHED.
.sp <- local({
  me <- "Pettigrew_etal_1998_Table1.R"
  ## Innermost source()/sys.source() frame precedes a wrapper's --file=.
  fr <- sys.frames()
  for (k in rev(seq_along(fr))) {
    for (name in c("ofile", "file")) {
      p <- tryCatch(get(name, envir = fr[[k]], inherits = FALSE),
                    error = function(e) NULL)
      if (is.character(p) && length(p) == 1L && basename(p) == me && file.exists(p))
        return(normalizePath(p))
    }
  }
  a <- sub("^--file=", "", grep("^--file=", commandArgs(FALSE), value = TRUE))
  if (length(a) == 1L && basename(a) == me && file.exists(a)) return(normalizePath(a))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p) && basename(p) == me && file.exists(p)) return(normalizePath(p))
  }
  stop("Run this file with Rscript, source()/sys.source(), or save and Source in RStudio.", call. = FALSE)
})
folder <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

snap <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                 header = FALSE, skip = 2, colClasses = "character",
                 stringsAsFactors = FALSE, check.names = FALSE,
                 fileEncoding = "UTF-8", na.strings = "")
names(snap) <- c("site_pair", "distance", "angle", "factor")
context <- utils::read.csv(file.path(folder, "reference_tables", paste0(item_name, "_context.csv")),
                    colClasses = "character", stringsAsFactors = FALSE,
                    check.names = FALSE, fileEncoding = "UTF-8", na.strings = "")
species <- utils::read.csv(file.path(folder, "reference_tables", paste0(item_name, "_species_context.csv")),
                    colClasses = "character", stringsAsFactors = FALSE,
                    check.names = FALSE, fileEncoding = "UTF-8", na.strings = "")
stopifnot(nrow(context) == 1L, context$item_name == item_name,
          nrow(species) == 1L, species$item_name == item_name)
area <- rep(NA_character_, nrow(snap))
group <- NA_character_
for (i in seq_len(nrow(snap))) {
  if (snap$site_pair[i] %in% c("Vr", "Vc")) group <- snap$site_pair[i]
  area[i] <- group
}
keep <- !is.na(snap$distance) & nzchar(snap$distance)
area <- area[keep]
snap <- snap[keep, , drop = FALSE]
num <- function(x) {
  value <- as.numeric(x)
  if (anyNA(value)) stop("Unparsed source number.", call. = FALSE)
  value
}
## mm, degrees and mm/degree are already the intended units.
## The printed magnification is read directly, NEVER recalculated distance/angle.
final.dataframe <- data.frame(
  source_row = seq_len(nrow(snap)),
  species_as_published = species$species_as_published,
  visual_area_as_published = area,
  recording_site_pair_as_published = snap$site_pair,
  recording_site_1 = sub("–.*$", "", snap$site_pair),
  recording_site_2 = sub("^.*–", "", snap$site_pair),
  recording_site_separation_mm = num(snap$distance),
  receptive_field_separation_deg = num(sub("^ca\\.\\s*", "", snap$angle)),
  receptive_field_separation_approximate = grepl("^ca\\.", snap$angle),
  cortical_magnification_mm_per_deg = num(snap$factor),
  data_role = context$data_role,
  source_ref_key = context$source_ref_key,
  source_locus = context$source_locus,
  source_pdf_page = as.integer(context$source_pdf_page),
  source_printed_page = as.integer(context$source_printed_page),
  source_year = as.integer(species$source_year),
  merge_gate = context$merge_gate,
  stringsAsFactors = FALSE, check.names = FALSE
)
stopifnot(nrow(final.dataframe) == 9L, !anyNA(area),
          !anyDuplicated(paste(area, snap$site_pair)))
utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")),
          row.names = FALSE, na = "", fileEncoding = "UTF-8")

## Fresh registry lookup by NAME on every execution; no cached row or DOI fallback.
item_encoded <- NA_character_
if (!is.na(base) && requireNamespace("readxl", quietly = TRUE)) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  matches <- which(filecodes$`Item name` == item_name)
  if (length(matches) == 1L) item_encoded <- filecodes$`Item encoded`[matches]
}
authority <- length(item_encoded) == 1L && !is.na(item_encoded) &&
             nzchar(item_encoded) && !grepl("_$|[/\\\\]", item_encoded)
## Opt-in only after fresh registry authority AND canonical R validation.
## This preparation session has not run R; public TSV publication is withheld.
if (authority && identical(Sys.getenv("EVOM1_ALLOW_PUBLIC_TSV"), "validated")) {
  if (!dir.exists(file.path(base, "__Public", "comparative-data"))) {
    warning("Public destination unavailable; TSV withheld.")
  } else {
    utils::write.table(final.dataframe,
                file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv")),
                sep = "\t", row.names = FALSE, na = "", fileEncoding = "UTF-8")
  }
} else warning("Public TSV withheld: fresh authority and explicit post-validation publication gate required.")
