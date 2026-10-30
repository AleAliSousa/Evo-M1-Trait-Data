# Rebuild from values transcribed directly from the article PDF Results text.
source <- read.csv("Young_etal_2013_ResultsTextSurface_pdf_transcription.csv", stringsAsFactors = FALSE)
stopifnot(nrow(source) == 8L)
write.csv(source, "Young_etal_2013_ResultsTextSurface.csv", row.names = FALSE, na = "")
