## Read the frozen printed-table snapshot; write one analysis CSV and public TSV.
.sp <- local({
  for (i in rev(seq_len(sys.nframe()))) {
    p <- sys.frame(i)$ofile; if (!is.null(p) && grepl('[.]R$', p)) return(normalizePath(p))
    p <- sys.frame(i)$build_script; if (!is.null(p) && grepl('[.]R$', p)) return(normalizePath(p))
  }
  a <- grep('^--file=', commandArgs(FALSE), value=TRUE)
  if (length(a)) return(normalizePath(sub('^--file=', '', a[1])))
  stop('Run saved item script with Rscript or source().')
})
folder <- dirname(.sp); item_name <- tools::file_path_sans_ext(basename(.sp)); base <- dirname(folder)
snap <- utils::read.csv(file.path(folder,paste0(item_name,'_snapshot.csv')),check.names=FALSE,
                        stringsAsFactors=FALSE,colClasses='character',na.strings='',fileEncoding='UTF-8')
key <- utils::read.csv(file.path(base,'_keys','General','species_key.csv'),stringsAsFactors=FALSE,fileEncoding='UTF-8')
key <- key[key$source_publication==basename(folder),]
lookup <- function(x){m <- match(x,key$variant_name);stopifnot(!anyNA(m));key$accepted_name[m]}
stopifnot(nrow(snap)==144L,ncol(snap)==10L)
species <- lookup(snap$Species)
parts <- c('Mc1','PP1','DP1','Mc2','PP2','IP2','DP2')
measure <- snap[,parts,drop=FALSE]
for(p in parts)measure[[p]] <- as.numeric(measure[[p]])
stopifnot(!anyNA(measure),all(as.matrix(measure)>0))
final.dataframe <- data.frame(source_row=seq_len(nrow(snap)),group_as_published=snap$Group,
 species_as_published=snap$Species,specimen_key_as_published=snap$Key,
 model_variant=ifelse(grepl(' comp H$| MH2 H$',snap$Species),'H',ifelse(grepl(' comp P$| MH2 P$',snap$Species),'P','')),
 measure,Species=species,observation_level=ifelse(grepl(' comp ',snap$Species),'composite model','specimen'),
 data_role='primary',check.names=FALSE,stringsAsFactors=FALSE)
row.names(final.dataframe) <- NULL
utils::write.csv(final.dataframe,file.path(folder,paste0(item_name,'.csv')),row.names=FALSE,na='',fileEncoding='UTF-8')
filecodes <- readxl::read_excel(file.path(base,'__ReadMe.xlsx'),sheet='Sheet1');registry_source <- '__ReadMe.xlsx'
if(!item_name %in% filecodes[['Item name']]){filecodes <- readxl::read_excel(file.path(base,'__ReadMeAddON.xlsx'),sheet='Sheet1');registry_source <- '__ReadMeAddON.xlsx'}
rr <- which(!is.na(filecodes[['Item name']]) & filecodes[['Item name']]==item_name);stopifnot(length(rr)==1L)
item_encoded <- filecodes[['Item encoded']][rr];stopifnot(!is.na(item_encoded),nzchar(item_encoded),!grepl('_$',item_encoded))
utils::write.table(final.dataframe,file.path(base,'__Public','comparative-data',paste0(item_encoded,'.tsv')),
                   sep='\t',row.names=FALSE,na='',fileEncoding='UTF-8')
cat('Registry:',registry_source,'; item:',item_name,'; rows:',nrow(final.dataframe),'\n')
