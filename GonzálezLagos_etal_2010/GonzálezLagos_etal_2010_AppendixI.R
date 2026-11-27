args <- grep('^--file=',commandArgs(FALSE),value=TRUE)
stopifnot(length(args)==1L)
folder <- dirname(normalizePath(sub('^--file=','',args[1])))
root <- dirname(folder)
item <- 'GonzálezLagos_etal_2010_AppendixI'
s <- read.csv(file.path(folder,paste0(item,'_snapshot.csv')),stringsAsFactors=FALSE,check.names=FALSE)
a <- read.csv(file.path(root,'_checks','gonzalez_lagos_appendixI_source_audit_2026-11-26.csv'),stringsAsFactors=FALSE,check.names=FALSE)
stopifnot(nrow(s)==43L,nrow(a)==43L,identical(s$source_id,a$source_id),
          !anyDuplicated(s$source_id),all(nzchar(s$citation_as_printed_normalized_linewrap)))
out <- data.frame(source_order=seq_len(nrow(s)),source_id=s$source_id,
                  citation_as_printed_normalized_linewrap=s$citation_as_printed_normalized_linewrap,
                  year_as_transcribed=s$year,
                  local_coverage_status=a$status,
                  verified_folder=a$verified_folder,
                  verified_brain_item_csv=a$verified_brain_item_csv,
                  evidence_or_next_action=a$evidence_or_next_action,
                  stringsAsFactors=FALSE)
write.csv(out,file.path(folder,paste0(item,'.csv')),row.names=FALSE,na='',fileEncoding='UTF-8')
reg <- readxl::read_excel(file.path(root,'__ReadMe.xlsx'),sheet='Sheet1')
hit <- which(!is.na(reg[['Item name']]) & reg[['Item name']]==item)
stopifnot(length(hit)==1L)
code <- reg[['Item encoded']][hit]
write.table(out,file.path(root,'__Public','comparative-data',paste0(code,'.tsv')),
            sep='\t',row.names=FALSE,na='',fileEncoding='UTF-8')
cat(item,':',nrow(out),'references ->',code,'\n')
