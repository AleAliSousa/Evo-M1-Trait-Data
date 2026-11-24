## Freeze the three sections of the publisher's HTML SI Table 2 in source order.
me <- "HerculanoHouzel_etal_2007_SITable2_snapshot.R"
a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
if (!length(a)) stop("Run this script with Rscript")
folder <- dirname(normalizePath(sub("^--file=", "", a[1])))
item_name <- sub("_snapshot\\.R$", "", me)
source_file <- file.path(folder, "index.html")
doc <- rvest::read_html(source_file)
tables <- rvest::html_elements(doc, "table")
stopifnot(length(tables) == 4L)
parts <- lapply(seq_along(tables)[-1], function(i) {
  ## HTML text extraction otherwise collapses 10<sup>6</sup> to 106.
  superscripts <- rvest::html_elements(tables[[i]], "sup")
  for (sup in superscripts)
    xml2::xml_set_text(sup, paste0("^", xml2::xml_text(sup)))
  tab <- as.data.frame(rvest::html_table(tables[[i]], fill = TRUE),
                       stringsAsFactors = FALSE)
  stopifnot(identical(dim(tab), c(8L, 11L)))
  tab[] <- lapply(tab, function(x) trimws(gsub("[[:space:]]+", " ", x)))
  section <- c("Cortex", "Cerebellum", "Remaining areas")[i - 1L]
  head <- as.data.frame(as.list(c(section, rep("", 10))),
                        stringsAsFactors = FALSE)
  names(head) <- names(tab)
  rbind(head, tab)
})
snapshot <- do.call(rbind, parts)
stopifnot(nrow(snapshot) == 27L,
          identical(as.character(snapshot[c(1, 10, 19), 1]),
                    c("Cortex", "Cerebellum", "Remaining areas")))
out <- file.path(folder, paste0(item_name, "_snapshot.csv"))
if (file.exists(out)) {
  old <- utils::read.csv(out, header = FALSE, check.names = FALSE,
                         colClasses = "character", na.strings = NULL)
  if (!identical(unname(as.matrix(old)), unname(as.matrix(snapshot))))
    stop("Frozen snapshot differs from current HTML; inspect before overwriting")
} else {
  utils::write.table(snapshot, out, sep = ",", quote = TRUE,
                     row.names = FALSE, col.names = FALSE, na = "",
                     fileEncoding = "UTF-8")
}
cat(item_name, ": frozen ", nrow(snapshot), " source-order rows\n", sep = "")
