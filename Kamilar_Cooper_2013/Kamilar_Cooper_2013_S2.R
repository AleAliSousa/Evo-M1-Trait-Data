# Frozen published supplement -> analysis CSV and public TSV.
# Optional DATASET_REGISTRY supplies an explicitly staged registry during registration.
suppressPackageStartupMessages({library(readxl); library(readr)})
base <- NULL
for (fr in rev(sys.frames())) {
  candidate <- get0("ofile", envir=fr, inherits=FALSE)
  if (is.character(candidate) && length(candidate)==1L && grepl("\\.R$", candidate)) {base <- candidate; break}
}
if (is.null(base)) {
  arg <- grep("^--file=", commandArgs(FALSE), value=TRUE)
  if (length(arg)) base <- sub("^--file=", "", arg[1])
}
if (is.null(base)) stop("Run with Rscript or source()")
base <- normalizePath(base)
folder <- dirname(base)
item_name <- tools::file_path_sans_ext(basename(base))
repo <- dirname(folder)
num <- function(x) suppressWarnings(as.numeric(trimws(as.character(x))))
raw <- read_excel(file.path(folder,paste0(item_name,"_snapshot.xlsx")),sheet=1,range="A1:AO214",col_types="text",na=c("","NA"))
names(raw) <- c("Species","Endocranial_volume_mm3","Female_endocranial_volume_mm3","Brain_size_ref","Male_body_mass_g","Female_body_mass_g","Body_mass_dimorphism","Mass_ref","Social_group_size","Adult_males","Adult_females","Adult_sex_ratio","Social_organization_ref","Interbirth_interval_days","Gestation_days","Weaning_age_days","Maximum_longevity_months","Litter_size","Life_history_ref","Midrange_latitude_deg","Mean_precipitation_mm","Mean_temperature_C","AET_mm","PET_mm","Climate_ref","Home_range_km2","Home_range_ref","Day_range_km","Day_range_ref","Territoriality_index","Diet_fruit_pct","Diet_leaves_pct","Diet_fauna_pct","Diet_ref","Canine_dimorphism","Canine_dimorphism_ref","Time_feeding_pct","Time_moving_pct","Time_resting_pct","Time_social_pct","Activity_budget_ref")
final.dataframe <- as.data.frame(raw,stringsAsFactors=FALSE)
numeric_columns <- c("Endocranial_volume_mm3","Female_endocranial_volume_mm3","Male_body_mass_g","Female_body_mass_g","Body_mass_dimorphism","Social_group_size","Adult_males","Adult_females","Adult_sex_ratio","Interbirth_interval_days","Gestation_days","Weaning_age_days","Maximum_longevity_months","Litter_size","Midrange_latitude_deg","Mean_precipitation_mm","Mean_temperature_C","AET_mm","PET_mm","Home_range_km2","Day_range_km","Territoriality_index","Diet_fruit_pct","Diet_leaves_pct","Diet_fauna_pct","Canine_dimorphism","Time_feeding_pct","Time_moving_pct","Time_resting_pct","Time_social_pct")
for (nm in numeric_columns) final.dataframe[[nm]] <- num(final.dataframe[[nm]])
# Isler endocranial volumes are in cm3; convert to mm3.
final.dataframe$Endocranial_volume_mm3 <- final.dataframe$Endocranial_volume_mm3 * 1000
final.dataframe$Female_endocranial_volume_mm3 <- final.dataframe$Female_endocranial_volume_mm3 * 1000
# Preserve exact printed citation cells; normalized individual keys are reviewable in a sidecar.
keys <- read_csv(file.path(folder,"reference_tables",paste0(item_name,"_reference_keys.csv")),show_col_types=FALSE,col_types=cols(.default=col_character()))
for (nm in unique(keys$cited_in_column)) {
 final.dataframe[[paste0(nm,"_printed")]] <- final.dataframe[[nm]]
 k <- keys[keys$cited_in_column==nm,]
 final.dataframe[[nm]] <- k$ref_keys[match(final.dataframe[[nm]],k$printed_cell)]
}
table_checks <- data.frame()
for (pair in list(c("Body_mass_dimorphism","Male_body_mass_g","Female_body_mass_g"),c("Adult_sex_ratio","Adult_females","Adult_males"))) {
 observed <- final.dataframe[[pair[2]]]/final.dataframe[[pair[3]]]; printed <- final.dataframe[[pair[1]]]
 tolerance <- 0.005
 ok <- is.finite(observed) & is.finite(printed)
 table_checks <- rbind(table_checks,data.frame(check_id=paste0(pair[1],"_",seq_along(printed)),basis=final.dataframe$Species,observed,printed,difference=observed-printed,tolerance,status=ifelse(!ok,"not_evaluable",ifelse(abs(observed-printed)<=tolerance,"pass","mismatch")),note="Compare source ratio to its components; absolute tolerance 0.005; retain cached source value."))
}

write_csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), na="")
registry <- read_excel(Sys.getenv("DATASET_REGISTRY", file.path(repo,"__ReadMe.xlsx")), sheet="Sheet1")
hit <- which(!is.na(registry[["Item name"]]) & registry[["Item name"]] == item_name)
if (length(hit)!=1L) stop("Register this item in __ReadMe.xlsx, or set DATASET_REGISTRY to the supplied staging workbook")
item_encoded <- registry[["Item encoded"]][hit]
stopifnot(!is.na(item_encoded), nzchar(item_encoded), !grepl("_$", item_encoded))
dir.create(file.path(repo,"__Public","comparative-data"),recursive=TRUE,showWarnings=FALSE)
write_tsv(final.dataframe, file.path(repo,"__Public","comparative-data",paste0(item_encoded,".tsv")),na="",quote="needed")
message(item_name, ": ",nrow(final.dataframe)," rows; ",ncol(final.dataframe)," columns")
