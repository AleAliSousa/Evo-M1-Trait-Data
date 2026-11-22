## Build exact individual regional cell counts from the deposited CSV member.
me <- "Baldoni_etal_2025_Figure2.R"
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
snap <- utils::read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")), check.names = FALSE, stringsAsFactors = FALSE)
stopifnot(nrow(snap) == 14L,
          identical(sort(unique(snap$Group)), sort(c("Summer Adult", "Summer Juvenile", "Winter Juvenile"))),
          sum(snap$Group == "Summer Adult") == 4L,
          sum(snap$Group == "Summer Juvenile") == 5L,
          sum(snap$Group == "Winter Juvenile") == 5L)
region_codes <- c("total", "ob", "neo", "nac", "cau", "amy", "hip")
region_names <- c("All brain", "Olfactory bulb", "Neocortex", "Nucleus accumbens",
                  "Caudoputamen", "Amygdala", "Hippocampus")
records <- vector("list", nrow(snap) * length(region_codes))
k <- 0L
for (i in seq_len(nrow(snap))) {
  for (j in seq_along(region_codes)) {
    code <- region_codes[j]
    all <- snap[[paste0(code, "_all")]][i]
    neu <- snap[[paste0(code, "_neu")]][i]
    glia <- if (code == "ob") NA_real_ else snap[[paste0(code, "_gl")]][i]
    k <- k + 1L
    records[[k]] <- data.frame(
      Species = "Sorex araneus", species_as_published = "common shrew",
      source_id = snap$id[i], animal_id = snap$animal[i],
      Group_as_published = snap$Group[i], phase_as_published = snap$phase[i],
      season = if (grepl("^Winter", snap$Group[i])) "Winter" else "Summer",
      age_stage = if (grepl("Adult$", snap$Group[i])) "Adult" else "Juvenile",
      figure2_plotted = snap$Group[i] %in% c("Summer Juvenile", "Winter Juvenile"),
      sex = snap$sex[i], source_region = code, Structure_as_published = region_names[j],
      AllCells.n = all, Neurons.n = neu, Glia.n = glia,
      All_minus_neurons_glia.n = if (is.na(glia)) NA_real_ else all - neu - glia,
      WholeBrain_Mass.mg = snap$brainmass[i] * 1000,
      check.names = FALSE, stringsAsFactors = FALSE)
  }
}
final.dataframe <- do.call(rbind, records)
stopifnot(nrow(final.dataframe) == 98L,
          all(!is.na(final.dataframe$AllCells.n)), all(!is.na(final.dataframe$Neurons.n)),
          sum(final.dataframe$figure2_plotted) == 70L)
check_rows <- final.dataframe[!is.na(final.dataframe$Glia.n), , drop = FALSE]
check_diff <- check_rows$Neurons.n + check_rows$Glia.n - check_rows$AllCells.n
table_checks <- data.frame(
  check_id = paste(check_rows$source_id, check_rows$source_region, sep = ":"),
  basis = "neuron plus glia equals all cells in deposited CSV",
  observed = check_rows$Neurons.n + check_rows$Glia.n,
  printed = check_rows$AllCells.n,
  difference = check_diff,
  tolerance = 1,
  status = ifelse(abs(check_diff) <= 1, "pass", "mismatch"),
  note = "Source values kept verbatim; discrepancies flagged",
  stringsAsFactors = FALSE)
utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), row.names = FALSE, na = "", fileEncoding = "UTF-8")
reg <- readxl::read_excel(file.path(root, "__ReadMe.xlsx"), sheet = "Sheet1")
hit <- which(reg[["Item name"]] == item_name)
if (length(hit) != 1L) stop("Expected one registry row for ", item_name)
item_encoded <- as.character(reg[["Item encoded"]][hit])
if (is.na(item_encoded) || !nzchar(item_encoded) || endsWith(item_encoded, "_")) stop("Invalid Item encoded")
public <- file.path(root, "__Public", "comparative-data")
dir.create(public, recursive = TRUE, showWarnings = FALSE)
utils::write.table(final.dataframe, file.path(public, paste0(item_encoded, ".tsv")), sep = "\t", row.names = FALSE, na = "", fileEncoding = "UTF-8")
cat(item_name, ": ", nrow(final.dataframe), " rows x ", ncol(final.dataframe), " columns\n", sep = "")
