## Hertz & Clausen (1963) Table 1: calf CNS-slice oxygen uptake.
## Reads only the frozen transcription; does not recalculate printed stimulation.
a <- grep("^--file=", commandArgs(FALSE), value=TRUE)
if (!length(a)) stop("Run with Rscript <script>.R", call.=FALSE)
.sp <- normalizePath(sub("^--file=", "", a[1]))
folder <- dirname(.sp)
item_name <- sub("\\.R$", "", basename(.sp))
base <- dirname(folder)
frozen <- file.path(folder, paste0(item_name, "_snapshot.csv"))
raw <- read.csv(frozen, check.names=FALSE, colClasses="character", na.strings=character(),
                stringsAsFactors=FALSE, fileEncoding="UTF-8")
stopifnot(nrow(raw)==14L, ncol(raw)==4L,
          identical(names(raw), c("Tissue","No KCl added","With KCl (48 mM) added","Stimulation (%)")))
decimal <- function(x) as.numeric(chartr("·−", ".-", x))
rate <- function(x) decimal(trimws(sub("\\s*\\([0-9]+\\)$", "", x)))
samples <- function(x) as.integer(sub("^.*\\(([0-9]+)\\)$", "\\1", x))
final.dataframe <- data.frame(
  source_row=seq_len(nrow(raw)), species_as_published="calf", Species=NA_character_,
  tissue_as_printed=raw$Tissue,
  oxygen_uptake_no_KCl_as_printed=raw[[2]],
  oxygen_uptake_no_KCl_umol_O2_per_g_fresh_wt_hr=rate(raw[[2]]),
  n_tissue_samples_no_KCl=samples(raw[[2]]),
  oxygen_uptake_with_KCl_as_printed=raw[[3]],
  oxygen_uptake_with_KCl_umol_O2_per_g_fresh_wt_hr=rate(raw[[3]]),
  n_tissue_samples_with_KCl=samples(raw[[3]]),
  stimulation_pct_as_printed=raw[[4]], stimulation_pct=decimal(raw[[4]]),
  stringsAsFactors=FALSE, check.names=FALSE)
stopifnot(!anyNA(final.dataframe[c("oxygen_uptake_no_KCl_umol_O2_per_g_fresh_wt_hr",
                                "oxygen_uptake_with_KCl_umol_O2_per_g_fresh_wt_hr",
                                "stimulation_pct")]))
## Printed stimulation uses an extrapolated/corrected log-rate comparison,
## so it is not asserted to equal a simple ratio of the two displayed rates.
out <- file.path(folder, paste0(item_name,".csv"))
write.csv(final.dataframe,out,row.names=FALSE,na="",fileEncoding="UTF-8")
suppressPackageStartupMessages(library(readxl))
reg <- readxl::read_excel(file.path(base,"__ReadMe.xlsx"),sheet="Sheet1")
code <- reg$`Item encoded`[match(item_name,reg$`Item name`)]
if (length(code)==1L && !is.na(code) && nzchar(code) && !grepl("_$",code)) {
  write.table(final.dataframe,file.path(base,"__Public","comparative-data",paste0(code,".tsv")),
              sep="\t",row.names=FALSE,na="",fileEncoding="UTF-8")
} else message(item_name,": analysis CSV built; public TSV pending owner registry row")
message(item_name,": ",nrow(final.dataframe)," tissue rows; source units preserved")
