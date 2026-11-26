#!/usr/bin/env Rscript
# Rosenberg (1935), Table II, printed p. 438: winter/spring experiment series.
# Read only the frozen page-image transcription; no measurements are coded here.
arg <- grep('^--file=', commandArgs(FALSE), value=TRUE)
if (!length(arg)) stop('Run with Rscript Rosenberg__1935_TableII.R')
folder <- dirname(normalizePath(sub('^--file=', '', arg[1])))
root <- dirname(folder)
item <- 'Rosenberg__1935_TableII'
snap <- read.csv(file.path(folder,paste0(item,'_snapshot.csv')),
                 check.names=FALSE, stringsAsFactors=FALSE, fileEncoding='UTF-8')
stopifnot(nrow(snap)==7L, ncol(snap)==9L,
          identical(snap$row_as_published,c(as.character(1:6),'Moyenne')))
parts <- c('brain','spinal_cord','cerebrospinal_axis','sciatic_nerve')
seasons <- c('winter','spring')
rows <- list()
for (i in seq_len(nrow(snap))) for (part in parts) for (season in seasons) {
  value <- snap[[paste0(part,'_',season)]][i]
  stopifnot(is.finite(value))
  rows[[length(rows)+1L]] <- data.frame(
    source_row=i, source_printed_page=438L, source_pdf_page=6L,
    species_as_published='Rana esculenta L.',
    experiment_or_mean=snap$row_as_published[i],
    statistic=if (i==7L) 'printed_mean' else 'experiment_value',
    season_as_published=if (season=='winter') 'grenouilles d\'hiver' else 'grenouilles de printemps',
    tissue=part, oxygen_mm3_per_g_h=value,
    oxygen_cm3_per_100g_min=value/600,
    temperature_reference_C=20L,
    preparation='isolated tissue at rest', stringsAsFactors=FALSE)
}
out <- do.call(rbind, rows)
stopifnot(nrow(out)==56L, sum(out$statistic=='experiment_value')==48L,
          sum(out$statistic=='printed_mean')==8L)
for (part in parts) for (season in c('grenouilles d\'hiver','grenouilles de printemps')) {
  subset <- out$tissue==part & out$season_as_published==season
  x <- out$oxygen_mm3_per_g_h[subset & out$statistic=='experiment_value']
  m <- out$oxygen_mm3_per_g_h[subset & out$statistic=='printed_mean']
  stopifnot(length(x)==6L, length(m)==1L, abs(mean(x)-m)<=0.5)
}
write.csv(out,file.path(folder,paste0(item,'.csv')),row.names=FALSE,na='',fileEncoding='UTF-8')
write.table(out,file.path(root,'__Public','comparative-data',
                          'ArchIntPhysiol41_434-445_TableII.tsv'),
            sep='\t',row.names=FALSE,na='',quote=TRUE,fileEncoding='UTF-8')
cat(item, ': ',nrow(out),' source cells (48 experiments + 8 means)\n',sep='')
