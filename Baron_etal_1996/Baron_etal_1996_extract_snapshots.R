# Baron, Stephan & Frahm (1996), Comparative Neurobiology in Chiroptera.
# Frozen source transcription of the book's RAW (non-index) tables.
#
# The book's PDF text layer has a scrambled reading order and a per-page
# "staircase" typesetting in which a row's values sit one half-line above its
# species name, so line-based parsing is unreliable.  This script therefore
# works from word COORDINATES (pdftools::pdf_data): species names are the
# non-numeric tokens, data columns are recovered by clustering the right edges
# of the numeric tokens, and each value is attached to a species by a per-page
# vertical offset chosen to make the assignment injective.
#
# REGRESSION GUARD: Tables 10 and 32 already have frozen snapshots produced by
# the earlier Python extractor.  This script re-derives both and stops unless
# every species string and every printed value is reproduced exactly, so the
# other tables are transcribed by a method that is checked against known-good
# output.  Run it with Rscript, or open in RStudio and Source.
#
# Size-index, average-size-index and percentage tables are deliberately NOT
# transcribed: they are derived from these raw tables (see the book's own
# Table 1 key, PDF pp. 264-265).

suppressPackageStartupMessages(library(pdftools))

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open it in RStudio and click Source.", call. = FALSE)
})
HERE <- dirname(.sp)
PDF <- file.path(HERE, "baron_etal_1996 book Comparative Neurobiology.pdf")

# ---------------------------------------------------------------- OCR repairs
# Literal token repairs, each checked against the rendered page.  No biological
# value is inferred or recomputed; these restore what is visibly printed.
TOKEN_REPAIRS <- c("~1.4" = "21.4", "/\",2.6" = "72.6", "1O.7" = "10.7",
                   "I" = "1", "l" = "1", "O" = "0")
# Letterform confusions inside otherwise numeric tokens (l/I/i -> 1, O/o/Q/D -> 0,
# J -> 1).  Applied only to tokens that already contain a digit.
NUMLIKE <- "^[0-9lOIiQDoJ][0-9lOIiQDoJ.,]*$"

# Species-name letterform repairs.  The abbreviated taxon wording the book
# prints is deliberately kept; only OCR damage is corrected.
NAME_REPAIRS <- c(
  "Laviafrons" = "Lavia frons", "Nycteris macro tis" = "Nycteris macrotis",
  "CaroWa perspicillata" = "Carollia perspicillata",
  "Sturn ira lilium" = "Sturnira lilium", "Sturn ira ludovici" = "Sturnira ludovici",
  "Sturn ira tUdae" = "Sturnira tildae", "Uroderma bUobatum" = "Uroderma bilobatum",
  "Lionycteris spurreUi" = "Lionycteris spurrelli",
  "Tadarida pUcata pUcata" = "Tadarida plicata plicata",
  "Cyttarops alec to" = "Cyttarops alecto", "Pteropus alec to" = "Pteropus alecto",
  "EctophyUa macconnelli" = "Ectophylla macconnelli",
  "Artibeus cine reus" = "Artibeus cinereus",
  "Artibeus jamaicen;is" = "Artibeus jamaicensis",
  "Miniopterus in flatus" = "Miniopterus inflatus", "fa io" = "Ia io",
  "Tonatia schuld" = "Tonatia schulzi",
  "Cynopterus braehyotis" = "Cynopterus brachyotis",
  "Eonyeteris spelaea" = "Eonycteris spelaea",
  "Hipposideros bieolor" = "Hipposideros bicolor",
  "Noetilio leporinus" = "Noctilio leporinus",
  "Molossus trinitatis (" = "Molossus trinitatis",
  "Penthetor /ucasi (PTN)" = "Penthetor lucasi (PTN)",
  "Penthetor /ucasi" = "Penthetor lucasi",
  "Ametrida centuria" = "Ametrida centurio",
  "Tadarida leu eo stigma" = "Tadarida leucostigma")

HEAD_RE  <- "^(Table|For|Brains|Size|Average|A verage|>|<)"
BAD_NAME <- "\\((cont|cant)\\.?\\)|^n$|^[A-Z]{2,4}$|\\bmm\\b|%"

fix_tok <- function(x) {
  x <- ifelse(x %in% names(TOKEN_REPAIRS), TOKEN_REPAIRS[x], x)
  i <- grepl(NUMLIKE, x) & grepl("[lOIiQDoJ]", x) & grepl("[0-9]", x)
  x[i] <- chartr("lOIiQDoJ", "10110001", x[i])
  x
}
is_heading <- function(s) {
  L <- gsub("[^A-Za-z]", "", s)
  nchar(L) < 3 || identical(L, toupper(L)) || grepl(BAD_NAME, s) || grepl(HEAD_RE, s)
}
# A value printed as "71. 4" reaches the text layer as two adjacent tokens.
merge_split_numbers <- function(pg) {
  pg <- pg[order(pg$y, pg$x), ]
  isn <- grepl("^[0-9][0-9.,]*$", pg$text); drop <- rep(FALSE, nrow(pg)); i <- 1L
  while (i < nrow(pg)) {
    if (isn[i] && isn[i + 1L] && abs(pg$y[i + 1L] - pg$y[i]) <= 2 &&
        (pg$x[i + 1L] - (pg$x[i] + pg$width[i])) < 3 &&
        (grepl("\\.$", pg$text[i]) || grepl("^[.,]", pg$text[i + 1L]))) {
      pg$text[i] <- paste0(pg$text[i], pg$text[i + 1L])
      pg$width[i] <- pg$x[i + 1L] + pg$width[i + 1L] - pg$x[i]
      drop[i + 1L] <- TRUE; isn[i + 1L] <- FALSE; i <- i + 2L
    } else i <- i + 1L
  }
  pg[!drop, ]
}
# Single-linkage clustering of numeric right edges into `ncol` data columns.
# Small clusters (marginal notes outside the table block) are discarded.
split_cols <- function(v, ncol) {
  cl <- function(thr) { o <- order(v); s <- v[o]; lab <- integer(length(v))
                        lab[o] <- cumsum(c(TRUE, diff(s) > thr)); lab }
  for (thr in c(8, 6, 10, 5, 12, 4, 14, 16, 3, 18, 20, 24)) {
    lab <- cl(thr); tb <- table(lab)
    keep <- as.integer(names(tb)[tb >= max(3, 0.25 * median(tb))])
    if (length(keep) == ncol) {
      out <- rep(NA_integer_, length(v))
      for (j in seq_along(keep)) out[lab == keep[j]] <- j
      return(out)
    }
  }
  o <- order(v); s <- v[o]; g <- diff(s)
  cut <- sort(order(g, decreasing = TRUE)[seq_len(ncol - 1L)])
  lab <- integer(length(v)); lab[o] <- rep(seq_len(ncol), times = diff(c(0, cut, length(s)))); lab
}

extract_page <- function(pg, ncol, y_min, y_max = Inf) {
  Encoding(pg$text) <- "UTF-8"
  a <- pg$y[grepl("^Abbreviations", pg$text)]
  ymax <- min(c(if (length(a)) min(a) - 2 else Inf, y_max))
  pg <- pg[pg$y >= y_min & pg$y <= ymax, ]
  pg <- pg[order(pg$y, pg$x), ]
  pg$text <- fix_tok(pg$text); pg <- pg[nzchar(pg$text), ]
  pg <- merge_split_numbers(pg)
  isnum <- grepl("^[0-9][0-9.,]*$", pg$text)
  nm <- pg[!isnum, ]; recs <- character(0); recy <- numeric(0)
  if (nrow(nm)) {
    g <- cumsum(c(TRUE, diff(nm$y) > 3))
    for (k in unique(g)) {
      L <- nm[g == k, ]; L <- L[order(L$x), ]
      s <- gsub("\\s+", " ", trimws(paste(L$text, collapse = " ")))
      if (is_heading(s)) next
      recs <- c(recs, s); recy <- c(recy, max(L$y))
    }
  }
  num <- pg[isnum, ]
  if (!length(recs) || !nrow(num)) return(NULL)
  lab <- split_cols(num$x + num$width, ncol)
  num <- num[!is.na(lab), ]; lab <- lab[!is.na(lab)]
  list(names = recs, y = recy,
       cols = lapply(seq_len(ncol), function(j) { t <- num[lab == j, ]; t[order(t$y, t$x), ] }))
}

assemble <- function(dat, pages, ncol, colnames_, y_min_first, y_max = Inf) {
  out <- NULL
  for (i in seq_along(pages)) {
    r <- extract_page(dat[[pages[i]]], ncol, if (i == 1L) y_min_first else 80, y_max)
    if (is.null(r)) next
    ns <- length(r$names); ny <- r$y
    score <- vapply(0:14, function(dl) sum(vapply(r$cols, function(t) {
      if (!nrow(t)) return(0L)
      idx <- vapply(t$y + dl, function(yy) which.min(abs(ny - yy)), 1L)
      length(unique(idx)) - 2L * sum(duplicated(idx))
    }, 1L)), 1L)
    dl <- (0:14)[which.max(score)]
    m <- as.data.frame(matrix(NA_character_, ns, ncol), stringsAsFactors = FALSE)
    names(m) <- colnames_
    for (j in seq_len(ncol)) {
      t <- r$cols[[j]]; if (!nrow(t)) next
      idx <- vapply(t$y + dl, function(yy) which.min(abs(ny - yy)), 1L)
      keep <- !duplicated(idx); m[idx[keep], j] <- t$text[keep]
    }
    nmv <- r$names
    nmv <- ifelse(nmv %in% names(NAME_REPAIRS), NAME_REPAIRS[nmv], nmv)
    out <- rbind(out, cbind(source_pdf_page = pages[i], species_printed = nmv, m,
                            stringsAsFactors = FALSE))
  }
  out <- out[rowSums(!is.na(out[, colnames_, drop = FALSE])) > 0, ]
  cbind(species_row = seq_len(nrow(out)), out, stringsAsFactors = FALSE)
}

# ------------------------------------------------------- table specifications
# pages / number of data columns / column names / first-page y cut / optional
# y cut where a later table starts on the same page.  Expected row counts are
# the species counts printed in the book's own Table 1 key.
SPECS <- list(
  Table8  = list(pages = 46:53,   cols = c("n","NET_mm3","NET_pct","VENT_mm3","VENT_pct","REST_mm3","REST_pct"), y1 = 142, N = 272),
  Table13 = list(pages = 74:78,   cols = c("TR","TSO","FUN","FGR","FCM","FCE"), y1 = 136, N = 150),
  Table16 = list(pages = 86:90,   cols = c("motX","motXII","REL","INO","PRP"), y1 = 134, N = 150),
  Table19 = list(pages = 98:102,  cols = c("VC","VM","VI","VL","VS"), y1 = 135, N = 150),
  Table22 = list(pages = 110:114, cols = c("AUD","CON","DCO","VCO","OLS"), y1 = 138, N = 150),
  Table25 = list(pages = 122:126, cols = c("MES","MTG","MTC","INC","SUC"), y1 = 135, N = 150),
  Table28 = list(pages = 134,     cols = c("CER","TCN","MCN","ICN","LCN"), y1 = 112, N = 18),
  Table30 = list(pages = 136,     cols = c("NLL","CGM","CGL","GLD","GLV"), y1 = 124, N = 19),
  Table36 = list(pages = 159,     cols = c("TOT","TOT_minus_BOL","ALLO_minus_BOL","NEO","ALLO","PAL_plus_BOL","SCH","HIP","CING"), y1 = 122, y2 = 293, N = 14),
  Table39 = list(pages = 161,     cols = c("TOT","NEO","ALLO","SEMI","SCH","BIC"), y1 = 98, y2 = 206, N = 6),
  Table42 = list(pages = 162,     cols = c("SEMI","PRPI","TOL","PSD","PAM"), y1 = 97, y2 = 204, N = 6),
  Table45 = list(pages = 163,     cols = c("BIC","RB","TT","CA","FD"), y1 = 99, y2 = 207, N = 6),
  Table48 = list(pages = 164,     cols = c("TOT","NEO","VIS","PRC","PRF","FRL","ALLO"), y1 = 100, y2 = 341, N = 15),
  # Table 51 prints two stacked blocks for the same six species.
  Table51 = list(pages = 166,     cols = c("BoW_g","BrW_mg","OBL","MES","CER","DIE","TEL"), y1 = 120, y2 = 200, N = 6,
                 block2 = list(cols = c("MOB","PAL_AMY","SEP","STR","HIP","SCH","NEO"), y1 = 205, y2 = 298))
)

message("Reading word coordinates from the PDF ...")
dat <- pdf_data(PDF, font_info = FALSE)
stopifnot(length(dat) == 170L)

# ------------------------------------------------------------ regression guard
guard <- function(item, pages, cols, y1) {
  old <- read.csv(file.path(HERE, paste0("Baron_etal_1996_", item, "_snapshot.csv")),
                  check.names = FALSE, stringsAsFactors = FALSE)
  new <- assemble(dat, pages, length(cols), cols, y1)
  if (nrow(new) != nrow(old)) stop(item, ": ", nrow(new), " rows re-derived, frozen snapshot has ", nrow(old))
  bad <- sum(iconv(trimws(old$species_printed), "UTF-8", "UTF-8") != new$species_printed, na.rm = TRUE)
  for (v in cols) {
    a <- suppressWarnings(as.numeric(old[[v]])); b <- suppressWarnings(as.numeric(new[[v]]))
    bad <- bad + sum(!(is.na(a) & is.na(b)) & (is.na(a) != is.na(b) | abs(a - b) > 1e-9))
  }
  if (bad) stop(item, ": ", bad, " cells differ from the frozen snapshot")
  message("  regression OK: ", item, " reproduced exactly (", nrow(new), " rows)")
}
message("Checking the extractor against the two frozen snapshots ...")
guard("Table10", 56:63, c("n","OBL","MES","CER","DIE","TEL"), 128)
guard("Table32", 138:145, c("MOB","PAL","STR","SEP","AMY","HIP","SCH","NEO"), 138)

# ------------------------------------------------------------------- write out
for (item in names(SPECS)) {
  s <- SPECS[[item]]
  y2 <- if (is.null(s$y2)) Inf else s$y2
  df <- assemble(dat, s$pages, length(s$cols), s$cols, s$y1, y2)
  if (!is.null(s$block2)) {
    b <- s$block2
    df2 <- assemble(dat, s$pages, length(b$cols), b$cols, b$y1, b$y2)
    # Block 2 repeats the species without the book's collection-code suffix,
    # so the blocks are matched on genus + epithet only.
    binom <- function(x) tolower(sub("^(\\S+\\s+\\S+).*$", "\\1", x))
    if (nrow(df) != nrow(df2) || !identical(binom(df$species_printed), binom(df2$species_printed)))
      stop(item, ": the two printed blocks do not agree on species")
    df <- cbind(df, df2[, b$cols, drop = FALSE])
  }
  if (nrow(df) != s$N)
    stop(item, ": ", nrow(df), " rows extracted, the book's Table 1 key gives N = ", s$N)
  out <- file.path(HERE, paste0("Baron_etal_1996_", item, "_snapshot.csv"))
  write.csv(df, out, row.names = FALSE, na = "")
  message(sprintf("  wrote %-42s %3d rows, %d empty cells",
                  basename(out), nrow(df),
                  sum(is.na(df[, setdiff(names(df), c("species_row","source_pdf_page","species_printed"))]))))
}
message("Done. Tables 2, 5 and 35 are NOT transcribed - see the folder README.")
