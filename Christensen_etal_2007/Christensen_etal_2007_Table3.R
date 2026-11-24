## Printed CA1 and CA2–3 hippocampal group summaries.
a <- grep('^--file=',commandArgs(FALSE),value=TRUE)
if (!length(a)) stop('Run with Rscript')
folder <- dirname(normalizePath(sub('^--file=','',a[1])))
item_name <- tools::file_path_sans_ext(basename(sub('^--file=','',a[1])))
root <- dirname(folder)
s <- utils::read.csv(file.path(folder,paste0(item_name,'_snapshot.csv')),
 check.names=FALSE,colClasses='character',na.strings='',fileEncoding='UTF-8')
stopifnot(nrow(s)==6L,ncol(s)==9L)
key <- utils::read.csv(file.path(root,'_keys','General','species_key.csv'),stringsAsFactors=FALSE)
k <- key[key$source_publication==basename(folder) & key$variant_name=='Macaca mulatta',]
stopifnot(nrow(k)==1L)
num <- function(x) as.numeric(gsub(',','.',x,fixed=TRUE))
regions <- unique(s[[1]])
stopifnot(identical(regions,c('CA1','CA2-3')))
final.dataframe <- do.call(rbind,lapply(seq_along(regions),function(i) {
 p <- s[s[[1]]==regions[i],]
 stopifnot(nrow(p)==3L,identical(p[[2]],c('Average','St Dev','CV')))
 a <- p[1,];sd <- p[2,];cv <- p[3,]
 data.frame(source_region_order=i,region_as_published=regions[i],
 species_label_in_article='rhesus monkey (Macaca mulatta)',Species=k$accepted_name,
 hemisphere='mixed (4 right, 4 left)',neuron_count_million_as_published=num(a[[3]]),
 neuron_number=num(a[[3]])*1e6,neuron_SD=num(sd[[3]])*1e6,neuron_CV=num(cv[[3]]),
 neuron_CE=num(a[[4]]),glia_count_million_as_published=num(a[[5]]),
 glia_number=num(a[[5]])*1e6,glia_SD=num(sd[[5]])*1e6,glia_CV=num(cv[[5]]),
 glia_CE=num(a[[6]]),processed_volume_mm3=num(a[[7]]),
 processed_volume_SD_mm3=num(sd[[7]]),processed_volume_CV=num(cv[[7]]),
 processed_volume_CE=num(a[[8]]),
 neuron_density_as_published_million_per_mm3=num(a[[9]]),
 neuron_density_per_mm3=num(a[[9]])*1e6,
 observation_level='hippocampal subregion group mean; eight control macaques, mixed sides',
 data_role='primary mixed-side stereological estimate',stringsAsFactors=FALSE)
}))
stopifnot(!anyNA(final.dataframe$neuron_number),
 all(final.dataframe$neuron_number>0),all(final.dataframe$glia_number>0))
utils::write.csv(final.dataframe,file.path(folder,paste0(item_name,'.csv')),
 row.names=FALSE,na='',fileEncoding='UTF-8')
reg <- readxl::read_excel(file.path(root,'__ReadMeAddON.xlsx'),sheet='Sheet1')
hit <- which(reg[['Item name']]==item_name)
if(length(hit)!=1L) stop('Expected one AddON registry row')
encoded <- as.character(reg[['Item encoded']][hit])
utils::write.table(final.dataframe,file.path(root,'__Public','comparative-data',paste0(encoded,'.tsv')),
 sep='\t',row.names=FALSE,na='',fileEncoding='UTF-8')
cat(item_name,': ',nrow(final.dataframe),' hippocampal summaries\n',sep='')
