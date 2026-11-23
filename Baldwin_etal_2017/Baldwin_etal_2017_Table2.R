## Table 2 ICMS site counts: own frozen HTML-table snapshot only.
.sp <- local({
  for (i in rev(seq_len(sys.nframe()))) {
    p <- sys.frame(i)$ofile; if (!is.null(p) && grepl('Table2[.]R$', p)) return(normalizePath(p))
    p <- sys.frame(i)$build_script; if (!is.null(p) && grepl('Table2[.]R$', p)) return(normalizePath(p))
  }
  a <- grep('^--file=',commandArgs(FALSE),value=TRUE)
  if(length(a))return(normalizePath(sub('^--file=','',a[1])))
  stop('Run saved item script with Rscript or source().')
})
folder <- dirname(.sp);item_name <- tools::file_path_sans_ext(basename(.sp));base <- dirname(folder)
snap <- utils::read.csv(file.path(folder,paste0(item_name,'_snapshot.csv')),
                        header=FALSE,colClasses='character',na.strings='',check.names=FALSE,fileEncoding='UTF-8')
stopifnot(nrow(snap)==22L,ncol(snap)==9L,snap[1,1]=='Table 2',snap[2,1]=='Case No.',snap[22,1]=='Note:')
d <- snap[3:21,,drop=FALSE];stopifnot(nrow(d)==19L)
key <- utils::read.csv(file.path(base,'_keys','General','species_key.csv'),stringsAsFactors=FALSE,fileEncoding='UTF-8')
key <- key[key$source_publication=='Baldwin_etal_2017' & key$variant_name=='tree shrews',]
stopifnot(nrow(key)==1L)
case <- d[[1]]
for(i in seq_along(case))if(is.na(case[i]) || !nzchar(case[i]))case[i] <- case[i-1L]
duration <- as.integer(d[[2]]);stopifnot(!anyNA(duration),all(duration %in% c(50L,500L,800L)))
areas <- c('M','3a','3b','Sc','PP','S2/Pv','Total')
parse_pair <- function(x){p <- strsplit(gsub(' ','',x,fixed=TRUE),'/',fixed=TRUE);stopifnot(all(lengths(p)==2L));matrix(as.integer(unlist(p)),ncol=2L,byrow=TRUE)}
counts <- lapply(3:9,function(j)parse_pair(d[[j]]));names(counts) <- areas
stopifnot(all(vapply(counts,function(x)!anyNA(x)&&all(x[,1]<=x[,2]),logical(1))))
actual <- Reduce('+',lapply(counts[1:6],function(x)x))
printed <- counts[['Total']]
table_checks <- do.call(rbind,lapply(seq_len(nrow(d)),function(i) data.frame(
  check_id=paste('area_sum',case[i],duration[i],c('responsive','tested'),sep='_'),
  basis='sum of six printed area cells versus printed row Total',
  observed=actual[i,],printed=printed[i,],difference=actual[i,]-printed[i,],tolerance=0,
  status=ifelse(actual[i,]==printed[i,],'pass','mismatch'),
  note='Published discrepancy retained, not silently repaired.',stringsAsFactors=FALSE)))
if(any(table_checks$status=='mismatch'))warning(sum(table_checks$status=='mismatch'),' Table 2 total checks mismatch; printed values retained.')
final.dataframe <- do.call(rbind,lapply(seq_len(nrow(d)),function(i)do.call(rbind,lapply(seq_along(areas),function(j)
  data.frame(source_row=i,case_as_published=case[i],stimulus_duration_ms=duration[i],
             area_as_published=areas[j],responsive_sites=counts[[j]][i,1],tested_sites=counts[[j]][i,2],
             fraction_as_published=d[[j+2]][i],
             row_role=if(case[i]=='Total')'cross-case total' else 'case observation',
             area_role=if(areas[j]=='Total')'row total' else 'brain area',
             Species=key$accepted_name[1],species_as_published='tree shrews',
             observation_level='case-duration-area',source_locator='Table 2',
             data_role='primary',stringsAsFactors=FALSE)))))
stopifnot(nrow(final.dataframe)==133L)
utils::write.csv(final.dataframe,file.path(folder,paste0(item_name,'.csv')),row.names=FALSE,na='',fileEncoding='UTF-8')
filecodes <- readxl::read_excel(file.path(base,'__ReadMe.xlsx'),sheet='Sheet1');registry_source <- '__ReadMe.xlsx'
if(!item_name %in% filecodes[['Item name']]){filecodes <- readxl::read_excel(file.path(base,'__ReadMeAddON.xlsx'),sheet='Sheet1');registry_source <- '__ReadMeAddON.xlsx'}
rr <- which(!is.na(filecodes[['Item name']]) & filecodes[['Item name']]==item_name);stopifnot(length(rr)==1L)
item_encoded <- filecodes[['Item encoded']][rr];stopifnot(!is.na(item_encoded),nzchar(item_encoded),!grepl('_$',item_encoded))
utils::write.table(final.dataframe,file.path(base,'__Public','comparative-data',paste0(item_encoded,'.tsv')),
                   sep='\t',row.names=FALSE,na='',fileEncoding='UTF-8')
cat('Registry:',registry_source,'; item:',item_name,'; case-duration-area rows:',nrow(final.dataframe),'\n')
