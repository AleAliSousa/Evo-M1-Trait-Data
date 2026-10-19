## Kamiya_Pirlot_1980_TABLE1
## Input : Kamiya_Pirlot_1980_TABLE1_snapshot.csv - Table 1 (p.107, PDF p.4) in its printed layout:
##         caption, original column headings, 9 component rows, the printed (unlabelled) sum row
##         and the "Total brain" line.
## Output: Kamiya_Pirlot_1980_TABLE1.csv (9 components; schema unchanged) and the registry-coded
##         public TSV, plus `table_checks`: the table checked against its own printed sums.
##         Checks are reported only; no value is ever changed by them.
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

## ---- read the frozen printed-layout table as text (nothing is converted on reading) ----
snap <- utils::read.csv(paste0(item_name,"_snapshot.csv"), header=FALSE, colClasses="character",
 na.strings=character(), check.names=FALSE, encoding="UTF-8")
codes <- c("N","Rh","S","D","St","H","M","C","O")    # as printed (Abbreviations, p.106)
stopifnot(identical(dim(snap), c(13L,4L)),
 snap[1,1]=="TABLE 1. VOLUMES AND PROGRESSION IN THE BRAIN OF P. GANGETICA",
 identical(unname(unlist(snap[2,])),
  c("Components","Volumes (mm\u00b3)","Percentages of total brain","Progression indices")),
 identical(snap[3:11,1], codes),
 snap[12,1]=="", snap[12,4]=="\u2014",              # printed sum row: no label; no index sum
 snap[13,1]=="Total brain")

## Printed number -> numeric (thousands commas removed).
num <- function(x) {
 ok <- grepl("^[0-9]+(\\.[0-9]+)?$|^[0-9]{1,3}(,[0-9]{3})+(\\.[0-9]+)?$", x)
 if(!all(ok)) stop("Table 1: unexpected cell(s) ", paste(shQuote(x[!ok]), collapse=", "), call.=FALSE)
 as.numeric(gsub(",", "", x))
}
## Number of printed decimals (the precision used by the checks).
dp <- function(x) ifelse(grepl(".", x, fixed=TRUE), nchar(sub("^[^.]*\\.", "", x)), 0L)

## ---- analysis view: the existing schema, one row per component ---------------------------
clean <- data.frame(component=snap[3:11,1], volume_mm3=num(snap[3:11,2]),
 percent_total_brain=num(snap[3:11,3]), progression_index=num(snap[3:11,4]),
 source=item_name, stringsAsFactors=FALSE)
stopifnot(nrow(clean)==9L)

## ---- table checks: the table against its own printed sum row (row 12) -----------------------
## Compared in whole units of the last printed decimal. Tolerance = what rounding of printed
## cells can explain: half a unit per summed cell; one unit for a recomputed percentage.
## Progression indices are not additive (the printed sum cell is a dash), so they are not
## checked here. A mismatch is reported and warned; no value is changed.
check <- function(id, basis, obs_u, prt_u, d, tol_u, note) data.frame(
 check_id=id, basis=basis, observed=obs_u/10^d, printed=prt_u/10^d,
 difference=(obs_u-prt_u)/10^d, tolerance=tol_u/10^d,
 status=ifelse(is.na(obs_u-prt_u), "not_evaluable", ifelse(abs(obs_u-prt_u)<=tol_u, "pass", "mismatch")),
 note=note, stringsAsFactors=FALSE)
dv <- dp(snap[12,2]); dpc <- dp(snap[12,3])
vu <- round(clean$volume_mm3*10^dv); pu <- round(clean$percent_total_brain*10^dpc)
tvu <- round(num(snap[12,2])*10^dv); tpu <- round(num(snap[12,3])*10^dpc)
table_checks <- rbind(
 check("volume_sum", "Sum of the 9 printed component volumes vs the printed sum (row 12)",
  sum(vu), tvu, dv, length(vu)/2, "All 9 components printed and summed."),
 check("percent_sum", "Sum of the 9 printed percentages vs the printed sum (row 12)",
  sum(pu), tpu, dpc, length(pu)/2, "All 9 components printed and summed."),
 do.call(rbind, lapply(seq_along(codes), function(i) check(sprintf("percent_%02d_%s", i, codes[i]),
  paste0(codes[i]," (row ",i+2L,"): 100 x volume / printed sum vs printed percentage"),
  floor(100*vu[i]*10^dpc/tvu + 0.5), pu[i], dpc, 1,
  "Recomputed to the printed decimals (half-up); 1 unit allowed for the authors' rounding."))))
stopifnot(nrow(table_checks)==11L, !anyDuplicated(table_checks$check_id))
bad <- table_checks$status=="mismatch"
message(item_name,": table_checks ",sum(table_checks$status=="pass")," pass, ",sum(bad)," mismatch, ",
 sum(table_checks$status=="not_evaluable")," not evaluable (see ReadMe).")
if(any(bad)) warning(item_name,": printed-table mismatch(es), values kept as printed: ",
 paste0(table_checks$check_id[bad]," (",table_checks$difference[bad],")", collapse="; "), call.=FALSE)

utils::write.csv(clean, paste0(item_name,".csv"), row.names=FALSE, na="NA")
if(!is.na(base)) {
 fc <- readxl::read_excel(file.path(base,"__ReadMe.xlsx"), sheet="Sheet1")
 item_encoded <- fc$`Item encoded`[match(item_name,fc$`Item name`)]
 out_dir <- file.path(base,"__Public","comparative-data")
 if(!is.na(item_encoded) && nzchar(item_encoded) && dir.exists(out_dir)) utils::write.table(clean,file.path(out_dir,paste0(item_encoded,".tsv")),sep="\t",row.names=FALSE,quote=TRUE,na="NA") else warning("Public TSV skipped: registry entry or output directory unavailable.")
} else warning("Repository root not found; public TSV skipped.")
message(item_name,": ",nrow(clean)," rows written")
