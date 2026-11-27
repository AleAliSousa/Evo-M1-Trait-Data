## Extract only printed Table 1 on PDF pp. 3–4; preserve source strings/order.
a <- grep("^--file=", commandArgs(FALSE), value=TRUE)
if (!length(a)) stop("Run with Rscript <script>.R",call.=FALSE)
sp <- normalizePath(sub("^--file=", "", a[1]))
folder <- dirname(sp)
item <- sub("_snapshot\\.R$", "", basename(sp))
pdf <- file.path(folder,"Plavcan-1997-Interpreting hominid behavior on.pdf")
pages <- pdftools::pdf_text(pdf)[3:4]
lines <- strsplit(paste(pages,collapse="\n"),"\n",fixed=TRUE)[[1]]
rows <- grep("^[A-Z][a-z]+ [a-z]+[[:space:]]+[0-9]",lines,value=TRUE)
stopifnot(length(rows)==87L)
parsed <- lapply(rows,function(x) {
  name <- sub("^([A-Z][a-z]+ [a-z]+)[[:space:]]+.*$","\\1",x)
  vals <- strsplit(trimws(sub("^[A-Z][a-z]+ [a-z]+[[:space:]]+","",x)),
                   "[[:space:]]+")[[1]]
  stopifnot(length(vals)==13L,grepl("^[0-9]+·[0-9]+$",vals[1]),
            grepl("^[1-4]$|^[–—]$",vals[13]))
  c(name,vals)
})
headers <- c("Species","Weight M (kg)","Weight F (kg)","Weight dim",
  "Mandibular dim MD","Mandibular dim BL","Mandibular dim Height",
  "Maxillary dim MD","Maxillary dim BL","Maxillary dim Height",
  "Male MD","Male BL","Male Height","Comp")
snap <- as.data.frame(do.call(rbind,parsed),stringsAsFactors=FALSE,
                      check.names=FALSE)
names(snap) <- headers
stopifnot(nrow(snap)==87L,identical(snap$Species[1],"Cercocebus albigena"),
          identical(tail(snap$Species,1),"Saguinus oedipus"))
dest <- file.path(folder,paste0(item,"_snapshot.csv"))
tmp <- tempfile(fileext=".csv")
write.csv(snap,tmp,row.names=FALSE,na="",fileEncoding="UTF-8")
if (file.exists(dest)) {
  stopifnot(identical(readBin(dest,"raw",n=file.info(dest)$size),
                      readBin(tmp,"raw",n=file.info(tmp)$size)))
  message("Frozen snapshot matches PDF extraction: ",dest)
} else {
  file.copy(tmp,dest)
  message("Frozen snapshot created: ",dest)
}
unlink(tmp)
