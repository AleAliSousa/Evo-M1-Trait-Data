# Mink_etal_1981_TABLE1.R -----------------------------------------------------
#
# Mink, Blumenschine & Adams (1981), Am J Physiol 241: R203-R212.
# TABLE 1 "Ratios of CNS metabolism to resting body metabolism" (pp. R208-R209).
#
# Reads the frozen snapshot (Mink_etal_1981_TABLE1_snapshot.xlsx, written by
# Mink_etal_1981_TABLE1_extract_snapshot.R) and does all the cleaning:
#   - strips the printed reference numbers "(nn)" and footnote marks "^x" into
#     their own columns, keeping the printed animal name verbatim;
#   - splits the two-line Body2 ranges and the two-line Body metabolic rate;
#   - adds the project-unit brain/cord masses in mg (printed in g);
#   - re-runs the five arithmetic relations the table's own footnotes e-i
#     define, into `table_checks`;
#   - writes the analysis CSV, the public TSV, and the item-scoped
#     reference_tables/Mink_etal_1981_TABLE1_references.csv lookup built from
#     the sibling item Mink_etal_1981_REFERENCES.csv.
#
# No table value is typed in this script.

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
folder <- dirname(.sp); setwd(folder)
item_name <- sub("\\.R$", "", basename(.sp))
base <- item_name

suppressPackageStartupMessages(library(readxl))

snap <- as.matrix(read_excel(paste0(base, "_snapshot.xlsx"), sheet = "TABLE1",
                             col_names = FALSE, .name_repair = "minimal"))
dimnames(snap) <- NULL
stopifnot(ncol(snap) == 13L, nrow(snap) == 72L)
stopifnot(identical(as.character(snap[3, 2:12]),
                    c("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K")))

dat  <- snap[5:46, , drop = FALSE]        # the 42 printed animal rows
foot <- snap[47:72, 1]                    # the printed footnote block
stopifnot(nrow(dat) == 42L, all(nzchar(dat[, 1])))

## ---- cell helpers -----------------------------------------------------------
## A printed cell can carry: a value, a reference number "(nn)", a superscript
## footnote mark "^x", thousands commas, an en-dash range, and a second printed
## line. Each is peeled off into its own field; nothing is repaired.

line_of  <- function(x, i) vapply(strsplit(x, "\n", fixed = TRUE),
                                  function(p) if (length(p) >= i) p[i] else NA_character_,
                                  character(1))
refs_of  <- function(x) vapply(regmatches(x, gregexpr("\\(([0-9]+)\\)", x)),
                               function(m) if (length(m))
                                 paste(gsub("[()]", "", m), collapse = "; ") else NA_character_,
                               character(1))
marks_of <- function(x) vapply(regmatches(x, gregexpr("\\^([a-z])", x)),
                               function(m) if (length(m))
                                 paste(gsub("\\^", "", m), collapse = "; ") else NA_character_,
                               character(1))
num_of <- function(x) {
  s <- gsub("\\([0-9]+\\)", "", x)       # drop reference numbers
  s <- gsub("\\^[a-z]", "", s)           # drop footnote marks
  s <- gsub(",", "", s, fixed = TRUE)    # thousands separators
  s <- trimws(s)
  s[s %in% c("", "NA")] <- NA_character_
  suppressWarnings(as.numeric(s))
}

## ---- printed columns --------------------------------------------------------
animal_printed <- gsub("\n", " ", dat[, 1], fixed = TRUE)
A <- dat[, 2]; B <- dat[, 3]; C <- dat[, 4];  D <- dat[, 5]
E <- dat[, 6]; Fc <- dat[, 7]; G <- dat[, 8]; H <- dat[, 9]
I <- dat[, 10]; J <- dat[, 11]; K <- dat[, 12]; RAT <- dat[, 13]

## Body2 (D) is a range on two printed lines for two rows; otherwise one value.
D_l1 <- line_of(D, 1); D_l2 <- line_of(D, 2)
is_range <- grepl("\u2013$", trimws(D_l1))            # trailing en dash
D_low  <- ifelse(is_range, num_of(sub("\u2013\\s*$", "", D_l1)), num_of(D_l1))
D_high <- ifelse(is_range, num_of(D_l2), num_of(D_l1))
stopifnot(sum(is_range) == 2L)                        # Goldfish and Shark

## Body metabolic rate (E): where two values are printed, footnote b says the
## BOTTOM one (matched to Body1) is the one carried into H.
E_l1 <- line_of(E, 1); E_l2 <- line_of(E, 2)
E_top  <- num_of(E_l1)
E_used <- ifelse(is.na(E_l2), E_top, num_of(E_l2))
stopifnot(sum(!is.na(E_l2)) == 14L)                   # 14 rows print two values

printed_marks <- function() {
  cols <- list(C = C, G = G, J = J, A = A, B = B, D = D, E = E, F = Fc)
  out <- rep(NA_character_, nrow(dat))
  for (nm in names(cols)) {
    m <- marks_of(cols[[nm]])
    hit <- !is.na(m)
    tag <- paste0(nm, ":", m)
    out[hit] <- ifelse(is.na(out[hit]), tag[hit], paste(out[hit], tag[hit], sep = "; "))
  }
  out
}

final.dataframe <- data.frame(
  printed_row = seq_len(nrow(dat)),
  printed_page = ifelse(seq_len(nrow(dat)) <= 30L, "R208", "R209"),
  animal_as_published = animal_printed,
  common_name_as_published = trimws(sub(",.*$", "", animal_printed)),
  species_as_published = trimws(sub("^[^,]*,\\s*", "", animal_printed)),

  body_weight_cns_specimen.g = num_of(A),
  brain_weight.g             = num_of(B),
  brain_weight.mg            = num_of(B) * 1000,
  spinal_cord_weight.g       = num_of(C),
  spinal_cord_weight.mg      = num_of(C) * 1000,

  body_weight_metabolism_specimen_printed = gsub("\n", " ", D, fixed = TRUE),
  body_weight_metabolism_specimen_low.g   = D_low,
  body_weight_metabolism_specimen_high.g  = D_high,

  body_metabolic_rate_printed              = gsub("\n", " ", E, fixed = TRUE),
  body_metabolic_rate_body2.cm3O2.100g.min = E_top,
  body_metabolic_rate_used.cm3O2.100g.min  = E_used,
  brain_metabolic_rate.cm3O2.100g.min      = num_of(Fc),
  spinal_metabolic_rate.cm3O2.100g.min     = num_of(G),

  body_metabolism.cm3O2.min   = num_of(H),
  brain_metabolism.cm3O2.min  = num_of(I),
  spinal_metabolism.cm3O2.min = num_of(J),
  cns_metabolism.cm3O2.min    = num_of(K),
  cns_to_body_metabolism_ratio = num_of(RAT),

  ref_keys_body_weight_cns_specimen        = refs_of(A),
  ref_keys_brain_weight                    = refs_of(B),
  ref_keys_spinal_cord_weight              = refs_of(C),
  ref_keys_body_weight_metabolism_specimen = refs_of(D),
  ref_keys_body_metabolic_rate             = refs_of(E),
  ref_keys_brain_metabolic_rate            = refs_of(Fc),
  ref_keys_spinal_metabolic_rate           = refs_of(G),
  printed_footnote_marks                   = printed_marks(),
  note = NA_character_,
  stringsAsFactors = FALSE
)

## ---- per-row notes kept with the data --------------------------------------
add_note <- function(df, rows, txt) {
  df$note[rows] <- ifelse(is.na(df$note[rows]), txt, paste(df$note[rows], txt, sep = " | "))
  df
}
r_trout <- which(final.dataframe$common_name_as_published == "Trout")
final.dataframe <- add_note(final.dataframe, r_trout,
  paste("Spinal cord weight printed as '0.312 (1)'. Footnote l (direct observation of",
        "Perca flavescens; cord = 67% of brain weight) is defined in the printed footnote",
        "block but carries no row marker anywhere in the table, and 0.312/0.466 = 67.0% of",
        "this row's brain weight. Kept as printed; see Mink_etal_1981-E001."))
r_wm <- which(final.dataframe$common_name_as_published %in% c("Goldfish", "Bat", "Sparrow"))
final.dataframe <- add_note(final.dataframe, r_wm,
  paste("Column H partly overprinted by the publisher's download watermark in this scan;",
        "value read after suppressing the watermark and corroborated by footnote e",
        "(H = E x A/100). See README."))
r_eleph <- which(final.dataframe$common_name_as_published == "Elephant")
final.dataframe <- add_note(final.dataframe, r_eleph,
  "Spinal cord weight and spinal metabolic rate printed as NA; footnote y: spinal cord metabolism (J) estimated from the spinal-cord-to-brain metabolic ratio of other large mammals.")

## ---- table checks (HOWTO section 7a): the five printed relations ------------
## footnote e: H = E x A/100   f: I = F x B/100   g: J = G x C/100
## footnote h: K = I + J       i: metabolic ratio = K/H
## Tolerance is the rounding slack the printed cells can explain: half a unit
## in the last SIGNIFICANT digit of each input, propagated, plus half a unit in
## the last significant digit of the printed result. Nothing is corrected.
half_ulp <- function(txt) {
  s <- gsub("\\([0-9]+\\)|\\^[a-z]|,|\\s", "", txt)
  s <- sub("^-", "", s)
  v <- suppressWarnings(as.numeric(s))
  d <- gsub("[^0-9]", "", s)
  d <- sub("^0+", "", d)
  if (grepl("\\.", s)) nsig <- nchar(d) else nsig <- nchar(sub("0+$", "", d))
  ifelse(is.na(v) | v == 0 | nsig == 0, NA_real_,
         0.5 * 10^(floor(log10(abs(v))) - (nsig - 1)))
}
hu <- function(x) vapply(x, half_ulp, numeric(1), USE.NAMES = FALSE)

E_used_txt <- ifelse(is.na(E_l2), E_l1, E_l2)
chk <- function(id, basis, expected, printed_txt, tol) {
  printed <- num_of(printed_txt)
  ok <- !is.na(expected) & !is.na(printed)
  data.frame(
    check_id   = paste0(id, "_", seq_along(expected)),
    basis      = paste0(basis, " [row ", seq_along(expected), ": ",
                        final.dataframe$animal_as_published, "]"),
    observed   = expected,
    printed    = printed,
    difference = expected - printed,
    tolerance  = tol,
    status     = ifelse(!ok, "not_evaluable",
                 ifelse(abs(expected - printed) <= tol, "pass", "mismatch")),
    note       = ifelse(!ok, "a printed cell is NA or not numeric", NA_character_),
    stringsAsFactors = FALSE)
}

prod_tol <- function(x_txt, y_txt, z_expected, z_txt) {
  x <- num_of(x_txt); y <- num_of(y_txt)
  abs(z_expected) * (hu(x_txt) / abs(x) + hu(y_txt) / abs(y)) + hu(z_txt)
}

tc_H <- chk("body_metabolism", "footnote e: H = E x A/100",
            E_used * num_of(A) / 100, H,
            prod_tol(E_used_txt, A, E_used * num_of(A) / 100, H))
tc_I <- chk("brain_metabolism", "footnote f: I = F x B/100",
            num_of(Fc) * num_of(B) / 100, I,
            prod_tol(Fc, B, num_of(Fc) * num_of(B) / 100, I))
tc_J <- chk("spinal_metabolism", "footnote g: J = G x C/100",
            num_of(G) * num_of(C) / 100, J,
            prod_tol(G, C, num_of(G) * num_of(C) / 100, J))
tc_K <- chk("cns_metabolism", "footnote h: K = I + J",
            num_of(I) + num_of(J), K, hu(I) + hu(J) + hu(K))
ratio_exp <- num_of(K) / num_of(H)
tc_R <- chk("metabolic_ratio", "footnote i: metabolic ratio = K/H",
            ratio_exp, RAT,
            abs(ratio_exp) * (hu(K) / abs(num_of(K)) + hu(H) / abs(num_of(H))) + hu(RAT))

table_checks <- rbind(tc_H, tc_I, tc_J, tc_K, tc_R)
tally <- table(factor(table_checks$status, c("pass", "mismatch", "not_evaluable")))
message(item_name, ": table checks  pass=", tally[["pass"]],
        "  mismatch=", tally[["mismatch"]],
        "  not_evaluable=", tally[["not_evaluable"]])
if (tally[["mismatch"]] > 0L) {
  bad <- table_checks[table_checks$status == "mismatch", ]
  for (i in seq_len(nrow(bad)))
    warning(sprintf("%s: %s observed %.6g vs printed %.6g (diff %.3g, tol %.3g)",
                    bad$check_id[i], bad$basis[i], bad$observed[i], bad$printed[i],
                    bad$difference[i], bad$tolerance[i]), call. = FALSE)
}

## ---- outputs ----------------------------------------------------------------
write.csv(final.dataframe, paste0(base, ".csv"), row.names = FALSE, na = "NA",
          fileEncoding = "UTF-8")
message(item_name, ": ", nrow(final.dataframe), " rows written to ", base, ".csv")

## ---- item-scoped reference lookup -------------------------------------------
## One row per individual printed reference number the item cites, bound to the
## sibling item Mink_etal_1981_REFERENCES.csv. Cited-but-absent keys and year
## mismatches are reported in `note`, never silently corrected.
ref_cols <- grep("^ref_keys_", names(final.dataframe), value = TRUE)
pairs <- do.call(rbind, lapply(ref_cols, function(cn) {
  v <- final.dataframe[[cn]]
  v <- v[!is.na(v)]
  k <- unlist(strsplit(v, "; ", fixed = TRUE))
  if (!length(k)) return(NULL)
  data.frame(ref_key = k, cited_in_column = cn, stringsAsFactors = FALSE)
}))
## numbers cited inside the printed footnotes the data rows point to
foot_marks <- unique(unlist(strsplit(na.omit(final.dataframe$printed_footnote_marks), "; ")))
foot_marks <- unique(sub("^[A-Z]:", "", foot_marks))
foot_lines <- setNames(foot, sub("^([a-z]) .*$", "\\1", foot))
for (m in foot_marks) {
  ln <- foot_lines[[m]]
  if (is.null(ln) || is.na(ln)) next
  nums <- unique(gsub("[()]", "", regmatches(ln, gregexpr("\\(([0-9]+)\\)", ln))[[1]]))
  if (length(nums))
    pairs <- rbind(pairs, data.frame(ref_key = nums,
                                     cited_in_column = paste0("printed_footnote_marks:", m),
                                     stringsAsFactors = FALSE))
}

refs_item <- read.csv("Mink_etal_1981_REFERENCES.csv", stringsAsFactors = FALSE,
                      encoding = "UTF-8")
agg <- aggregate(cited_in_column ~ ref_key, data = unique(pairs),
                 FUN = function(x) paste(sort(unique(x)), collapse = "; "))
agg$key_num <- as.integer(agg$ref_key)
agg <- agg[order(agg$key_num), ]
agg$citation <- refs_item$citation[match(agg$key_num, refs_item$ref_number)]
agg$note <- ifelse(is.na(agg$citation),
                   "cited in TABLE 1 but ABSENT from the printed reference list",
                   NA_character_)
references_out <- data.frame(ref_key = agg$ref_key, cited_in_column = agg$cited_in_column,
                             citation = agg$citation, note = agg$note,
                             stringsAsFactors = FALSE)
dir.create("reference_tables", showWarnings = FALSE)
write.csv(references_out, file.path("reference_tables", paste0(base, "_references.csv")),
          row.names = FALSE, na = "", fileEncoding = "UTF-8")
n_res <- sum(!is.na(references_out$citation))
message(item_name, ": ", nrow(references_out), " printed reference keys cited; ",
        n_res, " resolved against Mink_etal_1981_REFERENCES, ",
        nrow(references_out) - n_res, " unresolved")

## ---- public TSV --------------------------------------------------------------
root <- folder
while (dirname(root) != root && !file.exists(file.path(root, "__ReadMe.xlsx"))) root <- dirname(root)
if (file.exists(file.path(root, "__ReadMe.xlsx"))) {
  registry <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1",
                                 .name_repair = "minimal")
  item_encoded <- registry[["Item encoded"]][match(item_name, registry[["Item name"]])]
  if (length(item_encoded) == 1L && !is.na(item_encoded) && nzchar(item_encoded) &&
      !grepl("_$", item_encoded)) {
    tsv_dir <- file.path(root, "__Public", "comparative-data")
    dir.create(tsv_dir, showWarnings = FALSE, recursive = TRUE)
    write.table(final.dataframe, file.path(tsv_dir, paste0(item_encoded, ".tsv")),
                sep = "\t", row.names = FALSE, quote = TRUE, na = "",
                fileEncoding = "UTF-8")
    message(item_name, ": public TSV ", item_encoded, ".tsv")
  } else {
    warning(item_name, ": no usable 'Item encoded' in __ReadMe.xlsx. Public TSV not written.")
  }
}
