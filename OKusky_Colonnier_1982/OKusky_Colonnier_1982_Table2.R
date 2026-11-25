a <- grep('^--file=',commandArgs(FALSE),value=TRUE)
if (!length(a)) stop('Run with Rscript')
folder <- dirname(normalizePath(sub('^--file=','',a[1])))
item_name <- tools::file_path_sans_ext(basename(sub('^--file=','',a[1])))
root <- dirname(folder)
s <- utils::read.csv(file.path(folder,paste0(item_name,'_snapshot.csv')),check.names=FALSE,colClasses='character',na.strings='',fileEncoding='UTF-8')
num <- function(x) as.numeric(gsub(',','',x,fixed=TRUE))
p <- s[grepl('^[mf][0-9]+$',s[['Right specimen']]),]
r <- data.frame(source_order=seq_len(nrow(p)),specimen=p[['Right specimen']],hemisphere='right',species_label_in_article=p$Group,Species=p$Group,area17_surface_mm2=num(p[['Right surface (mm²)']]),stringsAsFactors=FALSE)
l <- p[grepl('^[mf][0-9]+$',p[['Left specimen']]),]
l <- data.frame(source_order=match(l[['Left specimen']],p[['Right specimen']])+0.5,specimen=l[['Left specimen']],hemisphere='left',species_label_in_article=l$Group,Species=l$Group,area17_surface_mm2=num(l[['Left surface (mm²)']]),stringsAsFactors=FALSE)
final.dataframe <- rbind(r,l); final.dataframe <- final.dataframe[order(final.dataframe$source_order),]
pooled <- s[grepl('^Average of 7',s[['Right specimen']]),'Right surface (mm²)']
printed_pooled_mean <- num(strsplit(pooled,' ± ',fixed=TRUE)[[1]][1])
stopifnot(nrow(final.dataframe)==7L,abs(mean(final.dataframe$area17_surface_mm2)-printed_pooled_mean)<0.01)
utils::write.csv(final.dataframe,file.path(folder,paste0(item_name,'.csv')),row.names=FALSE,na='',fileEncoding='UTF-8')
reg <- readxl::read_excel(file.path(root,'__ReadMeAddON.xlsx'),sheet='Sheet1')
hit <- which(reg[['Item name']]==item_name)
if(length(hit)!=1L) stop('Expected one AddON registry row')
encoded <- as.character(reg[['Item encoded']][hit])
utils::write.table(final.dataframe,file.path(root,'__Public','comparative-data',paste0(encoded,'.tsv')),sep='	',row.names=FALSE,na='',fileEncoding='UTF-8')
cat(item_name,': ',nrow(final.dataframe),' rows
',sep='')
