## Extract the printed table from the local PDF into a frozen source snapshot.
me <- "Baldoni_etal_2025_Table1_snapshot.R"
args <- grep("^--file=", commandArgs(FALSE), value=TRUE)
if (!length(args) || basename(sub("^--file=", "", args[1])) != me) stop("Run this script with Rscript")
folder <- dirname(normalizePath(sub("^--file=", "", args[1])))
item_name <- sub("_snapshot\\.R$", "", me)
out <- file.path(folder, paste0(item_name, "_snapshot.csv"))
if (file.exists(out)) stop("Frozen snapshot already exists: ", out)
pdf <- list.files(folder, pattern="^Baldoni-2025.*\\.pdf$", full.names=TRUE)
if (length(pdf) != 1L) stop("Expected one source PDF")
lines <- system2("pdftotext", c("-layout", shQuote(pdf), "-"), stdout=TRUE)
start <- grep("Table 1\\. Bayesian estimates of seasonal differences in regional brain volumes", lines)
end <- grep("^Estimated seasonal differences in regional brain volumes", lines)
stopifnot(length(start)==1L, length(end)==1L, end>start)
z <- lines[(start+1L):(end-1L)]
parts <- strsplit(trimws(z), "\\s{2,}", perl=TRUE)
parts <- Filter(function(p) length(p)==5L && p[1] != "Region", parts)
stopifnot(length(parts)==13L, all(lengths(parts)==5L))
dat <- as.data.frame(do.call(rbind, parts), stringsAsFactors=FALSE)
names(dat) <- c("Region", "Estimate (Δ winter − summer)", "Est. error", "95% CI lower", "95% CI upper")
foot <- lines[end]
foot <- paste(c(foot, lines[(end+1L):(end+3L)]), collapse=" ")
dat[nrow(dat)+1L,] <- c(foot, rep("",4))
utils::write.csv(dat, out, row.names=FALSE, na="", fileEncoding="UTF-8")
