# Build Heesy__2004 Table 1 from the frozen snapshot
# Run from the publication folder or set item_dir explicitly.
item_dir <- if (file.exists("Heesy__2004_Table1_snapshot.xlsx")) "." else "Heesy__2004"
if (!requireNamespace("readxl", quietly = TRUE)) stop("Install readxl")
if (!requireNamespace("readr", quietly = TRUE)) stop("Install readr")
snapshot <- readxl::read_excel(file.path(item_dir, "Heesy__2004_Table1_snapshot.xlsx"), sheet = "Table1_snapshot", skip = 1)
parse_num <- function(x) as.numeric(sub("°.*$", "", trimws(as.character(x))))
parse_sd <- function(x) { z <- sub(".*\\(([-0-9.]+)°\\).*", "\\1", as.character(x)); ifelse(grepl("\\(", x), as.numeric(z), NA_real_) }
parse_range <- function(x) { x <- gsub("°", "", as.character(x)); p <- strsplit(x, "-"); data.frame(min=vapply(p, function(z) as.numeric(z[1]), numeric(1)), max=vapply(p, function(z) as.numeric(z[length(z)]), numeric(1))) }
rng <- parse_range(snapshot$`Binocular field as printed`)
out <- data.frame(species_as_published=snapshot$Species, common_name=snapshot$`Common name`, n_specimens=as.integer(snapshot$n), orbit_convergence_mean_deg=parse_num(snapshot$`Orbit convergence as printed`), orbit_convergence_sd_deg=parse_sd(snapshot$`Orbit convergence as printed`), binocular_visual_field_min_deg=rng$min, binocular_visual_field_max_deg=rng$max, binocular_visual_field_midpoint_deg=(rng$min+rng$max)/2, binocular_visual_field_reference=snapshot$Reference, data_role="primary_orbit_convergence_secondary_visual_field", note=ifelse(rng$min!=rng$max, paste0("Range printed as ", rng$min, "-", rng$max, " degrees."), ""), source="Heesy__2004 Table1", check.names=FALSE)
readr::write_csv(out, file.path(item_dir, "Heesy__2004_Table1.csv"), na="")
message("Built Heesy__2004_Table1.csv with ", nrow(out), " rows")
