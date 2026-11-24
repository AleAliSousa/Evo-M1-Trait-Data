## Printed regional neocortical summaries -> analysis CSV and public TSV.
a <- grep('^--file=',commandArgs(FALSE),value=TRUE)
if (!length(a)) stop('Run with Rscript')
folder <- dirname(normalizePath(sub('^--file=','',a[1])))
item_name <- tools::file_path_sans_ext(basename(sub('^--file=','',a[1])))
root <- dirname(folder)
s <- utils::read.csv(file.path(folder,paste0(item_name,'_snapshot.csv')),
 check.names=FALSE,colClasses='character',na.strings='',fileEncoding='UTF-8')
stopifnot(nrow(s)==21L,ncol(s)==12L)
key <- utils::read.csv(file.path(root,'_keys','General','species_key.csv'),stringsAsFactors=FALSE)
k <- key[key$source_publication==basename(folder) & key$variant_name=='Macaca mulatta',]
stopifnot(nrow(k)==1L)
num <- function(x) as.numeric(gsub(',','.',x,fixed=TRUE))
regions <- unique(s[[1]])
stopifnot(length(regions)==7L)
final.dataframe <- do.call(rbind,lapply(seq_along(regions),function(i) {
 p <- s[s[[1]]==regions[i],]
 stopifnot(nrow(p)==3L,identical(p[[2]],c('Average','St Dev','CV')))
 a <- p[1,];sd <- p[2,];cv <- p[3,]
 data.frame(source_region_order=i,region_as_published=regions[i],
 species_label_in_article='rhesus monkey (Macaca mulatta)',Species=k$accepted_name,
 hemisphere='right',neuron_count_million_as_published=num(a[[3]]),
 neuron_number=num(a[[3]])*1e6,neuron_SD=num(sd[[3]])*1e6,neuron_CV=num(cv[[3]]),
 neuron_CE=num(a[[4]]),glia_count_million_as_published=num(a[[5]]),
 glia_number=num(a[[5]])*1e6,glia_SD=num(sd[[5]])*1e6,glia_CV=num(cv[[5]]),
 glia_CE=num(a[[6]]),total_cell_count_million_as_published=num(a[[7]]),
 total_cell_number=num(a[[7]])*1e6,total_cell_SD=num(sd[[7]])*1e6,
 total_cell_CV=num(cv[[7]]),total_cell_CE=num(a[[8]]),
 processed_volume_mm3=num(a[[9]]),processed_volume_SD_mm3=num(sd[[9]]),
 processed_volume_CV=num(cv[[9]]),processed_volume_CE=num(a[[10]]),
 neuron_density_as_published_million_per_mm3=num(a[[11]]),
 neuron_density_per_mm3=num(a[[11]])*1e6,
 neuron_density_SD_per_mm3=num(sd[[11]])*1e6,
 neuron_density_CV_if_published=num(cv[[11]]),
 neuron_glia_ratio_as_published=num(a[[12]]),
 count_total_minus_components_million=num(a[[7]])-num(a[[3]])-num(a[[5]]),
 observation_level='regional group mean; eight control macaques',
 data_role='primary right-hemisphere regional stereological estimate',stringsAsFactors=FALSE)
}))
stopifnot(all(abs(final.dataframe$count_total_minus_components_million)<=1),
 sum(final.dataframe$neuron_count_million_as_published[c(1,5,6)])==
 final.dataframe$neuron_count_million_as_published[7],
 sum(final.dataframe$glia_count_million_as_published[c(1,5,6)])==
 final.dataframe$glia_count_million_as_published[7])
utils::write.csv(final.dataframe,file.path(folder,paste0(item_name,'.csv')),
 row.names=FALSE,na='',fileEncoding='UTF-8')
reg <- readxl::read_excel(file.path(root,'__ReadMeAddON.xlsx'),sheet='Sheet1')
hit <- which(reg[['Item name']]==item_name)
if(length(hit)!=1L) stop('Expected one AddON registry row')
encoded <- as.character(reg[['Item encoded']][hit])
utils::write.table(final.dataframe,file.path(root,'__Public','comparative-data',paste0(encoded,'.tsv')),
 sep='\t',row.names=FALSE,na='',fileEncoding='UTF-8')
cat(item_name,': ',nrow(final.dataframe),' regional summaries\n',sep='')
