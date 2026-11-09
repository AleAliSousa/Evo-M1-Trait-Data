#!/usr/bin/env Rscript
# =============================================================================
# list_unclassified.R -- list the app variables that have no row in
# _keys/variable_definitions.csv (the "N of M variables are unclassified" banner).
#
# Runs the app's own startup (app.R up to the coverage check), so the list is
# exactly what the app sees after supersede / unalias / label harmonisation --
# not a re-implementation of it. Writes label, dataset, n_species, example value.
#
#   Rscript __ShinyApp/list_unclassified.R [out.csv]     (default: stdout summary only)
#
# Feed the result to _keys/classify_unclassified_labels.py.
# =============================================================================
args <- commandArgs(trailingOnly = FALSE)
file_arg <- sub("^--file=", "", args[grep("^--file=", args)])
app_dir <- dirname(normalizePath(file_arg))
out_path <- commandArgs(trailingOnly = TRUE)[1]
setwd(app_dir)
suppressWarnings(suppressMessages({
  ln  <- readLines("app.R", encoding = "UTF-8")
  end <- grep("^var_domain\\[!nzchar\\(var_domain\\)\\]", ln)[1]
  eval(parse(text = ln[1:end]), envir = globalenv())
}))
u <- present[!nzchar(look(lab_domain, present))]
d <- compiled[compiled$Variable %in% u, ]
res <- do.call(rbind, lapply(u, function(v) {
  x <- d[d$Variable == v, ]
  data.frame(label = v, dataset = x$Dataset[1], n_species = length(unique(x$Species)),
             example = substr(gsub("[^ -~]", "?", x$Value[1], useBytes = TRUE), 1, 60), stringsAsFactors = FALSE)
}))
if (is.null(res)) res <- data.frame(label = character(), dataset = character(),
                                    n_species = integer(), example = character())
# raw UTF-8 bytes: write.csv in a C locale mangles non-ASCII labels (same trap as
# build_variable_definitions.R)
if (!is.na(out_path)) {
  q <- function(x) paste0('"', gsub('"', '""', as.character(x)), '"')
  lines <- c("label,dataset,n_species,example",
             paste(q(res$label), q(res$dataset), res$n_species, q(res$example), sep = ","))
  con <- file(out_path, open = "wb")
  writeBin(charToRaw(enc2utf8(paste0(paste(lines, collapse = "\n"), "\n"))), con)
  close(con)
}
cat(sprintf("%d of %d variables unclassified\n", length(u), length(present)))
print(table(res$dataset))
