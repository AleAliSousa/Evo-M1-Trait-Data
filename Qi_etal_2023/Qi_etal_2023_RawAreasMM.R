# Qi et al. 2023 Vanderbilt deposited, digital-native section area workbook.
# Each worksheet version is retained separately; no rater averaging or SI merge.
arg <- grep('^--file=',commandArgs(FALSE),value=TRUE)
if(length(arg)!=1L)stop('Run with Rscript')
script <- normalizePath(sub('^--file=','',arg))
folder <- dirname(script);root <- dirname(folder)
item <- tools::file_path_sans_ext(basename(script))
cohort <- if(endsWith(item,'MM')) 'MM' else if(endsWith(item,'SQM')) 'SQM' else stop('Unknown workbook')
book <- file.path(folder,paste0('CuN_Area_Measure_',cohort,'_RawData.xlsx'))
as_num <- function(x) suppressWarnings(as.numeric(x))
cell <- function(x,r,c) if(r>=1L && c>=1L && r<=nrow(x) && c<=ncol(x)) x[r,c] else NA_character_
letter <- function(n) {
  ans <- ''
  while(n>0L) {rem <- (n-1L) %% 26L;ans <- paste0(LETTERS[rem+1L],ans);n <- (n-1L) %/% 26L}
  ans
}
parts <- list()
sheet_names <- readxl::excel_sheets(book)
for(sheet in sheet_names) {
  x <- as.matrix(readxl::read_excel(book,sheet=sheet,col_names=FALSE,
                                    col_types='text',.name_repair='minimal'))
  nr <- nrow(x)
  top <- x[seq_len(min(nr,12L)),,drop=FALSE]
  h <- which(top=='Area',arr.ind=TRUE)
  if(nrow(h)<1L || nrow(h)>4L)stop('Unexpected Area panels in ',sheet)
  h <- h[order(h[,'col'],h[,'row']),,drop=FALSE]
  if(cohort=='SQM' && nrow(h)>2L)stop('Unexpected SQM panels in ',sheet)
  case <- sub('_.*$','',sheet)
  variant <- sub('^[^_]+_','',sheet)
  title <- cell(x,1L,1L)
  source_group <- sub('^[^ ]+ ([A-Za-z]+)_.+$','\\1',title)
  if(identical(source_group,title))source_group <- NA_character_
  sheet_rows <- list()
  for(k in seq_len(nrow(h))) {
    hr <- h[k,'row'];ac <- h[k,'col']
    expected_side <- if(k %% 2L==1L) 'left' else 'right'
    region <- if(cohort=='MM' && k>2L) 'pars rotunda' else 'internal cuneate nucleus'
    near_header <- cell(x,hr,ac-1L)
    candidate <- c(near_header,vapply(seq.int(hr+1L,min(hr+5L,nr)),
                  function(r)cell(x,r,ac-1L),character(1)))
    candidate <- candidate[!is.na(candidate) & grepl('^(L-|R-|Left|Right|Lt-|Rt-)',candidate,ignore.case=TRUE)]
    side_label <- if(length(candidate))candidate[1] else NA_character_
    label_side <- if(is.na(side_label)) NA_character_ else if(grepl('^(L-|Left|Lt-)',side_label,ignore.case=TRUE)) 'left' else 'right'
    side <- if(is.na(label_side))expected_side else if(label_side==expected_side)label_side else 'unresolved'
    side_basis <- if(is.na(label_side))'panel order; label absent' else if(side=='unresolved')'printed label conflicts with panel order' else 'printed label and panel order agree'
    obex_header <- any(grepl('D.?[Oo]bex',x[seq_len(hr),2L]),na.rm=TRUE)
    for(r in seq.int(hr+1L,nr)) {
      label <- trimws(cell(x,r,ac-1L))
      if(!is.na(label) && label %in% c('Mean','SD','Min','Max','Median','StDev'))break
      area <- as_num(cell(x,r,ac))
      if(is.na(area) || area<=0)next
      marker <- cell(x,r,ac-2L)
      if(is.na(marker) || !(is.finite(as_num(marker)) || grepl('Skipped',marker,ignore.case=TRUE)))next
      status <- if(grepl('Skipped',marker,ignore.case=TRUE) || (!is.na(label) && grepl('Avg from adjacent',label,ignore.case=TRUE))) 'source interpolated/skipped' else 'source measured'
      sheet_rows[[length(sheet_rows)+1L]] <- data.frame(
        source_sheet=sheet,sheet_variant=variant,case_as_published=case,
        workbook_group_as_published=source_group,
        source_row=r,source_area_cell=paste0(letter(ac),r),panel_order=k,
        region=region,hemisphere=side,side_label_as_published=side_label,
        side_resolution=side_basis,section_marker_as_published=marker,
        distance_from_obex_um=if(obex_header)as_num(cell(x,r,2L)) else NA_real_,
        section_status=status,area_mm2=area,
        observation_level='source section x panel x worksheet version',
        data_role='primary',source=item,check.names=FALSE)
    }
  }
  if(!length(sheet_rows))stop('No section areas extracted from ',sheet)
  parts[[length(parts)+1L]] <- do.call(rbind,sheet_rows)
}
out <- do.call(rbind,parts)
stopifnot(length(unique(out$source_sheet))==length(sheet_names),all(out$area_mm2>0))
options(scipen=999)
write.csv(out,file.path(folder,paste0(item,'.csv')),row.names=FALSE,na='',fileEncoding='UTF-8')
paths <- file.path(root,c('__ReadMe.xlsx','__ReadMeAddON.xlsx'))
hits <- lapply(paths,function(p){z<-readxl::read_excel(p,sheet='Sheet1');z[z[['Item name']]==item,,drop=FALSE]})
hits <- hits[vapply(hits,nrow,integer(1))==1L]
if(length(hits)!=1L)stop('Expected exactly one registry row')
code <- as.character(hits[[1]][['Item encoded']][1])
if(is.na(code)||!nzchar(code)||endsWith(code,'_'))stop('Invalid Item encoded')
write.table(out,file.path(root,'__Public','comparative-data',paste0(code,'.tsv')),
            sep='\t',row.names=FALSE,na='',fileEncoding='UTF-8')
cat(item,': ',nrow(out),' section-panel rows from ',length(sheet_names),' worksheets\n',sep='')
