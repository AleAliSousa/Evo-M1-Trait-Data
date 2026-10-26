# Frozen published source -> analysis CSV -> registered public TSV.
# Extracted by Codex, 2026-10-25. See the item README and definitions.
options(scipen = 999)
.sp <- local({
  for (fr in rev(sys.frames())) if (!is.null(fr$ofile)) return(normalizePath(fr$ofile))
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly=TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run this saved file with Rscript or source().")
})
folder <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
base <- dirname(folder)
source_name <- basename(folder)
num <- function(x) suppressWarnings(as.numeric(x))
raw <- readxl::read_excel(file.path(folder,paste0(item_name,"_snapshot.xlsx")), sheet="table s1 revised", col_types="text")
# Exclude only the five trailing footnotes, using the numeric trial number.
x <- as.data.frame(raw[!is.na(num(raw[[10]])), ], stringsAsFactors=FALSE)
names(x) <- c("individual_id","zoo","date_tested","common_name","species","genus","family","suborder","sex","trial_number","successful_opening_box","latency_to_approach_s","time_working_s","behavioral_diversity","dexterity_score","species_average_group_size","group_size_category","retrieved_food","fed_before_trial","body_mass_g","brain_volume_mm3","cerebellum_brainstem_volume_mm3","anterior_cerebrum_volume_mm3","posterior_cerebrum_volume_mm3","total_endocranial_volume_mm3","puzzle_box_size")
x[x=="-"] <- NA
for (j in c(10,12:16,20:25)) x[[j]] <- num(x[[j]])
x$date_tested <- as.character(as.Date(num(x$date_tested),origin="1899-12-30"))
x$body_mass_g <- x$body_mass_g * 1000 # author kg -> g
x$brain_volume_mm3 <- x$brain_volume_mm3 * 1000 # author mL -> mm3
# Do not recode retrieved_food missing as Yes: source only marks No for unretrieved rewards.
x$brain_body_source_key <- "FinarelliFlynn2009"
x$regional_volume_source_key <- "Swanson2012"
x$behavior_data_role <- "primary"
x$anatomy_data_role <- "secondary"
x$first_trial_score_exception <- x$trial_number > 1 & (!is.na(x$behavioral_diversity) | !is.na(x$dexterity_score))
x$source <- source_name
final.dataframe <- x
stopifnot(nrow(x)==495, length(unique(x$individual_id))==140, length(unique(x$species))==39)
stopifnot(!anyDuplicated(x[c("individual_id","zoo","trial_number")]))
stopifnot(sum(x$first_trial_score_exception)==1,
          x$individual_id[x$first_trial_score_exception]=="Dogo",
          x$trial_number[x$first_trial_score_exception]==3)

# The live registry is the naming authority, looked up by item name.
filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet="Sheet1")
ix <- which(filecodes[["Item name"]] == item_name)
stopifnot(length(ix) == 1L)
item_encoded <- filecodes[["Item encoded"]][ix]
stopifnot(!is.na(item_encoded), nzchar(item_encoded), !grepl("_$", item_encoded))
utils::write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), row.names=FALSE, na="")
utils::write.table(final.dataframe, file.path(base, "__Public", "comparative-data", paste0(item_encoded, ".tsv")), sep="\t", row.names=FALSE, na="")
message(item_name, ": ", nrow(final.dataframe), " rows; ", ncol(final.dataframe), " columns")
