# Qi et al. 2023 SI Table S2: case-level New World monkey and galago Cu area differences.
arg <- grep('^--file=', commandArgs(FALSE), value=TRUE)
if(length(arg)!=1L)stop('Run with Rscript')
folder <- dirname(normalizePath(sub('^--file=','',arg)))
root <- dirname(folder)
item <- tools::file_path_sans_ext(basename(sub('^--file=','',arg)))
x <- read.csv(file.path(folder,paste0(item,'_snapshot.csv')),check.names=FALSE,
              colClasses='character',na.strings=NULL)
stopifnot(nrow(x)==85L,length(unique(x[['Case #']]))==85L)
out <- data.frame(
  source_row=seq_len(nrow(x)),species_as_published=x$Species,
  specimen_as_published=x[['Case #']],sex_as_published=x$Sex,
  lesion_as_published=x[['Lesion Level']],loss_as_published=x[['% Loss']],
  recovery_as_published=x[['Recovery (mo)']],
  recovery_months=suppressWarnings(as.numeric(x[['Recovery (mo)']])),
  ratio_denominator=ifelse(x[['Lesion Level']]=='Control','right side','intact side'),
  ratio_numerator=ifelse(x[['Lesion Level']]=='Control','left side','injured side'),
  cuneate_area_difference_percent=as.numeric(sub('%.*$','',x[['% Shrink (Inj/Int)']])),
  cuneate_p_as_published=x[['T-test (p)']],
  observation_level='individual case; mean section area difference',
  data_role='primary',source=item,check.names=FALSE)
stopifnot(all(!is.na(out$cuneate_area_difference_percent)))
options(scipen=999)
write.csv(out,file.path(folder,paste0(item,'.csv')),row.names=FALSE,na='',fileEncoding='UTF-8')
paths <- file.path(root,c('__ReadMe.xlsx','__ReadMeAddON.xlsx'))
hits <- lapply(paths,function(p){z<-readxl::read_excel(p,sheet='Sheet1');z[z[['Item name']]==item,,drop=FALSE]})
hits <- hits[vapply(hits,nrow,integer(1))==1L]
if(length(hits)!=1L)stop('Expected exactly one registry row')
code <- as.character(hits[[1]][['Item encoded']][1])
if(is.na(code)||!nzchar(code)||endsWith(code,'_'))stop('Invalid Item encoded')
write.table(out,file.path(root,'__Public','comparative-data',paste0(code,'.tsv')),
            sep='\t',row.names=FALSE,na='',fileEncoding='UTF-8')
cat(item,': ',nrow(out),' rows\n',sep='')
