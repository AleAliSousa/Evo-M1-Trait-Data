## Freeze the printed 24-row Table 1 from the exact local PDF.
a <- grep("^--file=",commandArgs(FALSE),value=TRUE)
if (!length(a)) stop("Run with Rscript")
folder <- dirname(normalizePath(sub("^--file=","",a[1])))
item_name <- "Lázaro_etal_2021_Table1"
target <- file.path(folder,paste0(item_name,"_snapshot.csv"))
if(file.exists(target)) stop("Frozen snapshot exists; refusing overwrite")
pages <- pdftools::pdf_text(file.path(folder,"Lazaro-2021-Geographic patterns in seasonal ch.pdf"))
lines <- strsplit(pages[9],"\n",fixed=TRUE)[[1]]
sections <- c("Brain case height decrease","Brain case height regrowth","Brain mass decrease","Brain mass regrowth","Body mass decrease","Body mass regrowth")
section <- NA_character_;rows <- list()
for(line in lines) {
 for (candidate in sections) if(grepl(candidate,line,fixed=TRUE) && length(rows)<24L) section <- candidate
 pieces <- trimws(strsplit(trimws(line)," {2,}",perl=TRUE)[[1]])
 pieces <- pieces[nzchar(pieces)]
 if(length(pieces)>=7L && grepl("^[0-9]+[.][0-9]+$",pieces[length(pieces)-5L]) && tail(pieces,1L)%in%c("No","Positive","Negative")) {
  rows[[length(rows)+1L]] <- c(section,tail(pieces,7L))
  if(length(rows)==24L) break
 }
}
if(length(rows)!=24L)stop("Expected 24 Table 1 result rows")
s <- as.data.frame(do.call(rbind,rows),stringsAsFactors=FALSE)
grid <- list(c("Table 1. Results from linear models to test correlation between intensity of Dehnel's Phenomenon and geographic variables",rep("",7)),
             c("","","F","SW","DF","Adj-R2","p","correlation"))
previous <- ""
for(i in seq_len(nrow(s))) {
  if(s[[1]][i]!=previous) {
    previous <- s[[1]][i]
    grid[[length(grid)+1L]] <- c(previous,rep("",7))
  }
  grid[[length(grid)+1L]] <- c("",as.character(s[i,2:8]))
}
grid[[length(grid)+1L]] <- c("Note: SW = P-value from Shapiro-Wilk test for normality of residuals distribution. DF = degrees of freedom.",rep("",7))
utils::write.table(do.call(rbind,grid),target,sep=",",row.names=FALSE,col.names=FALSE,
                   quote=TRUE,na="",fileEncoding="UTF-8")
cat("Frozen",nrow(s),"Table 1 model-result rows in printed section layout\n")
