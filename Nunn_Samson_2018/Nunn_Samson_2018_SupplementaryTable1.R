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
raw <- read_excel(file.path(folder,paste0(item_name,"_snapshot.xlsx")),sheet=1,range="A3:P33",col_types="text",na=c("","NA"))
names(raw) <- c("Species","Sleep_h_day","REM_h_day","NREM_h_day","Endocranial_volume_mm3","Male_body_mass_g","Female_body_mass_g","Folivory","Diet_category_count","Open_habitat","Terrestrial","Day_range_km","Social_group_size","Activity_period","Nocturnal","Cathemeral")
final.dataframe <- as.data.frame(raw,stringsAsFactors=FALSE)
numeric_columns <- c("Sleep_h_day","REM_h_day","NREM_h_day","Endocranial_volume_mm3","Male_body_mass_g","Female_body_mass_g","Folivory","Diet_category_count","Open_habitat","Terrestrial","Day_range_km","Social_group_size","Nocturnal","Cathemeral")
for (nm in numeric_columns) final.dataframe[[nm]] <- num(final.dataframe[[nm]])
# Source ECV in cm3 -> mm3 and both sex-specific body masses in kg -> g.
for (nm in c("Endocranial_volume_mm3","Male_body_mass_g","Female_body_mass_g")) final.dataframe[[nm]] <- final.dataframe[[nm]] * 1000
final.dataframe$Brain_value_basis <- ifelse(grepl("^Varecia_|^Eulemur_(macaco|flavifrons)$",final.dataframe$Species),"sister-species value reused",ifelse(final.dataframe$Species=="Propithecus_coquereli","genus average","species value compiled"))
final.dataframe$Day_range_basis <- ifelse(final.dataframe$Species %in% c("Microcebus_murinus","Phaner_furcifer"),"congeneric proxy","compiled; see Methods")
final.dataframe$Sleep_method <- ifelse(final.dataframe$Species=="Pongo_pygmaeus","videography",ifelse(final.dataframe$Species %in% c("Eulemur_coronatus","Eulemur_flavifrons","Lemur_catta","Propithecus_coquereli","Varecia_rubra","Varecia_variegata"),"actigraphy",ifelse(final.dataframe$Species=="Homo_sapiens","human synthesis","Phylogeny of Sleep high-quality compilation")))
observed <- final.dataframe$REM_h_day + final.dataframe$NREM_h_day
printed <- final.dataframe$Sleep_h_day
table_checks <- data.frame(check_id=paste0("sleep_sum_",seq_along(printed)),basis=final.dataframe$Species,observed,printed,difference=observed-printed,tolerance=0.015,status=ifelse(is.na(observed),"not_evaluable",ifelse(abs(observed-printed)<=0.015,"pass","mismatch")),note="REM + NREM vs TST. 0.015 h accounts for rounding three two-decimal values; independent study means may differ. Values retained.")

write_csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), na="")
registry <- read_excel(Sys.getenv("DATASET_REGISTRY", file.path(repo,"__ReadMe.xlsx")), sheet="Sheet1")
hit <- which(!is.na(registry[["Item name"]]) & registry[["Item name"]] == item_name)
if (length(hit)!=1L) stop("Register this item in __ReadMe.xlsx, or set DATASET_REGISTRY to the supplied staging workbook")
item_encoded <- registry[["Item encoded"]][hit]
stopifnot(!is.na(item_encoded), nzchar(item_encoded), !grepl("_$", item_encoded))
dir.create(file.path(repo,"__Public","comparative-data"),recursive=TRUE,showWarnings=FALSE)
write_tsv(final.dataframe, file.path(repo,"__Public","comparative-data",paste0(item_encoded,".tsv")),na="",quote="needed")
message(item_name, ": ",nrow(final.dataframe)," rows; ",ncol(final.dataframe)," columns")
