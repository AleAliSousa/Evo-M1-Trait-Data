# =====================================================================================
# Herculano-Houzel et al. (2015) — internal-consistency checks across ALL five tables
# =====================================================================================
# Paper: Herculano-Houzel, S., et al. (2015). Mammalian brains are made of these:
#   numbers of neurons and non-neuronal cells in the brains of 39 mammalian species.
#   Brain Behav Evol 86, 145-163. https://doi.org/10.1159/000437413
#
# SITUATION
#   HH2015 is a compilation: Tables 1-4 give, per structure (cerebral cortex,
#   cerebellum, rest of brain, olfactory bulb), the mass, neuron number (N),
#   other-cell number (O) and the derived densities (N/mg, O/mg) and ratio (O/N);
#   Table 5 gives whole-brain mass, neuron and other-cell numbers and % neurons.
#   A 2026-11-20 investigation found one printed value that contradicts the paper's
#   own counts (rabbit cerebellum O/N = 1.222, where the counts give 0.314; the
#   printed value duplicates the rabbit's olfactory-bulb ratio). This script checks
#   EVERY derived cell in all five tables the same way, so that one-off errors of
#   that kind cannot hide anywhere else in the paper's data as carried by Evo-M1.
#
# THE PER-SPECIMEN CAVEAT (why there is an EXPECTED_DEVIATION class)
#   The printed ratios and densities are means over specimens of per-specimen
#   ratios/densities, NOT ratios of the printed mean counts/masses. They therefore
#   legitimately deviate from the ratio of the printed means, typically by <1%
#   (median |dev| 0.05-0.3%) and occasionally by up to ~16%. Deviations are
#   classified, not just flagged:
#     PASS               |dev| within print rounding / 1% (see classify_derived()).
#     EXPECTED_DEVIATION 1-20%, no copy signature, multi-specimen row: consistent
#                        with per-specimen averaging.
#     SUSPECT            >20%, OR a copy signature (printed value equals another
#                        structure's / species' recomputed value within print
#                        rounding while its own row disagrees), OR any deviation
#                        beyond PASS in a SINGLE-SPECIMEN row (no SDs printed, or
#                        n = 1), where per-specimen averaging cannot operate and
#                        the printed derived value must equal the ratio of the
#                        printed counts exactly.
#   Empirical control: every single-specimen row in Tables 1-4 except the SUSPECT
#   cells agrees with its own counts to <= 0.71%.
#
# WHAT THIS SCRIPT DOES
#   1. Recomputes O/N, N/mg, O/mg for every row of Tables 1-4 and % neurons for
#      Table 5, and classifies each printed derived value (checks 1-2).
#   2. Copy-signature scan: tests every non-PASS printed derived value against the
#      recomputed values of all other structures (same species) and all other
#      species (same table) (check 3).
#   3. Table 5 whole-brain values vs the sum of Tables 1-3 per species (the
#      olfactory bulb is EXCLUDED from HH2015's whole brain: including it makes
#      every sum overshoot by the bulb's share, excluding it makes 33 of 39
#      species agree to <= 2%) (check 4).
#   4. Extraction fidelity: the per-table snapshot .xlsx (the frozen published
#      tables) vs the built .csv, and the built .csv vs the isotropic-
#      fractionator merge outputs (unfiltered + long), following the merge's
#      standardized-term maps; merge-derived variables (C.n, p.C.N, whole-brain
#      densities and O.p.N) are verified arithmetically (check 5).
#   OUTPUT: internal_checks_results.csv next to this script (one row per checked
#   cell) + printed summaries. See INTERNAL_CHECKS.md for methods and discussion.
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
folder    <- dirname(.sp)
paper_dir <- "/Users/crossmodal/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/HerculanoHouzel_etal_2015"
base <- dataset_root <- "/Users/crossmodal/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data"
setwd(folder)

library(readr); library(readxl); library(dplyr); library(tidyr); library(stringr)
options(scipen = 999)

PAPER <- "HerculanoHouzel_etal_2015"
STRUCT <- c("Table 1" = "Cerebral cortex", "Table 2" = "Cerebellum",
            "Table 3" = "RoB",           "Table 4" = "Olfactory bulb",
            "Table 5" = "Whole brain")
# half of the last printed digit, per derived quantity (rounding allowance)
HALF_UNIT <- c("O/N" = 0.0005, "N/mg" = 0.5, "O/mg" = 0.5, "% Neurons" = 0.05)

results <- list()
add_result <- function(table, species, structure, quantity, printed, recomputed,
                       deviation, classification, note = "") {
  results[[length(results) + 1]] <<- tibble(
    table = table, species = species, structure = structure, quantity = quantity,
    printed = printed, recomputed = recomputed, deviation = deviation,
    classification = classification, note = note)
}

## ---- load the five built tables -------------------------------------------------
tabs <- list()
for (tn in names(STRUCT)[1:4]) {
  df <- read_csv(file.path(paper_dir, paste0(PAPER, "_", sub(" ", "", tn), ".csv")),
                 show_col_types = FALSE)
  p <- paste0(STRUCT[[tn]], " ")
  sd_cols <- paste0(p, c("Mass, g SD", "N, n SD", "O, n SD", "N/mg SD", "O/mg SD", "O/N SD"))
  tabs[[tn]] <- df %>% transmute(
    Species,
    mass = .data[[paste0(p, "Mass, g")]], N = .data[[paste0(p, "N, n")]],
    O = .data[[paste0(p, "O, n")]],
    Nmg_p = .data[[paste0(p, "N/mg")]], Omg_p = .data[[paste0(p, "O/mg")]],
    ON_p = .data[[paste0(p, "O/N")]],
    n_spec = if ("Olfactory bulb n" %in% colnames(df)) .data[["Olfactory bulb n"]] else NA_real_,
    single_specimen = (rowSums(!is.na(select(df, any_of(sd_cols)))) == 0) |
                      (!is.na(n_spec) & n_spec == 1))
}
t5 <- read_csv(file.path(paper_dir, paste0(PAPER, "_Table5.csv")), show_col_types = FALSE) %>%
  transmute(Species, n_spec = .data[["Whole brain n"]],
            body_mass = .data[["Body mass, g"]], brain_mass = .data[["Brain mass, g"]],
            N = .data[["Whole brain Neurons"]], O = .data[["Whole brain Other cells"]],
            pct_p = .data[["Whole brain % Neurons"]],
            single_specimen = !is.na(n_spec) & n_spec == 1)

## ---- checks 1-2: derived quantities in Tables 1-4 and Table 5 -------------------
classify_derived <- function(dev_pct, half_unit, recomputed, single_specimen, signature) {
  pass_band <- max(1, half_unit / abs(recomputed) * 100)   # 1% or print rounding, whichever larger
  if (is.na(dev_pct)) return(NA_character_)
  if (abs(dev_pct) <= pass_band) return("PASS")
  if (!is.na(signature) && signature) return("SUSPECT")
  if (single_specimen) return("SUSPECT")                   # hard identity: n = 1 cannot average
  if (abs(dev_pct) > 20) return("SUSPECT")
  "EXPECTED_DEVIATION"
}

derived <- list()   # every derived cell, for the copy-signature scan
for (tn in names(STRUCT)[1:4]) {
  df <- tabs[[tn]]
  df <- df %>% mutate(ON_r = O / N, Nmg_r = N / (mass * 1000), Omg_r = O / (mass * 1000))
  tabs[[tn]] <- df
  long <- df %>% select(Species, single_specimen,
                        `O/N_p` = ON_p, `O/N_r` = ON_r,
                        `N/mg_p` = Nmg_p, `N/mg_r` = Nmg_r,
                        `O/mg_p` = Omg_p, `O/mg_r` = Omg_r) %>%
    pivot_longer(-c(Species, single_specimen), names_to = c("quantity", "kind"),
                 names_sep = "_", values_to = "value") %>%
    pivot_wider(names_from = kind, values_from = value, names_prefix = "v_") %>%
    rename(printed = v_p, recomputed = v_r) %>%
    mutate(table = tn, structure = STRUCT[[tn]])
  derived[[tn]] <- long
}
t5_long <- t5 %>% filter(!is.na(pct_p) & !is.na(N) & !is.na(O)) %>%
  transmute(Species, single_specimen, quantity = "% Neurons", printed = pct_p,
            recomputed = 100 * N / (N + O), table = "Table 5", structure = "Whole brain")
derived[["Table 5"]] <- t5_long
derived <- bind_rows(derived) %>%
  filter(!is.na(printed) & !is.na(recomputed)) %>%
  mutate(deviation = (printed - recomputed) / recomputed * 100,
         pass_band = pmax(1, HALF_UNIT[quantity] / abs(recomputed) * 100))

## ---- check 3: copy-signature scan ------------------------------------------------
# A printed derived value is a copy signature if it equals, within print rounding,
# the RECOMPUTED value of a different structure for the same species, or of a
# different species in the same table, while its own row disagrees beyond PASS.
derived <- derived %>% mutate(signature = FALSE, signature_note = "")
for (i in which(abs(derived$deviation) > derived$pass_band)) {
  r <- derived[i, ]
  tol <- HALF_UNIT[[r$quantity]]
  cross_struct <- derived %>% filter(Species == r$Species, quantity == r$quantity,
                                     structure != r$structure,
                                     abs(r$printed - recomputed) <= tol)
  cross_species <- derived %>% filter(table == r$table, quantity == r$quantity,
                                      Species != r$Species,
                                      abs(r$printed - recomputed) <= tol)
  hits <- c(if (nrow(cross_struct)) paste0(cross_struct$structure[1], " (same species)"),
            if (nrow(cross_species)) paste0(cross_species$Species[1], " (same table)"))
  if (length(hits)) {
    derived$signature[i] <- TRUE
    derived$signature_note[i] <- paste0("copy signature: printed value matches the recomputed ",
                                        r$quantity, " of ", hits[1], " within print rounding")
  }
}

for (i in seq_len(nrow(derived))) {
  r <- derived[i, ]
  cls <- classify_derived(r$deviation,
                          HALF_UNIT[[r$quantity]], r$recomputed,
                          isTRUE(r$single_specimen), isTRUE(r$signature))
  note <- r$signature_note
  if (isTRUE(cls == "SUSPECT") && isTRUE(r$single_specimen) && !isTRUE(r$signature))
    note <- paste0(note, if (nzchar(note)) "; " else "",
                   "single-specimen row (n = 1 / no SDs): per-specimen averaging cannot explain a deviation")
  if (cls == "EXPECTED_DEVIATION")
    note <- paste0(note, if (nzchar(note)) "; " else "",
                   "consistent with per-specimen averaging of ratios/densities")
  add_result(r$table, r$Species, r$structure, r$quantity, r$printed, r$recomputed,
             r$deviation, cls, note)
}

## ---- check 4: Table 5 vs sum of Tables 1-3 (olfactory bulb excluded) -------------
sum_rows <- list()
for (sp in t5$Species) {
  have <- names(STRUCT)[1:3][vapply(names(STRUCT)[1:3], function(tn) sp %in% tabs[[tn]]$Species, TRUE)]
  if (length(have) < 3) {
    add_result("Table 5", sp, "Whole brain", "Whole brain (Table 5 vs sum of Tables 1-3)",
               NA, NA, NA, "EXPECTED_DEVIATION",
               paste0("partial sum only: species missing from ", paste(setdiff(names(STRUCT)[1:3], have), collapse = ", ")))
    next
  }
  getv <- function(tn, col) tabs[[tn]][[col]][match(sp, tabs[[tn]]$Species)]
  sums <- c(brain_mass = sum(vapply(have, getv, numeric(1), "mass")),
            N = sum(vapply(have, getv, numeric(1), "N")),
            O = sum(vapply(have, getv, numeric(1), "O")))
  t5row <- t5[match(sp, t5$Species), ]
  printed <- c(brain_mass = t5row$brain_mass, N = t5row$N, O = t5row$O)
  devs <- (printed - sums) / sums * 100
  selective <- any(abs(devs) > 2) && sum(abs(devs) <= 0.5) >= 2   # one quantity off, the other two exact
  for (q in c("brain_mass", "N", "O")) {
    cls <- if (abs(devs[[q]]) <= 2) "PASS"
           else if (selective || abs(devs[[q]]) > 10) "SUSPECT"
           else "EXPECTED_DEVIATION"
    note <- "whole brain excludes the olfactory bulb (verified: bulb-included sums overshoot systematically)"
    if (cls == "SUSPECT" && !selective)
      note <- paste0("deviation > 10% against the sum of the structure tables; see INTERNAL_CHECKS.md ",
                     "for the cell-level diagnosis (in the elephant's case this is the Table 1 cortex ",
                     "other-cell count error seen from the whole-brain side)")
    if (cls == "SUSPECT" && selective)
      note <- paste0("selective deviation: this quantity disagrees with the structure sum while the ",
                     "other two agree to <= 0.5% — a transcription-error signature, not a specimen-set effect")
    if (cls == "EXPECTED_DEVIATION")
      note <- paste0(note, "; mixed-sign drift across mass/N/O, consistent with the whole-brain means ",
                     "being computed on a slightly different specimen set than the structure means")
    add_result("Table 5", sp, "Whole brain",
               paste0(c(brain_mass = "Brain mass, g", N = "Whole brain Neurons",
                        O = "Whole brain Other cells")[[q]], " (Table 5 vs sum of Tables 1-3)"),
               printed[[q]], sums[[q]], devs[[q]], cls, note)
  }
}

## ---- check 5a: extraction fidelity, snapshot .xlsx -> built .csv ------------------
split_pm <- function(x) {   # "9,730,000 ± 352,000" (or a plain number) -> c(mean, SD)
  if (is.na(x)) return(c(NA_real_, NA_real_))
  if (is.numeric(x)) return(c(as.numeric(x), NA_real_))
  parts <- str_split(gsub(",", "", str_replace_all(as.character(x), "\\+", "±")), "±")[[1]]
  c(suppressWarnings(as.numeric(trimws(parts[1]))),
    if (length(parts) > 1) suppressWarnings(as.numeric(trimws(parts[2]))) else NA_real_)
}
for (tn in names(STRUCT)) {
  snap <- suppressMessages(read_excel(file.path(paper_dir, paste0(PAPER, "_", sub(" ", "", tn), "_snapshot.xlsx")),
                                      col_names = FALSE))
  hdr <- as.character(snap[2, ])
  snap <- snap[3:(nrow(snap) - 2), , drop = FALSE]          # drop title/header and the 2 note rows
  colnames(snap) <- hdr
  built <- read_csv(file.path(paper_dir, paste0(PAPER, "_", sub(" ", "", tn), ".csv")),
                    show_col_types = FALSE)
  meas <- hdr[3:(length(hdr) - 1)]                          # measure columns between Order and Source
  for (j in seq_along(meas)) {
    cand <- colnames(built)[endsWith(colnames(built), paste0(" ", meas[j])) | colnames(built) == meas[j]]
    if (!length(cand)) next
    for (r in seq_len(nrow(snap))) {
      sp <- snap$Species[r]
      if (is.na(sp) || !sp %in% built$Species) next
      ms <- split_pm(snap[[2 + j]][r])
      brow <- built[match(sp, built$Species), ]
      for (k in 1:2) {
        lab <- if (k == 1) meas[j] else paste0(meas[j], " SD")
        carried <- if (k == 1) brow[[cand[1]]] else if (paste0(cand[1], " SD") %in% colnames(built)) brow[[paste0(cand[1], " SD")]] else NA_real_
        if (is.na(ms[k]) && is.na(carried)) next
        same <- !is.na(ms[k]) && !is.na(carried) && abs(ms[k] - carried) <= max(1e-9, abs(ms[k]) * 1e-9)
        add_result(tn, sp, STRUCT[[tn]],
                   paste0("Extraction fidelity (snapshot -> built CSV): ", lab),
                   ms[k], carried, if (same) 0 else (carried - ms[k]) / ms[k] * 100,
                   if (same) "PASS" else "SUSPECT",
                   if (same) "" else "repo extraction error: built CSV differs from the frozen published table")
      }
    }
  }
}

## ---- check 5b: extraction fidelity, built .csv -> merge outputs -------------------
merge_dir <- if (!is.na(base)) file.path(base, "__merging_cell_counts_isotropic_fractionator") else NA_character_
if (!is.na(merge_dir) && dir.exists(merge_dir)) {
  unf <- read_csv(file.path(merge_dir, "cell_counts_isotropic_fractionator_unfiltered.csv"),
                  show_col_types = FALSE)
  lng <- read_csv(file.path(merge_dir, "cell_counts_isotropic_fractionator_long.csv"),
                  show_col_types = FALSE)
  # printed name -> accepted name, from the merge's own long output (its
  # species_printed sometimes concatenates the printed and accepted names with "; ")
  name_map <- list()
  for (i in seq_len(nrow(lng)))
    for (nm in str_split(lng$species_printed[i], "; ")[[1]])
      name_map[[trimws(nm)]] <- lng$accepted_name[i]
  for (tn in names(STRUCT)) {
    item <- paste0(PAPER, "_", sub(" ", "", tn))
    tmap <- read_csv(file.path(merge_dir, "standardized_term_by_reference",
                               paste0(item, "_standardized_terms.csv")), show_col_types = FALSE)
    built <- read_csv(file.path(paper_dir, paste0(PAPER, "_", sub(" ", "", tn), ".csv")),
                      show_col_types = FALSE)
    for (j in seq_len(nrow(tmap))) {
      orig <- tmap$Original_Term[j]; std <- tmap$Standardized_Term[j]
      if (!orig %in% colnames(built) || !is.numeric(built[[orig]])) next
      for (sp in built$Species) {
        val <- built[[orig]][match(sp, built$Species)]
        if (is.na(val)) next
        cand_names <- unique(c(sp, name_map[[sp]]))
        u <- unf %>% filter(Species %in% cand_names, Variable == std, Source == item)
        carried <- if (nrow(u)) as.numeric(u$Value[1]) else NA_real_
        note <- ""
        if (nrow(u) && u$Species[1] != sp)
          note <- paste0("carried under accepted name '", u$Species[1], "'")
        if (is.na(carried)) {   # last resort: a unique value match anywhere in this item
          alt <- unf %>% filter(Variable == std, Source == item,
                                abs(as.numeric(Value) - val) <= max(1e-9, abs(val) * 1e-9))
          if (nrow(alt) == 1) {
            carried <- as.numeric(alt$Value[1])
            note <- paste0("carried under name '", alt$Species[1], "'")
          }
        }
        if (is.na(carried)) {
          add_result(tn, sp, STRUCT[[tn]], paste0("Extraction fidelity (built CSV -> merge): ", std),
                     val, NA, NA, "SUSPECT", "value missing from the merge unfiltered output")
        } else {
          same <- abs(carried - val) <= max(1e-9, abs(val) * 1e-9)
          add_result(tn, sp, STRUCT[[tn]], paste0("Extraction fidelity (built CSV -> merge): ", std),
                     val, carried, if (same) 0 else (carried - val) / val * 100,
                     if (same) "PASS" else "SUSPECT",
                     if (same) note else "merge carries a different value than the built CSV")
        }
      }
    }
  }
  # merge-derived variables, verified arithmetically against the built tables
  derive_check <- function(sp, item, var, expected, tn, structure) {
    u <- unf %>% filter(Species == sp, Variable == var, Source == item)
    if (!nrow(u)) return(invisible(NULL))
    carried <- as.numeric(u$Value[1])
    same <- abs(carried - expected) <= max(1e-6, abs(expected) * 1e-9)
    add_result(tn, sp, structure, paste0("Merge derivation: ", var),
               expected, carried, if (same) 0 else (carried - expected) / expected * 100,
               if (same) "PASS" else "SUSPECT",
               if (same) "merge-derived value recomputed from the built table" else "merge-derived value does not recompute")
  }
  for (tn in names(STRUCT)[1:4]) {
    df <- tabs[[tn]]; item <- paste0(PAPER, "_", sub(" ", "", tn))
    pref <- c("Cerebral cortex" = "CerebralCortex", "Cerebellum" = "Cerebellum",
              "RoB" = "RoB", "Olfactory bulb" = "OlfactoryBulb")[[STRUCT[[tn]]]]
    for (i in seq_len(nrow(df))) {
      derive_check(df$Species[i], item, paste0(pref, "_C.n"), df$N[i] + df$O[i], tn, STRUCT[[tn]])
      derive_check(df$Species[i], item, paste0(pref, "_p.C.N"), 100 * df$N[i] / (df$N[i] + df$O[i]), tn, STRUCT[[tn]])
    }
  }
  for (i in seq_len(nrow(t5))) {
    item <- paste0(PAPER, "_Table5"); sp <- t5$Species[i]
    derive_check(sp, item, "WholeBrain_C.n", t5$N[i] + t5$O[i], "Table 5", "Whole brain")
    derive_check(sp, item, "WholeBrain_O.p.N", t5$O[i] / t5$N[i], "Table 5", "Whole brain")
    derive_check(sp, item, "WholeBrain_N.p.mg", t5$N[i] / (t5$brain_mass[i] * 1000), "Table 5", "Whole brain")
    derive_check(sp, item, "WholeBrain_O.p.mg", t5$O[i] / (t5$brain_mass[i] * 1000), "Table 5", "Whole brain")
  }
} else {
  warning("merge folder not found from this location; check 5b skipped (run inside the full repo to include it)")
}

## ---- write results + summaries ----------------------------------------------------
out <- bind_rows(results)
write_csv(out, file.path(folder, "internal_checks_results.csv"))

cat("\n==== HH2015 internal checks ====\n")
cat("cells checked:", nrow(out), "\n")
print(out %>% count(classification))
cat("\n-- derived quantities (checks 1-2): |deviation| distribution --\n")
dq <- out %>% filter(quantity %in% c("O/N", "N/mg", "O/mg", "% Neurons"))
print(dq %>% group_by(quantity) %>%
        summarise(n = n(), median_abs_dev = median(abs(deviation), na.rm = TRUE),
                  p90 = quantile(abs(deviation), 0.9, na.rm = TRUE),
                  p95 = quantile(abs(deviation), 0.95, na.rm = TRUE),
                  max_abs_dev = max(abs(deviation), na.rm = TRUE), .groups = "drop"))
cat("\n-- SUSPECT cells --\n")
print(out %>% filter(classification == "SUSPECT") %>%
        select(table, species, structure, quantity, printed, recomputed, deviation))
cat("\nResults written to internal_checks_results.csv\n")
