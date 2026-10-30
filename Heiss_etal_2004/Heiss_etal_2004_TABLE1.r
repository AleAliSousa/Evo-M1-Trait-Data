## 0. Paths -------------------------------------------------------

.sp <- local({
  ## Rscript script.R
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) {
    return(normalizePath(sub("^--file=", "", a[1]), mustWork = TRUE))
  }
  
  ## source("script.R") / RStudio Source button
  ofile <- NULL
  frames <- sys.frames()
  
  for (i in rev(seq_along(frames))) {
    if (!is.null(frames[[i]]$ofile) && nzchar(frames[[i]]$ofile)) {
      ofile <- frames[[i]]$ofile
      break
    }
  }
  
  if (!is.null(ofile) && nzchar(ofile)) {
    return(normalizePath(ofile, mustWork = TRUE))
  }
  
  ## RStudio Run button / selected lines fallback
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) {
      return(normalizePath(p, mustWork = TRUE))
    }
  }
  
  ## Final fallback: assume working directory is the paper folder
  warning(
    "Could not detect script path; using current working directory as the paper folder."
  )
  
  file.path(normalizePath(getwd(), mustWork = TRUE), "unknown_script.R")
})

folder    <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))

if (identical(item_name, "unknown_script")) {
  ## Guess item name from the snapshot file in the working directory
  snapshots <- list.files(folder, pattern = "_snapshot\\.xlsx$", full.names = FALSE)
  
  if (length(snapshots) == 1) {
    item_name <- sub("_snapshot\\.xlsx$", "", snapshots)
  } else {
    stop(
      "Could not infer item_name. Run with Source/Rscript, or set item_name manually.",
      call. = FALSE
    )
  }
}

base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) {
    d <- dirname(d)
  }
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})

setwd(folder)

snapshot_xlsx <- file.path(folder, paste0(item_name, "_snapshot.xlsx"))
final_csv     <- file.path(folder, paste0(item_name, ".csv"))

if (!is.na(base)) {
  readme_xlsx    <- file.path(base, "__ReadMe.xlsx")
  public_tsv_dir <- file.path(base, "__Public", "comparative-data")
} else {
  readme_xlsx    <- NA_character_
  public_tsv_dir <- NA_character_
}



library(readxl)
library(tidyverse)


# ------------------------------------------------------------
# 1) Read raw sheet (no headers)
# ------------------------------------------------------------

raw <- read_excel(snapshot_xlsx, sheet = 1, col_names = FALSE) |>
  mutate(across(everything(), as.character))


# ------------------------------------------------------------
# 2) Build column names
# ------------------------------------------------------------

# IGNORE rows 1-2 (table title)
raw2 <- raw[-c(1, 2), ]

# Extract header rows as character vectors
h1 <- as.character(raw2[1, ])
h2 <- as.character(raw2[2, ])

h1[h1 == "NA"] <- NA
h2[h2 == "NA"] <- NA

h1 <- stringr::str_trim(h1)
h2 <- stringr::str_trim(h2)

# Fill to the right in row 1 to get main column names
for (i in seq_along(h1)) {
  if (is.na(h1[i]) && i > 1) {
    h1[i] <- h1[i - 1]
  }
}

# Combine header rows to create final column names
col_names <- mapply(
  function(a, b) {
    paste(c(a, b)[!is.na(c(a, b)) & c(a, b) != ""], collapse = " ")
  },
  h1, h2,
  USE.NAMES = FALSE
)


# ------------------------------------------------------------
# 3) Remove header rows and assign column names
# ------------------------------------------------------------

df0 <- raw2[-c(1:2), ]
colnames(df0) <- col_names


# ------------------------------------------------------------
# 4) Detect indentation
# ------------------------------------------------------------

# First, handle exception: make "Cerebral cortex" a category row

i <- which(df0$Region == "Cerebral cortex (global average)")
stopifnot(length(i) == 1)

new_row <- df0[i, ]
new_row[] <- NA
new_row$Region <- "Cerebral cortex"

df1 <- bind_rows(
  df0[1:(i - 1), ],
  new_row,
  df0[i, ] |> mutate(Region = paste0("    ", Region)),
  df0[(i + 1):nrow(df0), ]
)

df2 <- df1 |>
  mutate(
    raw_region = Region,
    indented = raw_region != str_trim(raw_region),
    region = str_squish(raw_region)
  )


# ------------------------------------------------------------
# 5) Create categories from subheader rows
# ------------------------------------------------------------

df3 <- df2 |>
  mutate(
    category = if_else(!indented, region, NA_character_)
  ) |>
  fill(category, .direction = "down")


# ------------------------------------------------------------
# 6) Remove category subheader rows and helper columns
# ------------------------------------------------------------

df4 <- df3 |>
  filter(indented) |>
  mutate(
    Region = str_squish(raw_region)
  ) |>
  select(category, everything()) |>
  select(-raw_region, -indented, -region)


# ------------------------------------------------------------
# 7) Coerce numeric columns
# ------------------------------------------------------------

is_numeric <- function(x) {
  str_detect(
    x,
    "^[-+]?[0-9]*\\.?[0-9]+([eE][-+]?[0-9]+)?$"
  )
}

df_numeric <- df4 |>
  mutate(
    P = str_remove_all(P, "†"),
    `Left minus right hemisphere Difference` =
      str_replace_all(
        `Left minus right hemisphere Difference`,
        "\u2212", "-"
      )
  ) |>
  mutate(across(
    -c(category, Region),
    ~ {
      x <- str_trim(.x)
      ifelse(is_numeric(x), as.numeric(x), x)
    }
  ))


# ------------------------------------------------------------
# 8) Save: local CSV + public TSV
# ------------------------------------------------------------

final.dataframe <- df_numeric

write.csv(final.dataframe, final_csv, row.names = FALSE)
message("Wrote ", final_csv, "  (", nrow(final.dataframe), " rows)")

if (is.na(base)) {
  warning("Repo root not found; TSV skipped.")
} else if (!file.exists(readme_xlsx)) {
  warning("__ReadMe.xlsx not found at ", readme_xlsx, "; TSV skipped.")
} else {
  filecodes <- read_excel(readme_xlsx, sheet = "Sheet1")
  
  norm_key <- function(x) {
    tolower(gsub("[ _]", "", as.character(x)))
  }
  
  item_encoded <- filecodes$`Item encoded`[
    match(norm_key(item_name), norm_key(filecodes$`Item name`))
  ]
  
  if (is.na(item_encoded) || !nzchar(item_encoded)) {
    warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
  } else {
    dir.create(public_tsv_dir, recursive = TRUE, showWarnings = FALSE)
    
    public_tsv <- file.path(public_tsv_dir, paste0(item_encoded, ".tsv"))
    
    write.table(
      final.dataframe,
      file = public_tsv,
      sep = "\t",
      row.names = FALSE
    )
    
    message("Wrote ", public_tsv)
  }
}