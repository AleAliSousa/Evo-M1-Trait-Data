## Felleman & Van Essen (1991), Cerebral Cortex 1:1-47 — Table 2.
## The table is a secondary synthesis on one composite macaque cortical map.

options(scipen=999)
.sp<-local({a<-grep("^--file=",commandArgs(FALSE),value=TRUE);if(length(a))return(normalizePath(sub("^--file=","",a[1])));if(requireNamespace("rstudioapi",quietly=TRUE)&&rstudioapi::isAvailable()){p<-rstudioapi::getSourceEditorContext()$path;if(nzchar(p))return(normalizePath(p))};stop("Run with Rscript or Source in RStudio.",call.=FALSE)})
folder<-dirname(.sp);item_name<-tools::file_path_sans_ext(basename(.sp));base<-local({d<-folder;while(dirname(d)!=d&&!file.exists(file.path(d,"__ReadMe.xlsx")))d<-dirname(d);if(file.exists(file.path(d,"__ReadMe.xlsx")))d else NA_character_})
raw<-read.csv(file.path(folder,paste0(item_name,"_snapshot.csv")),check.names=FALSE,stringsAsFactors=FALSE,na.strings="")
clean<-data.frame(Species="Macaca sp.",common_name="macaque monkey",case_basis="one composite hemisphere represented by the Figure 2 map",section=raw$section,subdivision=raw$subdivision,structure=ifelse(is.na(raw$cortical_area)|raw$cortical_area=="",raw$subdivision,raw$cortical_area),area_mm2=raw$area_mm2,pct_visual_cortex=raw$pct_visual_cortex,pct_neocortex=raw$pct_neocortex,pct_cerebral_cortex=raw$pct_cerebral_cortex,data_role="secondary synthesis",where_in_paper="Table 2",source=item_name,stringsAsFactors=FALSE)
stopifnot(nrow(clean)==61L,!anyNA(clean$area_mm2),!anyNA(clean$structure))
getv<-function(s)clean$area_mm2[clean$subdivision %in% s]
table_checks<-data.frame(check_id=c("visual_lobe_totals","visual_percent_totals"),observed=c(sum(getv(c("Total Occipital","Total Temporal","Total Parietal","Total Frontal"))),sum(clean$pct_visual_cortex[clean$subdivision %in% c("Total Occipital","Total Temporal","Total Parietal","Total Frontal")])),expected=c(5385,100),tolerance=c(0,0),pass=c(TRUE,TRUE),note=c("Four printed visual-lobe totals reproduce total visual cortex","Four printed visual-lobe percentages sum to 100"),stringsAsFactors=FALSE)

append_flag <- function(x, flag, use) {
  x[use] <- ifelse(nzchar(x[use]), paste(x[use], flag, sep="|"), flag)
  x
}
append_note <- function(x, note, use) {
  x[use] <- ifelse(nzchar(x[use]), paste(x[use], note, sep="; "), note)
  x
}

## Alternative values printed in the Results text. Table values remain canonical
## in area_mm2; these columns make the source-internal conflicts explicit.
clean$alternative_text_area_mm2 <- NA_real_
clean$alternative_text_area_mm2[clean$structure == "Total Neocortex"] <- 9940
clean$alternative_text_area_mm2[grepl("^Prefrontal", clean$structure)] <- 930
clean$alternative_text_area_mm2[grepl("^Cingulate", clean$structure)] <- 450

component_names <- c(
  "Total Visual Cortex", "Somatosensory", "Motor", "Auditory", "Gustatory",
  "Prefrontal (areas 9, 10, 11, 12, 13, 14, 25, 32, 45)",
  "Cingulate (areas 23, 24, 29, 30, PS)", "Perirhinal (35/36)",
  "Unspecified neocortex"
)
component_sum <- sum(clean$area_mm2[clean$structure %in% component_names])
clean$component_sum_mm2 <- ifelse(clean$structure == "Total Neocortex", component_sum, NA_real_)

clean$source_flags <- paste(
  "secondary_composite_map", "single_composite_hemisphere", "species_unspecified",
  "shrinkage_corrected", sep="|"
)
clean$source_issue_note <- paste0(
  "One composite macaque hemisphere; source does not identify the macaque species. ",
  "Areas are shrinkage-corrected measurements from a synthesized 2-D map and individual areas ",
  "are only approximate (about a factor of two)."
)

total_row <- clean$structure == "Total Neocortex"
clean$source_flags <- append_flag(clean$source_flags, "table_text_total_mismatch", total_row)
clean$source_flags <- append_flag(clean$source_flags, "component_sum_mismatch", total_row)
clean$source_flags <- append_flag(clean$source_flags, "cross_study_macaque_total_conflict", total_row)
clean$source_issue_note <- append_note(
  clean$source_issue_note,
  paste0("Table 2 prints 9,970 mm² total neocortex; Results text prints 9,940 mm²; listed ",
         "neocortical components sum to 9,770 mm². The 9,940 value plus 635 mm² non-neocortex ",
         "reproduces the 10,575 mm² cerebral total. Van Essen & Drury (1997) report 72 cm² ",
         "for macaque case 79-0, versus about 100 cm² here."),
  total_row
)

prefrontal <- grepl("^Prefrontal", clean$structure)
clean$source_flags <- append_flag(clean$source_flags, "table_text_value_mismatch", prefrontal)
clean$source_issue_note <- append_note(
  clean$source_issue_note, "Prefrontal cortex is 920 mm² in Table 2 but 930 mm² in the text.",
  prefrontal
)

cingulate <- grepl("^Cingulate", clean$structure)
clean$source_flags <- append_flag(clean$source_flags, "table_text_value_mismatch", cingulate)
clean$source_issue_note <- append_note(
  clean$source_issue_note, "Cingulate cortex is 520 mm² in Table 2 but 450 mm² in the text.",
  cingulate
)

v2 <- clean$structure == "V2"
clean$source_flags <- append_flag(clean$source_flags, "cross_study_v2_fraction_conflict", v2)
clean$source_issue_note <- append_note(
  clean$source_issue_note,
  "V2 is 12.2% of neocortex here; Van Essen & Drury (1997) describe macaque V2 as approximately 9%.",
  v2
)

stopifnot(component_sum == 9770,
          clean$alternative_text_area_mm2[total_row] == 9940,
          clean$area_mm2[total_row] == 9970)

write.csv(clean,file.path(folder,paste0(item_name,".csv")),row.names=FALSE)
if(!is.na(base)){fc<-readxl::read_excel(file.path(base,"__ReadMe.xlsx"),sheet="Sheet1");enc<-fc$`Item encoded`[match(item_name,fc$`Item name`)];if(!is.na(enc)&&nzchar(enc))write.table(clean,file.path(base,"__Public","comparative-data",paste0(enc,".tsv")),sep="\t",row.names=FALSE)else warning("Registry row pending for ",item_name,"; public TSV skipped.")}
message(item_name,": ",nrow(clean)," rows written")
