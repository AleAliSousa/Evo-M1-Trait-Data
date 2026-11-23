## Figure 21 threshold reader: scientific values from own frozen snapshot only.
.sp <- local({
 for(i in rev(seq_len(sys.nframe()))){p<-sys.frame(i)$ofile;if(!is.null(p)&&grepl('Figure21[.]R$',p))return(normalizePath(p));p<-sys.frame(i)$build_script;if(!is.null(p)&&grepl('Figure21[.]R$',p))return(normalizePath(p))}
 a<-grep('^--file=',commandArgs(FALSE),value=TRUE);if(length(a))return(normalizePath(sub('^--file=','',a[1])));stop('Run saved item script.')
})
folder <- dirname(.sp);item_name <- tools::file_path_sans_ext(basename(.sp));base <- dirname(folder)
snap <- utils::read.csv(file.path(folder,paste0(item_name,'_snapshot.csv')),header=FALSE,colClasses='character',na.strings='',check.names=FALSE,fileEncoding='UTF-8')
stopifnot(nrow(snap)==23L,ncol(snap)==10L,snap[1,1]=='Figure 21',snap[23,1]=='Note')
d <- snap[3:22,,drop=FALSE]
key <- utils::read.csv(file.path(base,'_keys','General','species_key.csv'),stringsAsFactors=FALSE,fileEncoding='UTF-8')
key <- key[key$source_publication=='Wu_etal_2000' & key$variant_name=='Galago garnetti',]
stopifnot(nrow(key)==1L)
mean <- as.numeric(d[[6]]);upper <- as.numeric(d[[7]])
stopifnot(nrow(d)==20L,!anyNA(mean),all(mean>=0),all(is.na(upper)|upper>=mean))
final.dataframe <- data.frame(source_order=as.integer(d[[1]]),area_as_published=d[[2]],series_as_published=d[[3]],
                              group_order=as.integer(d[[4]]),series_order=as.integer(d[[5]]),
                              mean_threshold_uA_approx=mean,upper_sem_endpoint_uA_approx=upper,
                              sem_uA_approx=upper-mean,digitization_halfwidth_uA=2,
                              errorbar_type='SEM (Figure 21 caption)',Species=key$accepted_name[1],
                              species_as_published='Galago garnetti',observation_level='area-by-movement-category mean across cases',
                              source_locator='Figure 21',data_role='primary',stringsAsFactors=FALSE)
stopifnot(identical(final.dataframe$source_order,seq_len(20L)))
utils::write.csv(final.dataframe,file.path(folder,paste0(item_name,'.csv')),row.names=FALSE,na='',fileEncoding='UTF-8')
filecodes <- readxl::read_excel(file.path(base,'__ReadMe.xlsx'),sheet='Sheet1');registry_source <- '__ReadMe.xlsx'
if(!item_name %in% filecodes[['Item name']]){filecodes <- readxl::read_excel(file.path(base,'__ReadMeAddON.xlsx'),sheet='Sheet1');registry_source <- '__ReadMeAddON.xlsx'}
rr <- which(!is.na(filecodes[['Item name']]) & filecodes[['Item name']]==item_name);stopifnot(length(rr)==1L)
item_encoded <- filecodes[['Item encoded']][rr];stopifnot(!is.na(item_encoded),nzchar(item_encoded),!grepl('_$',item_encoded))
utils::write.table(final.dataframe,file.path(base,'__Public','comparative-data',paste0(item_encoded,'.tsv')),
                   sep='\t',row.names=FALSE,na='',fileEncoding='UTF-8')
cat('Registry:',registry_source,'; item:',item_name,'; approximate bars:',nrow(final.dataframe),'\n')
