## Mixed-source comparison table; preserve per-cell citations and qualifiers.
me <- "Naumann_etal_2016_Table3.R"
a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
if (!length(a)) stop("Run with Rscript")
folder <- dirname(normalizePath(sub("^--file=", "", a[1])))
item_name <- tools::file_path_sans_ext(me)
root <- dirname(folder)
snap <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                        check.names = FALSE, colClasses = "character", na.strings = NULL)
stopifnot(nrow(snap) == 5L, ncol(snap) == 7L)
key <- utils::read.csv(file.path(root, "_keys", "General", "species_key.csv"),
                       stringsAsFactors = FALSE)
key <- key[key$source_publication == "Naumann_etal_2016", ]
idx <- match(snap[[1]], key$variant_name)
stopifnot(!anyNA(idx))
species <- key$accepted_name[idx]
order <- unname(c("Shrew"="Eulipotyphla", "Mouse"="Rodentia",
                  "Rat"="Rodentia", "Egyptian fruit bat"="Chiroptera",
                  "Human"="Primata")[snap[[1]]])

parse_value <- function(x) {
  x <- trimws(x)
  if (!nzchar(x)) return(c(value=NA_real_, SD=NA_real_, lower=NA_real_, upper=NA_real_, qualifier="not reported"))
  y <- gsub(",", "", x, fixed = TRUE)
  y <- gsub("×", "x", y, fixed = TRUE)
  factor <- 1
  if (grepl(" x 10^", y, fixed = TRUE)) {
    pieces <- strsplit(y, " x 10^", fixed = TRUE)[[1]]
    stopifnot(length(pieces) == 2L)
    factor <- 10^as.numeric(pieces[2]); y <- pieces[1]
  }
  approximate <- grepl("^∼", y)
  y <- sub("^∼", "", y)
  range <- regmatches(y, regexec("\\(([0-9.]+)[–-]([0-9.]+)\\)", y))[[1]]
  lower <- upper <- NA_real_
  if (length(range) == 3L) {
    lower <- as.numeric(range[2]) * factor; upper <- as.numeric(range[3]) * factor
    y <- trimws(sub("\\([^)]*\\)", "", y))
  }
  if (grepl("[–-]", y)) {
    bound <- strsplit(y, "[–-]")[[1]]
    stopifnot(length(bound) == 2L)
    return(c(value=NA_real_, SD=NA_real_, lower=as.numeric(bound[1])*factor,
             upper=as.numeric(bound[2])*factor, qualifier="range"))
  }
  pm <- strsplit(y, " ± ", fixed = TRUE)[[1]]
  stopifnot(length(pm) %in% c(1L,2L))
  c(value=as.numeric(pm[1])*factor,
    SD=if (length(pm)==2L) as.numeric(pm[2])*factor else NA_real_,
    lower=lower, upper=upper,
    qualifier=if (approximate) "approximate" else "reported")
}

fields <- list(
  list(label="brain size", value=2L, reference=3L, unit="mg"),
  list(label="layer 4 barrel/finger neurons", value=4L, reference=5L, unit="neurons"),
  list(label="entorhinal cortex neurons", value=6L, reference=7L, unit="neurons"))
res <- list(); n <- 0L
for (i in seq_len(nrow(snap))) for (field in fields) {
  raw <- snap[[field$value]][i]
  ref <- snap[[field$reference]][i]
  parsed <- parse_value(raw)
  role <- if (!nzchar(raw)) "not reported" else if (ref == "This study")
    "primary" else if (grepl("Estimate; this study", ref, fixed = TRUE))
    "author estimate" else "secondary"
  n <- n+1L
  res[[n]] <- data.frame(source_row=i, species_as_published=snap[[1]][i],
    Species=species[i], Order=order[i], measure=field$label,
    value_as_published=raw, value=as.numeric(parsed["value"]),
    SD=as.numeric(parsed["SD"]), lower_bound=as.numeric(parsed["lower"]),
    upper_bound=as.numeric(parsed["upper"]), qualifier=parsed["qualifier"],
    unit=field$unit, source_reference_as_published=ref,
    data_role=role, stringsAsFactors=FALSE)
}
final.dataframe <- do.call(rbind, res)
stopifnot(nrow(final.dataframe) == 15L,
          sum(final.dataframe$data_role == "primary") == 2L)
options(scipen=999)
utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")),
                 row.names=FALSE, na="", fileEncoding="UTF-8")
reg <- readxl::read_excel(file.path(root,"__ReadMeAddON.xlsx"),sheet="Sheet1")
hit <- which(reg[["Item name"]] == item_name)
if (length(hit)!=1L) stop("Expected one AddON registry row")
item_encoded <- as.character(reg[["Item encoded"]][hit])
if (!nzchar(item_encoded) || endsWith(item_encoded,"_")) stop("Invalid Item encoded")
utils::write.table(final.dataframe,
  file.path(root,"__Public","comparative-data",paste0(item_encoded,".tsv")),
  sep="\t",row.names=FALSE,na="",fileEncoding="UTF-8")
cat(item_name,": ",nrow(final.dataframe)," measure rows\n",sep="")
