## Seelke et al. (2016), Environmental Epigenetics 2:dvw019 — Table 2.

options(scipen=999)
.sp<-local({a<-grep("^--file=",commandArgs(FALSE),value=TRUE);if(length(a))return(normalizePath(sub("^--file=","",a[1])));if(requireNamespace("rstudioapi",quietly=TRUE)&&rstudioapi::isAvailable()){p<-rstudioapi::getSourceEditorContext()$path;if(nzchar(p))return(normalizePath(p))};stop("Run with Rscript or Source in RStudio.",call.=FALSE)})
folder<-dirname(.sp);item_name<-tools::file_path_sans_ext(basename(.sp));base<-local({d<-folder;while(dirname(d)!=d&&!file.exists(file.path(d,"__ReadMe.xlsx")))d<-dirname(d);if(file.exists(file.path(d,"__ReadMe.xlsx")))d else NA_character_})
raw<-read.csv(file.path(folder,paste0(item_name,"_snapshot.csv")),check.names=FALSE,stringsAsFactors=FALSE)
ns<-read.csv(file.path(folder,paste0(item_name,"_sample_sizes_snapshot.csv")),stringsAsFactors=FALSE)
cols<-names(raw)[-1];rows<-list();k<-0L
for(j in seq_along(cols))for(i in seq_len(nrow(raw))){parts<-strsplit(cols[j]," ")[[1]];x<-strsplit(raw[[cols[j]]][i]," ± ",fixed=TRUE)[[1]];k<-k+1L;rows[[k]]<-data.frame(Species="Microtus ochrogaster",common_name="prairie vole",group=parts[1],sex=parts[2],n=ns$n[match(cols[j],paste(ns$group,ns$sex))],structure=sub("^%","",raw$Area[i]),mean_pct_cortical_sheet=as.numeric(x[1]),se_pct_cortical_sheet=as.numeric(x[2]),statistic="mean ± SE",where_in_paper="Table 2",source=item_name,stringsAsFactors=FALSE)}
clean<-do.call(rbind,rows)
stopifnot(nrow(clean)==70L,sum(unique(clean[c("group","sex","n")])$n)==64L,!anyNA(clean[c("n","mean_pct_cortical_sheet","se_pct_cortical_sheet")]))

append_flag <- function(x, flag, use) {
  x[use] <- ifelse(nzchar(x[use]), paste(x[use], flag, sep="|"), flag)
  x
}
append_note <- function(x, note, use) {
  x[use] <- ifelse(nzchar(x[use]), paste(x[use], note, sep="; "), note)
  x
}

## Source-QC annotations. Printed values remain untouched.
clean$derived_unlisted_myelin_pct <- NA_real_
for (g in unique(paste(clean$group, clean$sex))) {
  use <- paste(clean$group, clean$sex) == g
  myelin <- use & clean$structure == "Myelin"
  listed <- use & clean$structure %in% c("S1", "S2/PV", "M1", "V1", "V2", "AC")
  clean$derived_unlisted_myelin_pct[myelin] <-
    clean$mean_pct_cortical_sheet[myelin] - sum(clean$mean_pct_cortical_sheet[listed])
}

clean$source_flags <- "adjusted_cortical_sheet_denominator"
clean$source_issue_note <- paste0(
  "Percent denominator is the adjusted cortical sheet; the Methods say cingulate cortex was ",
  "subtracted when visible."
)

ota_copy <- clean$group == "OTA" & clean$structure != "Myelin"
clean$source_flags <- append_flag(clean$source_flags, "possible_ota_sex_copy_error", ota_copy)
clean$source_issue_note <- append_note(
  clean$source_issue_note,
  paste0("OTA male and female means are identical for S1, S2/PV, M1, V1, V2 and AC despite ",
         "different n and uncertainty values; possible printed copy error."),
  ota_copy
)

lc_female <- clean$group == "LC" & clean$sex == "Female"
clean$source_flags <- append_flag(
  clean$source_flags, "negative_derived_unlisted_myelin_share", lc_female
)
clean$source_issue_note <- append_note(
  clean$source_issue_note,
  paste0("LC-female listed fields sum to 56.09% while %Myelin is 53.56%, leaving -2.53 ",
         "percentage points for the unlisted myelinated share; this is impossible under the ",
         "paper's stated %Myelin definition."),
  lc_female
)

ot_group <- clean$group == "OT"
clean$source_flags <- append_flag(clean$source_flags, "sex_specific_ot_dose", ot_group)
clean$source_issue_note <- append_note(
  clean$source_issue_note,
  "OT males received 3 µg and OT females received 6 µg, so OT sex contrasts also differ in dose.",
  ot_group
)

small_group <- clean$n <= 3L
clean$source_flags <- append_flag(clean$source_flags, "small_group_n", small_group)
clean$source_issue_note <- append_note(
  clean$source_issue_note, "Group mean is based on three animals.", small_group
)

ota_m <- clean[clean$group == "OTA" & clean$sex == "Male" & clean$structure != "Myelin", ]
ota_f <- clean[clean$group == "OTA" & clean$sex == "Female" & clean$structure != "Myelin", ]
ota_f <- ota_f[match(ota_m$structure, ota_f$structure), ]
stopifnot(nrow(ota_m) == 6L,
          all(ota_m$mean_pct_cortical_sheet == ota_f$mean_pct_cortical_sheet),
          abs(clean$derived_unlisted_myelin_pct[clean$group == "LC" & clean$sex == "Female" &
                                                clean$structure == "Myelin"] + 2.53) < 1e-10)

write.csv(clean,file.path(folder,paste0(item_name,".csv")),row.names=FALSE)
if(!is.na(base)){fc<-readxl::read_excel(file.path(base,"__ReadMe.xlsx"),sheet="Sheet1");enc<-fc$`Item encoded`[match(item_name,fc$`Item name`)];if(!is.na(enc)&&nzchar(enc))write.table(clean,file.path(base,"__Public","comparative-data",paste0(enc,".tsv")),sep="\t",row.names=FALSE)else warning("Registry row pending for ",item_name,"; public TSV skipped.")}
message(item_name,": ",nrow(clean)," rows written")
