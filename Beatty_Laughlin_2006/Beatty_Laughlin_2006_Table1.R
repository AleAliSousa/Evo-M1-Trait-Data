# Beatty_Laughlin_2006_Table1.R
#
# Beatty J, Laughlin RE (2006). Genomic regulation of natural variation in
# cortical and noncortical brain volume. BMC Neuroscience 7: 16.
# doi:10.1186/1471-2202-7-16 (PMID 16503985; PMCID PMC1402304)
#
# Item: Table 1 -- neocortical (cortical) and non-cortical brain volumes
# (mm3) for 34 BXD recombinant inbred mouse strains and the parental
# strains C57BL/6J and DBA/2J (strain means, N = 3-5).
#
# Frozen sources in this folder: the publisher PDF (1471-2202-7-16.pdf),
# the Europe PMC full-text XML (fulltext.xml, the machine-readable copy
# this transcription was taken from), and the publisher's supplementary
# figure files. The article has NO supplementary data files; all data are
# in the main-text tables.
#
# Data role: PRIMARY. The volumes are the authors' own measurements.
# In-vivo values are shrinkage-corrected by the authors; non-cortical
# volume = total - cortical, with total from fresh brain weight at
# specific gravity ~1.00. The "Regressed" columns are size-corrected
# values for QTL mapping (derived) and must not be pooled with volumes.
#
# Outputs:
#   Beatty_Laughlin_2006_Table1.csv               (this folder)
#   ../__Public/comparative-data/10.1186%2F1471-2202-7-16_Table1.tsv (for __Public/comparative-data/)
#
# Registry note: the public TSV name is the expected Item encoded
# (10.1186%2F1471-2202-7-16_Table1). The registry row was added on 2026-11-18; descriptive metadata remain incomplete.

tab <- read.csv(text = "
Strain,N,Cortical_volume_mm3_in_vivo,Noncortical_volume_mm3_in_vivo,Cortical_volume_mm3_regressed,Noncortical_volume_mm3_regressed
C57BL/6J,4,115.59,362.01,123.27,296.84
DBA/2J,4,91.92,293.81,104.63,245.17
BXD1,5,118.47,337.57,126.78,291.27
BXD2,5,99.58,340.76,106.36,274.38
BXD5,5,125.11,391.73,136.07,343.66
BXD6,4,90.41,289.17,103.1,253
BXD8,5,101.54,313.72,111.48,260.54
BXD9,3,107.47,324.06,117.53,278.23
BXD11,3,108.96,311.68,121.34,277.88
BXD12,5,105.06,338.96,114.15,281.95
BXD13,5,103.77,316.63,110.28,259.95
BXD14,5,103.47,340.79,111.53,276.46
BXD15,3,119.99,331.91,128.03,261.79
BXD16,5,115.06,343.66,121.32,285.37
BXD18,4,103.33,317.7,112.84,261.64
BXD19,4,90.66,324.69,101.64,279.25
BXD20,4,97.1,300.73,107.85,254.04
BXD21,4,111.76,320.44,122.58,273.95
BXD22,5,108.19,342.91,116.05,283.27
BXD23,5,100.65,328.09,112.47,283.28
BXD24,4,99.81,310.74,108.36,254.49
BXD25,5,99.65,293.39,113.57,264.54
BXD27,4,93.83,266.62,105.01,214.3
BXD28,4,89,304.6,97.9,255.09
BXD29,4,84.53,295.47,96.48,252.27
BXD30,4,77.29,269.43,90.87,237.01
BXD31,3,95.4,312.87,103.1,252.95
BXD32,3,99.07,357.4,106.77,289.71
BXD33,5,102.47,317.51,110.98,273.87
BXD34,5,101.59,309.03,106.29,249.39
BXD35,4,105.73,313.2,114.86,268.98
BXD36,5,102.7,301.32,113.49,261.82
BXD38,4,98.36,307.59,108.29,266.48
BXD39,5,101.14,307.1,108.94,261.01
BXD40,5,100.47,325.27,111.04,286.65
BXD42,4,101.05,352.17,108.89,303.33
", stringsAsFactors = FALSE)
tab$species_sci <- "Mus musculus"
tab <- tab[, c("species_sci","Strain","N","Cortical_volume_mm3_in_vivo",
  "Noncortical_volume_mm3_in_vivo","Cortical_volume_mm3_regressed",
  "Noncortical_volume_mm3_regressed")]

stopifnot(nrow(tab) == 36)
c57 <- tab[tab$Strain == "C57BL/6J", ]
stopifnot(c57$Cortical_volume_mm3_in_vivo == 115.59,
          c57$Noncortical_volume_mm3_in_vivo == 362.01)

write.csv(tab, "Beatty_Laughlin_2006_Table1.csv", row.names = FALSE)
write.table(tab, "../__Public/comparative-data/10.1186%2F1471-2202-7-16_Table1.tsv",
            sep = "\t", row.names = FALSE, quote = FALSE)
