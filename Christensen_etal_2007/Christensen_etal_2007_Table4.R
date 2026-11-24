## Printed eight monkey records plus two sex-specific average rows.
a <- grep('^--file=',commandArgs(FALSE),value=TRUE)
if (!length(a)) stop('Run with Rscript')
folder <- dirname(normalizePath(sub('^--file=','',a[1])))
item_name <- tools::file_path_sans_ext(basename(sub('^--file=','',a[1])))
root <- dirname(folder)
s <- utils::read.csv(file.path(folder,paste0(item_name,'_snapshot.csv')),
 check.names=FALSE,colClasses='character',na.strings='',fileEncoding='UTF-8')
stopifnot(nrow(s)==10L,ncol(s)==6L,
 identical(s[[1]],c(rep('F',4),'Average',rep('M',4),'Average')))
key <- utils::read.csv(file.path(root,'_keys','General','species_key.csv'),stringsAsFactors=FALSE)
k <- key[key$source_publication==basename(folder) & key$variant_name=='Macaca mulatta',]
stopifnot(nrow(k)==1L)
num <- function(x) as.numeric(gsub(',','.',x,fixed=TRUE))
volume_raw <- s[[5]]; volume_raw[volume_raw=='–'] <- NA_character_
sex <- c(rep('F',5),rep('M',5))
row_type <- ifelse(s[[1]]=='Average','sex mean','individual')
sequence <- c(1:4,NA_integer_,1:4,NA_integer_)
final.dataframe <- data.frame(source_row=seq_len(nrow(s)),gender_as_published=s[[1]],
 sex=sex,individual_sequence_within_sex=sequence,
 species_label_in_article='rhesus monkey (Macaca mulatta)',Species=k$accepted_name,
 hemisphere='right',neuron_count_million_as_published=as.integer(s[[2]]),
 neuron_number=as.numeric(s[[2]])*1e6,
 glia_count_million_as_published=as.integer(s[[3]]),
 glia_number=as.numeric(s[[3]])*1e6,
 total_cell_count_million_as_published=as.integer(s[[4]]),
 total_cell_number=as.numeric(s[[4]])*1e6,
 processed_volume_mm3=as.numeric(volume_raw),
 neuron_glia_ratio_as_published=num(s[[6]]),
 count_total_minus_components_million=as.integer(s[[4]])-as.integer(s[[2]])-as.integer(s[[3]]),
 observation_level=row_type,
 data_role=ifelse(row_type=='individual','primary individual estimate','published sex mean; not additional animal'),
 stringsAsFactors=FALSE)
stopifnot(sum(row_type=='individual')==8L,sum(is.na(final.dataframe$processed_volume_mm3))==1L,
 all(abs(final.dataframe$count_total_minus_components_million)<=1L),
 max(abs(final.dataframe$neuron_count_million_as_published[row_type=='individual']/
 final.dataframe$glia_count_million_as_published[row_type=='individual']-
 final.dataframe$neuron_glia_ratio_as_published[row_type=='individual']))<0.01)
utils::write.csv(final.dataframe,file.path(folder,paste0(item_name,'.csv')),
 row.names=FALSE,na='',fileEncoding='UTF-8')
reg <- readxl::read_excel(file.path(root,'__ReadMeAddON.xlsx'),sheet='Sheet1')
hit <- which(reg[['Item name']]==item_name)
if(length(hit)!=1L) stop('Expected one AddON registry row')
encoded <- as.character(reg[['Item encoded']][hit])
utils::write.table(final.dataframe,file.path(root,'__Public','comparative-data',paste0(encoded,'.tsv')),
 sep='\t',row.names=FALSE,na='',fileEncoding='UTF-8')
cat(item_name,': 8 individuals and 2 printed sex means\n',sep='')
