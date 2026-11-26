# Complete Barger 2012 dissertation limbic table; reference-only mixed provenance.
arg <- grep('^--file=', commandArgs(FALSE), value=TRUE)
if (length(arg) != 1L) stop('Run with Rscript')
script <- normalizePath(sub('^--file=', '', arg))
folder <- dirname(script)
root <- dirname(folder)
item <- tools::file_path_sans_ext(basename(script))
expected <- switch(item, 'Barger__2012_Table4.1'=22L,
                   'Barger__2012_Table4.2'=23L,
                   stop('Unexpected item: ', item))
snap <- read.csv(file.path(folder, paste0(item, '_snapshot.csv')),
                 check.names=FALSE, colClasses='character', na.strings=NULL,
                 stringsAsFactors=FALSE)
stopifnot(nrow(snap)==expected,
          identical(names(snap), c('Specimen','Species','A','Lat','Bas','AB','C',
                                   'CBL','CM','Hippo','Schi','Total','Refs.')),
          all(nzchar(snap$Species)))
num <- function(x) {
  x[x %in% c('--', '')] <- NA_character_
  as.numeric(x)
}
out <- data.frame(
  source_row=seq_len(nrow(snap)),
  specimen_as_published=snap$Specimen,
  taxon_as_published=snap$Species,
  has_printed_specimen_id=snap$Specimen != '--',
  amygdala_total_cc=num(snap$A),
  amygdala_lateral_cc=num(snap$Lat),
  amygdala_basal_cc=num(snap$Bas),
  amygdala_accessory_basal_cc=num(snap$AB),
  amygdala_central_cc=num(snap$C),
  corticobasolateral_cc=num(snap$CBL),
  centromedial_cc=num(snap$CM),
  hippocampus_cc=num(snap$Hippo),
  schizocortex_cc=num(snap$Schi),
  hippocampal_formation_total_cc=num(snap$Total),
  source_reference_code=snap[['Refs.']],
  row_granularity=ifelse(snap$Specimen == '--',
                         'unnamed taxon row', 'named or coded specimen'),
  data_role='secondary',
  merge_status='reference_only',
  source=item, check.names=FALSE)
volume_cols <- grep('_cc$', names(out), value=TRUE)
stopifnot(all(!is.na(out$amygdala_total_cc)),
          all(unlist(out[,volume_cols]) > 0, na.rm=TRUE))
if (item == 'Barger__2012_Table4.1') {
  disco <- out[out$specimen_as_published == 'Disco',,drop=FALSE]
  stopifnot(nrow(disco)==1L, disco$taxon_as_published=='Hylobates concolor')
} else stopifnot(!any(out$has_printed_specimen_id))
write.csv(out,file.path(folder,paste0(item,'.csv')),
          row.names=FALSE,na='',fileEncoding='UTF-8')
registry <- readxl::read_excel(file.path(root,'__ReadMeAddON.xlsx'),sheet='Sheet1')
matches <- registry[registry[['Item name']] == item,,drop=FALSE]
if (nrow(matches) != 1L) stop('Expected one AddON registry row')
encoded <- as.character(matches[['Item encoded']][1])
if (is.na(encoded) || !nzchar(encoded) || endsWith(encoded,'_'))
  stop('Invalid Item encoded')
write.table(out,file.path(root,'__Public','comparative-data',paste0(encoded,'.tsv')),
            sep='\t',row.names=FALSE,na='',fileEncoding='UTF-8')
cat(item,': ',nrow(out),' reference rows\n',sep='')
