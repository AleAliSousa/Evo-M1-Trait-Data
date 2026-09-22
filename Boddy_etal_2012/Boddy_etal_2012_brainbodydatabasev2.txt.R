## Boddy et al. 2012 brain_body_database_v2
##
## Input  : brain_body_database_v2.txt  (frozen snapshot)
## Output : Boddy_etal_2012_brainbodydatabasev2.txt.csv
##          10.1111%2Fj.1420-9101.2012.02491.x_brainbodydatabasev2.txt
##
## No separate snapshot file is required; the TXT file is the snapshot.

options(scipen = 999)

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  stop("Run with Rscript file.R", call. = FALSE)
})

folder <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))

base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) {
    d <- dirname(d)
  }
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})

setwd(folder)

dat <- read.delim(
  "brain_body_database_v2.txt",
  sep = "\t",
  quote = "\"",
  check.names = FALSE,
  stringsAsFactors = FALSE,
  na.strings = c("", "NA")
)

dat$source_dataset <- "Boddy_etal_2012_brainbodydatabasev2"

csv_file <- paste0(item_name, ".csv")

write.csv(
  dat,
  csv_file,
  row.names = FALSE,
  na = ""
)

message("Rows: ", nrow(dat))
message("CSV: ", basename(csv_file))

if (!is.na(base)) {
  
  filecodes <- readxl::read_excel(
    file.path(base, "__ReadMe.xlsx")
  )
  
  item_encoded <- filecodes$`Item encoded`[
    match(item_name, filecodes$`Item name`)
  ]
  
  if (!is.na(item_encoded) && nzchar(item_encoded)) {
    
    write.table(
      dat,
      file.path(
        base,
        "__Public",
        "comparative-data",
        item_encoded
      ),
      sep = "\t",
      row.names = FALSE,
      quote = TRUE,
      na = ""
    )
    
    message("Wrote public file: ", item_encoded)
  }
}