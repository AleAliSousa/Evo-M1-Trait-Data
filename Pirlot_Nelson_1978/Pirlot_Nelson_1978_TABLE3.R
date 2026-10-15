## Pirlot_Nelson_1978_TABLE3
## Input : one snapshot.csv; source-layout capture is authoritative, known old layout is transition-only
## Output: existing long CSV/registry-coded TSV; separate table_checks audit object
options(scipen=999)
.sp <- local({
 for(fr in rev(sys.frames())) for(nm in c("ofile", "file")) {
  p <- fr[[nm]]
  if(is.character(p) && length(p)==1L && !is.na(p) && nzchar(p) &&
     grepl("\\.[Rr]$", p) && file.exists(p)) return(normalizePath(p))
 }
 a <- grep("^--file=", commandArgs(FALSE), value=TRUE)
 if(length(a)) return(normalizePath(sub("^--file=", "", a[1])))
 if(requireNamespace("rstudioapi", quietly=TRUE) && rstudioapi::isAvailable()) {
  p <- rstudioapi::getSourceEditorContext()$path
  if(!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
  if(nzchar(p)) return(normalizePath(p))
 }
 stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call.=FALSE)
})
folder <- dirname(.sp); item_name <- tools::file_path_sans_ext(basename(.sp)); setwd(folder)
base <- local({ d <- folder; while(dirname(d)!=d && !file.exists(file.path(d,"__ReadMe.xlsx"))) d <- dirname(d); if(file.exists(file.path(d,"__ReadMe.xlsx"))) d else NA_character_ })
snap <- utils::read.csv(paste0(item_name,"_snapshot.csv"), header=FALSE,
 colClasses="character", check.names=FALSE, stringsAsFactors=FALSE,
 na.strings=character(), blank.lines.skip=FALSE, comment.char="", fill=FALSE,
 fileEncoding="UTF-8")
legacy_capture <- identical(dim(snap),c(37L,4L)) &&
 identical(unlist(snap[1,],use.names=FALSE),c("species","component","absolute_volume_mm3","percent_total_brain"))
if(!legacy_capture && !identical(dim(snap),c(24L,7L)))
 stop("Table 3: unsupported snapshot layout; expected the source grid or the exact known legacy schema.",call.=FALSE)
if(legacy_capture) {
 ## Exact legacy label/order validation only, not a common-name or taxonomy map.
 legacy_species <- c("Ornithorhynchus anatinus","Tachyglossus aculeatus","Didelphis marsupialis")
 legacy_components <- c("Neo","Scz","Hip","Sep","Pal","Bul","Str","Di","Mes","CbI","Med","Mesocortex")
 species_position <- rep(seq_len(3L),times=12L)
 component_position <- rep(seq_len(12L),each=3L)
 expected_missing <- (component_position==2L & species_position==3L) |
  (component_position==12L & species_position<=2L)
 stopifnot(identical(snap[[1]][2:37],rep(legacy_species,times=12L)),
  identical(snap[[2]][2:37],rep(legacy_components,each=3L)),
  identical(snap[[3]][2:37]=="",expected_missing),
  identical(snap[[4]][2:37]=="",expected_missing))
 legacy_number <- function(x,precision_limit) {
  present <- nzchar(x)
  places <- ifelse(grepl(".",x,fixed=TRUE),nchar(sub("^.*\\.","",x)),0L)
  valid <- grepl("^[0-9]+(\\.[0-9]+)?$",x) & places<=precision_limit
  if(anyNA(x) || any(present & !valid))
   stop("Table 3: invalid number in the known legacy capture.",call.=FALSE)
  out <- rep(NA_real_,length(x)); out[present] <- as.numeric(x[present])
  stopifnot(all(is.finite(out[present])),all(out[present]>0))
  out
 }
 clean <- data.frame(species=snap[[1]][2:37],component=snap[[2]][2:37],
  absolute_volume_mm3=legacy_number(snap[[3]][2:37],rep(c(2L,1L,2L),times=12L)),
  percent_total_brain=legacy_number(snap[[4]][2:37],2L),source=item_name,stringsAsFactors=FALSE)
 stopifnot(nrow(clean)==36L,sum(!is.na(as.matrix(clean[c("absolute_volume_mm3","percent_total_brain")])))==66L)
 table_checks <- data.frame(check_id="legacy_capture_printed_totals_unavailable",
  basis="Table 3 p.175/PDF 6 has printed totals, but the known legacy snapshot omits that row.",
  observed=NA_real_,printed=NA_real_,difference=NA_real_,status="not_evaluable",
  note="Transition-only legacy layout: validated exact schema, row labels/order, cardinality and missing pattern; numeric literals retained. Printed totals are not available in this capture, so neither subtotal nor percentage/volume checks are evaluated. No assumed pass or correction; source-layout snapshot remains authoritative and existing holds remain.",
  precision="Legacy capture precision retained; no rounding or numerical comparison.",
  unit="Legacy absolute_volume_mm3 and percent_total_brain columns; no conversion.",
  coverage=paste0("36 rows; 33 reported pairs and three unreported pairs: ",
   paste0(clean$species[expected_missing]," / ",clean$component[expected_missing],collapse="; "),
   ". No printed total row; not a complete-partition validation."),stringsAsFactors=FALSE)
} else {
label_map <- utils::read.csv(file.path("reference_tables",paste0(item_name,"_source_labels.csv")),
 colClasses="character", check.names=FALSE, stringsAsFactors=FALSE,
 na.strings=character(), fileEncoding="UTF-8")
stopifnot(identical(dim(snap),c(24L,7L)), snap[[1]][1]=="TABLE 3",
 snap[[1]][2]=="ABSOLUTE VOLUMES OF VARIOUS BRAIN STRUCTURES AND THEIR",
 snap[[1]][3]=="PERCENTAGE OF TOTAL BRAIN VOLUME",
 identical(names(label_map),c("label_type","source_position","source_label","analysis_label","source_locus","note")),
 nrow(label_map)==15L, all(label_map$label_type %in% c("species","component")),
 !anyNA(label_map), all(nzchar(label_map$source_locus)))
species_map <- label_map[label_map$label_type=="species",,drop=FALSE]
component_map <- label_map[label_map$label_type=="component",,drop=FALSE]
abs_cols <- c(2L,4L,6L); pct_cols <- abs_cols+1L
stopifnot(identical(species_map$source_position,as.character(seq_len(3L))),
 identical(component_map$source_position,as.character(seq_len(12L))),
 !anyDuplicated(species_map$analysis_label), !anyDuplicated(component_map$analysis_label),
 all(nzchar(label_map$analysis_label)),
 identical(unlist(snap[5,abs_cols],use.names=FALSE),species_map$source_label),
 identical(snap[[1]][8:19],component_map$source_label),
 all(snap[6,abs_cols]=="Abs. vol."), all(snap[6,pct_cols]=="% of"),
 all(snap[7,abs_cols]=="mm²"), all(snap[7,pct_cols]=="total brain"),
 snap[[1]][20]=="", all(snap[4,]==""), all(snap[21,]==""),
 grepl("medulla oblongata and mesocortex.",snap[[1]][24],fixed=TRUE))

decimal_places <- function(x) {
 ifelse(grepl(".",x,fixed=TRUE),nchar(sub("^.*\\.","",x)),0L)
}
source_units <- function(x,precision,allow_dash=TRUE) {
 present <- x!="—"
 valid <- grepl("^([0-9]+|[0-9]{1,3}(,[0-9]{3})+)(\\.[0-9]+)?$",x) & decimal_places(x)==precision
 if(anyNA(x) || any(present & !valid) || (!allow_dash && any(!present)))
  stop("Table 3: unexpected number, blank or precision; inspect the frozen source.",call.=FALSE)
 out <- rep(NA_real_,length(x))
 ## Remove punctuation from source strings: integer comparisons have no rounding tolerance.
 out[present] <- as.numeric(gsub("[,.]","",x[present]))
 stopifnot(all(is.finite(out[present])))
 out
}
volume_precision <- vapply(abs_cols,function(j) decimal_places(snap[[j]][20]),integer(1))
percent_precision <- vapply(pct_cols,function(j) decimal_places(snap[[j]][20]),integer(1))
printed_volume_units <- vapply(seq_along(abs_cols),function(s)
 source_units(snap[[abs_cols[s]]][20],volume_precision[s],FALSE),numeric(1))
printed_percent_units <- vapply(seq_along(pct_cols),function(s)
 source_units(snap[[pct_cols[s]]][20],percent_precision[s],FALSE),numeric(1))
volume_units <- vapply(seq_along(abs_cols),function(s)
 source_units(snap[[abs_cols[s]]][8:19],volume_precision[s]),numeric(12))
percent_units <- vapply(seq_along(pct_cols),function(s)
 source_units(snap[[pct_cols[s]]][8:19],percent_precision[s]),numeric(12))
stopifnot(all(printed_volume_units>0),identical(is.na(volume_units),is.na(percent_units)))
volumes <- sweep(volume_units,2,10^volume_precision,"/")
percentages <- sweep(percent_units,2,10^percent_precision,"/")
## The printed header reads mm²; caption/Methods describe volumes. Retain legacy mm³ interpretation,
## without converting or correcting numbers; source-label metadata preserves the printed terms.
clean <- do.call(rbind,lapply(seq_len(12L),function(i) data.frame(
 species=species_map$analysis_label, component=component_map$analysis_label[i],
 absolute_volume_mm3=as.vector(volumes[i,]),percent_total_brain=as.vector(percentages[i,]),
 source=item_name,stringsAsFactors=FALSE)))
stopifnot(nrow(clean)==36L,sum(!is.na(as.matrix(clean[c("absolute_volume_mm3","percent_total_brain")])))==66L)

check_row <- function(check_id,basis,observed,printed,status,note,s,unit,precision,
                      position=NA_integer_,unrounded_observed=NA_real_) {
 present <- !is.na(volume_units[,s])
 missing <- if(any(!present)) paste0(component_map$source_label[!present]," (row ",
  which(!present),")",collapse="; ") else "none"
 included <- if(any(present)) paste0(component_map$source_label[present]," (row ",
  which(present),")",collapse="; ") else "none"
 context <- paste0("Table 3 p.175/PDF 6; ",species_map$source_label[s]," [",species_map$analysis_label[s],"]")
 if(!is.na(position)) context <- paste0(context,"; source component ",
  component_map$source_label[position]," (position ",position,"; analysis ",component_map$analysis_label[position],")")
 note <- paste0(context,". ",note)
 if(is.finite(unrounded_observed)) note <- paste0(note,
  " Unrounded calculated percent (binary double, before source-precision rounding): ",
  format(unrounded_observed,digits=17L,scientific=FALSE,trim=TRUE),".")
 data.frame(check_id=check_id,basis=basis,observed=observed,printed=printed,
  difference=round(observed-printed,precision),status=status,note=note,
  precision=paste0(precision," decimal places as printed; ",
   if(grepl("^cell_",basis)) "half-up ratio rounding; no mismatch tolerance"
   else "source-scaled integer arithmetic; no total tolerance"),
  unit=unit,coverage=paste0(sum(present),"/",nrow(volume_units),
   " listed component rows reported; unreported: ",missing,"; included: ",included,
   ". Reported cells only; no full-partition or all-cell-accuracy certification; dashes are not zero."),
  stringsAsFactors=FALSE)
}
checks <- list()
for(s in seq_len(3L)) {
 present <- !is.na(volume_units[,s])
 coverage_note <- paste0("Sum of ",sum(present),"/",length(present),
  " reported component cells only; dashes are unreported, not zero or assumed inapplicable. ",
  "Whole-total evaluation is not_evaluable with incomplete coverage; residuals are diagnostic only. ",
  "No complete-partition or individual-cell accuracy certification. Values retained.")
 v_sum <- if(any(present)) sum(volume_units[present,s]) else NA_real_
 p_sum <- if(any(present)) sum(percent_units[present,s]) else NA_real_
 checks[[length(checks)+1L]] <- check_row(
  paste0("reported_volume_sum_",species_map$source_label[s]),"reported_component_subtotal_diagnostic_vs_printed_whole_total",
  v_sum/10^volume_precision[s],printed_volume_units[s]/10^volume_precision[s],
  if(!all(present) || is.na(v_sum)) "not_evaluable" else if(v_sum==printed_volume_units[s]) "pass" else "mismatch",
  coverage_note,s,"source absolute volume (printed mm²; interpreted mm³)",volume_precision[s])
 checks[[length(checks)+1L]] <- check_row(
  paste0("reported_percent_sum_",species_map$source_label[s]),"reported_percentage_subtotal_diagnostic_vs_printed_whole_total",
  p_sum/10^percent_precision[s],printed_percent_units[s]/10^percent_precision[s],
  if(!all(present) || is.na(p_sum)) "not_evaluable" else if(p_sum==printed_percent_units[s]) "pass" else "mismatch",
  coverage_note,s,"percent",percent_precision[s])
 for(i in seq_len(12L)) {
  observed <- raw_percent <- NA_real_
  if(is.na(volume_units[i,s]) || is.na(percent_units[i,s])) {
   status <- "not_evaluable"
   note <- "Printed dash: unreported, not zero. This cell's percentage/volume relation cannot be tested."
  } else {
   raw_percent <- 100*volume_units[i,s]/printed_volume_units[s]
   ## Half-up decimal rounding at the printed percent precision, using source-scaled integers.
   expected_units <- floor((100*volume_units[i,s]*10^percent_precision[s]+
     printed_volume_units[s]/2)/printed_volume_units[s])
   observed <- expected_units/10^percent_precision[s]
   status <- if(expected_units==percent_units[i,s]) "pass" else "mismatch"
   note <- paste0("100 × reported volume / printed absolute total, rounded half-up to ",
    percent_precision[s]," printed decimals; absolute-unit glyph ambiguity cancels in this ratio. ",
    "No correction or rebalancing; column coverage remains incomplete.")
  }
  checks[[length(checks)+1L]] <- check_row(
   paste0("percent_from_volume_",species_map$source_label[s],"_",sprintf("%02d",i)),
   "cell_percentage_vs_volume_over_printed_total",observed,percentages[i,s],status,
   note,s,"percent (difference in percentage points)",percent_precision[s],i,raw_percent)
 }
}
table_checks <- do.call(rbind,checks)
stopifnot(nrow(table_checks)==42L)
}
stopifnot(!anyDuplicated(table_checks$check_id),
 all(table_checks$status %in% c("pass","mismatch","not_evaluable","not_applicable")),
 identical(names(table_checks),c("check_id","basis","observed","printed","difference","status","note","precision","unit","coverage")),
 all(vapply(table_checks[c("precision","unit","coverage")],is.character,logical(1))))
if(legacy_capture) warning(item_name,": transition-only legacy snapshot; printed totals unavailable, numerical checks not_evaluable. No assumed pass. Install source-label metadata before the source-layout snapshot.",call.=FALSE)
bad <- table_checks$status=="mismatch"
if(any(bad)) warning(item_name,": printed-table mismatches (observed minus printed): ",
 paste0(table_checks$check_id[bad],"=",format(table_checks$difference[bad],trim=TRUE),collapse="; "),
 ". Values retained; inspect table_checks for precision, units and incomplete-coverage notes.",call.=FALSE)
message(item_name,": table_checks: ",sum(table_checks$status=="pass")," pass, ",
 sum(bad)," mismatch, ",sum(table_checks$status=="not_evaluable"),
 " not_evaluable. Reported-component sums do not certify complete coverage.")

utils::write.csv(clean,paste0(item_name,".csv"),row.names=FALSE,na="NA")
if(!is.na(base)) {
 fc <- readxl::read_excel(file.path(base,"__ReadMe.xlsx"),sheet="Sheet1")
 item_encoded <- fc$`Item encoded`[match(item_name,fc$`Item name`)]
 out_dir <- file.path(base,"__Public","comparative-data")
 if(!is.na(item_encoded) && nzchar(item_encoded) && dir.exists(out_dir)) utils::write.table(clean,file.path(out_dir,paste0(item_encoded,".tsv")),sep="\t",row.names=FALSE,quote=TRUE,na="NA") else warning("Public TSV skipped: registry entry or output directory unavailable.")
} else warning("Repository root not found; public TSV skipped.")
message(item_name,": ",nrow(clean)," rows written")
