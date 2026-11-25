## Charvet et al. 2013 advance publication, Table 1: frozen specimen table -> CSV/TSV.
a <- grep('^--file=', commandArgs(FALSE), value=TRUE)
if (!length(a)) stop('Run with Rscript')
folder <- dirname(normalizePath(sub('^--file=', '', a[1])))
item_name <- tools::file_path_sans_ext(basename(sub('^--file=', '', a[1])))
root <- dirname(folder); base <- file.path(folder, item_name)
s <- utils::read.csv(paste0(base, '_snapshot.csv'), header=FALSE,
                     colClasses='character', na.strings=NULL, check.names=FALSE,
                     fileEncoding='UTF-8')
stopifnot(nrow(s)==15L, ncol(s)==7L, s[2,1]=='Species name')
labels <- as.character(unlist(s[2,2:7],use.names=FALSE))
expected <- c('Specimen ID','Sex','Brain weight (g)','Hemisphere',
 'Thickness (µm)','Guard zone (µm)','Correction factor range',
 'Correction factor mean (SD)','Number of selected sample sites',
 'Number of selected sections','Total supragranular layer neurons sampled',
 'Total infragranular layer neurons sampled')
stopifnot(identical(s[3:14,1],expected))
x <- t(as.matrix(s[3:14,2:7])); colnames(x) <- expected
num <- function(z) {z <- gsub(' ', '', z, fixed=TRUE); stopifnot(all(grepl('^[0-9]+([.][0-9]+)?$',z)));as.numeric(z)}
brain_source <- x[,'Brain weight (g)']
brain_footnote <- ifelse(grepl('[a-z]$',brain_source),sub('.*([a-z])$','\\1',brain_source),NA_character_)
brain_g <- num(sub('[a-z]$','',brain_source))
range <- gsub('%','',x[,'Correction factor range'],fixed=TRUE)
range <- strsplit(range,'–',fixed=TRUE)
stopifnot(all(lengths(range)==2L))
mean_sd <- regmatches(x[,'Correction factor mean (SD)'],
 gregexpr('[0-9]+([.][0-9]+)?',x[,'Correction factor mean (SD)']))
stopifnot(all(lengths(mean_sd)==2L))
final.dataframe <- data.frame(
 source_column=seq_along(labels),species_as_published=labels,Species=labels,
 specimen_id=ifelse(x[,'Specimen ID']=='N/A',NA_character_,x[,'Specimen ID']),
 sex_as_published=x[,'Sex'],hemisphere_as_published=x[,'Hemisphere'],
 brain_weight_mg=brain_g*1000,brain_weight_footnote=brain_footnote,
 section_thickness_um=num(x[,'Thickness (µm)']),
 guard_zone_um=num(x[,'Guard zone (µm)']),
 correction_factor_min_pct=vapply(range,`[`,character(1),1L) |> num(),
 correction_factor_max_pct=vapply(range,`[`,character(1),2L) |> num(),
 correction_factor_mean_pct=num(vapply(mean_sd,`[`,character(1),1L)),
 correction_factor_sd_pct=num(vapply(mean_sd,`[`,character(1),2L)),
 selected_sample_sites=num(x[,'Number of selected sample sites']),
 selected_sections=num(x[,'Number of selected sections']),
 supragranular_neurons_sampled=num(x[,'Total supragranular layer neurons sampled']),
 infragranular_neurons_sampled=num(x[,'Total infragranular layer neurons sampled']),
 data_role='primary specimen metadata; hamster brain weight secondary',
 stringsAsFactors=FALSE,check.names=FALSE)
utils::write.csv(final.dataframe,paste0(base,'.csv'),row.names=FALSE,na='',fileEncoding='UTF-8')
reg <- readxl::read_excel(file.path(root,'__ReadMeAddON.xlsx'),sheet='Sheet1')
hit <- which(reg[['Item name']]==item_name)
if(length(hit)!=1L)stop('Expected one AddON registry row')
item_encoded <- as.character(reg[['Item encoded']][hit])
utils::write.table(final.dataframe,file.path(root,'__Public','comparative-data',paste0(item_encoded,'.tsv')),
 sep='\t',row.names=FALSE,na='',fileEncoding='UTF-8')
cat(item_name,': ',nrow(final.dataframe),' specimen rows\n',sep='')
