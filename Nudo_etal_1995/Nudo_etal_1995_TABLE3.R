# Nudo et al. 1995 - TABLE 3: corticospinal (CS) somata counts averaged BY TAXONOMIC ORDER.
#
# PRINTED SOURCE -> the frozen copy is Nudo_etal_1995_TABLE3_snapshot.xlsx (sheet "TABLE3"),
# captured by Nudo_etal_1995_extract_snapshot.py from a 300-dpi render of p. 187 (right
# column, immediately above TABLE 4). This script reads ONLY that snapshot.
#
# Output shape: ONE ROW PER TAXONOMIC ORDER (9). There is NO species column and no species to
# resolve - the unit of observation is the order, and every value is the unweighted mean over
# that order's species in TABLE 2. This table is therefore DERIVED from TABLE 2 and must never
# be merged as if it were independent data (Data role = secondary; sec 9).
#
# UNITS: counts (dimensionless) and percentages. Nothing to convert (sec 6).
#
# Source: Nudo, R. J., Sutherland, D. P., & Masterton, R. B. (1995). J Comp Neurol
#   358(2):181-205. DOI 10.1002/cne.903580203.

## 0. PATHS --------------------------------------------------------
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
paper_dir <- dirname(.sp)
item_name <- "Nudo_etal_1995_TABLE3"
snapshot_xlsx <- file.path(paper_dir, paste0(item_name, "_snapshot.xlsx"))
final_csv     <- file.path(paper_dir, paste0(item_name, ".csv"))
dataset_root <- local({
  d <- paper_dir
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
public_tsv_dir <- if (!is.na(dataset_root)) file.path(dataset_root, "__Public", "comparative-data") else NA
readme_xlsx    <- if (!is.na(dataset_root)) file.path(dataset_root, "__ReadMe.xlsx") else NA

## 1. PACKAGES -----------------------------------------------------
library(readxl)

## 2. NUMBER PARSING -----------------------------------------------
NA_TOKENS <- c("", "-", "–", "—", "NA", "n.a.", "n/a", "__", "e")
well_formed <- function(tok) {
  tok <- trimws(tok)
  if (!nzchar(tok)) return(FALSE)
  if (!grepl(",", tok, fixed = TRUE)) return(grepl("^[0-9]+(\\.[0-9]+)?$", tok))
  g <- strsplit(tok, ",", fixed = TRUE)[[1]]
  if (!grepl("^[0-9]{1,3}$", g[1])) return(FALSE)
  all(grepl("^[0-9]{3}(\\.[0-9]+)?$", g[-1]))
}
num1 <- function(tok) {
  tok <- trimws(as.character(tok))
  if (tok %in% NA_TOKENS) return(NA_real_)
  if (!well_formed(tok)) return(NA_real_)
  as.numeric(gsub(",", "", tok, fixed = TRUE))
}

## 3. READ SNAPSHOT ------------------------------------------------
snap <- as.data.frame(read_excel(snapshot_xlsx, sheet = "TABLE3", col_names = FALSE,
                                 .name_repair = "minimal"), stringsAsFactors = FALSE)
snap <- snap[-(1:3), , drop = FALSE]
names(snap) <- paste0("V", seq_len(ncol(snap)))
chr <- function(x) { x <- trimws(as.character(x)); x[is.na(x) | x == "NA"] <- ""; x }
for (j in names(snap)) snap[[j]] <- chr(snap[[j]])
snap <- snap[nzchar(snap$V1) & nzchar(snap$V3), , drop = FALSE]   # drops the footnote row

## 4. BUILD --------------------------------------------------------
out <- NULL
for (i in seq_len(nrow(snap))) {
  r <- unlist(snap[i, ], use.names = FALSE)
  flags <- character(0)
  for (k in 2:9) if (nzchar(r[k]) && is.na(num1(r[k])))
    flags <- c(flags, sprintf("column %d printed '%s' - not parseable as a number", k, r[k]))
  A <- num1(r[4]); B <- num1(r[5]); C <- num1(r[6]); Cp <- num1(r[7]); tot <- num1(r[3])
  # The order means are means of per-species TOTALS, so mean(#A)+mean(#B)+mean(#C)+mean(#C')
  # can fall short of mean(#CSN) by exactly the mean "Other" count, which TABLE 3 does not
  # print. A shortfall is expected; an EXCESS would be an error.
  if (!any(is.na(c(A, B, C, Cp, tot))) && (A + B + C + Cp) - tot > 0.5)
    flags <- c(flags, sprintf("region means sum to %g, more than the printed mean #CSN %g",
                              A + B + C + Cp, tot))
  out <- rbind(out, data.frame(
    Order_Nudo1995            = r[1],       # printed order name, verbatim
    n_species                 = num1(r[2]),
    mean_CS_somata_total      = tot,
    mean_CS_somata_A          = A,
    mean_CS_somata_B          = B,
    mean_CS_somata_C          = C,
    mean_CS_somata_Cprime     = Cp,
    mean_CS_somata_pct_A      = num1(r[8]),
    mean_CS_somata_pct_B      = num1(r[9]),
    parse_flags               = if (length(flags)) paste(flags, collapse = "; ") else NA_character_,
    stringsAsFactors = FALSE))
}
rownames(out) <- NULL

## 4b. CHECKS ------------------------------------------------------
stopifnot(nrow(out) == 9)
stopifnot(sum(out$n_species) == 24)        # the 9 orders partition the 24 species of TABLE 2
# TABLE 3 prints "Lagomorpha"; TABLES 2/4/5 print "Lagamorpha" in the same rabbit row.
if (!"Lagomorpha" %in% out$Order_Nudo1995)
  warning("TABLE 3: expected a 'Lagomorpha' row")

## 5. SAVE ---------------------------------------------------------
options(scipen = 999)
write.csv(out, final_csv, row.names = FALSE, fileEncoding = "UTF-8")

if (!is.na(dataset_root) && file.exists(readme_xlsx)) {
  filecodes    <- read_excel(readme_xlsx, sheet = "Sheet1")
  item_encoded <- filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
  if (is.na(item_encoded)) {
    warning("No 'Item encoded' in __ReadMe.xlsx for Item name: ", item_name)
  } else {
    dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)
    write.table(out, file.path(public_tsv_dir, paste0(item_encoded, ".tsv")),
                sep = "\t", row.names = FALSE, fileEncoding = "UTF-8")
  }
}
cat(sprintf("Nudo TABLE 3: %d rows (%d species across the 9 orders), %d flagged\n",
            nrow(out), sum(out$n_species), sum(!is.na(out$parse_flags))))
