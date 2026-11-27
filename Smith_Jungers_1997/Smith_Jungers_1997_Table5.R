args <- grep('^--file=',commandArgs(FALSE),value=TRUE)
stopifnot(length(args)==1L)
folder <- dirname(normalizePath(sub('^--file=','',args[1])))
root <- dirname(folder)
item <- 'Smith_Jungers_1997_Table5'
s <- read.csv(file.path(folder,paste0(item,'_snapshot.csv')),stringsAsFactors=FALSE,check.names=FALSE)
stopifnot(nrow(s)==317L,length(unique(s$species_as_published))==249L,
          sum(!nzchar(s$male_body_mass_kg_as_printed) & !nzchar(s$female_body_mass_kg_as_printed))==18L)
exact_numeric <- function(x) {
  x <- gsub('·','.',x,fixed=TRUE)
  y <- suppressWarnings(as.numeric(x))
  y[!grepl('^[0-9]+(\\.[0-9]+)?$',x)] <- NA_real_
  y
}
out <- data.frame(source_row=s$source_row,
                  Species=s$species_as_published,
                  family_as_published=s$family_as_published,
                  male_n=exact_numeric(s$male_sample_size_as_printed),
                  female_n=exact_numeric(s$female_sample_size_as_printed),
                  male_body_mass_kg=exact_numeric(s$male_body_mass_kg_as_printed),
                  female_body_mass_kg=exact_numeric(s$female_body_mass_kg_as_printed),
                  male_n_as_printed=s$male_sample_size_as_printed,
                  female_n_as_printed=s$female_sample_size_as_printed,
                  male_body_mass_kg_as_printed=s$male_body_mass_kg_as_printed,
                  female_body_mass_kg_as_printed=s$female_body_mass_kg_as_printed,
                  raw_source_line=s$raw_source_line,
                  source_pdf_page=s$source_pdf_page,
                  source_line_on_page=s$source_line_on_page,
                  stringsAsFactors=FALSE)
write.csv(out,file.path(folder,paste0(item,'.csv')),row.names=FALSE,na='',fileEncoding='UTF-8')
reg <- readxl::read_excel(file.path(root,'__ReadMe.xlsx'),sheet='Sheet1')
hit <- which(!is.na(reg[['Item name']]) & reg[['Item name']]==item)
stopifnot(length(hit)==1L)
code <- reg[['Item encoded']][hit]
write.table(out,file.path(root,'__Public','comparative-data',paste0(code,'.tsv')),
            sep='\t',row.names=FALSE,na='',fileEncoding='UTF-8')
cat(item,':',nrow(out),'source-layout rows ->',code,'\n')
