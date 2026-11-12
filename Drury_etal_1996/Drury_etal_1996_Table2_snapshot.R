## Drury_etal_1996_Table2_snapshot.R -- writes the frozen snapshot of Table 2 (scanned PDF).
##
## Drury, H. A., Van Essen, D. C., Anderson, C. H., Lee, C. W., Coogan, T. A., & Lewis, J. W. (1996).
##   Computerized mappings of the cerebral cortex: A multiresolution flattening method and a
##   surface-based coordinate system. Journal of Cognitive Neuroscience, 8(1), 1-28.
##   https://doi.org/10.1162/jocn.1996.8.1.1   (Table 2 on journal p. 15 = PDF page 15)
##
## Why a typed block: the PDF is a scan whose text layer garbles this table (split numbers such as
##   "94 1" for 941, label soup). The table was therefore read by eye from a 300-dpi render of PDF
##   page 15 by an AI assistant (Copilot) on 2026-11-10 and typed below as a verbatim printed-layout
##   block (the Jacobs_etal_2018_Table3_snapshot.R pattern). Second reading: every number below was
##   matched, in printed order, against the numbers in the page's OCR text layer (see the README).
## Layout kept: the table prints as two side-by-side column blocks; rows are listed in reading order,
##   left block top to bottom, then right block top to bottom (column `block`, printed line `line`).
##   Group headings keep blank value cells. Labels are as printed, including "MST1" and "S11" (the
##   typeface's l/1 and II/11; the build script maps them) and the footnote's "Fellemann".
## Frozen guard: refuses to overwrite an existing snapshot that differs from this block, unless
##   EVOM1_UNFREEZE names this item (e.g. EVOM1_UNFREEZE="Drury_etal_1996_Table2").

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  of <- tryCatch(sys.frames()[[1]]$ofile, error = function(e) NULL)
  if (is.character(of) && length(of) == 1L && nzchar(of)) return(normalizePath(of))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, source() it, or open in RStudio and Source (save first).", call. = FALSE)
})
folder    <- dirname(.sp)
item_name <- sub("_snapshot$", "", tools::file_path_sans_ext(basename(.sp)))   # Drury_etal_1996_Table2

printed <- "block|line|Cortical area|Area (mm2)|Percent of total
caption|0|Table 2. Surface Area of Cortical Subdivisions in the Macaque^a||
left|1|Visual areas||
left|2|Occipital||
left|3|V1|941|13.1
left|4|V2|691|9.6
left|5|V3|38|0.5
left|6|VP|64|0.9
left|7|V3A|54|0.7
left|8|V4|298|4.1
left|9|VOT|38|0.5
left|10|V4t|17|0.2
left|11|MT|38|0.5
left|12|Temporal||
left|13|FST|37|0.5
left|14|PITd|93|1.3
left|15|PITv|92|1.3
left|16|CITd|41|0.6
left|17|CITv|94|1.3
left|18|AITd|65|0.9
left|19|AITv|61|0.8
left|20|STPp|110|1.5
left|21|STPa|57|0.8
left|22|TF|133|1.8
left|23|TH|50|0.7
left|24|Parietal||
left|25|MSTd|53|0.7
left|26|MST1|13|0.2
left|27|PO|58|0.8
left|28|PIP|58|0.8
left|29|LIP|32|0.4
left|30|VIP|59|0.8
left|31|MIP|35|0.5
left|32|MDP|49|0.7
left|33|DPL|54|0.8
left|34|7a|87|1.2
left|35|Frontal||
left|36|FEF|94|1.3
left|37|46|122|1.7
left|38|Subtotal (visual)|3726|51.7
left|39|Somatosensory areas||
left|40|3a|72|1.0
left|41|3b|101|1.4
left|42|1|100|1.4
left|43|2|136|1.9
left|44|5|162|2.2
left|45|7b|137|1.9
left|46|S11|107|1.5
left|47|Ri|26|0.4
left|48|Ig|16|0.2
left|49|Id|16|0.2
left|50|Subtotal (somatosensory)|872|12.1
left|51|Motor areas||
left|52|4|367|5.1
left|53|6|197|2.7
left|54|SMA|88|1.2
left|55|Subtotal (motor)|652|9.1
left|56|Auditory areas||
left|57|AUD|153|2.1
left|58|A1|16|0.2
left|59|RL|20|0.3
right|1|CM|14|0.2
right|2|L|13|0.2
right|3|Pa|9|0.1
right|4|Subtotal (auditory)|224|3.1
right|5|Gustatory area||
right|6|G|19|0.3
right|7|Prefrontal areas||
right|8|9|139|1.9
right|9|10|144|2.0
right|10|11|24|0.3
right|11|12|19|0.3
right|12|13|37|0.5
right|13|14|64|0.9
right|14|25|45|0.6
right|15|32|27|0.4
right|16|45|39|0.5
right|17|Subtotal (prefrontal)|538|7.5
right|18|Cingulate areas||
right|19|23|135|1.9
right|20|24|176|2.4
right|21|29|25|0.3
right|22|30|34|0.5
right|23|Ps|7|0.1
right|24|Perirhinal areas||
right|25|35|41|0.6
right|26|36|73|1.0
right|27|Unspecified cortex|357|5.0
right|28|Subtotal (neocortex)|6878|95.5
right|29|Hippocampal formation||
right|30|S|42|0.6
right|31|CA1|59|0.8
right|32|CA3|35|0.5
right|33|Transitional areas||
right|34|PrS|26|0.4
right|35|PaS|19|0.3
right|36|ER|67|0.9
right|37|Pro|34|0.5
right|38|Pall|7|0.1
right|39|Paleocortex||
right|40|PAC|29|0.4
right|41|PIR|9|0.1
right|42|Total non-neocortex|327|4.5
right|43|Total cerebral cortex|7205|100.0
footnote|0|^a Surface areas of different functional subdivisions of the cerebral cortex, expressed as absolute surface area (column 2) and as a percentage of total cortical surface area (column 3). These values accurately represent the surface area within the intact cortex, given the particular border assignments made on the model of the hemisphere (Fellemann & Van Essen, 1991). We also calculated the surface areas on the two-dimensional map for all of these areas. The two-dimensional estimates were inaccurate by only a few percent for most cortical areas. The inaccuracies were substantially larger (more than 20%) for four areas (V3, V3A, PIP, and FEF), which are located in particularly convoluted regions that contained large residual distortions in the final map.||"

snap <- read.table(text = printed, sep = "|", header = TRUE, quote = "", comment.char = "",
                   colClasses = "character", check.names = FALSE, na.strings = character(0))
out_file <- file.path(folder, paste0(item_name, "_snapshot.csv"))
tmp <- tempfile(fileext = ".csv")
write.csv(snap, tmp, row.names = FALSE, fileEncoding = "UTF-8")
if (file.exists(out_file) && !identical(readLines(out_file, encoding = "UTF-8"), readLines(tmp, encoding = "UTF-8"))) {
  if (!identical(Sys.getenv("EVOM1_UNFREEZE"), item_name))
    stop(basename(out_file), " is frozen and differs from this block; not overwritten. ",
         "Set EVOM1_UNFREEZE=\"", item_name, "\" to replace it on purpose.", call. = FALSE)
}
if (!file.exists(out_file) || !identical(readLines(out_file, encoding = "UTF-8"), readLines(tmp, encoding = "UTF-8"))) {
  file.copy(tmp, out_file, overwrite = TRUE)
  message(item_name, ": snapshot written (", nrow(snap), " printed rows)")
} else message(item_name, ": snapshot unchanged (", nrow(snap), " printed rows)")
