## Read only this item's frozen snapshot; write analysis CSV and public TSV.
me <- "deRooij_etal_2016_Table2.R"
script_path <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a) && basename(sub("^--file=", "", a[1])) == me)
    return(normalizePath(sub("^--file=", "", a[1])))
  hits <- list.files(getwd(), pattern = paste0("^", me, "$"), recursive = TRUE, full.names = TRUE)
  if (length(hits) != 1L) stop("Cannot locate script: ", me)
  normalizePath(hits)
})
folder <- dirname(script_path)
item_name <- tools::file_path_sans_ext(basename(script_path))
root <- folder
while (!file.exists(file.path(root, "__ReadMe.xlsx")) && dirname(root) != root) root <- dirname(root)
if (!file.exists(file.path(root, "__ReadMe.xlsx"))) stop("Repository root not found")
snap <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")), skip=1, check.names=FALSE, colClasses="character", na.strings="")
stopifnot(nrow(snap)==21L)
groups <- c("born_before_famine", "early_gestation_exposed", "conceived_after_famine")
sex <- ""
n_by_group <- numeric(3)
records <- list()
for (i in seq_len(20L)) {
  z <- snap[i,]
  label <- z[[1]]
  if (label %in% c("Males (n)","Females (n)")) {
    sex <- if (label=="Males (n)") "male" else "female"
    n_by_group <- as.integer(unlist(z[2:4], use.names=FALSE))
    next
  }
  unit <- if (grepl("\\(ml\\)",label)) "mm3" else if (grepl("\\(cm\\)",label)) "cm" else if (grepl("\\(mm\\)",label)) "mm" else "ratio"
  factor <- if (unit=="mm3") 1000 else 1 # ml to mm3
  total <- z[[5]]
  m <- regexec("^([0-9.]+) \\(([0-9.]+)\\)$", total)
  g <- regmatches(total,m)[[1]]
  if (length(g)!=3L) stop("Unparsed Total (SD): ",total)
  for (j in seq_along(groups)) records[[length(records)+1L]] <- data.frame(
    Species="Homo sapiens", species_as_published="human", sex=sex,
    exposure_group=groups[j], source_measure=label, unit=unit,
    n=n_by_group[j], GroupMean=as.numeric(z[[j+1L]])*factor,
    OverallMean_all_groups=as.numeric(g[2])*factor,
    OverallSD_all_groups=as.numeric(g[3])*factor,
    P_exposed_vs_combined_unexposed=as.numeric(z[[6]]),
    check.names=FALSE, stringsAsFactors=FALSE)
}
final.dataframe <- do.call(rbind,records)
stopifnot(nrow(final.dataframe)==54L)

utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), row.names=FALSE, na="", fileEncoding="UTF-8")
reg <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet="Sheet1")
hit <- which(reg[["Item name"]] == item_name)
if (length(hit) != 1L) stop("Expected one registry row for ", item_name)
item_encoded <- as.character(reg[["Item encoded"]][hit])
if (is.na(item_encoded) || !nzchar(item_encoded) || endsWith(item_encoded, "_")) stop("Invalid Item encoded")
public <- file.path(root, "__Public", "comparative-data")
dir.create(public, recursive=TRUE, showWarnings=FALSE)
utils::write.table(final.dataframe, file.path(public, paste0(item_encoded, ".tsv")), sep="\t", row.names=FALSE, na="", fileEncoding="UTF-8")
cat(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe), " columns\n", sep="")
