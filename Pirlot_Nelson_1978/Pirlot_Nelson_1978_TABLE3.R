## Pirlot_Nelson_1978_TABLE3
## Input : Pirlot_Nelson_1978_TABLE3_snapshot.csv - Table 3 (p.175, PDF p.6) in its printed layout:
##         caption, PLATYPUS / ECHIDNA / OPOSSUM column pairs, 12 component rows, the printed
##         (unlabelled) total row and the footnote that expands the component codes.
## Output: Pirlot_Nelson_1978_TABLE3.csv (species x component; schema unchanged) and the
##         registry-coded public TSV, plus `table_checks`: the table checked against its own
##         printed totals. Checks are reported only; no value is ever changed by them.
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

## ---- read the frozen printed-layout grid as text (nothing is converted on reading) ----
snap <- utils::read.csv(paste0(item_name,"_snapshot.csv"), header=FALSE, colClasses="character",
 na.strings=character(), check.names=FALSE, encoding="UTF-8")
dash <- "\u2014"                                    # printed em dash = not reported
codes <- c("Neo","Scz","Hip","Sep","Pal","Bul","Str","Di","Mes","Cbl","Med","Mes")  # as printed
vol_col <- c(2L,4L,6L); pct_col <- vol_col+1L       # "Abs. vol." and "% of total brain" columns
stopifnot(identical(dim(snap), c(24L,7L)), snap[1,1]=="TABLE 3",
 snap[2,1]=="ABSOLUTE VOLUMES OF VARIOUS BRAIN STRUCTURES AND THEIR",
 snap[3,1]=="PERCENTAGE OF TOTAL BRAIN VOLUME",
 identical(unname(unlist(snap[5,vol_col])), c("PLATYPUS","ECHIDNA","OPOSSUM")),
 all(unlist(snap[6,vol_col])=="Abs. vol."), all(unlist(snap[6,pct_col])=="% of"),
 all(unlist(snap[7,vol_col]) %in% c("mm\u00b2","mm\u00b3")),   # superscripts as read from the scan
 all(unlist(snap[7,pct_col])=="total brain"),
 identical(snap[8:19,1], codes), snap[20,1]=="",
 endsWith(snap[24,1], "medulla oblongata and mesocortex."))

## Printed number -> numeric (thousands commas removed); printed dash -> NA, never zero.
num <- function(x) {
 ok <- x==dash | grepl("^[0-9]+(\\.[0-9]+)?$|^[0-9]{1,3}(,[0-9]{3})+(\\.[0-9]+)?$", x)
 if(!all(ok)) stop("Table 3: unexpected cell(s) ", paste(shQuote(x[!ok]), collapse=", "), call.=FALSE)
 out <- rep(NA_real_, length(x)); out[x!=dash] <- as.numeric(gsub(",", "", x[x!=dash])); out
}
## Number of printed decimals (the precision used by the checks).
dp <- function(x) ifelse(grepl(".", x, fixed=TRUE), nchar(sub("^[^.]*\\.", "", x)), 0L)
vol <- sapply(vol_col, function(j) num(snap[8:19,j]))   # 12 components x 3 species
pct <- sapply(pct_col, function(j) num(snap[8:19,j]))
tot_vol <- num(unname(unlist(snap[20,vol_col]))); tot_pct <- num(unname(unlist(snap[20,pct_col])))
stopifnot(identical(is.na(vol), is.na(pct)), !anyNA(tot_vol), !anyNA(tot_pct))

## ---- analysis view: the existing long schema, one row per species x component ----------
## Column headings -> the binomials printed in Material and methods (p.171), as before.
species <- c(PLATYPUS="Ornithorhynchus anatinus", ECHIDNA="Tachyglossus aculeatus",
 OPOSSUM="Didelphis marsupialis")[unlist(snap[5,vol_col])]
## Row labels -> existing analysis codes: the 2nd "Mes" is mesocortex (footnote order
## "... medulla oblongata and mesocortex"); printed "Cbl" keeps the existing code "CbI".
component <- c(codes[-12L], "Mesocortex"); component[component=="Cbl"] <- "CbI"
clean <- data.frame(species=rep(unname(species), times=12L), component=rep(component, each=3L),
 absolute_volume_mm3=as.vector(t(vol)), percent_total_brain=as.vector(t(pct)),
 source=item_name, stringsAsFactors=FALSE)
stopifnot(nrow(clean)==36L, sum(!is.na(clean$absolute_volume_mm3))==33L)

## ---- table checks: the table against its own printed totals ------------------------------
## Compared in whole units of the last printed decimal. Tolerance = what rounding of printed
## cells can explain: half a unit per summed cell; one unit for a recomputed percentage.
## Dash cells are unreported: left out of sums and not checkable. A mismatch is reported
## and warned; no value is changed.
check <- function(id, basis, obs_u, prt_u, d, tol_u, note) data.frame(
 check_id=id, basis=basis, observed=obs_u/10^d, printed=prt_u/10^d,
 difference=(obs_u-prt_u)/10^d, tolerance=tol_u/10^d,
 status=ifelse(is.na(obs_u-prt_u), "not_evaluable", ifelse(abs(obs_u-prt_u)<=tol_u, "pass", "mismatch")),
 note=note, stringsAsFactors=FALSE)
checks <- list()
for(s in 1:3) {
 sp <- snap[5,vol_col[s]]
 printed <- !is.na(vol[,s])
 dv <- dp(snap[20,vol_col[s]]); dpc <- dp(snap[20,pct_col[s]])
 vu <- round(vol[,s]*10^dv); pu <- round(pct[,s]*10^dpc)
 tvu <- round(tot_vol[s]*10^dv); tpu <- round(tot_pct[s]*10^dpc)
 left_out <- if(any(!printed)) paste0("; left out (printed as a dash): row ",
  paste(which(!printed)+7L, codes[!printed], collapse=", ")) else ""
 checks[[length(checks)+1L]] <- check(paste0("volume_sum_",sp),
  paste0(sp,": sum of the printed component volumes vs the printed total (row 20)"),
  sum(vu[printed]), tvu, dv, sum(printed)/2, paste0(sum(printed)," components summed",left_out))
 checks[[length(checks)+1L]] <- check(paste0("percent_sum_",sp),
  paste0(sp,": sum of the printed percentages vs the printed total (row 20)"),
  sum(pu[printed]), tpu, dpc, sum(printed)/2, paste0(sum(printed)," components summed",left_out))
 for(i in 1:12) checks[[length(checks)+1L]] <- check(sprintf("percent_%s_%02d_%s", sp, i, codes[i]),
  paste0(sp," ",codes[i]," (row ",i+7L,"): 100 x volume / printed total vs printed percentage"),
  if(printed[i]) floor(100*vu[i]*10^dpc/tvu + 0.5) else NA_real_, pu[i], dpc, 1,
  if(printed[i]) "Recomputed to the printed decimals (half-up); 1 unit allowed for the authors' rounding."
  else "Printed as a dash (not reported), so not checkable.")
}
table_checks <- do.call(rbind, checks)
stopifnot(nrow(table_checks)==42L, !anyDuplicated(table_checks$check_id))
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
