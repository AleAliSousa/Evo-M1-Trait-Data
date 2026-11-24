## Publisher supplementary table -> secondary meta-analysis CSV and public TSV.
a <- grep('^--file=', commandArgs(FALSE), value=TRUE)
if (!length(a)) stop('Run with Rscript')
folder <- dirname(normalizePath(sub('^--file=', '', a[1])))
item_name <- tools::file_path_sans_ext(basename(sub('^--file=', '', a[1])))
root <- dirname(folder)
table_no <- as.integer(sub('^.*_TableS', '', item_name))
stopifnot(table_no %in% 3:6)
snapshot <- file.path(folder, paste0(item_name, '_snapshot.xlsx'))
s <- readxl::read_excel(snapshot, sheet=paste0('Table S',table_no),
                        skip=1, col_types='text')
stopifnot(ncol(s)==7L,
          nrow(s)==c(`3`=21L,`4`=12L,`5`=21L,`6`=12L)[as.character(table_no)],
          identical(names(s)[c(1,2,4:7)],
                    c('Species','Number of studies','Lower 95% CI',
                      'Upper 95% CI','Z-value','p-value')),
          names(s)[3]==if(table_no==6L) 'Point stimate' else 'Point estimate')
num <- function(x) as.numeric(gsub(',', '.', x, fixed=TRUE))
index_type <- if (table_no %in% 3:4) 'signed mean handedness index (MHI)' else
  'mean absolute handedness index (MABSHI)'
task <- if (table_no %in% c(3,5)) 'tube task' else 'other coordinated bimanual tasks'
bound_low <- if (table_no %in% 3:4) -1 else 0
point <- num(s[[3]])
lower <- num(s[[4]])
upper <- num(s[[5]])
p_text <- s[[7]]
p_op <- ifelse(startsWith(p_text,'<'),'<','=')
p_numeric <- num(sub('^<','',p_text))
final.dataframe <- data.frame(
  source_row=seq_len(nrow(s)), source_table=paste0('Table S',table_no),
  species_as_published=s[[1]], Species=s[[1]],
  number_of_studies=as.integer(s[[2]]),
  task_type=task, index_type=index_type,
  meta_analytic_point_estimate=point,
  lower_95_CI=lower, upper_95_CI=upper,
  z_value=num(s[[6]]), p_value_as_published=p_text,
  p_value_operator=p_op, p_value_bound=p_numeric,
  point_outside_index_scale=point<bound_low | point>1,
  CI_outside_index_scale=lower<bound_low | upper>1,
  observation_level='species moderator estimate from meta-analysis',
  data_role='secondary; study samples overlap other compilations',
  stringsAsFactors=FALSE)
stopifnot(!anyNA(final.dataframe[,c('number_of_studies',
              'meta_analytic_point_estimate','lower_95_CI','upper_95_CI',
              'z_value','p_value_bound')]),
          all(final.dataframe$number_of_studies>=1L),
          all(lower<=point & point<=upper),
          all(p_numeric>=0 & p_numeric<=1))
utils::write.csv(final.dataframe,file.path(folder,paste0(item_name,'.csv')),
                 row.names=FALSE,na='',fileEncoding='UTF-8')
reg <- readxl::read_excel(file.path(root,'__ReadMeAddON.xlsx'),sheet='Sheet1')
hit <- which(reg[['Item name']]==item_name)
if(length(hit)!=1L) stop('Expected one AddON registry row')
item_encoded <- as.character(reg[['Item encoded']][hit])
utils::write.table(final.dataframe,
  file.path(root,'__Public','comparative-data',paste0(item_encoded,'.tsv')),
  sep='\t',row.names=FALSE,na='',fileEncoding='UTF-8')
cat(item_name,': ',nrow(final.dataframe),' secondary species estimates; ',
    sum(final.dataframe$point_outside_index_scale),' point estimates outside scale\n',sep='')
