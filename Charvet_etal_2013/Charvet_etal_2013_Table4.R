## Charvet et al. 2013 advance publication, Table 4: regional means and SEs.
a <- grep('^--file=',commandArgs(FALSE),value=TRUE)
if(!length(a))stop('Run with Rscript')
folder <- dirname(normalizePath(sub('^--file=','',a[1])))
item_name <- tools::file_path_sans_ext(basename(sub('^--file=','',a[1])))
root <- dirname(folder);base <- file.path(folder,item_name)
s <- utils::read.csv(paste0(base,'_snapshot.csv'),header=FALSE,colClasses='character',
 na.strings=NULL,check.names=FALSE,fileEncoding='UTF-8')
stopifnot(nrow(s)==20L,ncol(s)==5L,
 identical(as.character(unlist(s[2,],use.names=FALSE)),c('Species','Region','Total neuron number mean (SE)',
 'Supragranular neuron number mean (SE)','Infragranular neuron number mean (SE)')))
num <- function(x) {x <- gsub(' ','',x,fixed=TRUE);stopifnot(all(grepl('^[0-9]+([.][0-9]+)?$',x)));as.numeric(x)}
mean_se <- function(x) {
 x <- gsub(' ','',x,fixed=TRUE)
 stopifnot(all(grepl('^[0-9]+([.][0-9]+)?[(][0-9]+([.][0-9]+)?[)]$',x)))
 z <- regmatches(x,gregexpr('[0-9]+([.][0-9]+)?',x))
 cbind(mean=as.numeric(vapply(z,`[`,character(1),1L)),
       se=as.numeric(vapply(z,`[`,character(1),2L)))
}
rows <- s[3:20,,drop=FALSE]
stopifnot(identical(rep(c('Rostral','Caudal','Varies by'),6L),rows[[2L]]))
labels <- rows[[1L]][seq(1L,18L,by=3L)]
stopifnot(all(nzchar(labels)),all(rows[[1L]][setdiff(1:18,seq(1,18,3))]==''))
final.dataframe <- data.frame(source_species_block=seq_along(labels),
 species_as_published=labels,Species=labels,stringsAsFactors=FALSE)
for(k in 3:5) {
 stem <- c('total','supragranular_II_IV','infragranular_V_VI')[k-2]
 for(region in c('rostral','caudal')) {
  idx <- seq(if(region=='rostral')1L else 2L,18L,by=3L)
  parsed <- mean_se(rows[[k]][idx])
  final.dataframe[[paste0(region,'_',stem,'_neurons_per_mm2_mean')]] <- parsed[,'mean']
  final.dataframe[[paste0(region,'_',stem,'_neurons_per_mm2_se')]] <- parsed[,'se']
 }
 final.dataframe[[paste0(stem,'_caudal_rostral_ratio_printed')]] <- num(rows[[k]][seq(3L,18L,by=3L)])
}
final.dataframe$caudal_se_exceeds_mean <-
 final.dataframe$caudal_total_neurons_per_mm2_se >
 final.dataframe$caudal_total_neurons_per_mm2_mean
final.dataframe$data_role <- 'primary regional sample mean and SE'

# Compare each printed total to the layer means and each printed ratio to caudal/rostral.
checks <- list()
for(region in c('rostral','caudal')) {
 observed <- final.dataframe[[paste0(region,'_supragranular_II_IV_neurons_per_mm2_mean')]]+
   final.dataframe[[paste0(region,'_infragranular_V_VI_neurons_per_mm2_mean')]]
 printed <- final.dataframe[[paste0(region,'_total_neurons_per_mm2_mean')]]
 for(i in seq_along(labels))checks[[length(checks)+1L]] <- data.frame(
  check_id=paste('layer_sum',labels[i],region,sep='_'),
  basis=paste(labels[i],region,'total mean vs sum of layer means'),
  observed=observed[i],printed=printed[i],difference=observed[i]-printed[i],
  tolerance=0.5,status=ifelse(abs(observed[i]-printed[i])<=0.5,'pass','mismatch'),
  note='Means in neurons/mm2; tolerance allows tiny source rounding differences',stringsAsFactors=FALSE)
}
for(stem in c('total','supragranular_II_IV','infragranular_V_VI')) {
 observed <- final.dataframe[[paste0('caudal_',stem,'_neurons_per_mm2_mean')]]/
   final.dataframe[[paste0('rostral_',stem,'_neurons_per_mm2_mean')]]
 printed <- final.dataframe[[paste0(stem,'_caudal_rostral_ratio_printed')]]
 for(i in seq_along(labels))checks[[length(checks)+1L]] <- data.frame(
  check_id=paste('ratio',labels[i],stem,sep='_'),
  basis=paste(labels[i],stem,'caudal / rostral vs printed Varies by'),
  observed=observed[i],printed=printed[i],difference=observed[i]-printed[i],
  tolerance=0.02,status=ifelse(abs(observed[i]-printed[i])<=0.02,'pass','mismatch'),
  note='Printed ratios are retained, including publication discrepancies',stringsAsFactors=FALSE)
}
table_checks <- do.call(rbind,checks)
if(any(table_checks$status=='mismatch'))warning(sum(table_checks$status=='mismatch'),
 ' Table 4 arithmetic mismatch(es); see item README')
utils::write.csv(final.dataframe,paste0(base,'.csv'),row.names=FALSE,na='',fileEncoding='UTF-8')
reg <- readxl::read_excel(file.path(root,'__ReadMeAddON.xlsx'),sheet='Sheet1')
hit <- which(reg[['Item name']]==item_name)
if(length(hit)!=1L)stop('Expected one AddON registry row')
item_encoded <- as.character(reg[['Item encoded']][hit])
utils::write.table(final.dataframe,file.path(root,'__Public','comparative-data',paste0(item_encoded,'.tsv')),
 sep='\t',row.names=FALSE,na='',fileEncoding='UTF-8')
cat(item_name,': ',nrow(final.dataframe),' species rows; ',
 sum(table_checks$status=='mismatch'),' arithmetic mismatches\n',sep='')
