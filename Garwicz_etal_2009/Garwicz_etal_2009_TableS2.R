## Garwicz, Christensson & Psouni (2009)
## Table S2. Database for multiple-regression model
##
## Input  : Garwicz_etal_2009_TableS2_snapshot.csv  (frozen extraction from
##          0905777106si.pdf, page 6; already produced by the sibling
##          Garwicz_etal_2009_TableS1.R build, which extracts both S1 and S2
##          in one pass)
## Output : Garwicz_etal_2009_TableS2.csv
##          __Public/comparative-data/<Item encoded>.tsv
##
## Table S2 is the paper's own raw trait database, printed by common ("lay
## term") name only -- unlike the sibling TableS1 item, this build does NOT
## merge in binomial species names from Table S1's taxonomy list, since S2 is
## registered here as its own distinct printed table, not a re-derived join.

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

library(dplyr)
library(stringr)
library(readxl)

snapshot <- read.csv(
  "Garwicz_etal_2009_TableS2_snapshot.csv",
  stringsAsFactors = FALSE,
  check.names = FALSE
)

## Split the literature reference "(n)" (or "(n, m)") out of each measure
## column into its own "<col> Ref" column -- same convention as the sibling
## TableS1 build.
separate_ref <- function(df, col) {
  df %>%
    mutate(
      !!sym(paste0(col, " Ref")) := str_extract(!!sym(col), "\\(([^)]+)\\)"),
      !!sym(col)                 := str_remove(!!sym(col), " \\([^)]*\\)")
    )
}

dat <- snapshot %>%
  rename(
    `Species (lay term)`                  = `Species (lay term)`,
    `Absolute Brain Mass (g)`             = `AbsBrM, g`,
    `Neonatal Brain Mass (g)`             = `NeoBrM (1), g`,
    `Body Mass (g)`                       = `BoM, g`,
    `Gestation (days)`                    = `Gest., days`,
    `Walking onset (Postnatal days)`      = `WO, days_PN`,
    `Walking onset (Postconception days)` = `WO, days_PC`,
    `Precocial/Altricial`                 = `Pre/Alt`,
    `Hindlimb Standing Position`          = `HSP`
  ) %>%
  separate_ref("Absolute Brain Mass (g)") %>%
  separate_ref("Body Mass (g)") %>%
  separate_ref("Gestation (days)") %>%
  separate_ref("Walking onset (Postnatal days)") %>%
  select(
    `Species (lay term)`,
    `Absolute Brain Mass (g)`, `Absolute Brain Mass (g) Ref`,
    `Neonatal Brain Mass (g)`,
    `Body Mass (g)`, `Body Mass (g) Ref`,
    `Gestation (days)`, `Gestation (days) Ref`,
    `Walking onset (Postnatal days)`, `Walking onset (Postnatal days) Ref`,
    `Walking onset (Postconception days)`,
    `Precocial/Altricial`,
    `Hindlimb Standing Position`
  )

## "—" means no reported value (neonatal brain mass for a few species).
dat$`Neonatal Brain Mass (g)` <- ifelse(
  dat$`Neonatal Brain Mass (g)` %in% c("—", ""),
  NA,
  dat$`Neonatal Brain Mass (g)`
)

## Remove thousands-separator commas and coerce the five measure columns to
## numeric.
numeric_cols <- c(
  "Absolute Brain Mass (g)", "Neonatal Brain Mass (g)", "Body Mass (g)",
  "Gestation (days)", "Walking onset (Postnatal days)",
  "Walking onset (Postconception days)"
)
for (col in numeric_cols) {
  dat[[col]] <- as.numeric(gsub(",", "", dat[[col]]))
}

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
        paste0(item_encoded, ".tsv")
      ),
      sep = "\t",
      row.names = FALSE,
      na = ""
    )

    message("Wrote public file: ", item_encoded, ".tsv")
  }
}
