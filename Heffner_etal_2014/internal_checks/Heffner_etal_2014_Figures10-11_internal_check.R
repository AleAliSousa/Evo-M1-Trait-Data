## Heffner_etal_2014_Figures10-11_internal_check.R -- cross-item internal check (build HOWTO 7b)
##
## Heffner, R. S., Koay, G., & Heffner, H. E. (2014). Hearing in alpacas (Vicugna pacos):
## Audiogram, localization acuity, and use of binaural locus cues. J. Acoust. Soc. Am.
## 135, 778-788. doi:10.1121/1.4861344
##
## Fig. 10 (this item) and Fig. 9 (sibling item Heffner_etal_2014_Figure9) plot the same
## sound-localization thresholds on two different scales, digitised independently, so the
## two snapshots can be compared for the species they share. This needs the Figure9 snapshot,
## hence it lives here and not in Heffner_etal_2014_Figures10-11.R (which reads only its own
## snapshot). READ-ONLY: reads the two snapshots, writes only
## internal_checks/Heffner_etal_2014_Figures10-11_internal_check.csv; no value is changed, a
## mismatch is warned and kept. Nothing from Figure9 enters the item's CSV/TSV.
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
folder    <- dirname(.sp)                       # <Paper>/internal_checks
paper_dir <- dirname(folder)                    # <Paper>
item_name <- sub("_internal_check$", "", tools::file_path_sans_ext(basename(.sp)))
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
snapshot_csv  <- file.path(paper_dir, paste0(item_name, "_snapshot.csv"))                       # own snapshot
sibling_name  <- paste0(basename(paper_dir), "_Figure9")                                        # sibling item
sibling_csv   <- file.path(paper_dir, paste0(sibling_name, "_snapshot.csv"))
check_csv     <- file.path(folder, paste0(item_name, "_internal_check.csv"))
invisible(Sys.setlocale("LC_CTYPE", "en_US.UTF-8"))

## 1. PACKAGES ------------------------------------------------------
suppressPackageStartupMessages({ library(tidyverse) })

## 2. LOAD (own snapshot + sibling snapshot, read only) ------------------
snap <- read.csv(snapshot_csv, comment.char = "#", stringsAsFactors = FALSE, encoding = "UTF-8")
f9   <- read.csv(sibling_csv,  comment.char = "#", stringsAsFactors = FALSE, encoding = "UTF-8")
stopifnot(nrow(snap) == 48L, nrow(f9) == 34L)

## 3. CHECKS ---------------------------------------------------------
## Fig. 10 thresholds per species, split exactly as Heffner_etal_2014_Figures10-11.R does
## (footnote asterisk stripped, "A, B" labels split); Fig. 9 labels split likewise.
f10l <- snap %>% filter(figure == "Figure 10") %>%
  mutate(sp = strsplit(sub("^\\*", "", label_as_printed), ",\\s*")) %>%
  tidyr::unnest_longer(sp) %>% mutate(sp = sub("^\\*", "", sp))
f9l  <- f9 %>% mutate(sp = strsplit(label_as_printed, ",\\s*")) %>% tidyr::unnest_longer(sp)
cmp  <- inner_join(f10l, f9l, by = "sp")
d10v9 <- cmp$value - cmp$localization_threshold_deg

table_checks <- tibble::tribble(
  ~check_id, ~basis, ~observed, ~printed, ~tolerance, ~note,
  "Fig10_vs_Fig9_max", "largest |Fig.10 - Fig.9| threshold over the species on both scales (deg)",
                       round(max(abs(d10v9)), 3), 0, 0.6,
                       "both figures digitised independently from their own bitmaps; 'printed' = 0 (the two plots should agree); tolerance 0.6 deg",
  "Fig10_vs_Fig9_n",   "species common to Figs. 9 and 10", nrow(cmp), 21, 0,
                       "species names matched as printed after splitting 'A, B' labels and stripping the footnote asterisk") %>%
  mutate(difference = observed - printed,
         status = ifelse(abs(difference) <= tolerance, "pass", "mismatch")) %>%
  select(check_id, basis, observed, printed, difference, tolerance, status, note)

## WRITE CHECK CSV (the only file written) --------------------------------
write.csv(table_checks, check_csv, row.names = FALSE, na = "", fileEncoding = "UTF-8")
print(as.data.frame(table_checks[, 1:7]), row.names = FALSE)
if (any(table_checks$status != "pass"))
  warning(sum(table_checks$status != "pass"), " cross-item check(s) not 'pass' -- kept as printed, see README.")
cat("Checked", item_name, ":", nrow(table_checks), "cross-item checks ->", basename(check_csv), "\n")
