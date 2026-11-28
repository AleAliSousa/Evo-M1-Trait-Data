## Extract the printed table from the local PDF into a frozen source snapshot.
me <- "deRooij_etal_2016_Table2_snapshot.R"
args <- grep("^--file=", commandArgs(FALSE), value=TRUE)
if (!length(args) || basename(sub("^--file=", "", args[1])) != me) stop("Run this script with Rscript")
folder <- dirname(normalizePath(sub("^--file=", "", args[1])))
item_name <- sub("_snapshot\\.R$", "", me)
out <- file.path(folder, paste0(item_name, "_snapshot.csv"))
if (file.exists(out)) stop("Frozen snapshot already exists: ", out)
pdf <- list.files(folder, pattern="^de Rooij-2016.*\\.pdf$", full.names=TRUE)
if (length(pdf) != 1L) stop("Expected one source PDF")
lines <- system2("pdftotext", c("-layout", shQuote(pdf), "-"), stdout=TRUE)
start <- grep("^Table 2 Volumetric head and brain characteristics", lines)
end <- grep("^Table 3 DTI and FLAIR", lines)
stopifnot(length(start)==1L, length(end)==1L, end>start)
z <- lines[(start+1L):(end-1L)]
z <- z[grepl("^\\s*(Males \\(n\\)|Females \\(n\\)|Head circumference|Adult head|ICV|TBV|Total ventricular|Total grey|Total white|Cortical thickness)", z, perl=TRUE)]
parts <- strsplit(trimws(z), "\\s{2,}", perl=TRUE)
stopifnot(length(parts)==20L, all(lengths(parts) %in% c(5L,6L)))
dat <- as.data.frame(do.call(rbind, lapply(parts, function(p) c(p,rep("",6L-length(p))))), stringsAsFactors=FALSE)
names(dat) <- c("Measure", "Born before", "In early gestation", "Conceived after", "Total (SD)", "P")
foot <- grep("^Data are given in means \\(SD\\); P-values for difference between the exposed", lines, value=TRUE)
stopifnot(length(foot)>=1L)
dat[nrow(dat)+1L,] <- c(foot[1],rep("",5))
grid <- rbind(c("", "Exposure to famine", "", "", "", ""), names(dat), as.matrix(dat))
utils::write.table(grid, out, sep=",", row.names=FALSE, col.names=FALSE,
                   quote=TRUE, na="", fileEncoding="UTF-8")
