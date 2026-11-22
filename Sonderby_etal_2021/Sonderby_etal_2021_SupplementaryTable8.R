# Born-digital source -> analysis CSV + public TSV. No source values are hardcoded.
.sp <- local({
  frames <- sys.frames()
  for (i in rev(seq_along(frames))) if (!is.null(frames[[i]]$ofile))
    return(normalizePath(frames[[i]]$ofile))
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  stop("Run with Rscript or source().")
})
folder <- dirname(.sp)
base <- dirname(folder)
item_name <- tools::file_path_sans_ext(basename(.sp))
options(stringsAsFactors = FALSE)
doi <- "10.1038/s41398-021-01213-0"
sheet <- "Table S8"
raw <- as.data.frame(readxl::read_excel(file.path(folder,paste0(item_name,"_snapshot.xlsx")),
  sheet=sheet, col_names=FALSE, col_types="text", .name_repair="minimal"))
num <- function(x) suppressWarnings(as.numeric(x))
out <- list()
for (offset in c(0,9)) {
  subset <- model <- contrast <- NA_character_
  for (i in 2:nrow(raw)) {
    label <- trimws(raw[i,offset+1]); if (is.na(label) || !nzchar(label)) next
    vals <- unlist(raw[i,],use.names=FALSE)
    if (grepl("^Model ", label)) { model <- sub("^Model ","",label); next }
    if (grepl(" vs ",label,fixed=TRUE)) { contrast <- label; next }
    if (!is.finite(num(vals[offset+2]))) {
      if (label==toupper(label) && !grepl("^Supplementary",label)) subset <- label
      next
    }
    stopifnot(!is.na(subset), !is.na(model))
    metric <- if (label=="SurfArea") "surface_area" else if(label=="Thickness") "thickness" else if(label=="ICV") "intracranial_volume" else if(offset==0) "surface_area" else "thickness"
    level <- if(label %in% c("SurfArea","Thickness","ICV")) "global" else "regional"
    effect <- num(vals[offset+5])
    ci_text <- vals[offset+6]
    stopifnot(grepl("±",ci_text,fixed=TRUE))
    halfwidth <- num(gsub("[^0-9.eE+-]","",ci_text))
    ns <- num(vals[offset+c(2,3)])
    p <- num(vals[offset+7])
    out[[length(out)+1]] <- data.frame(species="Homo sapiens",study="Sonderby_etal_2021",
      source_sheet=sheet,source_row=i,source_column=offset+1,region=label,level=level,
      metric=metric,hemisphere="bilateral",atlas="Desikan-Killiany",subset=subset,
      contrast=contrast,adjustment=if(model=="plusICV" && label!="ICV") "ICV" else "none",
      model_source=model,covariates="age + age^2 + sex + scanner site; ICV when model plusICV (except ICV outcome); inverse-normal residual transform",
      effect_type="Cohen_d",effect=effect,
      ci_halfwidth_source=ci_text,ci_low=effect-halfwidth,ci_high=effect+halfwidth,
      n_group1_source=ns[1],n_group2_source=ns[2],
      n=sum(ns),t_source=num(vals[offset+4]),p=p,
      percent_difference_source=NA_real_,
      doi=doi,note="Published two-sided equal-variance t test; effect orientation retained under source heading on normalized covariate residuals; rounded effects and CI halfwidths; no new test or spatial null. Repeated global rows in the two metric panels retained.")
  }
}
final.dataframe <- do.call(rbind,out)
stopifnot(nrow(final.dataframe)>0,all(is.finite(final.dataframe$effect)),all(final.dataframe$n>0))

write.csv(final.dataframe, file.path(folder, paste0(item_name, ".csv")), row.names=FALSE, na="NA")
# Resolve the live registry by name. A new item has a prepared registry packet;
# use its explicitly provisional DOI code until the owner pastes that packet.
filecodes <- as.data.frame(readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet="Sheet1"))
idx <- match(item_name, filecodes[["Item name"]])
item_encoded <- if (!is.na(idx)) filecodes[["Item encoded"]][idx] else NA_character_
if (is.na(item_encoded) || !nzchar(item_encoded)) {
  item_encoded <- paste0(URLencode(doi, reserved=TRUE), "_", sub(paste0(basename(folder), "_"), "", item_name, fixed=TRUE))
  message("Registry pending; provisional TSV code: ", item_encoded)
}
stopifnot(!endsWith(item_encoded,"_"))
write.table(final.dataframe, file.path(base,"__Public","comparative-data",paste0(item_encoded,".tsv")),
            sep="\t", row.names=FALSE, quote=TRUE, na="NA")
message(item_name, ": ", nrow(final.dataframe), " rows")
