## Harvey & Clutton-Brock 1985 Table 1: frozen PDF transcription -> analysis CSV/TSV.
a <- grep('^--file=',commandArgs(FALSE),value=TRUE)
if (!length(a)) stop('Run with Rscript')
folder <- dirname(normalizePath(sub('^--file=','',a[1])))
item_name <- tools::file_path_sans_ext(basename(sub('^--file=','',a[1])))
root <- dirname(folder)
s <- utils::read.csv(file.path(folder,paste0(item_name,'_snapshot.csv')),
                     header=FALSE,skip=2,colClasses='character',na.strings=NULL,
                     check.names=FALSE,fileEncoding='UTF-8')
stopifnot(ncol(s)==15L)
fields <- c('female_body_mass_g','male_body_mass_g','gestation_days',
            'neonatal_body_mass_g','offspring_per_litter','weaning_age_days',
            'estrous_cycle_days','female_age_first_breeding_months',
            'female_age_sexual_maturity_months','maximum_lifespan_years',
            'interbirth_interval_days','male_age_sexual_maturity_months',
            'neonatal_brain_mass_mg','adult_brain_mass_mg')
to_num <- function(x) {
  x <- trimws(x)
  x[x %in% c('','-')] <- NA_character_
  stopifnot(all(is.na(x) | grepl('^[0-9][0-9,.]*$',x)))
  as.numeric(gsub(',','',x,fixed=TRUE))
}
family <- NA_character_; subfamily <- NA_character_; pdf_page <- 4L
records <- list()
for (i in seq_len(nrow(s))) {
  label <- trimws(s[i,1])
  vals <- as.character(s[i,2:15])
  vals[is.na(vals)] <- ''
  if (label=='TABLE 1. Continued.') {pdf_page <- pdf_page+1L; next}
  if (!nzchar(label)) next  # repeated numbered header
  if (all(!nzchar(trimws(vals)))) {
    if (grepl('idae$',label)) {family <- label;subfamily <- NA_character_}
    else if (grepl('inae$',label)) subfamily <- label
    next
  }
  x <- vapply(vals,to_num,numeric(1))
  stopifnot(length(x)==14L)
  x[c(1,2,13,14)] <- x[c(1,2,13,14)]*1000  # kg -> g; brain g -> mg
  row <- data.frame(source_row=length(records)+1L,source_pdf_page=pdf_page,
                    source_printed_page=pdf_page+558L,
                    species_as_published=label,Species=label,
                    family_as_published=family,subfamily_as_published=subfamily,
                    stringsAsFactors=FALSE)
  row[fields] <- as.list(x)
  row$data_role <- 'secondary literature compilation'
  row$taxonomic_resolution <- 'verbatim historical source label; unharmonized'
  row$primary_pool_eligible <- FALSE
  records[[length(records)+1L]] <- row
}
final.dataframe <- do.call(rbind,records)
stopifnot(nrow(final.dataframe)==135L,
          identical(sort(unique(final.dataframe$source_pdf_page)),4:8),
          !anyNA(final.dataframe$family_as_published),
          sum(!is.na(final.dataframe$adult_brain_mass_mg))>100L)
utils::write.csv(final.dataframe,file.path(folder,paste0(item_name,'.csv')),
                 row.names=FALSE,na='',fileEncoding='UTF-8')
reg <- readxl::read_excel(file.path(root,'__ReadMeAddON.xlsx'),sheet='Sheet1')
hit <- which(reg[['Item name']]==item_name)
if(length(hit)!=1L) stop('Expected one AddON registry row')
item_encoded <- as.character(reg[['Item encoded']][hit])
utils::write.table(final.dataframe,
  file.path(root,'__Public','comparative-data',paste0(item_encoded,'.tsv')),
  sep='\t',row.names=FALSE,na='',fileEncoding='UTF-8')
cat(item_name,': ',nrow(final.dataframe),' species; ',
    sum(!is.na(final.dataframe$adult_brain_mass_mg)),' adult brain masses\n',sep='')
