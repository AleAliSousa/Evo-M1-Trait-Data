# Figure 2 top-left plotted coordinates from the paper's printed Table 1.
# The frozen Table1-a_snapshot.xlsx is the source; no plotted values are hand-entered here.
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value=TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  stop("Run with Rscript Figure2TopLeft.R", call.=FALSE)
})
folder <- dirname(.sp)
repo <- dirname(folder)
library(readxl)
snap <- as.data.frame(read_excel(file.path(folder, "HerculanoHouzel_etal_2013_Table1-a_snapshot.xlsx"), sheet="Table1a", .name_repair="minimal"), check.names=FALSE)
snap <- snap[snap$Area != "Total", ]
stopifnot(nrow(snap)==18L, !anyDuplicated(snap$Area))
# Abbreviations printed beside the Figure 2 points; values come from Table 1.
area <- c(par="Parietal", il="Infralimbic", fr="Frontal", orb="Orbital",
          ect="Ectorhinal", c="Cingulate", V2L="V2L", V2M="V2M",
          S2="S2", ins="Insula", rs="Retrosplenial", `S1l`="S1-limb",
          a="Auditory", ent="Entorhinal", pir="Piriform", m="Motor",
          V1="V1", `S1f`="S1-face")
stopifnot(length(area)==18L, setequal(unname(area), snap$Area))
s <- snap[match(unname(area), snap$Area), ]
number <- function(x) as.numeric(gsub(",", "", sub("\\s*±.*", "", as.character(x))))
neurons <- number(s$Neurons_mean_SEM)
density <- as.numeric(s$N_per_mm3)
stopifnot(all(is.finite(neurons)), all(is.finite(density)), all(density>0))
out <- data.frame(region=names(area), neurones=neurons,
                  `vol mm^3`=neurons/density, check.names=FALSE)
write.csv(out, file.path(folder,"HerculanoHouzel_etal_2013_Figure2TopLeft.csv"), row.names=FALSE, na="")
registry <- read_excel(file.path(repo,"__ReadMe.xlsx"), sheet="Sheet1")
item <- "HerculanoHouzel_etal_2013_Figure2TopLeft"
encoded <- registry$`Item encoded`[match(item,registry$`Item name`)]
stopifnot(length(encoded)==1L, !is.na(encoded), nzchar(encoded))
write.table(out, file.path(repo,"__Public","comparative-data",paste0(encoded,".tsv")),
            sep="\t",row.names=FALSE,na="",quote=FALSE)
message("Built ",nrow(out)," Figure 2 coordinates from frozen Table 1")
