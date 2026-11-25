## Charvet et al. 2013 advance publication, Table 2: frozen layer counts -> CSV/TSV.
a <- grep('^--file=', commandArgs(FALSE),value=TRUE)
if(!length(a))stop('Run with Rscript')
folder <- dirname(normalizePath(sub('^--file=','',a[1])))
item_name <- tools::file_path_sans_ext(basename(sub('^--file=','',a[1])))
root <- dirname(folder); base <- file.path(folder,item_name)
s <- utils::read.csv(paste0(base,'_snapshot.csv'),header=FALSE,colClasses='character',
 na.strings=NULL,check.names=FALSE,fileEncoding='UTF-8')
stopifnot(nrow(s)==6L,ncol(s)==7L,s[3,1]=='Layer II–VI neuron numbers',
 s[4,1]=='Layer II–IV neuron numbers',s[5,1]=='Layer V–VI neuron numbers')
labels <- as.character(unlist(s[2,2:7],use.names=FALSE))
values <- t(as.matrix(s[3:5,2:7]));storage.mode(values) <- 'numeric'
stopifnot(!anyNA(values))
final.dataframe <- data.frame(source_column=seq_along(labels),
 species_as_published=labels,Species=labels,
 total_isocortical_neurons=values[,1]*1e6,
 supragranular_II_IV_neurons=values[,2]*1e6,
 infragranular_V_VI_neurons=values[,3]*1e6,
 hemisphere_scope='unilateral',data_role='primary optical-disector estimate',
 stringsAsFactors=FALSE)
diff <- abs(final.dataframe$total_isocortical_neurons-
 final.dataframe$supragranular_II_IV_neurons-final.dataframe$infragranular_V_VI_neurons)
table_checks <- data.frame(check_id='layer_sum',basis='Table 2 total vs layers II–IV + V–VI',
 observed=max(diff),printed=0,difference=max(diff),tolerance=1,
 status=ifelse(max(diff)<=1,'pass','mismatch'),
 note='Six species; source values in millions converted to neurons; one-neuron tolerance for floating point',
 stringsAsFactors=FALSE)
if(table_checks$status=='mismatch')warning('Table 2 layer sum mismatch')
utils::write.csv(final.dataframe,paste0(base,'.csv'),row.names=FALSE,na='',fileEncoding='UTF-8')
reg <- readxl::read_excel(file.path(root,'__ReadMeAddON.xlsx'),sheet='Sheet1')
hit <- which(reg[['Item name']]==item_name)
if(length(hit)!=1L)stop('Expected one AddON registry row')
item_encoded <- as.character(reg[['Item encoded']][hit])
utils::write.table(final.dataframe,file.path(root,'__Public','comparative-data',paste0(item_encoded,'.tsv')),
 sep='\t',row.names=FALSE,na='',fileEncoding='UTF-8')
cat(item_name,': ',nrow(final.dataframe),' species rows\n',sep='')
