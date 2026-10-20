## Catania & Remple (2002), PNAS 99:5692-5697 — Table 1 plus the paper's
## same-study rat percentage comparison in Results/Figure 4.

options(scipen = 999)
.sp <- local({ a <- grep("^--file=", commandArgs(FALSE), value = TRUE); if (length(a)) return(normalizePath(sub("^--file=", "", a[1]))); if (requireNamespace("rstudioapi", quietly=TRUE) && rstudioapi::isAvailable()) { p <- rstudioapi::getSourceEditorContext()$path; if (nzchar(p)) return(normalizePath(p)) }; stop("Run with Rscript or Source in RStudio.", call.=FALSE) })
folder <- dirname(.sp); item_name <- tools::file_path_sans_ext(basename(.sp))
base <- local({ d <- folder; while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d); if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_ })
raw <- read.csv(file.path(folder, paste0(item_name, "_snapshot.csv")), check.names=FALSE, stringsAsFactors=FALSE)
cols <- names(raw)[-1]
parse_area <- function(x) suppressWarnings(as.numeric(sub("^.*\\(([0-9.]+)\\).*$", "\\1", x)))
parse_pct <- function(x) ifelse(grepl("%", x), suppressWarnings(as.numeric(sub("^\\s*([0-9.]+)%.*$", "\\1", x))), NA_real_)
rows <- list(); k <- 0L
for (j in seq_along(cols)) for (i in seq_len(nrow(raw))) {
  x <- raw[[cols[j]]][i]; k <- k + 1L
  rows[[k]] <- data.frame(
    Species="Heterocephalus glaber", common_name="naked mole-rat",
    case_id=if (j <= 4) sub("Case ", "", cols[j]) else NA_character_,
    statistic=c(rep("individual",4),"mean","SD")[j], n=if (j > 4) 4L else 1L,
    structure=if (raw[[1]][i] == "Total S1") "primary somatosensory cortex (S1)" else if (raw[[1]][i] == "Total neocortex") "total neocortex" else paste0(raw[[1]][i], " representation in S1"),
    area_mm2=parse_area(x), percent_value=parse_pct(x),
    percent_denominator=if (grepl("%", x)) "S1" else NA_character_,
    value_status="as reported", where_in_paper="Table 1", source=item_name,
    stringsAsFactors=FALSE
  )
}
clean <- do.call(rbind, rows)
txt <- read.csv(file.path(folder, paste0(item_name, "_text_snapshot.csv")), stringsAsFactors=FALSE)
txt_species <- c("naked mole-rat"="Heterocephalus glaber", "Long-Evans laboratory rat"="Rattus norvegicus")
extra <- data.frame(
  Species=unname(txt_species[txt$species_as_published]), common_name=txt$species_as_published,
  case_id=NA_character_, statistic="approximate", n=as.integer(sub(" .*", "", txt$n)),
  structure=txt$structure, area_mm2=NA_real_, percent_value=txt$value,
  percent_denominator="total neocortex", value_status=txt$qualifier,
  where_in_paper=txt$source_location, source=item_name, stringsAsFactors=FALSE
)
clean <- rbind(clean, extra)
stopifnot(nrow(clean) == 56L, !anyNA(clean$Species), !anyNA(clean$structure))
table_checks <- data.frame(
  check_id="body_part_pct_mean_sum", observed=sum(clean$percent_value[clean$statistic=="mean" & clean$percent_denominator=="S1"]),
  expected=100, tolerance=1, pass=abs(sum(clean$percent_value[clean$statistic=="mean" & clean$percent_denominator=="S1"])-100)<=1,
  note="Mean body-part percentages in Table 1 sum to 100% within rounding", stringsAsFactors=FALSE)
write.csv(clean, file.path(folder, paste0(item_name, ".csv")), row.names=FALSE)
if (!is.na(base)) { fc <- readxl::read_excel(file.path(base,"__ReadMe.xlsx"), sheet="Sheet1"); enc <- fc$`Item encoded`[match(item_name, fc$`Item name`)]; if (!is.na(enc) && nzchar(enc)) write.table(clean,file.path(base,"__Public","comparative-data",paste0(enc,".tsv")),sep="\t",row.names=FALSE) else warning("Registry row pending for ",item_name,"; public TSV skipped.") }
message(item_name, ": ", nrow(clean), " rows written")
