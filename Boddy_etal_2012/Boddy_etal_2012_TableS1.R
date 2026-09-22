
## Boddy et al. 2012 Table S1
## Input  : jeb_2491_sm_tables1.xlsx (treated as frozen snapshot)
## Output : Boddy_etal_2012_TableS1.csv
##          <Item encoded>.tsv in __Public/comparative-data/

library(readxl)

.sp <- local({
  a <- grep('^--file=', commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub('^--file=', '', a[1])))
  stop('Run with Rscript file.R', call.=FALSE)
})
folder <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
setwd(folder)

snap <- read_excel('jeb_2491_sm_tables1.xlsx')
clean <- as.data.frame(snap, stringsAsFactors = FALSE)
clean$source <- 'Boddy_etal_2012_TableS1'

write.csv(clean, paste0(item_name, '.csv'), row.names = FALSE)

base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, '__ReadMe.xlsx'))) d <- dirname(d)
  if (file.exists(file.path(d, '__ReadMe.xlsx'))) d else NA_character_
})

if (!is.na(base)) {
  fc <- readxl::read_excel(file.path(base,'__ReadMe.xlsx'))
  item_encoded <- fc$`Item encoded`[match(item_name, fc$`Item name`)]
  if (!is.na(item_encoded) && nzchar(item_encoded)) {
    write.table(clean,
      file.path(base,'__Public','comparative-data', paste0(item_encoded,'.tsv')),
      sep='	', row.names=FALSE, quote=TRUE)
  }
}
