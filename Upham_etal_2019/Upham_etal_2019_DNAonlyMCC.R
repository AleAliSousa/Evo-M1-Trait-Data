# Upham et al. 2019 (MamPhy v1) DNA-only MCC tree -> tip inventory CSV + public TSV
# The frozen source is the untouched .tre download (digital-native: no _snapshot).
# A tree is not a table, so what gets databased is its TIP SET, one row per tip.
# House pipeline: frozen source -> clean here -> CSV + DOI-coded TSV.

suppressWarnings(suppressMessages({library(ape); library(readxl)}))

repo <- "~/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data"
if (dir.exists(repo)) setwd(repo)
folder    <- "Upham_etal_2019"
item_name <- "Upham_etal_2019_DNAonlyMCC"

# ---- read frozen source ------------------------------------------------------
f <- list.files(folder, pattern = "\\.(tre|nwk|newick|nex|tree)$",
                full.names = TRUE, ignore.case = TRUE)
if (!length(f))
  stop("No .tre in ", folder, "/ -- see ", folder, "/", folder, ".README.md for the\n",
       "  exact file to download (MamPhy_fullPosterior_BDvr_DNAonly_4098sp_",
       "topoFree_NDexp_MCC_v2_target.tre).")
src <- f[1]
txt <- readLines(src, warn = FALSE)
tr  <- if (any(grepl("#NEXUS", txt, ignore.case = TRUE))) read.nexus(src) else read.tree(src)
if (inherits(tr, "multiPhylo")) { warning("multiple trees; using the first"); tr <- tr[[1]] }

# ---- parse tip labels: Genus_species_FAMILY_ORDER ---------------------------
parts <- strsplit(tr$tip.label, "_+")
pick  <- function(i) vapply(parts, function(v) if (length(v) >= i) v[i] else NA_character_,
                            character(1))
genus <- pick(1); epithet <- pick(2)
species_sci <- ifelse(is.na(epithet), genus, paste(genus, epithet))
fam_tip <- pick(3); ord_tip <- pick(4)
tidy_case <- function(x) ifelse(is.na(x), NA_character_,
                                paste0(toupper(substring(x, 1, 1)),
                                       tolower(substring(x, 2))))

# terminal branch lengths + root-to-tip age
edge_len <- setNames(tr$edge.length, tr$edge[, 2])
term_bl  <- unname(edge_len[as.character(seq_len(Ntip(tr)))])
r2t      <- node.depth.edgelength(tr)[seq_len(Ntip(tr))]

# ---- which tips are ours? ----------------------------------------------------
ref <- read.csv("_keys/species_reference.csv", stringsAsFactors = FALSE,
                encoding = "UTF-8")$accepted_name
in_project <- tolower(species_sci) %in% tolower(trimws(ref))

df <- data.frame(
  tip_label             = tr$tip.label,
  species_sci           = species_sci,
  Genus                 = genus,
  Family_tip            = tidy_case(fam_tip),
  Order_tip             = tidy_case(ord_tip),
  terminal_branch_length = term_bl,
  root_to_tip_age        = r2t,
  in_project             = in_project,
  stringsAsFactors = FALSE)
df <- df[order(df$Order_tip, df$Family_tip, df$species_sci), ]

# ---- write analysis CSV + DOI-coded public TSV -------------------------------
write.csv(df, file.path(folder, paste0(item_name, ".csv")),
          row.names = FALSE, fileEncoding = "UTF-8")

filecodes    <- tryCatch(read_excel("__ReadMe.xlsx", sheet = "Sheet1"),
                         error = function(e) NULL)
item_encoded <- if (!is.null(filecodes))
  filecodes$"Item encoded"[match(item_name, filecodes$"Item name")] else NA
if (is.na(item_encoded)) {
  item_encoded <- "10.1371%2Fjournal.pbio.3000494_DNAonlyMCC"
  warning("Item not yet in __ReadMe.xlsx; using known encoded name.")
}
tsv_dir <- "__Public/comparative-data/"
if (dir.exists(tsv_dir))
  write.table(df, paste0(tsv_dir, item_encoded, ".tsv"),
              sep = "\t", row.names = FALSE, quote = TRUE, fileEncoding = "UTF-8")

# ---- checks ------------------------------------------------------------------
spread <- max(r2t) - min(r2t)
cat("Upham MamPhy DNA-only MCC:", nrow(df), "tips written\n")
cat("  root age            :", sprintf("%.2f", max(r2t)), "\n")
cat("  root-to-tip spread  :", sprintf("%.6g", spread),
    if (spread <= 1e-3 * max(r2t)) "(ultrametric)\n" else "(NOT ultrametric!)\n")
cat("  project species here:", sum(df$in_project), "\n")
if (nrow(df) > 5000)
  warning("~", nrow(df), " tips: this looks like the COMPLETED (taxonomy-imputed) tree, ",
          "not DNA-only. The DNA-only MCC tree has ~4098 tips. Do not use the completed tree.")
mars <- c("Diprotodontia", "Didelphimorphia", "Dasyuromorphia")
if (!any(df$Order_tip %in% mars))
  warning("No marsupial tips found -- this looks like a placental-only tree.")
