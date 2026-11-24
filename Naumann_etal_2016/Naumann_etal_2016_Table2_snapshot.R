## Freeze Table 2 from the locally held Europe PMC full-text XML.
me <- "Naumann_etal_2016_Table2_snapshot.R"
a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
if (!length(a)) stop("Run with Rscript")
folder <- dirname(normalizePath(sub("^--file=", "", a[1])))
item_name <- sub("_snapshot\\.R$", "", me)
doc <- xml2::read_xml(file.path(folder, "Naumann_etal_2016_fullText.xml"))
wrap <- xml2::xml_find_all(doc, ".//table-wrap")
labels <- vapply(wrap, function(x) xml2::xml_text(xml2::xml_find_first(x, "./label")), character(1))
hit <- which(labels == "Table 2")
stopifnot(length(hit) == 1L)
tab <- xml2::xml_find_first(wrap[[hit]], ".//table")
for (sup in rvest::html_elements(tab, "sup"))
  xml2::xml_set_text(sup, paste0("^", xml2::xml_text(sup)))
snapshot <- as.data.frame(rvest::html_table(tab, fill = TRUE), stringsAsFactors = FALSE)
stopifnot(nrow(snapshot) == 5L)
out <- file.path(folder, paste0(item_name, "_snapshot.csv"))
if (file.exists(out)) {
 old <- utils::read.csv(out, check.names = FALSE, colClasses = "character", na.strings = NULL)
 if (!identical(unname(as.matrix(old)), unname(as.matrix(snapshot))))
   stop("Frozen snapshot differs from full-text XML")
} else {
 utils::write.csv(snapshot, out, row.names = FALSE, fileEncoding = "UTF-8")
}
cat(item_name, ": ", nrow(snapshot), " source-order rows\n", sep = "")
