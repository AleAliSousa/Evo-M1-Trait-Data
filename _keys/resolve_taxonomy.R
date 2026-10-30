# resolve_taxonomy.R
#
# Fill current Order / Family for _keys/species_reference.csv from an authority,
# in the order you asked for: NCBI first (by NCBI taxid where we have one, else
# by name), then ITIS, then GBIF as a last resort. Writes the resolved values
# back with the source recorded, and flags where the resolved order disagrees
# with the MDD order already in the table.
#
# ON-DEMAND ONLY: run_all_scripts_v2.R skips it. ~215 species x up to four web
# lookups does not fit the sweep's 300 s timeout (2026-09-26 sweep: TIMEOUT at
# 185/215), and it rewrites species_reference.csv from live web services.
#
# Needs internet (works from your machine; the
# sandbox could not reach NCBI's eutils reliably, which is why this is a script).
#
# Packages: install.packages(c("readr","dplyr","stringr","xml2","rentrez","taxize"))
# Optional but recommended for NCBI rate limits: set an API key, e.g.
#   Sys.setenv(ENTREZ_KEY = "your_ncbi_api_key")   # raises NCBI to 10 req/s

suppressPackageStartupMessages({
  library(readr); library(dplyr); library(stringr)
  library(xml2); library(rentrez); library(taxize)
})

## Work from this script's own folder (was a hard-coded /Users/crossmodal/... path)
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open it in RStudio and click Source.", call. = FALSE)
})
setwd(dirname(.sp))
ref <- read_csv("species_reference.csv", show_col_types = FALSE)

# pull a given rank's name out of a (ranks, names) lineage
get_rank <- function(ranks, names_, want) {
  v <- names_[match(want, tolower(ranks))]
  if (length(v) == 0) NA_character_ else v
}

# NCBI by taxid (most reliable: no name ambiguity)
ncbi_by_taxid <- function(taxid) {
  x <- tryCatch(entrez_fetch(db = "taxonomy", id = taxid, rettype = "xml"),
                error = function(e) NULL)
  if (is.null(x)) return(c(NA, NA))
  doc <- tryCatch(read_xml(x), error = function(e) NULL)
  if (is.null(doc)) return(c(NA, NA))
  r <- xml_text(xml_find_all(doc, ".//LineageEx/Taxon/Rank"))
  n <- xml_text(xml_find_all(doc, ".//LineageEx/Taxon/ScientificName"))
  c(get_rank(r, n, "order"), get_rank(r, n, "family"))
}

# any db by name, via taxize::classification ("ncbi" / "itis" / "gbif")
classif_by_name <- function(name, db) {
  cl <- tryCatch(taxize::classification(name, db = db, rows = 1, messages = FALSE)[[1]],
                 error = function(e) NULL)
  if (is.null(cl) || !is.data.frame(cl) || nrow(cl) == 0) return(c(NA, NA))
  c(get_rank(cl$rank, cl$name, "order"), get_rank(cl$rank, cl$name, "family"))
}

n <- nrow(ref)
ord <- fam <- src <- rep(NA_character_, n)
for (i in seq_len(n)) {
  nm  <- ref$accepted_name[i]
  tid <- as.character(ref$ncbi_taxid[i])
  of <- c(NA, NA); s <- NA_character_

  if (!is.na(tid) && nzchar(tid)) { of <- ncbi_by_taxid(tid);        if (!is.na(of[1])) s <- "NCBI:taxid" }
  if (is.na(of[1]))               { of <- classif_by_name(nm, "ncbi"); if (!is.na(of[1])) s <- "NCBI:name" }
  if (is.na(of[1]))               { of <- classif_by_name(nm, "itis"); if (!is.na(of[1])) s <- "ITIS" }
  if (is.na(of[1]))               { of <- classif_by_name(nm, "gbif"); if (!is.na(of[1])) s <- "GBIF" }

  ord[i] <- of[1]; fam[i] <- of[2]; src[i] <- s
  message(sprintf("[%d/%d] %-34s -> %-16s %-16s (%s)", i, n, nm,
                  ifelse(is.na(of[1]), "?", of[1]), ifelse(is.na(of[2]), "?", of[2]),
                  ifelse(is.na(s), "UNRESOLVED", s)))
  Sys.sleep(if (nzchar(Sys.getenv("ENTREZ_KEY"))) 0.12 else 0.34)  # respect NCBI rate limit
}

## A lookup that failed this time (network down, rate-limited, timed out) must not
## wipe a value an earlier run resolved: keep the previous value where this run got NA.
keep_prev <- function(new, old) if (is.null(old)) new else ifelse(is.na(new), as.character(old), new)
ref$Order_resolved   <- keep_prev(ord, ref$Order_resolved)
ref$Family_resolved  <- keep_prev(fam, ref$Family_resolved)
ref$taxonomy_source  <- keep_prev(src, ref$taxonomy_source)
# QA: does the freshly resolved order match the MDD order already recorded?
ord <- ref$Order_resolved
ref$order_matches_MDD <- ifelse(is.na(ref$Order_MDD) | ref$Order_MDD == "", NA,
                                tolower(ref$Order_MDD) == tolower(ref$Order_resolved))

write_csv(ref, "species_reference.csv")

message("\nResolved ", sum(!is.na(ord)), "/", n, " species.")
message("By source: ", paste(names(table(src, useNA = "ifany")),
                              table(src, useNA = "ifany"), sep = "=", collapse = ", "))
mm <- which(ref$order_matches_MDD == FALSE)
if (length(mm)) {
  message("Order disagreements vs MDD (review): ", length(mm))
  print(ref[mm, c("accepted_name", "Order_MDD", "Order_resolved", "taxonomy_source")])
}
