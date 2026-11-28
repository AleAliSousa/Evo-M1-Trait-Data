read_table51_printed <- function(path) {
  raw <- utils::read.csv(path, header=FALSE, check.names=FALSE, stringsAsFactors=FALSE,
                         colClasses="character", na.strings="", blank.lines.skip=FALSE,
                         fileEncoding="UTF-8")
  stopifnot(ncol(raw)==8L, nrow(raw)==16L, grepl("^Table 51", raw[[1]][1]))
  first <- raw[3:8, , drop=FALSE]
  second <- raw[11:16, , drop=FALSE]
  binom <- function(x) sub(" \\([^)]*\\)$", "", x)
  stopifnot(identical(binom(first[[1]]),second[[1]]))
  out <- cbind(first[,1:8,drop=FALSE],second[,2:8,drop=FALSE])
  names(out) <- c("species_printed","BoW_g","BrW_mg","OBL","MES","CER","DIE","TEL",
                  "MOB","PAL_AMY","SEP","STR","HIP","SCH","NEO")
  out$species_row <- seq_len(nrow(out))
  out$source_pdf_page <- 166L
  out
}
