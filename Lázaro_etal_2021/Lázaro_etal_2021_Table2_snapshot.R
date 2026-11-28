## Freeze the printed 114-row Table 2 from the exact local PDF.
a <- grep("^--file=",commandArgs(FALSE),value=TRUE)
if (!length(a)) stop("Run with Rscript")
folder <- dirname(normalizePath(sub("^--file=","",a[1])))
item_name <- "Lázaro_etal_2021_Table2"
target <- file.path(folder,paste0(item_name,"_snapshot.csv"))
if(file.exists(target)) stop("Frozen snapshot exists; refusing overwrite")
pages <- pdftools::pdf_text(file.path(folder,"Lazaro-2021-Geographic patterns in seasonal ch.pdf"))
lines <- unlist(strsplit(paste(pages[5:7],collapse="\n"),"\n",fixed=TRUE))
sections <- c("Brain case height decrease","Brain case height regrowth","Brain mass decrease","Brain mass regrowth","Body mass decrease","Body mass regrowth")
section <- NA_character_;rows <- list()
for(line in lines) {
 t <- trimws(line)
 if(t %in% sections) section <- t
 pieces <- trimws(strsplit(t," {2,}",perl=TRUE)[[1]])
 pieces <- pieces[nzchar(pieces)]
 if(length(pieces)==6L && grepl("^[0-9]+[.][0-9]+$",pieces[2]) && pieces[6]%in%c("No","Positive","Negative"))
  rows[[length(rows)+1L]] <- c(section,pieces)
}
if(length(rows)!=114L)stop("Expected 114 Table 2 result rows; found ",length(rows))
s <- as.data.frame(do.call(rbind,rows),stringsAsFactors=FALSE)
grid <- list(c("Table 2. Results from linear models testing correlation between intensity of Dehnel's Phenomenon and climate variables",rep("",5)),
             c("","F","DF","Adj-R2","P","correlation"))
previous <- ""
for(i in seq_len(nrow(s))) {
  if(s[[1]][i]!=previous) {
    previous <- s[[1]][i]
    grid[[length(grid)+1L]] <- c(previous,rep("",5))
  }
  grid[[length(grid)+1L]] <- as.character(s[i,2:7])
  if(i %in% c(42L,85L)) {
    grid[[length(grid)+1L]] <- c("(Continues)",rep("",5))
    grid[[length(grid)+1L]] <- c("Table 2 (Continued)",rep("",5))
    grid[[length(grid)+1L]] <- c("","F","DF","Adj-R2","P","correlation")
  }
}
utils::write.table(do.call(rbind,grid),target,sep=",",row.names=FALSE,col.names=FALSE,
                   quote=TRUE,na="",fileEncoding="UTF-8")
cat("Frozen",nrow(s),"Table 2 model-result rows in printed section and page layout\n")
