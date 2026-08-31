# =====================================================================================
# Dos Santos et al. (2020) — data check: published Table 1  vs  authors' unpublished data
# =====================================================================================
# Paper: Dos Santos, S. E., et al. (2020). Similar Microglial Cell Densities across Brain
#   Structures and Mammalian Species. J Neurosci 40(24), 4622-4643.
#   https://doi.org/10.1523/JNEUROSCI.2339-19.2020
#
# SITUATION
#   The published Table 1 (main PDF) contains transcription/typographical errors in several
#   cell-count values (some physically impossible: neurons or microglia > total cells). The
#   authors provided an updated UNPUBLISHED spreadsheet
#   ("2020-PublishedDataMammalsMicroglia - cópia.xlsx", received Mar 2024 via O. Todorov from
#   A. Tikky). Checks (this script) show the unpublished data is internally consistent and
#   agrees with older publications (e.g. Herculano-Houzel et al. 2015). The unpublished data
#   is therefore used in the merged cell-counts dataset; the published Table 1 is excluded.
#
# WHAT THIS SCRIPT DOES (replaces the exploratory DosSantos_etal_2020_Table1_conflictcheck.Rmd)
#   1. Loads published Table 1 and the unpublished raw spreadsheet.
#   2. Summarises the unpublished data to one value per animal x structure.
#   3. Compares EVERY structure x measure (C, N, I, I/N, N/mg, I/mg, mass, microglia/cell I/C),
#      computing % difference, and classifies each as match / minor / MAJOR / HUGE.
#   4. Runs an internal-consistency scan of the PUBLISHED data (flags neurons or microglia
#      that exceed total cells — a definitive typo signature).
#   5. Cross-checks whole-brain and cortex neuron counts against Herculano-Houzel et al. 2015.
#   OUTPUT: DosSantos_etal_2020_comparison_report.csv  (+ printed summaries)
# =====================================================================================

## ---- paths: self-contained (Rscript or RStudio; full repo or lone folder) ----
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
folder <- paper_dir <- dirname(.sp)                                   # this paper's folder
item_name <- table_name <- tools::file_path_sans_ext(basename(.sp))  # = file name (matches __ReadMe.xlsx)
base <- dataset_root <- local({                                      # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)

setwd(paste0(base, "/"))
folder <- paste0(folder, "/")
library(dplyr); library(tidyr); library(readr); library(readxl); library(stringr)
options(scipen = 999)

first2 <- function(x) vapply(strsplit(trimws(x), "\\s+"),
                             function(p) paste(p[seq_len(min(2, length(p)))], collapse = " "), character(1))
classify <- function(p) ifelse(is.na(p), NA,
                        ifelse(abs(p) < 1, "match",
                        ifelse(abs(p) < 10, "minor",
                        ifelse(abs(p) < 100, "MAJOR", "HUGE"))))

# ---- 1. PUBLISHED Table 1 (wide); add per-structure microglia/cell I/C; pivot long ----
pub_wide <- read_csv(paste0(folder, "DosSantos_etal_2020_Table1.csv"), show_col_types = FALSE)
prefixes <- unique(sub("_.*$", "", setdiff(colnames(pub_wide), "Species name")))
for (p in prefixes) {
  ic <- paste0(p, "_I/C"); I <- paste0(p, "_I"); C <- paste0(p, "_C")
  if (all(c(I, C) %in% colnames(pub_wide))) pub_wide[[ic]] <- pub_wide[[I]] / pub_wide[[C]]
}
pub_long <- pub_wide %>%
  pivot_longer(-`Species name`, names_to = "col", values_to = "published") %>%
  separate(col, into = c("Structure", "Measure"), sep = "_", extra = "merge") %>%
  rename(Species = `Species name`) %>%
  mutate(sp2 = first2(Species))

# ---- 2. UNPUBLISHED raw -> mean per Animal x Structure -> map codes -> long ----
## The unpublished spreadsheet moved to the PRIVATE repo (repo boundary; see
## __COMPARISON_MOVED.md). Resolve it through the house helper — it stops with an
## actionable message if the private repo is not mounted. (Fixed 2026-08-29: the old
## line read it from this folder, where it no longer exists.)
source(file.path(base, "_helpers", "restricted_data.R"))
unp_raw <- read_excel(evom1_restricted_file(
  "unpublished_data/____Unpublished__DosSantos_microglia_2024",
  "2020-PublishedDataMammalsMicroglia - cópia.xlsx"))

meas_map <- tibble::tribble(
  ~unp_col,                 ~Measure,
  "Number cells 2H",        "C",
  "Neurons, 2H",            "N",
  "Number Iba1 cells 2H",   "I",
  "Iba1/N",                 "I/N",
  "N/mg",                   "N/mg",
  "Iba1/mg",                "I/mg",
  "Structure mass, 2H (g)", "Structure mass (g)",
  "%Iba1+",                 "I/C"
)
struct_map <- tibble::tribble(
  ~Structure_unp,                              ~Structure,
  "Whole brain",                               "Br",
  "Cerebellum",                                "Cb",
  "Cerebellum total",                          "Cb",
  "Cerebral cortex, total -hp",                "Ctx",
  "Cerebral Cx, total - hp",                   "Ctx",
  "Cerebral cortex, total (GM+WM+hippoc)",     "Cx",
  "Cx total (GM+WM+Hp+Ent+Amyg)",              "Cx",
  "Hippocampus",                               "Hp",
  "Pons + Medulla",                            "P+M",
  "Rest of brain",                             "RoB"
)

unp_long <- unp_raw %>%
  group_by(`Animal Latin Name`, Structure) %>%
  summarise(across(all_of(meas_map$unp_col), ~ mean(.x, na.rm = TRUE)), .groups = "drop") %>%
  inner_join(struct_map, by = c("Structure" = "Structure_unp")) %>%
  select(Species = `Animal Latin Name`, Structure, all_of(meas_map$unp_col)) %>%
  pivot_longer(all_of(meas_map$unp_col), names_to = "unp_col", values_to = "unpublished") %>%
  left_join(meas_map, by = "unp_col") %>%
  mutate(unpublished = ifelse(is.nan(unpublished), NA, unpublished),
         sp2 = first2(Species)) %>%
  filter(!is.na(unpublished)) %>%
  group_by(sp2, Structure, Measure) %>%          # collapse the 2 unpublished labels mapped to one code
  summarise(unpublished = mean(unpublished, na.rm = TRUE), .groups = "drop")

# ---- 3. COMPARE ----
comparison <- pub_long %>%
  filter(!is.na(published)) %>%
  full_join(unp_long, by = c("sp2", "Structure", "Measure")) %>%
  mutate(pct_diff = round((unpublished - published) / published * 100, 3),
         flag = classify(pct_diff)) %>%
  arrange(desc(abs(pct_diff)))

write_csv(comparison %>% select(Species = sp2, Structure, Measure, published, unpublished, pct_diff, flag),
          paste0(folder, "DosSantos_etal_2020_comparison_report.csv"))

cat("\n===== MAJOR / HUGE discrepancies (|%diff| > 10) =====\n")
comparison %>% filter(flag %in% c("MAJOR", "HUGE")) %>%
  select(Species = sp2, Structure, Measure, published, unpublished, pct_diff) %>% as.data.frame() %>% print()

# ---- 4. INTERNAL-CONSISTENCY SCAN of PUBLISHED data (neurons or microglia > total cells) ----
cat("\n===== IMPOSSIBLE published values (neurons N or microglia I exceed total cells C) =====\n")
impossible <- list()
for (p in prefixes) {
  C <- pub_wide[[paste0(p, "_C")]]; N <- pub_wide[[paste0(p, "_N")]]; I <- pub_wide[[paste0(p, "_I")]]
  if (is.null(C)) next
  if (!is.null(N)) { bad <- which(!is.na(N) & !is.na(C) & N > C)
    for (i in bad) impossible[[length(impossible)+1]] <- data.frame(Species=pub_wide$`Species name`[i], Structure=p, problem=sprintf("N=%.0f > C=%.0f (%.0fx)", N[i], C[i], N[i]/C[i])) }
  if (!is.null(I)) { bad <- which(!is.na(I) & !is.na(C) & I > C)
    for (i in bad) impossible[[length(impossible)+1]] <- data.frame(Species=pub_wide$`Species name`[i], Structure=p, problem=sprintf("I=%.0f > C=%.0f (%.0fx)", I[i], C[i], I[i]/C[i])) }
}
if (length(impossible)) print(do.call(rbind, impossible)) else cat("  none\n")

# ---- 5. CROSS-CHECK vs Herculano-Houzel et al. 2015 (older primary source) ----
cat("\n===== Cross-check whole-brain & cortex NEURONS vs Herculano-Houzel et al. 2015 =====\n")
hh_wb  <- read_csv(file.path(base, "HerculanoHouzel_etal_2015", "HerculanoHouzel_etal_2015_Table5.csv"), show_col_types = FALSE) %>%
  transmute(sp2 = first2(Species), HH2015_WB_neurons = `Whole brain Neurons`)
hh_ctx <- read_csv(file.path(base, "HerculanoHouzel_etal_2015", "HerculanoHouzel_etal_2015_Table1.csv"), show_col_types = FALSE) %>%
  transmute(sp2 = first2(Species), HH2015_Ctx_neurons = `Cerebral cortex N, n`)
ds_wb  <- pub_long %>% filter(Structure == "Br", Measure == "N") %>% transmute(sp2, DS_pub_WB_N = published)
ds_wb_u<- unp_long %>% filter(Structure == "Br", Measure == "N") %>% transmute(sp2, DS_unp_WB_N = unpublished)
wb_check <- hh_wb %>% inner_join(ds_wb, by = "sp2") %>% left_join(ds_wb_u, by = "sp2")
if (nrow(wb_check)) print(as.data.frame(wb_check)) else cat("  no overlapping species for whole-brain neurons\n")
ds_cx  <- pub_long %>% filter(Structure == "Cx", Measure == "N") %>% transmute(sp2, DS_pub_Cx_N = published)
cx_check <- hh_ctx %>% inner_join(ds_cx, by = "sp2")
if (nrow(cx_check)) { cat("\n-- cortex neurons (HH2015 vs DS2020 published) --\n"); print(as.data.frame(cx_check)) }

cat("\nWrote ", paste0(folder, "DosSantos_etal_2020_comparison_report.csv"), "\n")
cat("See DosSantos_etal_2020_comparison_summary.md for the narrative summary.\n")

# =====================================================================================
# 6. BROADER CROSS-CHECK — DS2020 vs OTHER Herculano-Houzel-team papers
# =====================================================================================
# Tests whether the unpublished data matches independently-published HH-team cell counts:
#   Herculano-Houzel et al. 2015 (afrotherians/artiodactyls/primates),
#   Dos Santos et al. 2017 (marsupials), Jardim-Messeder et al. 2017 (carnivores).
# Compares neurons (N) and total cells (C = neurons + other cells) per structure.
# NOTE: whole brain & cerebellum are unambiguous; "cortex" (Ctx) differs in definition
#       across papers (hippocampus/entorhinal inclusion) so treat cortex rows with caution.
rd <- function(p) suppressMessages(read_csv(p, show_col_types = FALSE))
NO_long <- function(df, spcol, struct, N, O) tibble(
  sp2 = first2(df[[spcol]]), Structure = struct,
  external_N = suppressWarnings(as.numeric(df[[N]])),
  external_O = suppressWarnings(as.numeric(df[[O]])))

hh1 <- rd(file.path(base, "HerculanoHouzel_etal_2015", "HerculanoHouzel_etal_2015_Table1.csv"))
hh2 <- rd(file.path(base, "HerculanoHouzel_etal_2015", "HerculanoHouzel_etal_2015_Table2.csv"))
hh5 <- rd(file.path(base, "HerculanoHouzel_etal_2015", "HerculanoHouzel_etal_2015_Table5.csv"))
ds17 <- rd(file.path(base, "DosSantos_etal_2017", "DosSantos_etal_2017_TableS1.csv"))
jm17 <- rd(file.path(base, "JardimMesseder_etal_2017", "JardimMesseder_etal_2017_Table1.csv"))

ext <- bind_rows(
  NO_long(hh5, "Species", "Br",  "Whole brain Neurons",  "Whole brain Other cells") %>% mutate(external_source = "HH2015"),
  NO_long(hh1, "Species", "Ctx", "Cerebral cortex N, n", "Cerebral cortex O, n")     %>% mutate(external_source = "HH2015"),
  NO_long(hh2, "Species", "Cb",  "Cerebellum N, n",      "Cerebellum O, n")          %>% mutate(external_source = "HH2015"),
  # Dos Santos 2017 marsupials: O = N * (O/N)
  ds17 %>% transmute(sp2 = first2(Species), Structure = "Br",  external_N = NBR,  external_O = NBR  * `O/NBR`,  external_source = "DosSantos2017"),
  ds17 %>% transmute(sp2 = first2(Species), Structure = "Ctx", external_N = NCX,  external_O = NCX  * `O/NCX`,  external_source = "DosSantos2017"),
  ds17 %>% transmute(sp2 = first2(Species), Structure = "Cb",  external_N = NCB,  external_O = NCB  * `O/NCB`,  external_source = "DosSantos2017"),
  ds17 %>% transmute(sp2 = first2(Species), Structure = "Hp",  external_N = NHP,  external_O = NHP  * `O/NHP`,  external_source = "DosSantos2017"),
  ds17 %>% transmute(sp2 = first2(Species), Structure = "RoB", external_N = NROB, external_O = NROB * `O/NROB`, external_source = "DosSantos2017"),
  # Jardim-Messeder 2017 carnivores: O columns given directly
  jm17 %>% transmute(sp2 = first2(Species), Structure = "Br",  external_N = NBR,  external_O = OBR,  external_source = "JardimMesseder2017"),
  jm17 %>% transmute(sp2 = first2(Species), Structure = "Ctx", external_N = NCxT, external_O = OCxT, external_source = "JardimMesseder2017"),
  jm17 %>% transmute(sp2 = first2(Species), Structure = "Cb",  external_N = NCB,  external_O = OCB,  external_source = "JardimMesseder2017"),
  jm17 %>% transmute(sp2 = first2(Species), Structure = "Hp",  external_N = NHP,  external_O = OHP,  external_source = "JardimMesseder2017"),
  jm17 %>% transmute(sp2 = first2(Species), Structure = "RoB", external_N = NRoB, external_O = ORoB, external_source = "JardimMesseder2017")
) %>%
  mutate(N = external_N, C = external_N + external_O) %>%
  select(sp2, Structure, external_source, N, C) %>%
  pivot_longer(c(N, C), names_to = "Measure", values_to = "external") %>%
  filter(!is.na(external))

ds_pub <- pub_long %>% filter(Measure %in% c("N", "C")) %>% transmute(sp2, Structure, Measure, DS2020_published = published)
ds_unp <- unp_long %>% filter(Measure %in% c("N", "C")) %>% transmute(sp2, Structure, Measure, DS2020_unpublished = unpublished)

crosssource <- ext %>%
  inner_join(ds_pub, by = c("sp2", "Structure", "Measure")) %>%
  left_join(ds_unp,  by = c("sp2", "Structure", "Measure")) %>%
  mutate(pub_vs_ext_pct  = round((DS2020_published   - external) / external * 100, 1),
         unpub_vs_ext_pct = round((DS2020_unpublished - external) / external * 100, 1),
         verdict = ifelse(!is.na(unpub_vs_ext_pct) & !is.na(pub_vs_ext_pct) &
                          abs(unpub_vs_ext_pct) < 5 & abs(pub_vs_ext_pct) >= 10,
                          "unpub matches ext; PUBLISHED off", "")) %>%
  arrange(desc(abs(pub_vs_ext_pct)))
write_csv(crosssource, paste0(folder, "DosSantos_etal_2020_crosssource_check.csv"))

cat("\n===== Cross-source: PUBLISHED off but UNPUBLISHED matches an independent HH paper =====\n")
crosssource %>% filter(verdict != "") %>%
  select(Species = sp2, external_source, Structure, Measure, DS2020_published, DS2020_unpublished, external, pub_vs_ext_pct, unpub_vs_ext_pct) %>%
  as.data.frame() %>% print()
cat("\nMedian |unpublished - external| (whole brain & cerebellum neurons; should be ~0):\n")
crosssource %>% filter(Structure %in% c("Br", "Cb"), Measure == "N", !is.na(unpub_vs_ext_pct)) %>%
  group_by(Structure) %>% summarise(n = n(), median_abs_pct = median(abs(unpub_vs_ext_pct))) %>% as.data.frame() %>% print()
cat("\nWrote ", paste0(folder, "DosSantos_etal_2020_crosssource_check.csv"), "\n")
