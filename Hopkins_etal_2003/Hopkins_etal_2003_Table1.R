## Table 1 individual tube-task counts. Reads only this item's frozen snapshot.
.sp <- local({
  for (i in rev(seq_len(sys.nframe()))) {
    p <- sys.frame(i)$ofile; if (!is.null(p) && grepl('Table1[.]R$', p)) return(normalizePath(p))
    p <- sys.frame(i)$build_script; if (!is.null(p) && grepl('Table1[.]R$', p)) return(normalizePath(p))
  }
  a <- grep('^--file=', commandArgs(FALSE), value=TRUE)
  if (length(a)) return(normalizePath(sub('^--file=', '', a[1])))
  stop('Run saved item script with Rscript or source().')
})
folder <- dirname(.sp); item_name <- tools::file_path_sans_ext(basename(.sp)); base <- dirname(folder)
snap <- utils::read.csv(file.path(folder,paste0(item_name,'_snapshot.csv')),
                        header=FALSE,colClasses='character',na.strings='',check.names=FALSE,fileEncoding='UTF-8')
stopifnot(nrow(snap)==53L,ncol(snap)==9L,snap[1,1]=='Table 1',snap[2,2]=='Subject',snap[53,1]=='Note.')
d <- snap[3:52,,drop=FALSE]
key <- utils::read.csv(file.path(base,'_keys','General','species_key.csv'),stringsAsFactors=FALSE,fileEncoding='UTF-8')
key <- key[key$source_publication=='Hopkins_etal_2003',]
idx <- match(d[[1]],key$variant_name);stopifnot(!anyNA(idx),!anyDuplicated(key$variant_name))
left <- as.integer(d[[6]]);right <- as.integer(d[[7]])
z <- as.numeric(chartr('⫺−','--',d[[8]]))
stopifnot(!anyNA(left),!anyNA(right),!anyNA(z),all(left+right>0))
expected_z <- (right-left)/sqrt(right+left)
table_checks <- data.frame(check_id=paste0('z_vs_counts_',d[[2]]),basis='z = (R-L)/sqrt(R+L) from printed counts',
                           observed=expected_z,printed=z,difference=expected_z-z,tolerance=0.12,
                           status=ifelse(abs(expected_z-z)<=0.12,'pass','mismatch'),
                           note='Printed values retained; a mismatch may be a source table error.',stringsAsFactors=FALSE)
if(any(table_checks$status=='mismatch'))warning(sum(table_checks$status=='mismatch'),' printed z values differ from counts; retained verbatim.')
final.dataframe <- data.frame(source_row=seq_len(nrow(d)),group_as_published=d[[1]],subject_as_published=d[[2]],
                              sex_as_published=d[[3]],rearing_as_published=d[[4]],age_years=as.numeric(d[[5]]),
                              left_uses=left,right_uses=right,z_as_published=z,handedness_as_published=d[[9]],
                              pooled_LI_from_counts=(right-left)/(right+left),
                              Species=key$accepted_name[idx],species_resolution_note=key$note[idx],
                              task='coordinated bimanual tube',observation_level='individual',
                              source_locator='Table 1',data_role='primary',stringsAsFactors=FALSE)
stopifnot(nrow(final.dataframe)==50L,all(abs(final.dataframe$pooled_LI_from_counts)<=1))
utils::write.csv(final.dataframe,file.path(folder,paste0(item_name,'.csv')),row.names=FALSE,na='',fileEncoding='UTF-8')
filecodes <- readxl::read_excel(file.path(base,'__ReadMe.xlsx'),sheet='Sheet1');registry_source <- '__ReadMe.xlsx'
if(!item_name %in% filecodes[['Item name']]){filecodes <- readxl::read_excel(file.path(base,'__ReadMeAddON.xlsx'),sheet='Sheet1');registry_source <- '__ReadMeAddON.xlsx'}
rr <- which(!is.na(filecodes[['Item name']]) & filecodes[['Item name']]==item_name);stopifnot(length(rr)==1L)
item_encoded <- filecodes[['Item encoded']][rr];stopifnot(!is.na(item_encoded),nzchar(item_encoded),!grepl('_$',item_encoded))
utils::write.table(final.dataframe,file.path(base,'__Public','comparative-data',paste0(item_encoded,'.tsv')),
                   sep='\t',row.names=FALSE,na='',fileEncoding='UTF-8')
cat('Registry:',registry_source,'; item:',item_name,'; individuals:',nrow(final.dataframe),'\n')
