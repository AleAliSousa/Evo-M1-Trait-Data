# Qi et al. 2023 SI Table S1: case-level macaque cuneate and pars rotunda area differences.
arg <- grep('^--file=', commandArgs(FALSE), value=TRUE)
if(length(arg)!=1L)stop('Run with Rscript')
folder <- dirname(normalizePath(sub('^--file=','',arg)))
root <- dirname(folder)
item <- tools::file_path_sans_ext(basename(sub('^--file=','',arg)))
x <- read.csv(file.path(folder,paste0(item,'_snapshot.csv')),check.names=FALSE,
              colClasses='character',na.strings=NULL)
stopifnot(nrow(x)==37L,length(unique(x[['Case #']]))==37L)
numeric_if_plain <- function(z) {
  ans <- rep(NA_real_, length(z))
  plain <- grepl('^[0-9]+(\\.[0-9]+)?$', z)
  ans[plain] <- as.numeric(z[plain])
  ans
}
out <- data.frame(
  source_row=seq_len(nrow(x)),species_as_published=x$Species,
  specimen_as_published=x[['Case #']],sex_as_published=x$Sex,
  injury_as_published=x[['Type of injury']],
  time_of_injury_as_published=x[['Time of injury (mo)']],
  survival_as_published=x[['Survival time (mo)']],
  survival_months=numeric_if_plain(x[['Survival time (mo)']]),
  ratio_denominator=ifelse(grepl('^Control',x[['Type of injury']]),'right side','intact side'),
  ratio_numerator=ifelse(grepl('^Control',x[['Type of injury']]),'left side','injured side'),
  cuneate_area_difference_percent=as.numeric(sub('%$','',x[['%Shrink-Cu']])),
  cuneate_p_as_published=x[['T-test (p) Cu']],
  rotunda_area_difference_percent=as.numeric(sub('%$','',x[['%Shrink-Ro']])),
  rotunda_p_as_published=x[['T-test (p) Ro']],
  observation_level='individual case; mean section area difference',
  data_role='primary',source=item,check.names=FALSE)
stopifnot(all(!is.na(out$cuneate_area_difference_percent)),
          all(!is.na(out$rotunda_area_difference_percent)))
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
