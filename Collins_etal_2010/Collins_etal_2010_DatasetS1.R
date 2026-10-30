## Collins, Airey, Young, Leitch & Kaas 2010, PNAS 107(36):15927-15932 — Dataset S1
## doi:10.1073/pnas.1010356107 · Team Kaas · isotropic-fractionator cortical cell/neuron counts.
## Raw per-tissue-piece counts for ONE cortical hemisphere from each of 5 specimens / 4 primate species:
##   Otolemur garnetti (galago #1 case 07-104 grid; galago #2 case 08-07 areas),
##   Aotus nancymae (owl monkey, case 07-78), Macaca mulatta (macaque, case 08-59, NOT flattened -> no
##   surface area), Papio cynocephalus anubis (baboon, case 09-27). Species/case from SI p.1 + Fig legends.
## Snapshot = faithful copy of the supplement (sd01.xls). All cleaning happens here. Golden rule kept.

options(scipen = 999)
## ---- paths: self-contained (Rscript or RStudio; full repo or lone folder) ----
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)             # Rscript file.R
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path                    # RStudio: Source
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path  # RStudio: Run
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
folder    <- dirname(.sp)                                # this paper's folder
item_name <- tools::file_path_sans_ext(basename(.sp))    # = file name, matches __ReadMe.xlsx
base      <- local({                                     # repo root; NA if run as a lone folder
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
setwd(folder)
library(readxl)

## ---- specimen metadata (SI p.1 species list + Fig 1/2/S1/S2 hemisphere) ----
meta <- data.frame(
  sheet       = c("07104Galago","0807Galago","0778OwlMonkey","0859Macaque","0927Baboon"),
  Species     = c("Otolemur garnetti","Otolemur garnetti","Aotus nancymae","Macaca mulatta","Papio cynocephalus anubis"),
  common_name = c("galago","galago","owl monkey","macaque monkey","baboon"),
  specimen    = c("07-104","08-07","07-78","08-59","09-27"),
  hemisphere  = c("left","right","left","right", NA),          # 09-27 side not stated
  stringsAsFactors = FALSE
)

## ---- column aliases: the 5 sheets use different spellings/orders; map by NAME, never position ----
alias <- c(
  Tube_id="piece_id", Piece_Id="piece_id", Tube_Id="piece_id", Piece_id="piece_id",
  Surf_area_mm2="surface_area_mm2", Surf_Area_mm2="surface_area_mm2", S_Area_mm2="surface_area_mm2",
  Tube_Wt_g="tissue_weight_g", Piece_Wt="tissue_weight_g", Piece_Wt_g="tissue_weight_g",
  Total_cells="total_cells", Total_Cells="total_cells",
  NeuN_Percent="neun_percent_printed",
  Total_Neurons="total_neurons", Total_neurons="total_neurons",
  Cell_Dens_Wt="cell_density_per_g", Cell_Dens_SA="cell_density_per_mm2",
  Neu_Dens_Wt="neuron_density_per_g", Neu_Dens_SA="neuron_density_per_mm2"
)
canon <- c("piece_id","surface_area_mm2","tissue_weight_g","total_cells","neun_percent_printed",
           "total_neurons","cell_density_per_g","cell_density_per_mm2",
           "neuron_density_per_g","neuron_density_per_mm2")

snap <- "Collins_etal_2010_DatasetS1_snapshot.xlsx"
parts <- lapply(seq_len(nrow(meta)), function(i) {
  sh <- meta$sheet[i]
  raw <- read_excel(snap, sheet = sh)
  names(raw) <- alias[names(raw)]                        # rename to canonical
  stopifnot(!any(is.na(names(raw))))                     # every header must be known
  # assemble in a fixed column order; missing cols (e.g. macaque surface area) -> NA
  d <- as.data.frame(lapply(canon, function(k) if (k %in% names(raw)) raw[[k]] else NA))
  names(d) <- canon
  d$piece_id <- as.character(d$piece_id)                 # keep '29a','V1','DL',...
  data.frame(
    Species     = meta$Species[i],
    common_name = meta$common_name[i],
    specimen    = meta$specimen[i],
    hemisphere  = meta$hemisphere[i],
    piece_id    = d$piece_id,
    piece_type  = ifelse(grepl("[A-Za-z]", d$piece_id), "area", "grid"),
    surface_area_mm2       = suppressWarnings(as.numeric(d$surface_area_mm2)),
    tissue_weight_g        = suppressWarnings(as.numeric(d$tissue_weight_g)),
    total_cells            = suppressWarnings(as.numeric(d$total_cells)),
    neun_percent_printed   = suppressWarnings(as.numeric(d$neun_percent_printed)),  # verbatim (baboon = %, others = fraction)
    neun_ratio             = round(suppressWarnings(as.numeric(d$total_neurons)) /
                                   suppressWarnings(as.numeric(d$total_cells)), 4), # derived, unambiguous
    total_neurons          = suppressWarnings(as.numeric(d$total_neurons)),
    cell_density_per_g     = suppressWarnings(as.numeric(d$cell_density_per_g)),
    cell_density_per_mm2   = suppressWarnings(as.numeric(d$cell_density_per_mm2)),
    neuron_density_per_g   = suppressWarnings(as.numeric(d$neuron_density_per_g)),
    neuron_density_per_mm2 = suppressWarnings(as.numeric(d$neuron_density_per_mm2)),
    source = item_name, stringsAsFactors = FALSE
  )
})
clean <- do.call(rbind, parts)

## ---- local CSV ----
csv_file <- file.path(folder, paste0(item_name, ".csv"))
write.csv(clean, csv_file, row.names = FALSE)
message(item_name, ": ", nrow(clean), " tissue pieces written to ", basename(csv_file))

## ---- public TSV: look up the DOI code from __ReadMe.xlsx ----
tsv_dir <- file.path(base, "__Public", "comparative-data")
item_encoded <- if (!is.na(base) && file.exists(file.path(base, "__ReadMe.xlsx"))) {
  filecodes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
  filecodes$`Item encoded`[match(item_name, filecodes$`Item name`)]
} else NA_character_

if (is.na(item_encoded) || !nzchar(item_encoded)) {
  warning("No 'Item encoded' for '", item_name, "' in __ReadMe.xlsx; TSV skipped.")
} else if (!dir.exists(path.expand(tsv_dir))) {
  warning("Shared folder not found: ", tsv_dir, "; TSV skipped.")
} else {
  tsv_file <- file.path(path.expand(tsv_dir), paste0(item_encoded, ".tsv"))
  write.table(clean, tsv_file, sep = "\t", row.names = FALSE)
  message("Wrote ", tsv_file)
}
