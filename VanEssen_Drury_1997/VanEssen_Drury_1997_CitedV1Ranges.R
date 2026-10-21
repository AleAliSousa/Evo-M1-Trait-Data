# Rebuild secondary ranges transcribed from Van Essen & Drury's PDF, p. 11.
source <- read.csv("VanEssen_Drury_1997_CitedV1Ranges_pdf_transcription.csv", stringsAsFactors = FALSE)
stopifnot(nrow(source) == 2L)
write.csv(source, "VanEssen_Drury_1997_CitedV1Ranges.csv", row.names = FALSE, na = "")
