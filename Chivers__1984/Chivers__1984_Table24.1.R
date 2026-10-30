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
scalar <- function(x) {x <- gsub(" ","",x,fixed=TRUE); ifelse(grepl("^[0-9]+([.][0-9]+)?$",x),num(x),NA_real_)}
fill <- function(x) {for(i in seq_along(x)) if(i>1 && !nzchar(x[i])) x[i]<-x[i-1];x}
raw <- read_csv(file.path(folder,paste0(item_name,"_snapshot.csv")),skip=1,n_max=24,col_types=cols(.default=col_character()),na=character(),trim_ws=FALSE,name_repair="minimal",show_col_types=FALSE)

raw$Species <- fill(raw$Species)
is_group <- apply(raw[,3:ncol(raw)],1,function(z)all(z==""))
location <- ifelse(is_group,raw[[2]],"")
raw$Location <- fill(location)
final.dataframe <- raw[!is_group,,drop=FALSE]
names(final.dataframe)[1:2]<-c("species_as_published","Observer")
final.dataframe$Source_row <- which(!is_group)+2L
cols <- c("Density_gp_km2","Home_range_ha","Territory_ha","Day_range_m","Night_trees","Feeding_min_day","Fruit_flowers_pct","Leaves_pct","Animal_matter_pct","Travel_min_day","Active_period_min","Feeding_pct_active","Feed_travel_ratio","Travel_pct_active","Biomass_kg_km2","Fruit_leaves_ratio","Dayrange_biomass_ratio","Dayrange_homerange_ratio","Dayrange_fruit_ratio")
for(j in seq_along(cols)) {
 v <- final.dataframe[[j+2]]
 # Exact headline values only. Ranges, bounds, and parenthetic alternatives remain raw.
 first <- sub("\n.*$","",v)
 if(j==2) first <- trimws(sub(" [(].*$","",first))
 final.dataframe[[cols[j]]] <- scalar(first)
}
# Keep uncertainty separately. No midpoint is manufactured for a range.
for(j in c(1,2,3,5)) {
 v<-gsub("[¹²]","",final.dataframe[[j+2]])
 range<-grepl("^[0-9]+-[0-9]+$",v)
 final.dataframe[[paste0(cols[j],"_lower")]]<-ifelse(range,num(sub("-.*","",v)),NA_real_)
 final.dataframe[[paste0(cols[j],"_upper")]]<-ifelse(range,num(sub(".*-","",v)),NA_real_)
}
table_checks <- data.frame(check_id=paste0("diet_",seq_len(nrow(final.dataframe))),basis="F+FL + L + A",observed=rowSums(final.dataframe[,c("Fruit_flowers_pct","Leaves_pct","Animal_matter_pct")]),printed=100,tolerance=1.5)
table_checks$difference<-table_checks$observed-100
table_checks$status<-ifelse(is.na(table_checks$observed),"not_evaluable",ifelse(abs(table_checks$difference)<=1.5,"pass","mismatch"))
table_checks$note<-"Three rounded diet percentages; allow 0.5 percentage point per component."
if(any(table_checks$status=="mismatch"))warning("Printed diet percentages do not sum within rounding tolerance; retained unchanged")
# Check printed time-derived relationships without replacing any published value.
for (spec in list(c("Feeding_min_day","Active_period_min","Feeding_pct_active",100,1),c("Travel_min_day","Active_period_min","Travel_pct_active",100,1),c("Feeding_min_day","Travel_min_day","Feed_travel_ratio",1,0.1))) {
 observed<-final.dataframe[[spec[1]]]/final.dataframe[[spec[2]]]*as.numeric(spec[4]);printed<-final.dataframe[[spec[3]]];delta<-observed-printed;tol<-as.numeric(spec[5])
 ck<-data.frame(check_id=paste0(spec[3],"_",seq_along(observed)),basis=paste(spec[1],"/",spec[2],"×",spec[4]),observed=observed,printed=printed,tolerance=tol,difference=delta,status=ifelse(is.na(delta),"not_evaluable",ifelse(abs(delta)<=tol,"pass","mismatch")),note="Diagnostic ratio of printed means; underlying averaging may differ. Values retained unchanged.")
 table_checks<-rbind(table_checks,ck)
}
if(any(table_checks$status=="mismatch"))warning("Printed time ratios contain discrepancies; see table_checks; retained unchanged")
write_csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), na="")
registry <- read_excel(Sys.getenv("DATASET_REGISTRY", file.path(repo,"__ReadMe.xlsx")), sheet="Sheet1")
hit <- which(!is.na(registry[["Item name"]]) & registry[["Item name"]] == item_name)
if (length(hit)!=1L) stop("Register this item in __ReadMe.xlsx, or set DATASET_REGISTRY to the supplied staging workbook")
item_encoded <- registry[["Item encoded"]][hit]
stopifnot(!is.na(item_encoded), nzchar(item_encoded), !grepl("_$", item_encoded))
dir.create(file.path(repo,"__Public","comparative-data"),recursive=TRUE,showWarnings=FALSE)
write_tsv(final.dataframe, file.path(repo,"__Public","comparative-data",paste0(item_encoded,".tsv")),na="",quote="needed")
message(item_name, ": ",nrow(final.dataframe)," rows; ",ncol(final.dataframe)," columns")
