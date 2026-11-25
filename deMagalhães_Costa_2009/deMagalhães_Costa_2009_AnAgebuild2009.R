## AnAge Build 11: frozen digital-native export -> analysis CSV + public TSV.
a <- grep('^--file=',commandArgs(FALSE),value=TRUE)
if (!length(a)) stop('Run with Rscript')
folder <- dirname(normalizePath(sub('^--file=','',a[1])))
item_name <- tools::file_path_sans_ext(basename(sub('^--file=','',a[1])))
root <- dirname(folder)
frozen <- file.path(folder,paste0(item_name,'_snapshot.txt'))
raw <- utils::read.delim(frozen,sep='\t',header=TRUE,quote='',
                         check.names=FALSE,colClasses='character',
                         na.strings=character(0),stringsAsFactors=FALSE,
                         fileEncoding='UTF-8')
stopifnot(nrow(raw)==4095L,ncol(raw)==30L,
          !anyDuplicated(paste(raw$Genus,raw$Species)))
name_map <- c(
  'Kingdom'='Kingdom','Phylum'='Phylum','Class'='Class','Order'='Order',
  'Family'='Family','Genus'='Genus','Species'='Species',
  'Common name'='Common_name','Female maturity (days)'='Female_maturity_days',
  'Male maturity (days)'='Male_maturity_days',
  'Gestation/Incubation (days)'='Gestation_Incubation_days',
  'Weaning (days)'='Weaning_days','Litter/Clutch size'='Litter_Clutch_size',
  'Litters/Clutches per year'='Litters_Clutches_per_year',
  'Inter-litter/Interbirth interval'='Inter_litter_Interbirth_interval_days',
  'Birth weight (g)'='Birth_weight_g','Weaning weight (g)'='Weaning_weight_g',
  'Adult weight (g)'='Adult_weight_g','Growth rate (1/days)'='Growth_rate_per_day',
  'Maximum longevity (yrs)'='Maximum_longevity_yrs','Source'='Source_ref',
  'Specimen origin'='Specimen_origin','Sample size'='Sample_size',
  'Data quality'='Data_quality','IMR (per yr)'='IMR_per_yr',
  'MRDT (yrs)'='MRDT_yrs','Metabolic rate (W)'='Metabolic_rate_W',
  'Body mass (g)'='Body_mass_g','Temperature (K)'='Temperature_K',
  'References'='References')
stopifnot(identical(sort(names(name_map)),sort(names(raw))))
names(raw) <- unname(name_map[names(raw)])
numeric_columns <- c('Female_maturity_days','Male_maturity_days',
  'Gestation_Incubation_days','Weaning_days','Litter_Clutch_size',
  'Litters_Clutches_per_year','Inter_litter_Interbirth_interval_days',
  'Birth_weight_g','Weaning_weight_g','Adult_weight_g','Growth_rate_per_day',
  'Maximum_longevity_yrs','IMR_per_yr','MRDT_yrs','Metabolic_rate_W',
  'Body_mass_g','Temperature_K')
parse_num <- function(x,column) {
  clean <- gsub(',','',x,fixed=TRUE)
  clean[clean %in% c('','-','n.a.')] <- NA_character_
  out <- suppressWarnings(as.numeric(clean))
  if (any(!is.na(clean) & is.na(out))) stop('Unexpected numeric token in ',column)
  out
}
for (column in numeric_columns) raw[[column]] <- parse_num(raw[[column]],column)
final.dataframe <- data.frame(source_row=seq_len(nrow(raw)),
  scientific_name=paste(raw$Genus,raw$Species),raw,
  check.names=FALSE,stringsAsFactors=FALSE)
stopifnot(nrow(final.dataframe)==4095L,ncol(final.dataframe)==32L,
          all(nzchar(final.dataframe$scientific_name)))
utils::write.csv(final.dataframe,file.path(folder,paste0(item_name,'.csv')),
                 row.names=FALSE,na='',fileEncoding='UTF-8')
registry <- readxl::read_excel(file.path(root,'__ReadMeAddON.xlsx'),sheet='Sheet1')
nfc <- function(x) if(requireNamespace('stringi',quietly=TRUE))
  stringi::stri_trans_nfc(x) else x
hit <- which(nfc(registry[['Item name']])==nfc(item_name))
if(length(hit)!=1L) stop('Expected one AddON registry row for ',item_name)
item_encoded <- as.character(registry[['Item encoded']][hit])
stopifnot(nzchar(item_encoded),!grepl('_$',item_encoded))
utils::write.table(final.dataframe,
  file.path(root,'__Public','comparative-data',paste0(item_encoded,'.tsv')),
  sep='\t',row.names=FALSE,na='',fileEncoding='UTF-8')
cat(item_name,': ',nrow(final.dataframe),' species rows\n',sep='')
