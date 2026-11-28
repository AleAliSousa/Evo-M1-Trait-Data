## Printed main-text model-output table, kept separate from the fuller supplement.
a <- grep('^--file=',commandArgs(FALSE),value=TRUE)
if (!length(a)) stop('Run with Rscript')
folder <- dirname(normalizePath(sub('^--file=','',a[1])))
item_name <- 'Feix_etal_2015_Table1'; root <- dirname(folder)
s <- utils::read.csv(file.path(folder,paste0(item_name,'_snapshot.csv')),
 check.names=FALSE,colClasses='character',fileEncoding='UTF-8')
stopifnot(nrow(s)==31L,ncol(s)==4L)
section <- is.na(s[[2]]) | !nzchar(s[[2]])
group <- rep(NA_character_, nrow(s))
group[section] <- s$Taxon[section]
for (i in seq_len(nrow(s))[-1]) if (is.na(group[i])) group[i] <- group[i-1]
s <- s[!section, , drop=FALSE]
group <- group[!section]
stopifnot(nrow(s)==28L)
num <- c('peak workspace','relative object size (R)','real object size R (mm)')
for (x in num) stopifnot(!anyNA(as.numeric(s[[x]])))
final.dataframe <- data.frame(source_row=seq_len(nrow(s)),group_as_published=group,
 species_as_published=s$Taxon,peak_workspace=as.numeric(s[[num[1]]]),
 relative_object_size_R=as.numeric(s[[num[2]]]),real_object_size_R_mm=as.numeric(s[[num[3]]]),
 source_note=ifelse(s$Taxon=='Hylobates lar',
 'Main Table 1 prints 2.20 mm; Supplementary Table 1 prints 22.2 mm. Both retained in their respective items; resolve before merge.',''),
 observation_level=ifelse(group=='fossils','fossil individual/composite model','taxon model summary'),
 data_role='primary modeled output; subset of Supplementary Table 1',stringsAsFactors=FALSE)
stopifnot(sum(group=='fossils')==7L,
 final.dataframe$real_object_size_R_mm[which(s$Taxon=='Hylobates lar')]==2.20)
utils::write.csv(final.dataframe,file.path(folder,paste0(item_name,'.csv')),
 row.names=FALSE,na='',fileEncoding='UTF-8')
reg <- readxl::read_excel(file.path(root,'__ReadMeAddON.xlsx'),sheet='Sheet1')
hit <- which(reg[['Item name']]==item_name)
if (length(hit)!=1L) stop('Expected one AddON registry row')
encoded <- as.character(reg[['Item encoded']][hit])
utils::write.table(final.dataframe,
 file.path(root,'__Public','comparative-data',paste0(encoded,'.tsv')),
 sep='\t',row.names=FALSE,na='',fileEncoding='UTF-8')
cat(item_name,': ',nrow(final.dataframe),' source rows\n',sep='')
