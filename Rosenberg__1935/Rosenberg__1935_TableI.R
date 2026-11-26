#!/usr/bin/env Rscript
# Rosenberg (1935), Table I, printed p. 436: monthly isolated-tissue oxygen use.
# Read only the frozen page-image transcription; no measurements are coded here.
arg <- grep('^--file=', commandArgs(FALSE), value=TRUE)
if (!length(arg)) stop('Run with Rscript Rosenberg__1935_TableI.R')
folder <- dirname(normalizePath(sub('^--file=', '', arg[1])))
root <- dirname(folder)
item <- 'Rosenberg__1935_TableI'
snap <- read.csv(file.path(folder, paste0(item, '_snapshot.csv')),
                 na.strings='', check.names=FALSE, stringsAsFactors=FALSE,
                 fileEncoding='UTF-8')
stopifnot(nrow(snap)==11L, ncol(snap)==17L,
          identical(snap$month_as_published,
                    c('Septembre','Octobre','Novembre','Décembre','Janvier',
                      'Février','Mars','Avril','Mai','Juin','Juillet')))
parts <- c('brain','spinal_cord','cerebrospinal_axis','sciatic_nerve')
rows <- list()
for (i in seq_len(nrow(snap))) for (part in parts) {
  value <- snap[[paste0(part, '_o2_mm3_g_h')]][i]
  if (is.na(value)) next
  n <- snap[[paste0(part, '_n')]][i]
  ext <- snap[[paste0(part, '_extremes_printed')]][i]
  bounds <- if (is.na(ext)) c(NA_real_,NA_real_) else
    as.numeric(strsplit(ext, '-', fixed=TRUE)[[1]])
  stopifnot(length(bounds)==2L, is.finite(value), is.finite(n), n>=1,
            is.na(bounds[1]) || bounds[1]<=value,
            is.na(bounds[2]) || bounds[2]>=value)
  rows[[length(rows)+1L]] <- data.frame(
    source_month_row=i, source_printed_page=436L, source_pdf_page=4L,
    species_as_published='Rana esculenta L.',
    month_as_published=snap$month_as_published[i],
    tissue=part, n_experiments=n,
    oxygen_mm3_per_g_h=value,
    oxygen_cm3_per_100g_min=value/600,
    extremes_as_published=ext,
    extremes_low_mm3_per_g_h=bounds[1],
    extremes_high_mm3_per_g_h=bounds[2],
    probable_error_of_mean_pct=snap[[paste0(part, '_probable_error_mean_pct')]][i],
    temperature_reference_C=20L,
    preparation='isolated tissue at rest', stringsAsFactors=FALSE)
}
out <- do.call(rbind, rows)
stopifnot(nrow(out)==28L,
          sum(out$tissue=='brain')==7L,
          sum(out$tissue=='spinal_cord')==8L,
          sum(out$tissue=='cerebrospinal_axis')==4L,
          sum(out$tissue=='sciatic_nerve')==9L)
write.csv(out, file.path(folder,paste0(item,'.csv')), row.names=FALSE, na='', fileEncoding='UTF-8')
write.table(out, file.path(root,'__Public','comparative-data',
                           'ArchIntPhysiol41_434-445_TableI.tsv'),
            sep='\t', row.names=FALSE, na='', quote=TRUE, fileEncoding='UTF-8')
cat(item, ': ', nrow(out), ' tissue-month values\n', sep='')
