# Ricklefs__2010_taxonomy_check.R
#
# QA (not a build): compares the printed Order / Family / binomial of SI Appendices 4 and 6 with AnAge
# Build 15 (deMagalhães_etal_2024_anagedata.txt.csv) and with each other. Writes
# reference_tables/Ricklefs__2010_taxonomy_check.csv, one row per printed (appendix, section, Order,
# Family, Genus, Species). Clear misplacements are recorded as errata (Ricklefs__2010_errata.csv); the
# rest (bird ordinal scheme of Sibley & Ahlquist, older family names, misspellings) are listed here only.
item_dir <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) dirname(normalizePath(sub("^--file=", "", a[1]))) else dirname(rstudioapi::getActiveDocumentContext()$path)
})
root   <- dirname(item_dir)
folder <- basename(item_dir)
an <- read.csv(file.path(root, "deMagalhães_etal_2024", "deMagalhães_etal_2024_anagedata.txt.csv"),
               colClasses = "character", encoding = "UTF-8")
an$binomial <- paste(an$Genus, an$Species)
gen <- aggregate(cbind(Order, Family) ~ Genus, unique(an[, c("Genus", "Order", "Family")]),
                 function(x) paste(unique(x), collapse = "/"))
snaps <- lapply(c(Appendix4 = "Appendix4", Appendix6 = "Appendix6"), function(it)
  read.csv(file.path(item_dir, paste0(folder, "_", it, "_snapshot.csv")), check.names = FALSE,
           colClasses = "character", encoding = "UTF-8"))
out <- do.call(rbind, lapply(names(snaps), function(it) {
  u <- unique(snaps[[it]][, c("section", "Order", "Family", "Genus", "Species")])
  u$appendix <- it; u$binomial <- paste(u$Genus, u$Species)
  other <- snaps[[setdiff(names(snaps), it)]]
  u$in_other_appendix <- u$binomial %in% paste(other$Genus, other$Species)
  i <- match(u$binomial, an$binomial)
  u$AnAge_match <- ifelse(!is.na(i), "binomial", ifelse(u$Genus %in% gen$Genus, "genus only", "none"))
  g <- match(u$Genus, gen$Genus)
  u$AnAge_Order  <- ifelse(!is.na(i), an$Order[i],  gen$Order[g])
  u$AnAge_Family <- ifelse(!is.na(i), an$Family[i], gen$Family[g])
  u$order_differs  <- !is.na(u$AnAge_Order)  & !mapply(function(a, b) a %in% strsplit(b, "/")[[1]], u$Order,  u$AnAge_Order)
  u$family_differs <- !is.na(u$AnAge_Family) & !mapply(function(a, b) a %in% strsplit(b, "/")[[1]], u$Family, u$AnAge_Family)
  u[, c("appendix", "section", "Order", "Family", "Genus", "Species", "in_other_appendix", "AnAge_match",
        "AnAge_Order", "AnAge_Family", "order_differs", "family_differs")]
}))
write.csv(out, file.path(item_dir, "reference_tables", paste0(folder, "_taxonomy_check.csv")), row.names = FALSE, fileEncoding = "UTF-8")
print(with(out, table(appendix, AnAge_match)))
print(aggregate(cbind(order_differs, family_differs) ~ appendix + section, out, sum))
