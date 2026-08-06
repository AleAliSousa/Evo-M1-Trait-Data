# Nudo et al. 1995 - TABLE 2: number and percentage of corticospinal (CS) somata in each
# cortical region of origin, per species (HRP retrograde labelling, C1-C2 hemisection).
#
# PRINTED SOURCE -> the frozen copy is Nudo_etal_1995_TABLE2_snapshot.xlsx (sheet "TABLE2"),
# captured by Nudo_etal_1995_extract_snapshot.py from 300-dpi renders of p. 185. This script
# reads ONLY that snapshot.
#
# Output shape: ONE ROW PER SPECIES (24), printed row order kept.
#
# UNITS: counts (dimensionless) and percentages; soma diameter in um. Nothing to convert
# (sec 6 - no mass, volume or body-weight column lives in this table).
#
# REGIONS (Methods, p. 184): A = frontal+parietal cortex, roughly M1 + premotor + SMA + S1 +
# posterior parietal; B = roughly S2; C = arcuate (lateral) premotor area, primates only;
# C' = rostral forelimb area, rodents + rabbit only; "Other" = the remainder.
# A printed 0 in #C / #C' therefore means "that region does not exist in this species", NOT
# "not measured" - it is a true zero and is carried as 0, never as NA.
#
# THE PARENTHETICAL IN "Maximum profile #" (printed footnote 2): where the ipsilateral total
# exceeded the contralateral total (the three hedgehogs, mole, hyrax) the cell prints
# "contralateral (ipsilateral)", and it is the IPSILATERAL number the paper carries forward.
# The cell is split into two columns and the one actually used is recorded explicitly.
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
item_name <- "Nudo_etal_1995_TABLE2"
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

## 2. SPECIES RESOLVER (paper-scoped; _keys/SPECIES_NAMING.md sec 3) -
# TABLE 2 prints the species only as the genus/species initials of footnote 1 ("R.n.", "G.s.",
# ... "see Table 1"). Those initials are resolved through the SAME species key, as Nudo1995
# variant_name rows - no expansion is hand-coded here (sec 5). The printed binomial for each
# token is in TABLE 1.
TOKEN <- "Nudo1995"
ref <- if (!is.na(dataset_root))
  read.csv(file.path(dataset_root, "_keys", "species_reference.csv"),
           stringsAsFactors = FALSE)$accepted_name else character(0)
read_key_rows <- function() {
  out <- list()
  if (!is.na(dataset_root))
    for (kf in list.files(file.path(dataset_root, "_keys"), pattern = "species_key.csv",
                          recursive = TRUE, full.names = TRUE)) {
      k <- read.csv(kf, stringsAsFactors = FALSE)
      if (!all(c("variant_name", "accepted_name", "source_publication") %in% names(k))) next
      k <- k[trimws(k$source_publication) == TOKEN, , drop = FALSE]
      if (nrow(k)) out[[length(out) + 1L]] <- k[, c("variant_name", "accepted_name")]
    }
  if (length(out)) return(do.call(rbind, out))
  staged <- file.path(paper_dir, "PROPOSED_species_key_rows.csv")
  if (file.exists(staged)) {
    warning("No '", TOKEN, "' rows in _keys/*/species_key.csv - falling back to the staged ",
            "PROPOSED_species_key_rows.csv. Merge it into the key, then delete the staged file.")
    k <- read.csv(staged, stringsAsFactors = FALSE)
    return(k[trimws(k$source_publication) == TOKEN, c("variant_name", "accepted_name")])
  }
  data.frame(variant_name = character(0), accepted_name = character(0))
}
km <- local({
  k <- read_key_rows(); m <- list()
  for (i in seq_len(nrow(k))) {
    v <- tolower(trimws(k$variant_name[i]))
    if (nzchar(v) && is.null(m[[v]])) m[[v]] <- k$accepted_name[i]
  }
  m
})
resolve <- function(x) {
  cx <- trimws(gsub("\\s+", " ", as.character(x)))
  if (!nzchar(cx)) return(NA_character_)
  a <- km[[tolower(cx)]]; if (!is.null(a)) return(a)
  hit <- match(tolower(cx), tolower(ref)); if (!is.na(hit)) return(ref[hit])
  cx
}

## 3. NUMBER PARSING -----------------------------------------------
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
# "765 (2,135)" -> contralateral 765, ipsilateral 2135, style "()"
# "615 [1,415]" -> contralateral 615, ipsilateral 1415, style "[]"  (footnote 2 says
#                  "parentheses"; this one row is printed with square brackets - kept as printed)
split_profiles <- function(cell) {
  cell <- trimws(as.character(cell))
  op <- if (grepl("(", cell, fixed = TRUE)) "(" else
        if (grepl("[", cell, fixed = TRUE)) "[" else ""
  if (!nzchar(op)) return(list(contra = num1(cell), ipsi = NA_real_, style = ""))
  cl <- if (op == "(") ")" else "]"
  i <- regexpr(op, cell, fixed = TRUE); j <- regexpr(cl, cell, fixed = TRUE)
  list(contra = num1(trimws(substr(cell, 1, i - 1))),
       ipsi   = num1(trimws(substr(cell, i + 1, j - 1))),
       style  = paste0(op, cl))
}

## 4. READ SNAPSHOT ------------------------------------------------
snap <- as.data.frame(read_excel(snapshot_xlsx, sheet = "TABLE2", col_names = FALSE,
                                 .name_repair = "minimal"), stringsAsFactors = FALSE)
snap <- snap[-(1:3), , drop = FALSE]
names(snap) <- paste0("V", seq_len(ncol(snap)))
chr <- function(x) { x <- trimws(as.character(x)); x[is.na(x) | x == "NA"] <- ""; x }
for (j in names(snap)) snap[[j]] <- chr(snap[[j]])
snap <- snap[nzchar(snap$V1) & nzchar(snap$V5), , drop = FALSE]   # drops the 2 footnote rows

## 5. BUILD --------------------------------------------------------
# Printed order names in the "Animal/G.s./Order" cell are typeset inconsistently. Two printed
# order strings are typographic errors; they are NOT altered in the snapshot, and the printed
# string survives in Order_Nudo1995. Order_resolved carries the corrected spelling and every
# correction is named in parse_flags so it stays visible (sec 7 - record, don't hide):
#   "Camivora"   (TABLE 2, cat row only; TABLES 4-5 print "Carnivora")  -> Carnivora
#   "Lagamorpha" (TABLES 2/4/5 rabbit row; TABLE 3 prints "Lagomorpha") -> Lagomorpha
ORDER_FIX <- c(Camivora = "Carnivora", Lagamorpha = "Lagomorpha")
out <- NULL
for (i in seq_len(nrow(snap))) {
  r <- unlist(snap[i, ], use.names = FALSE)
  flags <- character(0)
  parts  <- strsplit(r[1], "/", fixed = TRUE)[[1]]
  common <- trimws(parts[1]); gs <- trimws(parts[2]); ord <- trimws(parts[3])
  ord_ok <- if (!is.na(ORDER_FIX[ord])) unname(ORDER_FIX[ord]) else ord
  if (ord_ok != ord) flags <- c(flags, sprintf("order printed '%s' - typographic error for '%s'",
                                               ord, ord_ok))
  pr <- split_profiles(r[2])
  used <- if (!is.na(pr$ipsi)) pr$ipsi else pr$contra
  hemi <- if (!is.na(pr$ipsi)) "ipsilateral" else "contralateral"
  if (pr$style == "[]")
    flags <- c(flags, "ipsilateral total printed in SQUARE brackets although footnote 2 says parentheses")

  diam <- num1(r[3]); corr <- num1(r[4]); tot <- num1(r[5])
  cnt  <- vapply(c(6, 8, 10, 12, 14), function(k) num1(r[k]), numeric(1))     # A B C C' Other
  pct  <- vapply(c(7, 9, 11, 13, 15), function(k) num1(r[k]), numeric(1))
  for (k in 3:15) if (nzchar(r[k]) && is.na(num1(r[k])))     # col 2 is handled above
    flags <- c(flags, sprintf("column %d printed '%s' - not parseable as a number", k, r[k]))

  # --- printed-value checks (never corrected; a failure is named, the printed value stays) ---
  # (a) the stereological correction is the classic thin-section factor with an effective
  #     section thickness of 100 um: correction term == round(100 / (100 + soma diameter), 3)
  if (!is.na(diam) && !is.na(corr) && abs(corr - round(100 / (100 + diam), 3)) > 1e-9)
    flags <- c(flags, sprintf("correction term %.3f != round(100/(100+%.2f),3)=%.3f",
                              corr, diam, round(100 / (100 + diam), 3)))
  # (b) corrected #CSN == round(profile count used * correction term)
  if (!is.na(used) && !is.na(corr) && !is.na(tot) && abs(tot - round(used * corr)) > 0.5)
    flags <- c(flags, sprintf("corrected #CSN %g != round(%g x %.3f)=%g",
                              tot, used, corr, round(used * corr)))
  # (c) the five regional counts sum to the corrected total
  if (!any(is.na(cnt)) && !is.na(tot) && abs(sum(cnt) - tot) > 0.5)
    flags <- c(flags, sprintf("regions sum to %g but corrected #CSN is %g", sum(cnt), tot))
  # (d) every printed percentage recomputes from the printed counts (1 dp, half-up)
  lbl <- c("A", "B", "C", "C'", "Other")
  for (j in seq_along(cnt)) {
    if (is.na(cnt[j]) || is.na(pct[j]) || is.na(tot) || tot == 0) next
    exp <- floor(cnt[j] / tot * 1000 + 0.5) / 10
    if (abs(exp - pct[j]) > 0.05001)
      flags <- c(flags, sprintf("%%%s printed %.1f but %g/%g = %.1f", lbl[j], pct[j],
                                cnt[j], tot, exp))
  }

  out <- rbind(out, data.frame(
    Animal_Nudo1995              = r[1],        # printed cell, verbatim (invariant 3)
    animal_common_Nudo1995       = common,
    gs_initials_Nudo1995         = gs,          # printed genus/species initials (footnote 1)
    Order_Nudo1995               = ord,         # printed order, verbatim (incl. "Camivora")
    Order_resolved               = ord_ok,
    species_sci                  = resolve(gs),
    CS_profiles_contralateral    = pr$contra,
    CS_profiles_ipsilateral      = pr$ipsi,     # NA unless the cell printed a parenthetical
    CS_profiles_bracket_printed  = pr$style,
    CS_profiles_used             = used,
    hemisphere_used              = hemi,
    soma_diameter.um             = diam,
    correction_term              = corr,
    CS_somata_total              = tot,
    CS_somata_A                  = cnt[1],
    CS_somata_pct_A              = pct[1],
    CS_somata_B                  = cnt[2],
    CS_somata_pct_B              = pct[2],
    CS_somata_C                  = cnt[3],
    CS_somata_pct_C              = pct[3],
    CS_somata_Cprime             = cnt[4],
    CS_somata_pct_Cprime         = pct[4],
    CS_somata_other              = cnt[5],
    CS_somata_pct_other          = pct[5],
    method                       = "HRP applied to a C1-C2 spinal hemisection; TMB; profiles counted in every 5th 50-um section; stereologically corrected",
    parse_flags                  = if (length(flags)) paste(flags, collapse = "; ") else NA_character_,
    stringsAsFactors = FALSE))
}
rownames(out) <- NULL

## 5b. CHECKS ------------------------------------------------------
stopifnot(nrow(out) == 24)
cat(sprintf("  mean corrected #CSN over 24 species = %.0f (paper text, p. 186: 24,071)\n",
            mean(out$CS_somata_total)))
cat(sprintf("  mean #B = %.0f (paper: 1,241);  mean %%B = %.1f (paper: 9.0)\n",
            mean(out$CS_somata_B), mean(out$CS_somata_pct_B)))
pr <- out[out$Order_resolved == "Primates", ]
cat(sprintf("  primates: mean #C = %.0f (paper: 888), mean %%C = %.1f (paper: 2.2)\n",
            mean(pr$CS_somata_C), mean(pr$CS_somata_pct_C)))
cp <- out[out$CS_somata_Cprime > 0, ]
cat(sprintf("  species with C': n = %d, mean #C' = %.0f (paper: 1,319), mean %%C' = %.1f (paper: 11.6)\n",
            nrow(cp), mean(cp$CS_somata_Cprime), mean(cp$CS_somata_pct_Cprime)))

## 6. SAVE ---------------------------------------------------------
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
cat(sprintf("Nudo TABLE 2: %d rows, %d flagged\n", nrow(out), sum(!is.na(out$parse_flags))))
