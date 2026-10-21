# Rebuild only values transcribed from the article PDF Results text.
source <- read.csv("Mayer_etal_2019_Fig6_pdf_transcription.csv", stringsAsFactors = FALSE)
stopifnot(nrow(source) == 3L, identical(source$case_number, c("15-01", "15-03", "15-04")))
write.csv(source, "Mayer_etal_2019_Fig6.csv", row.names = FALSE, na = "")
