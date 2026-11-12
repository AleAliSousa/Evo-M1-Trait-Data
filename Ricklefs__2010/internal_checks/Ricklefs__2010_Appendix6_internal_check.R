# Ricklefs__2010_Appendix6_internal_check.R -- cross-item internal check (build HOWTO 7b)
#
# Ricklefs, R. E. (2010). Life-history connections to rates of aging in terrestrial vertebrates.
# PNAS, 107(22), 10314-10319. https://doi.org/10.1073/pnas.1005862107 -- Supporting Information.
#
# Appendix 6 (life-history variables, this item) is printed for "the species used in this
# analysis", i.e. the Appendix 4 species (Weibull parameters, sibling item
# Ricklefs__2010_Appendix4). This check asks whether every Appendix 6 species also appears in
# Appendix 4 by its exact printed binomial (Genus + Species). It needs the Appendix 4 snapshot, so it
# lives here and not in Ricklefs__2010_Appendix6.R (which reads only its own snapshot).
# READ-ONLY: reads the two snapshots, writes only
# internal_checks/Ricklefs__2010_Appendix6_internal_check.csv. No value is changed; a mismatch is
# warned and kept as printed. Nothing from Appendix 4 enters the item's CSV/TSV.

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
check_dir <- dirname(.sp)                      # <Paper>/internal_checks
item_dir  <- dirname(check_dir)                # <Paper>
root <- local({
  d <- item_dir
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (!file.exists(file.path(d, "__ReadMe.xlsx")))
    stop("No __ReadMe.xlsx found above ", item_dir, call. = FALSE)
  d
})
folder    <- basename(item_dir)
item_name <- sub("_internal_check$", "", sub("\\.R$", "", basename(.sp)))   # "Ricklefs__2010_Appendix6"
frozen    <- file.path(item_dir, paste0(item_name, "_snapshot.csv"))        # own snapshot
a4        <- file.path(item_dir, paste0(folder, "_Appendix4_snapshot.csv")) # sibling snapshot
check_csv <- file.path(check_dir, paste0(item_name, "_internal_check.csv"))

# ---- 1. Read the two frozen snapshots (all character, as printed) ----
snap <- read.csv(frozen, check.names = FALSE, colClasses = "character", na.strings = character(0), encoding = "UTF-8")
a4s  <- read.csv(a4,     check.names = FALSE, colClasses = "character", encoding = "UTF-8")
if (nrow(snap) != 425L) stop("expected 425 printed rows, got ", nrow(snap), call. = FALSE)

# ---- 2. Check: every species here has Weibull parameters in Appendix 4 (same analysis set) ----
## Same key as the item script: Species_Ricklefs2010 = paste(Genus, Species), exact printed binomial.
in4 <- paste(snap$Genus, snap$Species) %in% paste(a4s$Genus, a4s$Species)
table_checks <- data.frame(
  check_id  = "species_in_Appendix4",
  basis     = "Appendix 6 species whose exact printed binomial (Genus Species) also appears in Appendix 4 (count)",
  observed  = sum(in4),
  printed   = nrow(snap),
  tolerance = 0,
  note      = paste0("printed = all ", nrow(snap), " Appendix 6 rows (the SI describes both appendices as the species of this analysis); ",
                     "no spelling variants or synonyms are folded together, so a miss may be a printing/taxonomy difference"),
  stringsAsFactors = FALSE)
table_checks$difference <- table_checks$observed - table_checks$printed
table_checks$status     <- ifelse(abs(table_checks$difference) <= table_checks$tolerance, "pass", "mismatch")
table_checks <- table_checks[, c("check_id", "basis", "observed", "printed", "difference", "tolerance", "status", "note")]
cat("species also in Appendix 4 (exact printed binomial):", sum(in4), "/", nrow(snap), "\n")
if (any(!in4)) cat("not in Appendix 4:", paste(unique(paste(snap$Genus, snap$Species)[!in4]), collapse = "; "), "\n")

# ---- Write the check CSV (the only file written) ----
write.csv(table_checks, check_csv, row.names = FALSE, na = "", fileEncoding = "UTF-8")
if (any(table_checks$status != "pass"))
  warning(sum(table_checks$status != "pass"), " cross-item check(s) not 'pass' -- kept as printed, see README.", call. = FALSE)
message("Checked ", item_name, ": ", nrow(table_checks), " cross-item check -> ", basename(check_csv))
