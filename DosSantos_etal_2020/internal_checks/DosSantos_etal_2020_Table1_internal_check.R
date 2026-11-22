# DosSantos_etal_2020_Table1_internal_check.R -----------------------------------
#
# Internal check of Dos Santos et al. (2020), J Neurosci 40(24): 4622-4643
# (doi 10.1523/JNEUROSCI.2339-19.2020). The published paper is checked AGAINST ITSELF:
# every check compares printed values of this paper with each other. (The second run, below,
# applies the errata file's proposed values; two of those, E007 and E008, are the authors'
# unpublished figures and are named as such in the errata file. No check uses them as evidence.)
#
# Why this exists. Table 1 (pp. 4625-4627) carries a small number of printed values that
# are wrong -- some physically impossible (more neurons than cells). No erratum has been
# published. This script finds them from the publication alone, so every erratum recorded in
# reference_tables/DosSantos_etal_2020_errata.csv is flagged by evidence any reader can
# reproduce. The comparison with the authors' unpublished spreadsheet is a separate,
# private check (Evo-M1-Trait-Data-restricted,
# restricted_checks/_cross_table/DosSantos_2020_published_vs_authors_unpublished/).
#
# Families of checks, all on the FROZEN SNAPSHOT of Table 1 (printed strings):
#   A  within one row (species x structure):
#        N <= C and I <= C                      (a count cannot exceed the total)
#        N/mg  = N / (mass * 1000)
#        I/N   = I / N          an identity BY THE PAPER'S OWN DEFINITION: the Table 1
#                               footnote (p. 4627) states I = (I/N measured) x (N published)
#        I/mg  = I / (mass * 1000)   NOT an identity by that footnote: I/mg is "measured
#                               from the samples available", I is I/N x N. The two agree
#                               within 2% in 129 of 153 rows and within 5% in 144, so a large gap is still a
#                               finding -- but it can mean two published estimates of I
#                               disagree, not that one cell is misprinted.
#   B  across rows of one species:
#        Br = Cx + Cb + RoB    and    Cx = Ctx + Hp     for mass, C, N, I, No. of samples
#        the same two sums for the densities, mass-weighted (I/mg x mass and N/mg x mass
#        are additive), which tests the printed densities without using the I column
#   C  Table 1 against Table 5 (p. 4639): per clade and structure (Cx, Cb, RoB), the
#        range and mean of I% all cells (100 I/C), I% other cells (100 I/(C-N)) and I/mg,
#        and the range of I/N, recomputed from Table 1 and compared with the print.
#   D  Table 1 against Table 2 (pp. 4628-4629), DESCRIPTIVE ONLY: 100 I/C of the cortex
#        row against the bracket spanned by that species' gray- and white-matter site
#        means. Table 2 is per cortical site, Table 1 per whole structure, so this is a
#        plausibility band, never a transcription test and never grounds for a correction.
#   E  Table 1 against Figure 5D and 5H (p. 4638): 100 I/C and 100 I/(C-N) of the eight
#        primate cortex rows against the markers read off the figure by
#        DosSantos_etal_2020_Figure5_primate_cortex_points.py. Tolerance 3% (the reading
#        reproduces the self-consistent rows to 1% in D and 2.3% in H).
#
# The whole set is run twice: on the table as printed, and on the table with the
# proposed values of reference_tables/DosSantos_etal_2020_errata.csv applied (rows not
# withdrawn, with a proposed value). The second run is the test of the errata: a
# correction that is right removes its failures and creates none.
#
# Tolerance (families A-C): the larger of 2% of the implied value and half a unit in the
# last printed decimal of the printed value (family E: 3%). severity = pass | minor (<= 10%) |
# major (> 10%) | impossible. Only major and impossible failures are candidates for a
# correction; minor ones are recorded and left as printed.
#
# candidate_cells (families A and B, failures only): the cells of the failing check that
# no PASSING equality check vouches for. One candidate = the arithmetic isolates the wrong
# cell; several or none = the table alone cannot decide. This is mechanical; the decision
# per cell, with its evidence, is in the errata file.
#
# Read-only: reads the Table 1 snapshot and the errata file in the paper folder and the
# input tables beside this script (Table 5 and Table 2 as printed, the clade of each
# species, the Figure 5 markers); writes only, next to this script,
#   DosSantos_etal_2020_Table1_internal_check.csv                as printed
#   DosSantos_etal_2020_Table1_internal_check_after_errata.csv   with the errata applied
# It never changes a value in the paper folder.

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
folder <- dirname(.sp); setwd(folder)                       # <Paper>/internal_checks
item_name <- sub("_internal_check\\.R$", "", basename(.sp))  # DosSantos_etal_2020_Table1
paper_dir <- dirname(folder)
options(scipen = 999)

## 1. Read the snapshot (printed strings) and the check inputs -------------------
snap <- read.csv(file.path(paper_dir, paste0(item_name, "_snapshot.csv")),
                 colClasses = "character", check.names = FALSE, encoding = "UTF-8")
stopifnot(nrow(snap) == 156L,
          identical(colnames(snap), c("Species name", "Structure", "Structure mass (g)", "C", "N",
                                      "I", "N/mg", "I/mg", "I/N", "No. of samples")))
t5 <- read.csv("DosSantos_etal_2020_Table5_printed.csv", stringsAsFactors = FALSE)
t2 <- read.csv("DosSantos_etal_2020_Table2_printed.csv", stringsAsFactors = FALSE)
clades <- read.csv("DosSantos_etal_2020_Table1_clades.csv", stringsAsFactors = FALSE)
fig5 <- read.csv("DosSantos_etal_2020_Figure5_primate_cortex_points.csv", stringsAsFactors = FALSE)
stopifnot(nrow(t5) == 64L, nrow(t2) == 32L, nrow(clades) == 33L, nrow(fig5) == 16L)
errata_file <- file.path(paper_dir, "reference_tables", "DosSantos_etal_2020_errata.csv")

measures <- c(mass = "Structure mass (g)", C = "C", N = "N", I = "I",
              Nmg = "N/mg", Img = "I/mg", IN = "I/N", S = "No. of samples")
to_num   <- function(x) suppressWarnings(as.numeric(gsub(" ", "", x)))
# half a unit in the last printed decimal ("0.140" -> 0.0005; "13 098" -> 0.5)
half_unit <- function(x) {
  s <- gsub(" ", "", x)
  d <- ifelse(grepl("\\.", s), nchar(sub("^[^.]*\\.", "", s)), 0L)
  ifelse(is.na(to_num(x)), NA_real_, 0.5 * 10^(-d))
}
tab <- data.frame(species = snap[["Species name"]],
                  structure = gsub("\\*", "", snap[["Structure"]]),
                  one_specimen = grepl("^[A-Za-z+]+\\*$", snap[["Structure"]]),
                  stringsAsFactors = FALSE)
for (m in names(measures)) {
  tab[[m]] <- to_num(snap[[measures[[m]]]])
  tab[[paste0(m, "_hu")]] <- half_unit(snap[[measures[[m]]]])
}
tab$clade <- clades$clade_table5[match(tab$species, clades$species_table1)]
stopifnot(!anyNA(tab$clade))
cell_name <- function(structure, m) paste0(structure, "_", measures[[m]])

## 2-4. All checks as a function of the table (run on the print, then on print + errata)
run_checks <- function(tab) {
  row_of <- function(sp, st) which(tab$species == sp & tab$structure == st)
  checks <- list()
  add_check <- function(family, check, species, structure, printed, observed, half_unit,
                        cells, basis, impossible = FALSE, descriptive = FALSE, note = "") {
    if (is.na(printed) || is.na(observed)) return(invisible())
    checks[[length(checks) + 1L]] <<- data.frame(
      family = family, check = check, species = species, structure = structure,
      basis = basis, observed = observed, printed = printed, half_unit = half_unit,
      cells = paste(cells, collapse = "; "), impossible = impossible,
      descriptive = descriptive, note = note, stringsAsFactors = FALSE)
  }

  # A. within one row
  for (i in seq_len(nrow(tab))) {
    r <- tab[i, ]; sp <- r$species; st <- r$structure
    cn <- function(m) cell_name(st, m)
    if (!is.na(r$N) && !is.na(r$C))
      add_check("A", "N_le_C", sp, st, r$N, r$C, 0, c(cn("N"), cn("C")),
                "neurons N must not exceed total cells C", impossible = r$N > r$C)
    if (!is.na(r$I) && !is.na(r$C))
      add_check("A", "I_le_C", sp, st, r$I, r$C, 0, c(cn("I"), cn("C")),
                "microglia I must not exceed total cells C", impossible = r$I > r$C)
    add_check("A", "N_per_mg", sp, st, r$Nmg, r$N / (r$mass * 1000), r$Nmg_hu,
              c(cn("Nmg"), cn("N"), cn("mass")), "printed N/mg vs N / (mass x 1000)")
    add_check("A", "I_per_mg", sp, st, r$Img, r$I / (r$mass * 1000), r$Img_hu,
              c(cn("Img"), cn("I"), cn("mass")), "printed I/mg vs I / (mass x 1000)")
    add_check("A", "I_per_N", sp, st, r$IN, r$I / r$N, r$IN_hu,
              c(cn("IN"), cn("I"), cn("N")), "printed I/N vs I / N")
  }

  # B. across rows of one species
  sums <- list(Br = c("Cx", "Cb", "RoB"), Cx = c("Ctx", "Hp"))
  for (sp in unique(tab$species)) {
    for (whole in names(sums)) {
      parts <- sums[[whole]]
      iw <- row_of(sp, whole); ip <- unlist(lapply(parts, function(p) row_of(sp, p)))
      if (length(iw) != 1L || length(ip) != length(parts)) next
      for (m in c("mass", "C", "N", "I", "S")) {
        add_check("B", paste0("sum_", m), sp, whole, tab[[m]][iw], sum(tab[[m]][ip]),
                  tab[[paste0(m, "_hu")]][iw],
                  c(cell_name(whole, m), vapply(parts, cell_name, "", m = m)),
                  sprintf("printed %s %s vs %s", whole, measures[[m]],
                          paste(parts, collapse = " + ")))
      }
    }
  }

  # B (densities). mass-weighted sums: density_whole = sum(density_part x mass_part) / mass_whole
  for (sp in unique(tab$species)) {
    for (whole in names(sums)) {
      parts <- sums[[whole]]
      iw <- row_of(sp, whole); ip <- unlist(lapply(parts, function(p) row_of(sp, p)))
      if (length(iw) != 1L || length(ip) != length(parts)) next
      for (m in c("Nmg", "Img")) {
        add_check("B", paste0("wsum_", m), sp, whole, tab[[m]][iw],
                  sum(tab[[m]][ip] * tab$mass[ip]) / tab$mass[iw], tab[[paste0(m, "_hu")]][iw],
                  c(cell_name(whole, m), cell_name(whole, "mass"),
                    vapply(parts, cell_name, "", m = m), vapply(parts, cell_name, "", m = "mass")),
                  sprintf("printed %s %s vs mass-weighted %s", whole, measures[[m]],
                          paste(parts, collapse = " + ")))
      }
    }
  }

  # C. Table 1 against Table 5
  tab$I_pct_all_cells   <- 100 * tab$I / tab$C
  tab$I_pct_other_cells <- 100 * tab$I / (tab$C - tab$N)
  tab$I_per_mg <- tab$Img
  tab$I_per_N  <- tab$IN
  t5_cells <- list(I_pct_all_cells = c("I", "C"), I_pct_other_cells = c("I", "C", "N"),
                   I_per_mg = "Img", I_per_N = "IN")
  t5_half_unit <- function(v) ifelse(v >= 100, 0.5, ifelse(v >= 0.5, 0.005, 0.0005))
  for (k in seq_len(nrow(t5))) {
    g <- t5$group[k]; st <- t5$structure[k]; me <- t5$measure[k]
    sel <- tab$structure == st & !is.na(tab[[me]]) & (g == "All clades" | tab$clade == g)
    if (!any(sel)) next
    v <- tab[[me]][sel]; sps <- tab$species[sel]; n <- length(v)
    cells_of <- function(sp) vapply(t5_cells[[me]], function(m) cell_name(st, m), "")
    for (stat in c("min", "max")) {
      w <- if (stat == "min") which.min(v) else which.max(v)
      pr <- t5[[paste0("range_", stat)]][k]
      add_check("C", paste0("table5_", stat, "_", me), sps[w], st, pr, v[w], t5_half_unit(pr),
                cells_of(sps[w]),
                sprintf("Table 5 %s, %s %s: printed range %s vs Table 1 %s (n = %d)",
                        g, st, me, stat, stat, n),
                note = sprintf("extreme Table 1 row: %s", sps[w]))
    }
    if (!is.na(t5$mean[k])) {
      one <- tab$one_specimen[sel]
      add_check("C", paste0("table5_mean_", me), paste0("(", g, ")"), st, t5$mean[k], mean(v),
                t5_half_unit(t5$mean[k]), "*",
                sprintf("Table 5 %s, %s %s: printed mean vs Table 1 mean (n = %d)", g, st, me, n),
                note = sprintf("Table 1 mean %.4g, SE %.3g (printed SE %g)%s", mean(v),
                               sd(v) / sqrt(n), t5$se[k],
                               if (any(one)) sprintf("; without single-specimen rows (%s): mean %.4g, n = %d",
                                                     paste(sps[one], collapse = ", "),
                                                     mean(v[!one]), sum(!one)) else ""))
    }
  }

  # D. Table 1 against Table 2 (descriptive plausibility band)
  t2s <- t2[t2$level == "species", ]
  for (k in seq_len(nrow(t2s))) {
    sp <- t2s$species_table1[k]
    for (st in c("Ctx", "Cx")) {
      i <- row_of(sp, st)
      if (length(i) != 1L || is.na(tab$I_pct_all_cells[i])) next
      lo <- min(t2s$gm_mean[k] - 2 * t2s$gm_se[k], t2s$wm_mean[k] - 2 * t2s$wm_se[k])
      hi <- max(t2s$gm_mean[k] + 2 * t2s$gm_se[k], t2s$wm_mean[k] + 2 * t2s$wm_se[k])
      v <- tab$I_pct_all_cells[i]
      nearest <- if (v < lo) lo else if (v > hi) hi else v
      add_check("D", "table2_band_I_pct_all_cells", sp, st, nearest, v, 0,
                c(cell_name(st, "I"), cell_name(st, "C")),
                sprintf("Table 1 %s 100 I/C vs Table 2 site means: gray %g +/- %g%%, white %g +/- %g%% (band = means -/+ 2 SE)",
                        st, t2s$gm_mean[k], t2s$gm_se[k], t2s$wm_mean[k], t2s$wm_se[k]),
                descriptive = TRUE,
                note = sprintf("band %.2f-%.2f%%; Table 1 gives %.2f%%", lo, hi, v))
    }
  }

  # E. Table 1 against Figure 5D / 5H (primate cortex markers)
  for (k in seq_len(nrow(fig5))) {
    i <- row_of(fig5$species_table1[k], "Cx"); me <- fig5$measure[k]
    if (length(i) != 1L) next
    add_check("E", paste0("figure5_", me), fig5$species_table1[k], "Cx", fig5$y_read_pct[k],
              tab[[me]][i], 0, vapply(t5_cells[[me]], function(m) cell_name("Cx", m), ""),
              sprintf("%s: marker read off the figure vs Table 1 %s", fig5$locator[k], me),
              note = sprintf("marker assigned by %s; figure x %s vs Table 1 N/mg %s (order only)",
                             fig5$assigned_by[k], fig5$x_read_N_per_mg[k], fig5$table1_N_per_mg[k]))
  }

  chk <- do.call(rbind, checks)

  ## 3. Tolerance, status, severity -------------------------------------------------
  chk$difference <- chk$printed - chk$observed
  chk$pct_difference <- 100 * chk$difference / abs(chk$observed)
  inequality <- chk$check %in% c("N_le_C", "I_le_C")
  chk$tolerance <- ifelse(inequality | chk$descriptive, 0,
                          pmax(ifelse(chk$family == "E", 0.03, 0.02) * abs(chk$observed),
                               chk$half_unit, na.rm = TRUE))
  within <- ifelse(inequality, !chk$impossible, abs(chk$difference) <= chk$tolerance + 1e-9)
  chk$status <- ifelse(within, "pass", "mismatch")
  chk$severity <- ifelse(within, "pass",
                   ifelse(chk$descriptive, "descriptive",
                    ifelse(chk$impossible, "impossible",
                     ifelse(abs(chk$pct_difference) > 10, "major", "minor"))))

  ## 4. Candidate cells for the row/sum failures ------------------------------------
  # A cell is vouched for when it takes part in at least one PASSING equality check of the
  # same species: a family A ratio, a family B sum, a Table 5 range end that the species'
  # own row reproduces (family C min/max -- the printed extreme IS that row's value), or
  # a Figure 5 marker (family E). The inequalities and the clade means vouch for nothing.
  split_cells <- function(x) strsplit(x, "; ", fixed = TRUE)[[1]]
  ab <- chk$family %in% c("A", "B")
  vouching <- chk$status == "pass" & !inequality &
              (ab | (chk$family == "C" & grepl("^table5_(min|max)_", chk$check)) | chk$family == "E")
  vouched <- lapply(split(chk[vouching, ], chk$species[vouching]),
                    function(d) unique(unlist(lapply(d$cells, split_cells))))
  chk$candidate_cells <- ""
  for (i in which(ab & chk$status == "mismatch")) {
    cand <- setdiff(split_cells(chk$cells[i]), vouched[[chk$species[i]]])
    chk$candidate_cells[i] <- if (length(cand)) paste(cand, collapse = "; ") else "(none: every cell passes another check)"
  }
  chk
}

## 5. Run on the print, then on the print with the errata applied -----------------
finish <- function(chk) {
  chk$check_id <- paste0(chk$family, "_", chk$check, "_", ave(seq_len(nrow(chk)),
                         paste(chk$family, chk$check), FUN = seq_along))
  out <- chk[, c("check_id", "family", "check", "species", "structure", "basis",
                 "observed", "printed", "difference", "pct_difference", "tolerance",
                 "status", "severity", "cells", "candidate_cells", "note")]
  num_cols <- c("observed", "printed", "difference", "pct_difference", "tolerance")
  out[num_cols] <- lapply(out[num_cols], signif, 8)
  out
}
report <- function(x, label) {
  cat(sprintf("\n%s -- %s: %d checks\n", item_name, label, nrow(x)))
  print(table(family = x$family, severity = x$severity))
}

internal_checks <- finish(run_checks(tab))
write.csv(internal_checks, paste0(item_name, "_internal_check.csv"), row.names = FALSE)
report(internal_checks, "as printed")

# Errata rows that carry a proposed value and are not withdrawn. `variable` is the item
# column "<Structure>_<measure>" (e.g. "Br_C"); the species is the quoted row label in
# `locator` (... row "Tragelaphus strepsiceros Br").
if (file.exists(errata_file)) {
  er <- read.csv(errata_file, colClasses = "character", check.names = FALSE)
  er <- er[er$item == item_name & er$status != "withdrawn" & nzchar(er$proposed_value) &
           er$variable != "*", , drop = FALSE]
  tab2 <- tab
  for (k in seq_len(nrow(er))) {
    st <- sub("_.*$", "", er$variable[k]); me <- sub("^[^_]*_", "", er$variable[k])
    m  <- names(measures)[match(me, measures)]
    sp <- sub(paste0(" ", st, "\\**$"), "", sub('^.*row "([^"]+)".*$', "\\1", er$locator[k]))
    i  <- which(tab2$species == sp & tab2$structure == st)
    if (is.na(m) || length(i) != 1L)
      stop("errata row ", er$errata_id[k], ": cannot locate '", er$variable[k], "' for the row in '",
           er$locator[k], "' in the Table 1 snapshot.", call. = FALSE)
    if (!isTRUE(all.equal(tab2[[m]][i], to_num(er$printed_value[k]))))
      stop("errata row ", er$errata_id[k], ": printed_value '", er$printed_value[k],
           "' is not what the snapshot carries (", tab2[[m]][i], ").", call. = FALSE)
    tab2[[m]][i] <- to_num(er$proposed_value[k])
    tab2[[paste0(m, "_hu")]][i] <- half_unit(er$proposed_value[k])
  }
  after <- finish(run_checks(tab2))
  write.csv(after, paste0(item_name, "_internal_check_after_errata.csv"), row.names = FALSE)
  report(after, sprintf("with %d errata value(s) applied", nrow(er)))
}

bad <- internal_checks[internal_checks$severity %in% c("major", "impossible"), ]
if (nrow(bad))
  warning(nrow(bad), " major or impossible failure(s) in the table as printed (",
          length(unique(bad$species)), " species/clade group(s)); printed values are kept as ",
          "printed. See ", item_name, "_internal_check.csv and ",
          "reference_tables/DosSantos_etal_2020_errata.csv.", call. = FALSE)
