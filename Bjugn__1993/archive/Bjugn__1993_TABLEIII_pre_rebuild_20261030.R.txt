## Bjugn__1993_TABLEIII.R -- frozen printed TABLE III (p.29, PDF page 5) -> analysis CSV.
## Staged build, matching Bjugn__1993_TABLEI/II: writes only the analysis CSV by default.
## No public TSV write is attempted here -- publication requires the same owner/DOI/R gates
## documented for the sibling items in this folder (see README).
self <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  stop("Run with Rscript file.R", call. = FALSE)
})
folder <- dirname(self)
item_name <- tools::file_path_sans_ext(basename(self))
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

snap <- utils::read.csv(paste0(item_name, "_snapshot.csv"), header = FALSE,
                         colClasses = "character", check.names = FALSE, fill = TRUE,
                         blank.lines.skip = FALSE, na.strings = NULL, fileEncoding = "UTF-8")
if (snap[1L, 1L] != "TABLE III") stop("Wrong printed table.")

## body rows: Slab 1-8 (col1 numeric 1..8)
body <- snap[grepl("^[0-9]+$", snap[[1L]]), 1:8, drop = FALSE]
names(body) <- c("slab", "Q_minus_cells_counted_oblique", "F_fields_counted",
                 "P_points_transverse", "Xi_QminusP_over_F", "A_Xi_squared",
                 "B_Xi_times_Xi_plus_1", "C_Xi_times_Xi_plus_2")
num <- function(x) suppressWarnings(as.numeric(x))
for (col in names(body)) body[[col]] <- num(body[[col]])

body$animal_id_as_published <- 1
body$species_as_published <- "mouse"
body$CE_gray_matter_cell_number <- 0.072
body$data_role <- "primary"
body$observation_level <- "worked_example_single_animal"
body$source_table <- "TABLE III"
body$source_printed_page <- 29
body$source_pdf_page <- 5
body$DOI <- "10.1016/0006-8993(93)90744-8"
body$PMID <- 8293301
body$Reference <- item_name

utils::write.csv(body, paste0(item_name, ".csv"), row.names = FALSE, na = "", fileEncoding = "UTF-8")
message(item_name, ": ", nrow(body), " rows written (analysis CSV only; no public TSV)")
