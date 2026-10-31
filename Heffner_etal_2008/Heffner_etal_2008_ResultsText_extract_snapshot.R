# Heffner_etal_2008_ResultsText_extract_snapshot.R
# -----------------------------------------------------------------------------
# Builds the CONSTRUCTED snapshot for Heffner et al. (2008) Results prose
# (__HOWTO_make_a_snapshot.md, "When there is no table").
#
# The item's values are published only in running text, so the snapshot is a
# table we construct: one row per reported value, carrying the verbatim
# sentence it came from and the printed page, so a reviewer can find each
# number on the page.
#
# No value is typed into this script. Each sentence is located in the PDF's
# text layer by an anchored printed literal, and the number is pulled out of
# the located sentence with a capture group. The script refuses to overwrite a
# frozen copy that differs.
# -----------------------------------------------------------------------------
suppressPackageStartupMessages({ library(pdftools); library(stringr); library(readr) })

.script_path <- local({
  args <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(args)) return(normalizePath(sub("^--file=", "", args[1])))
  stop("Run with Rscript --vanilla.", call. = FALSE)
})
folder <- dirname(.script_path)
item_name <- "Heffner_etal_2008_ResultsText"
pdf_file  <- file.path(folder, "Heffner-2008-Sound localization acuity and its.pdf")
out_csv   <- file.path(folder, paste0(item_name, "_snapshot.csv"))

## ---- two-column reading-order reconstruction --------------------------------
dat <- pdf_data(pdf_file)
column_text <- function(page, side, x_split = 300) {
  d <- dat[[page]]
  d <- d[if (side == "L") d$x < x_split else d$x >= x_split, ]
  d <- d[order(d$y, d$x), ]
  line <- cumsum(c(TRUE, diff(d$y) > 3))
  s <- paste(tapply(d$text, line, paste, collapse = " "), collapse = " ")
  s <- gsub("- ", "", s, fixed = TRUE)          # join words hyphenated at line end
  s <- gsub("\ufb01", "fi", s); s <- gsub("\ufb02", "fl", s)   # PDF ligature glyphs
  str_squish(s)
}
# printed pages 80-86 == PDF pages 1-7 (running head on PDF page 5 prints "84")
printed_page_of <- function(pdf_page) as.character(79L + pdf_page)

# Return the printed sentence delimited by two anchored printed literals.
# Both literals must occur exactly once on the reconstructed column, and the
# end literal must follow the start literal; nothing is inferred.
sentence <- function(pdf_page, side, start_literal, end_literal) {
  txt <- column_text(pdf_page, side)
  s <- str_locate_all(txt, fixed(start_literal))[[1]]
  e <- str_locate_all(txt, fixed(end_literal))[[1]]
  if (nrow(s) != 1L) stop("Start literal matched ", nrow(s), " times: ", start_literal, call. = FALSE)
  if (nrow(e) != 1L) stop("End literal matched ", nrow(e), " times: ", end_literal, call. = FALSE)
  if (e[1, "end"] < s[1, "start"]) stop("End literal precedes start literal: ", start_literal, call. = FALSE)
  str_squish(substr(txt, s[1, "start"], e[1, "end"]))
}

## ---- the reported values ----------------------------------------------------
## section / page / species / quantity / unit / anchor / capture pattern
spec <- list(
  list("3.1", 4, "L", "E. helvum",                "number of subjects tested (sound localization)", "individuals",
       "The abilities of the two E. helvum", "illustrated in Fig. 1.", "the (two) E\\. helvum"),
  list("3.1", 4, "L", "C. brachyotis",            "number of subjects tested (sound localization)", "individuals",
       "The abilities of the two E. helvum", "illustrated in Fig. 1.", "the (two) C\\. brachyotis"),
  list("3.1", 4, "L", "E. helvum; C. brachyotis", "angle at which every individual performed perfectly", "degrees",
       "Each individual was capable", "or greater separation.", "at angles of ([0-9.]+)\u00b0 or greater"),
  list("3.1", 4, "L", "E. helvum",                ".50 performance threshold (minimum audible angle)", "degrees",
       "Below about 30\u00b0,", "for C. brachyotis.", "averaging ([0-9.]+)\u00b0 for E\\. helvum"),
  list("3.1", 4, "L", "C. brachyotis",            ".50 performance threshold (minimum audible angle)", "degrees",
       "Below about 30\u00b0,", "for C. brachyotis.", "and ([0-9.]+)\u00b0 for C\\. brachyotis"),
  list("3.2", 4, "L", "E. helvum",                "number of retinae obtained", "retinae",
       "We were able to obtain retinae", "of one E. helvum.", "retinae of (one) E\\. helvum"),
  list("3.2", 4, "L", "E. helvum",                "diameter of the flattened retina", "mm",
       "The flattened retina was", "approximately 190\u00b0.", "was ([0-9.]+) mm in diameter"),
  list("3.2", 4, "L", "E. helvum",                "visual angle subtended by the retina", "degrees",
       "The flattened retina was", "approximately 190\u00b0.", "visual angle of approximately ([0-9.]+)\u00b0"),
  list("3.2", 5, "L", "E. helvum",                "binocular field of vision", "degrees",
       "This is consistent with our measured", "approximately 60\u00b0.", "binocular field of vision of approximately ([0-9.]+)\u00b0"),
  list("3.2", 5, "L", "E. helvum",                "horizontal width of the field of best vision (>=75% of maximum ganglion-cell density)", "degrees",
       "The horizontal width of the field of best vision", "at least 75% of maximum).", "for E\\. helvum is ([0-9.]+)\u00b0"),
  list("3.2", 5, "L", "C. brachyotis",            "retinal analysis", "",
       "Due to agreement obligations", "from C. brachyotis.", NA_character_)
)

rows <- lapply(seq_along(spec), function(i) {
  s <- spec[[i]]
  sent <- sentence(s[[2]], s[[3]], s[[7]], s[[8]])
  val  <- if (is.na(s[[9]])) "n.a." else {
    m <- str_match(sent, s[[9]])
    if (is.na(m[1, 2])) stop("Value capture failed for: ", s[[5]], call. = FALSE)
    m[1, 2]
  }
  qual <- if (!is.na(s[[9]]) && str_detect(s[[9]], "approximately")) "approximately"
          else if (!is.na(s[[9]]) && str_detect(s[[9]], "or greater")) "or greater"
          else ""
  data.frame(
    row                = i,
    section            = s[[1]],
    printed_page       = printed_page_of(s[[2]]),
    pdf_page           = s[[2]],
    species_as_printed = s[[4]],
    quantity_as_printed = s[[5]],
    value_printed      = val,
    units_printed      = s[[6]],
    qualifier          = qual,
    verbatim_sentence  = sent,
    stringsAsFactors = FALSE)
})
snapshot <- do.call(rbind, rows)
stopifnot(nrow(snapshot) == 11L)

## ---- freeze (never silently overwrite a differing frozen copy) --------------
## readr::write_csv always emits UTF-8 regardless of the session locale; base
## write.csv(fileEncoding = "UTF-8") does not -- under a C locale it degrades the
## printed degree sign to the literal text "<U+00B0>", so the frozen evidence would
## depend on who ran the extract. The comparison is on raw bytes for the same reason.
tmp <- tempfile(fileext = ".csv")
write_csv(snapshot, tmp, na = "")
read_bytes <- function(p) readBin(p, "raw", file.info(p)$size)
if (file.exists(out_csv)) {
  if (identical(read_bytes(tmp), read_bytes(out_csv))) {
    message("Frozen snapshot unchanged: ", basename(out_csv))
  } else {
    stop("Frozen snapshot on disk differs from the extraction. Refusing to overwrite ",
         basename(out_csv), " -- inspect the difference first.", call. = FALSE)
  }
} else {
  file.copy(tmp, out_csv)
  message("Wrote constructed snapshot: ", basename(out_csv), " (", nrow(snapshot), " rows)")
}
print(snapshot[, c("row","section","printed_page","species_as_printed","quantity_as_printed","value_printed","units_printed","qualifier")])
