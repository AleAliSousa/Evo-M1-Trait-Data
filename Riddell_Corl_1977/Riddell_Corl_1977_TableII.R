## Riddell_Corl_1977_TableII -- Anatomical and performance data for several
## species on five tasks (pp.391-392)
## Input : Riddell_Corl_1977_TableII_snapshot.xlsx  (frozen; printed layout,
##         both printed pages in one sheet)
## Output: Riddell_Corl_1977_TableII.csv + public TSV
##
## One analysis row per printed data row (task block x species, 30 rows).  The
## table is a COMPILATION: every P (body weight) / E (brain weight) value and
## every behavioural rank carries a printed reference number, resolved to a
## full citation in reference_tables/Riddell_Corl_1977_TableII_references.csv
## (join: split the *_reference columns on "; ", then match on ref_key).  Only
## the two rows whose "E and P reference" reads "present study" are primary.
options(scipen = 999, stringsAsFactors = FALSE)

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
folder    <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
setwd(folder)
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
if (is.na(base)) stop("Repository root (__ReadMe.xlsx) not found above ", folder, call. = FALSE)
source(file.path(base, "_keys", "resolve_species.R"))

## numbers as printed -> numeric; blanks and the printed non-numeric tokens stay NA
num <- function(x) {
  x <- gsub("\u00a0", " ", as.character(x), fixed = TRUE)
  x <- gsub(",", "", trimws(x))
  x[x %in% c("", "-", "\u2013", "\u2014", "NA", "n.a.", "NR", "NE")] <- NA_character_
  suppressWarnings(as.numeric(x))
}

s <- as.data.frame(readxl::read_excel("Riddell_Corl_1977_TableII_snapshot.xlsx",
                                      col_names = FALSE, .name_repair = "minimal"))
s[is.na(s)] <- ""
stopifnot(nrow(s) == 36L, ncol(s) == 14L)
hdr <- unlist(s[3, ], use.names = FALSE)
stopifnot(hdr[1] == "Species", hdr[4] == "P, g", hdr[5] == "E, g",
          identical(unlist(s[30, ], use.names = FALSE), hdr))   # header repeated on p.392

## data rows are the rows whose first cell starts with a printed row number
is_data <- grepl("^[0-9]+ ", s[[1]]) & s[[2]] == "{"
d <- s[is_data, ]
stopifnot(nrow(d) == 30L)

## the printed page each row sits on
page <- ifelse(which(is_data) < which(s[[1]] == "[page 392]"), 391L, 392L)

## "Dependent variable" is printed once per braced block and carried down
task <- d[[3]]
for (i in seq_along(task)) if (!nzchar(task[i])) task[i] <- task[i - 1L]
stopifnot(all(nzchar(task)))
task_block <- cumsum(c(TRUE, task[-1] != task[-length(task)]))
stopifnot(max(task_block) == 5L)

row_no  <- as.integer(sub("^([0-9]+) .*$", "\\1", d[[1]]))
species <- trimws(sub("^[0-9]+ ", "", d[[1]]))

## printed multi-citations "24, 35" -> house separator "; "
refjoin <- function(x) gsub(",\\s*", "; ", trimws(x))

P   <- num(d[[4]])
E   <- num(d[[5]])
Nc  <- num(d[[6]])
H   <- num(d[[7]])

final.dataframe <- data.frame(
  task_block_printed      = task_block,
  task_as_published       = task,
  printed_page            = page,
  row_number_printed      = row_no,
  species_printed         = species,
  Body_Mass.g             = P,                 # printed "P, g" -- already project units
  Brain_Mass.g            = E,                 # printed "E, g"
  Brain_Mass.mg           = E * 1000,          # project unit for brain weight
  Nc_index_x1e7           = Nc,                # printed "Nc x 10^7" (Jerison extra neurons)
  Nc_index_neurons        = Nc * 1e7,
  Herschel_index_H        = H,
  learning_set_slope      = num(d[[8]]),
  behavior_rank           = num(d[[9]]),
  Nc_rank                 = num(d[[10]]),
  E_rank                  = num(d[[11]]),
  H_rank                  = num(d[[12]]),
  behavior_reference      = refjoin(d[[13]]),
  E_and_P_reference       = refjoin(d[[14]]),
  data_role_of_row        = ifelse(trimws(d[[14]]) == "present study",
                                   "primary (E and P measured here)", "secondary"),
  row.names = NULL, check.names = FALSE)
sp <- resolve_species(species, "Riddell_Corl_1977")
final.dataframe$accepted_name <- sp$accepted_name
final.dataframe$species_basis <- sp$species_basis
final.dataframe$reidentified  <- sp$reidentified
final.dataframe$source        <- "Riddell_Corl_1977_TableII"
stopifnot(!any(sp$unresolved), !anyNA(P), !anyNA(E), !anyNA(Nc), !anyNA(H))

## ---- table checks (section 7a) -------------------------------------------
## The printed Nc / E / H rank columns are rankings of the printed Nc / E / H
## values within each braced task block (Nc and E descending, H ascending), so
## the table checks itself.  Ties take average ranks, as the printed 1.5 / 1.5
## pair in the conditioned-response block shows.  "Behavior rank" is NOT
## checkable here: the behavioural measure it ranks is not printed.
chk <- function(id, printed, value, decreasing) {
  obs <- unsplit(lapply(split(value, task_block),
                        function(v) rank(if (decreasing) -v else v, ties.method = "average")),
                 task_block)
  n_bad <- sum(abs(obs - printed) > 1e-9)
  data.frame(check_id = id,
             basis = paste0("printed ", id, " re-derived from the printed values within each task block (",
                            if (decreasing) "descending" else "ascending", ", average ranks for ties)"),
             observed = n_bad, printed = 0, difference = n_bad, tolerance = 0,
             status = if (n_bad == 0L) "pass" else "mismatch",
             note = paste0(length(printed), " printed ranks over 5 task blocks"),
             stringsAsFactors = FALSE)
}
table_checks <- rbind(
  chk("Nc_rank", final.dataframe$Nc_rank, Nc, TRUE),
  chk("E_rank",  final.dataframe$E_rank,  E,  TRUE),
  chk("H_rank",  final.dataframe$H_rank,  H,  FALSE))
if (any(table_checks$status != "pass"))
  warning("Table II: rank check(s) failed: ",
          paste(table_checks$check_id[table_checks$status != "pass"], collapse = ", "))
print(table_checks)

## ---- write the analysis CSV and the DOI-coded public TSV -----------------
stopifnot(is.data.frame(final.dataframe), nrow(final.dataframe) > 0L)
write.csv(final.dataframe, paste0(item_name, ".csv"), row.names = FALSE, na = "")

fc <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
item_encoded <- fc$`Item encoded`[match(item_name, fc$`Item name`)]
if (is.na(item_encoded)) stop("No registry row for Item name '", item_name, "'", call. = FALSE)
## Column A of Sheet1 has carried trailing whitespace, which the Item-name
## formula pastes into Item encoded ("10.1037%2Fh0073864<NBSP>_TABLE1").  No
## legitimate encoded stem contains a space, so strip every space (incl. NBSP)
## before using it as a filename.  Harmless once file_list.R has been re-run.
item_encoded <- gsub("[[:space:]]", "",
                     gsub("\u00a0", "", item_encoded, fixed = TRUE))
if (!nzchar(item_encoded)) stop("Empty 'Item encoded' for ", item_name, call. = FALSE)
out_dir <- file.path(base, "__Public", "comparative-data")
if (dir.exists(out_dir)) {
  write.table(final.dataframe, file.path(out_dir, paste0(item_encoded, ".tsv")),
              sep = "\t", row.names = FALSE, quote = TRUE, na = "")
} else warning("__Public/comparative-data not mounted; public TSV skipped.")
message(item_name, ": ", nrow(final.dataframe), " rows -> ", item_encoded, ".tsv")
