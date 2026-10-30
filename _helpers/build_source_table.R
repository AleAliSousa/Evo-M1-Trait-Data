# Reader shared by the Nick/Fran source batch. Frozen files are never rewritten here.
build_source_table <- function(folder, item_name, base) {
  spec <- jsonlite::fromJSON(file.path(folder, 'reference_tables', paste0(item_name, '_build.json')), simplifyVector = FALSE)
  frozen <- file.path(folder, spec$snapshot)
  if (grepl('\\.xlsx?$', frozen)) {
    raw <- as.data.frame(readxl::read_excel(frozen, sheet=spec$sheet, skip=spec$skip, col_types='text', .name_repair='minimal'), check.names=FALSE)
  } else raw <- read.csv(frozen, check.names=FALSE, colClasses='character', na.strings=NULL)
  raw[is.na(raw)] <- ''
  if(isTRUE(spec$append_next_species_line)) for(i in seq_len(nrow(raw)-1L)) {
    if(nzchar(raw[i,2]) && grepl('^\\(',raw[i+1,1])) raw[i,1]<-paste(raw[i,1],raw[i+1,1])
  }
  source_rows <- seq_len(nrow(raw))
  if (length(spec$keep_rows)) { source_rows <- unlist(spec$keep_rows); raw <- raw[source_rows,,drop=FALSE] }
  if (isTRUE(spec$fill_species)) {
    for(i in seq_len(nrow(raw))) if(i>1 && !nzchar(raw[i,spec$species_col])) raw[i,spec$species_col] <- raw[i-1,spec$species_col]
  }
  parse_value <- function(x) {
    z<-trimws(gsub('(cid:219)', '', x, fixed=TRUE)); z<-gsub('Û','',z,fixed=TRUE)
    z<-gsub('[∗*]$', '', z); z<-gsub(',','',z,fixed=TRUE); z<-gsub('·','.',z,fixed=TRUE)
    missing<-z %in% c('', '-', '–', '—', '---', 'NA', 'n.a.')
    v<-lo<-hi<-unc<-rep(NA_real_,length(z)); qualifier<-rep('',length(z))
    for(i in which(!missing)) {
      s<-z[i]
      if(grepl('^[<>≤≥]',s)) {qualifier[i]<-substr(s,1,1);s<-substring(s,2)}
      if(grepl('^[0-9.]+\\s*±\\s*[0-9.]+$',s)) {
        a<-as.numeric(strsplit(s,'\\s*±\\s*')[[1]]);v[i]<-a[1];unc[i]<-a[2]
      } else if(grepl('^[0-9.]+\\s*[–-]\\s*[0-9.]+$',s)) {
        a<-as.numeric(strsplit(s,'\\s*[–-]\\s*')[[1]]);lo[i]<-a[1];hi[i]<-a[2];qualifier[i]<-'range'
      } else if(grepl('^[+-]?([0-9]+(\\.[0-9]*)?|\\.[0-9]+)([eE][+-]?[0-9]+)?$',s)) v[i]<-as.numeric(s)
      else stop('Unparsed numeric cell in ', item_name, ': ', x[i])
    }
    for(i in which(qualifier %in% c('>','≥','<','≤'))) { if(qualifier[i] %in% c('>','≥')) lo[i]<-v[i] else hi[i]<-v[i]; v[i]<-NA_real_ }
    list(value=v,lower=lo,upper=hi,uncertainty=unc,qualifier=qualifier)
  }
  final.dataframe<-data.frame(source_row=source_rows,check.names=FALSE)
  for(col in spec$columns) {
    x<-trimws(raw[[col$index]])
    if (col$type == 'number') {
      a<-parse_value(x); factor<-if(is.null(col$factor)) 1 else col$factor
      final.dataframe[[paste0(col$code,'_raw')]]<-x
      final.dataframe[[col$code]]<-a$value*factor
      if(any(!is.na(a$lower)) || any(!is.na(a$upper))) {final.dataframe[[paste0(col$code,'_lower')]]<-a$lower*factor;final.dataframe[[paste0(col$code,'_upper')]]<-a$upper*factor}
      if(any(!is.na(a$uncertainty))) final.dataframe[[paste0(col$code,'_uncertainty')]]<-a$uncertainty*factor
      if(any(nzchar(a$qualifier))) final.dataframe[[paste0(col$code,'_qualifier')]]<-a$qualifier
    } else final.dataframe[[col$code]]<-x
  }
  final.dataframe$source_item<-item_name
  final.dataframe$data_role<-spec$role
  if(!is.null(spec$species_constant)) final.dataframe$species_as_published<-spec$species_constant
  filecodes<-as.data.frame(readxl::read_excel(file.path(base,'__ReadMe.xlsx'),sheet='Sheet1', col_types='text'))
  item_encoded<-filecodes[['Item encoded']][match(item_name,filecodes[['Item name']])]
  if(length(item_encoded)!=1L || is.na(item_encoded) || !nzchar(item_encoded)) {
    stop('Registry entry missing for ',item_name)
  }
  stopifnot(identical(item_encoded,spec$item_encoded),!grepl('_$',item_encoded),nrow(final.dataframe)==spec$expected_rows)
  table_checks <- data.frame(check=character(),observed=numeric(),expected=numeric(),passed=logical())
  if(spec$folder=='Posada_Colell_2007') for(ph in c('Covered','Uncovered','Marked')) {
    code<-paste0(ph,'_count'); val<-sum(final.dataframe[[code]][final.dataframe$behaviour!='Total']); expected<-final.dataframe[[code]][final.dataframe$behaviour=='Total']; table_checks<-rbind(table_checks,data.frame(check=paste(ph,'component count sum'),observed=val,expected=expected,passed=val==expected))
  }
  if(spec$folder=='Mallavarapu__2001') table_checks<-rbind(table_checks,data.frame(check='play composition sums to 100',observed=sum(final.dataframe$Play_composition.pct),expected=100,passed=abs(sum(final.dataframe$Play_composition.pct)-100)<1e-8))
  if(nrow(table_checks)) {
    write.csv(table_checks,file.path(folder,'reference_tables',paste0(item_name,'_table_checks.csv')),row.names=FALSE)
    if(any(!table_checks$passed)) warning(item_name,': published totals do not match components; values retained unchanged')
  }
  write.csv(final.dataframe,file.path(folder,paste0(item_name,'.csv')),row.names=FALSE,na='')
  write.table(final.dataframe,file.path(base,'__Public','comparative-data',paste0(item_encoded,'.tsv')),sep='\t',row.names=FALSE,na='',qmethod='double')
  defs_file <- file.path(folder,'reference_tables',paste0(item_name,'_definitions.csv'))
  defs <- read.csv(defs_file, check.names=FALSE, colClasses='character',na.strings=NULL)
  for(nm in setdiff(names(final.dataframe), defs$Code)) {
    z <- as.list(rep('',ncol(defs))); names(z)<-names(defs); z$Code<-nm;z$Definition<-if(grepl('_raw$',nm)) 'Verbatim source cell' else if(grepl('_lower$|_upper$',nm)) 'Reported interval or censoring bound, same units as the measure' else if(grepl('_uncertainty$',nm)) 'Published plus-minus component; see item method before interpreting as SD/SEM' else 'Source metadata';z$role<-'info';z$Reference<-item_name; defs<-rbind(defs,as.data.frame(z,check.names=FALSE))
  }
  write.csv(defs,defs_file,row.names=FALSE,na='')
  message(item_name,': ',nrow(final.dataframe),' rows, CSV + public TSV')
  invisible(final.dataframe)
}
