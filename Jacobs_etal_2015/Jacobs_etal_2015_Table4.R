## Table 4 is printed with species in columns and measures in rows.
## The snapshot preserves that layout; this reader performs the transpose.
options(scipen = 999)

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  stop("Run with Rscript file.R", call. = FALSE)
})
folder <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
snapshot <- read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")),
                     header = FALSE, check.names = FALSE, stringsAsFactors = FALSE,
                     colClasses = "character", na.strings = character())
stopifnot(ncol(snapshot) == 6L, nrow(snapshot) == 15L,
          identical(snapshot[1, 1], "Table 4. Demographics of species in pyramidal neuron comparisons arranged by brain mass (high to low)"))
species <- as.character(snapshot[2, -1])
stopifnot(identical(species, c("Elephant^a", "Humpback Whale^b", "Minke Whale^b",
                               "Bottlenose Dolphin^b", "Giraffe")))
labels <- as.character(snapshot[3:9, 1])
expected <- c("Age/sex", "Fixation method^c", "Region sampled^d", "Mean Soma depth (µm)^e",
              "Mean Brain mass (g)", "Mean Soma size (µm²)^f", "n Pyramidal neurons")
stopifnot(identical(labels, expected))
stopifnot(identical(as.character(snapshot[10:15, 1]), letters[1:6]))
cell <- function(label) as.character(snapshot[match(label, snapshot[[1]]), -1])
pair <- function(x) {
  z <- strsplit(x, " ± ", fixed = TRUE)
  stopifnot(all(lengths(z) == 2L))
  list(mean = as.integer(gsub(",", "", vapply(z, `[[`, "", 1L), fixed = TRUE)),
       sd = as.integer(vapply(z, `[[`, "", 2L)))
}
depth <- pair(cell("Mean Soma depth (µm)^e"))
size <- pair(cell("Mean Soma size (µm²)^f"))
fixation <- cell("Fixation method^c")
fix_method <- sub(" \\(AT.*$", "", fixation)
fix_note <- ifelse(grepl("\\(AT", fixation), sub("^.*\\((AT[^)]*)\\)$", "\\1", fixation), "")
fix_note <- gsub(" ", "", fix_note, fixed = TRUE)
age <- gsub("–", "-", cell("Age/sex"), fixed = TRUE)
dat <- data.frame(
  Species = sub("\\^[ab]$", "", species),
  `Source Ref` = ifelse(grepl("\\^", species), sub("^.*\\^", "", species), ""),
  `Age/sex` = age,
  `Fixation method` = fix_method,
  `Fixation method note` = fix_note,
  `Region sampled` = cell("Region sampled^d"),
  `Mean Soma depth (um)` = depth$mean,
  `Mean Soma depth SD (um)` = depth$sd,
  `Mean Brain mass (g)` = as.integer(gsub(",", "", cell("Mean Brain mass (g)"), fixed = TRUE)),
  `Mean Soma size (um2)` = size$mean,
  `Mean Soma size SD (um2)` = size$sd,
  `n Pyramidal neurons` = as.integer(cell("n Pyramidal neurons")),
  check.names = FALSE, stringsAsFactors = FALSE
)
stopifnot(nrow(dat) == 5L, !anyNA(dat))
write.csv(dat, file.path(folder, paste0(item_name, ".csv")), row.names = FALSE, na = "")

base <- dirname(folder)
if (file.exists(file.path(base, "__ReadMe.xlsx"))) {
  fc <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  item_encoded <- fc$`Item encoded`[match(item_name, fc$`Item name`)]
  if (!is.na(item_encoded) && nzchar(item_encoded)) {
    write.table(dat, file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv")),
                sep = "\t", row.names = FALSE, quote = TRUE, na = "")
  }
}
