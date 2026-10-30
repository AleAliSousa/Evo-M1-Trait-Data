# crosspub_value_match.R
#
# Cross-PUBLICATION value matcher. Some later papers re-use earlier measurements under
# DIFFERENT labels (renamed species and/or anatomical terms). If two publications report
# the SAME numeric value for a species, it is almost certainly the SAME underlying datum.
# This script matches one publication's per-species volumes against (a) every per-source
# value in the merge (volumes_unfiltered.csv) and (b) the Smaers 2011 raw supplementary
# tables aggregated to species means, label- and unit-agnostic (tries cm3<->mm3), and
# reports the matches. Output: crosspub_<paper>_value_match.csv (+ see crosspub_<paper>_FINDINGS.md).
#
# FINDINGS for Smaers et al. 2017 Table S1 (volumes) — confirmed against the cited primaries:
#   primary_visual  = Frahm et al. 1984 area striata (EXACT, 14 spp)  -> SECONDARY (cited de Sousa 2010
#                     [S6], which re-used Frahm's V1); do NOT re-add to the merge (already Tier 1).
#   prefrontal      = Smaers 2011 Suppl. Table 2 (anterior section-5, L+R)  -> Smaers' own primary.
#   frontal_motor   = Smaers 2010/2011 own, but the POSTERIOR section-5 was never published -> NOT
#                     publicly verifiable (only scattered coincidental matches); flag before use.
#   other_association = neocortex - frontal - primary visual (derived residual) -> secondary/derived.
# See crosspub_Smaers2017_FINDINGS.md and ../Smaers_etal_2017/primary_source_checks/.

suppressPackageStartupMessages({ library(readr); library(dplyr); library(tidyr); library(stringr); library(purrr) })
## ---- paths: self-contained (Rscript or RStudio); discovers the repo root ----
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)             # Rscript file.R
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path                    # RStudio: Source
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path  # RStudio: Run
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
folder <- dirname(.sp)                                    # this script's folder (__merging_volumes)
base   <- local({                                         # repo root (anchored on __ReadMe.xlsx)
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
if (is.na(base)) stop("Project root not found (no __ReadMe.xlsx above this script); this cross-publication check needs the full project.", call. = FALSE)
setwd(folder)
input <- file.path(base, "Smaers_etal_2017/Smaers_etal_2017_TableS1part1.csv")
out   <- "crosspub_Smaers2017_value_match.csv"
tol   <- 0.02
norm  <- function(s) str_squish(tolower(gsub("[._]", " ", s)))

# species aliases (2011<->2017 relabelings + the canonical fixes used in the merge)
snc <- read_csv(file.path(base, "Smaers_etal_2017/primary_source_checks/species_name_changes_2011_to_2017.csv"), show_col_types = FALSE)
alias <- bind_rows(transmute(snc, a = norm(name_2011), b = norm(name_2017)),
                   transmute(snc, a = norm(name_2017), b = norm(name_2011)))
fix2011 <- c("cercopithecus ascianus"="cercopithecus ascanius","cercocebus albigena"="lophocebus albigena",
             "procolobus badius"="piliocolobus badius","lagothrix lagotricha"="lagothrix lagothricha")

# reference (a) merged per-source values, mm3
ref <- read_csv("volumes_unfiltered.csv", show_col_types = FALSE) %>%
  transmute(sp = norm(Species), Variable, Value = as.numeric(Value), Source) %>% filter(!is.na(Value))
# reference (b) Smaers 2011 raw ST1 (total frontal) + ST2 (anterior sec-5 = prefrontal), species means, cm3->mm3
add_smaers <- function(fn, cols, src) {
  read_csv(file.path(base, "Smaers_etal_2011", fn), show_col_types = FALSE) %>%
    group_by(sp = norm(species)) %>%
    summarise(across(all_of(cols), ~ mean(as.numeric(.x), na.rm = TRUE) * 1000), .groups = "drop") %>%
    pivot_longer(-sp, names_to = "Variable", values_to = "Value") %>% mutate(Source = src)
}
ref <- bind_rows(ref,
  add_smaers("Smaers_etal_2011_SupplementaryTable2.csv", c("sec5_grey_total_cm3","sec5_white_total_cm3"), "Smaers_etal_2011_SupplementaryTable2"),
  add_smaers("Smaers_etal_2011_SupplementaryTable1.csv", c("frontal_grey_total_cm3","frontal_white_total_cm3"), "Smaers_etal_2011_SupplementaryTable1"))

inp <- read_csv(input, show_col_types = FALSE); meas <- setdiff(names(inp), c("species","source"))
res <- list()
for (i in seq_len(nrow(inp))) {
  sp <- norm(inp$species[i]); sps <- unique(c(sp, alias$b[alias$a == sp])); sps <- unique(c(sps, unname(fix2011[sps])))
  for (col in meas) {
    val <- suppressWarnings(as.numeric(inp[[col]][i])); if (is.na(val)) next
    cand <- ref %>% filter(sp %in% sps, Value != 0) %>%
      mutate(d = pmin(abs(Value - val*1000), abs(Value - val)) / abs(Value)) %>%
      filter(d <= tol) %>% arrange(d) %>% slice(1)
    res[[length(res)+1]] <- tibble(smaers2017_species = inp$species[i], smaers2017_variable = col,
      smaers2017_value = val,
      matched_source = if (nrow(cand)) cand$Source else "(no match)",
      matched_variable = if (nrow(cand)) cand$Variable else "",
      matched_value = if (nrow(cand)) cand$Value else NA_real_,
      pct_diff = if (nrow(cand)) round(cand$d*100, 2) else NA_real_)
  }
}
bind_rows(res) %>% arrange(smaers2017_variable, smaers2017_species) %>% write_csv(out)
message("cross-pub matches -> ", out)
