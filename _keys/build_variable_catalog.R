# build_variable_catalog.R
#
# Build a variable-level (long) catalog from every paper folder's *_definitions.csv.
# Each measured variable becomes one row, so a table that mixes many structures /
# measures / provenance becomes many rows -- which is how you find data that can
# actually be pooled. Output:
#   _keys/variable_catalog.csv                one row per (item x measured variable)
#   _keys/variable_catalog_compatibility.csv  groups of variables that measure the
#                                             same structure x measure-class (poolable)
#
# Inputs: every <folder>/.../*_definitions.csv (schema: Code, Definition, Structure,
#   Measure, Stat, role, taxon, Reference, Note, Source Note), plus
#   _keys/anatomy_reference.csv for canonical structure names.
# Run from the _keys/ folder (or set `root`).

suppressPackageStartupMessages({
  library(readr); library(dplyr); library(stringr); library(purrr); library(tidyr)
})
## Set working directory to this script folder
setwd("/Users/crossmodal/Library/CloudStorage/OneDrive-AllenInstitute/Species/Evo-M1-Trait-Data/_keys")
root <- ".."   # repo root, relative to _keys/

# admin/metadata columns that are NOT measured traits
meta_measures <- c("Species","Source","Specimen","Sex","Age","Sample","Provenance","Note","Method","n")

# collapse the Measure vocabulary into a broad, poolable class (units differ within a class)
measure_class <- function(m) dplyr::case_when(
  str_detect(m, regex("vol", ignore_case = TRUE))                  ~ "volume",
  str_detect(m, regex("mass|weight", ignore_case = TRUE))          ~ "mass",
  str_detect(m, regex("length", ignore_case = TRUE))               ~ "length",
  str_detect(m, regex("surface|area", ignore_case = TRUE))         ~ "surface area",
  str_detect(m, regex("size.?index|index", ignore_case = TRUE))    ~ "size index (allometric)",
  str_detect(m, regex("pct|percent", ignore_case = TRUE))          ~ "percentage (relative)",
  str_detect(m, regex("permille", ignore_case = TRUE))             ~ "per mille (relative)",
  str_detect(m, "^p\\.C\\.")                                       ~ "proportion (of CNS/body/brain)",
  str_detect(m, "\\.p\\.mg$|\\.p\\.mm3")                           ~ "density (per mass/volume)",
  str_detect(m, "\\.p\\.N$")                                       ~ "ratio (per neuron)",
  str_detect(m, "\\.p\\.C$")                                       ~ "ratio",
  str_detect(m, "\\.n$") | str_detect(m, regex("count|number", ignore_case = TRUE)) ~ "count (number)",
  TRUE ~ m
)

norm_struct <- function(x) tolower(str_replace_all(replace_na(x, ""), "[^A-Za-z0-9]", ""))

files <- list.files(root, pattern = "_[Dd]efinitions.*\\.csv$", recursive = TRUE, full.names = TRUE)
## __ShinyApp/data/variable_definitions.csv is an APP EXPORT, not a paper definitions file —
## and it carries its own `domain` column, which collided with anat's `domain` in the
## left_join below and broke the catalog transmute ("object 'domain' not found",
## sweep 2026-08-29). Excluded. (__Public likewise holds only copies.)
files <- files[!str_detect(files, "__Archive|/_keys/|/_checks/|/\\.git/|/__ShinyApp/|/__Public/")]

read_def <- function(f) {
  d <- tryCatch(suppressWarnings(read_csv(f, col_types = cols(.default = col_character()),
                                          locale = locale(encoding = "UTF-8"))),
                error = function(e) read_csv(f, col_types = cols(.default = col_character()),
                                             locale = locale(encoding = "latin1")))
  paper <- basename(dirname(f)); if (paper == "reference_tables") paper <- basename(dirname(dirname(f)))
  d$paper <- paper; d$def_file <- f; d
}

defs <- map_dfr(files, read_def)

vars <- defs %>%
  filter(!is.na(Measure), str_squish(Measure) != "", !(Measure %in% meta_measures)) %>%
  mutate(measure_class = measure_class(Measure), .struct_key = norm_struct(Structure))

anat <- read_csv(file.path(root, "_keys/anatomy_reference.csv"),
                 col_types = cols(.default = col_character())) %>%
  transmute(.struct_key = norm_struct(canonical_structure), anat_canonical = canonical_structure, domain)

# NOTE on resolution: volume-style definitions give one row per real variable
# (Structure + Measure both set -> full structure x measure resolution). Cell-count
# definitions are a legend: structure codes and measure codes on separate rows, so
# the measure-code rows have no Structure -- their real variables (structure x
# measure) live in the data columns. Those rows are kept here at measure-class
# resolution and labelled accordingly.
catalog <- vars %>%
  left_join(anat, by = ".struct_key") %>%
  transmute(paper,
            item               = coalesce(na_if(Reference, ""), paper),
            Code, Structure,
            canonical_structure = coalesce(anat_canonical, na_if(str_squish(Structure), ""),
                                           "(structure-agnostic; see data columns)"),
            domain, Measure, measure_class, Stat, role, taxon, Definition) %>%
  arrange(canonical_structure, measure_class, paper)

write_csv(catalog, file.path(root, "_keys/variable_catalog.csv"))

compat <- catalog %>%
  mutate(compat_key = paste(canonical_structure, measure_class, sep = " | ")) %>%
  group_by(compat_key, canonical_structure, measure_class) %>%
  summarise(n_variables = n(), n_papers = n_distinct(paper),
            papers = paste(sort(unique(paper)), collapse = "; "),
            taxa   = paste(sort(unique(taxon)),  collapse = "; "),
            roles  = paste(sort(unique(role)),   collapse = "; "), .groups = "drop") %>%
  mutate(poolable = n_papers >= 2) %>%
  arrange(desc(n_papers), desc(n_variables))

write_csv(compat, file.path(root, "_keys/variable_catalog_compatibility.csv"))

message("variable_catalog.csv: ", nrow(catalog), " measured variables from ",
        n_distinct(catalog$paper), " papers")
message("compatibility groups: ", nrow(compat),
        "  | poolable (>=2 papers): ", sum(compat$poolable))
