## Printed stereological sampling parameters, not estimated animal traits.
a <- grep('^--file=',commandArgs(FALSE),value=TRUE)
if (!length(a)) stop('Run with Rscript')
folder <- dirname(normalizePath(sub('^--file=','',a[1])))
item_name <- tools::file_path_sans_ext(basename(sub('^--file=','',a[1])))
root <- dirname(folder)
s <- utils::read.csv(file.path(folder,paste0(item_name,'_snapshot.csv')),
 check.names=FALSE,colClasses='character',fileEncoding='UTF-8')
stopifnot(nrow(s)==8L,ncol(s)==8L)
key <- utils::read.csv(file.path(root,'_keys','General','species_key.csv'),stringsAsFactors=FALSE)
k <- key[key$source_publication==basename(folder) & key$variant_name=='Macaca mulatta',]
stopifnot(nrow(k)==1L)
steps <- strsplit(s[[3]],' × ',fixed=TRUE)
stopifnot(all(lengths(steps)==2L))
final.dataframe <- data.frame(source_row=seq_len(nrow(s)),region_as_published=s[[1]],
 species_label_in_article='rhesus monkey (Macaca mulatta)',Species=k$accepted_name,
 one_over_section_sampling_fraction=as.integer(s[[2]]),
 section_sampling_fraction=1/as.integer(s[[2]]),
 step_x_um=as.numeric(vapply(steps,`[`,character(1),1L)),
 step_y_um=as.numeric(vapply(steps,`[`,character(1),2L)),
 sections_sampled=as.integer(s[[4]]),counting_frame_area_um2=as.numeric(s[[5]]),
 disectors_sampled=as.integer(s[[6]]),sampled_neuron_profiles=as.integer(s[[7]]),
 sampled_glial_profiles=as.integer(s[[8]]),
 hemisphere=ifelse(grepl('^CA',s[[1]]),'mixed (4 right, 4 left)','right'),observation_level='regional stereological sampling design',
 data_role='method parameters and sampled profiles; not estimated cell numbers',stringsAsFactors=FALSE)
stopifnot(!anyNA(final.dataframe$sampled_neuron_profiles),all(final.dataframe$section_sampling_fraction>0))
utils::write.csv(final.dataframe,file.path(folder,paste0(item_name,'.csv')),
 row.names=FALSE,na='',fileEncoding='UTF-8')
reg <- readxl::read_excel(file.path(root,'__ReadMeAddON.xlsx'),sheet='Sheet1')
hit <- which(reg[['Item name']]==item_name)
if(length(hit)!=1L) stop('Expected one AddON registry row')
encoded <- as.character(reg[['Item encoded']][hit])
utils::write.table(final.dataframe,file.path(root,'__Public','comparative-data',paste0(encoded,'.tsv')),
 sep='\t',row.names=FALSE,na='',fileEncoding='UTF-8')
cat(item_name,': ',nrow(final.dataframe),' method rows\n',sep='')
