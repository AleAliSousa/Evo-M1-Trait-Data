# Read-only migration preview: compare the hand-maintained artifact catalog
# with the file-level registries. This does not replace artifacts.csv.
args <- commandArgs(trailingOnly = FALSE)
script_arg <- grep("^--file=", args, value = TRUE)
if (length(script_arg) != 1L)
  stop("Run with Rscript __metadata/pilot/preview_artifact_derivation.R")
here <- dirname(normalizePath(sub("^--file=", "", script_arg)))
root <- normalizePath(file.path(here, "..", ".."), winslash = "/")
folders <- c("ManyPrimates__2022", "Mink_etal_1981", "Boddy_etal_2012",
             "Falcone_etal_2019", "Buchsbaum_etal_1989", "Kaufman__2004",
             "Heffner_Heffner_2010_b", "Bahney_vonBartheld_2018",
             "Fobbs_etal_2011", "Kennedy_etal_1978")
read_chars <- function(path) {
  if (!file.exists(path)) stop("Missing file registry: ", path)
  read.csv(path, colClasses = "character", na.strings = character(),
           check.names = FALSE, stringsAsFactors = FALSE)
}
legacy <- read_chars(file.path(here, "artifacts.csv"))
files <- do.call(rbind, lapply(folders, function(folder)
  read_chars(file.path(root, folder, "pipeline_files.csv"))))
shared <- read_chars(file.path(here, "shared_pipeline_files.csv"))
files <- rbind(files, shared)
if (anyDuplicated(files$file_id) || anyDuplicated(files$path))
  stop("New file registry IDs and paths must be unique")
if (anyDuplicated(legacy$artifact_id) || anyDuplicated(legacy$path))
  stop("Legacy artifact IDs and paths must be unique")

is_paper_public <- vapply(legacy$path, function(path)
  any(startsWith(path, paste0(folders, "/"))) ||
    startsWith(path, "__Public/comparative-data/"), logical(1L))
if (sum(is_paper_public) != 267L || sum(!is_paper_public) != 24L)
  stop("Expected 267 paper/public and 24 shared legacy artifacts")
index <- match(legacy$artifact_id, files$file_id)
new_path <- files$path[index]
path_match <- !is.na(index) & legacy$path == new_path
if (any(!path_match & is_paper_public))
  stop("A paper/public artifact ID is absent or points to another path: ",
       paste(legacy$artifact_id[!path_match & is_paper_public], collapse = "; "))
if (any(!path_match & !is.na(index)))
  stop("A shared artifact ID points to another path: ",
       paste(legacy$artifact_id[!path_match & !is.na(index)], collapse = "; "))
missing_shared <- legacy$artifact_id[!is_paper_public & is.na(index)]

file <- files[index, , drop = FALSE]
zone <- ifelse(startsWith(file$path, "__Public/comparative-data/"),
               "public_tsv", ifelse(grepl("/reference_tables/", file$path,
                                         fixed = TRUE),
                                    "reference_tables", ifelse(is_paper_public,
                                                              "paper_folder", "")))
items <- read_chars(file.path(here, "items.csv"))
registration <- ifelse(file$path %in% items$public_tsv_path,
                       "registered_item_output", "supporting")
clean <- function(x) ifelse(is.na(x), "", x)
same <- function(x, y) clean(x) == clean(y)
preview <- data.frame(
  artifact_id = legacy$artifact_id,
  path = legacy$path,
  location = ifelse(is_paper_public, "paper_or_public", "shared_global"),
  file_id = file$file_id,
  file_role = file$file_role,
  creation_mode = file$creation_mode,
  stage = file$stage,
  authority_status = file$authority_status,
  id_exact = same(legacy$artifact_id, file$file_id),
  path_exact = path_match,
  storage_zone_from_path_exact = ifelse(is_paper_public,
                                        same(legacy$storage_zone, zone), NA),
  registration_from_item_exact = same(legacy$registration_status,
                                      registration),
  owner_item_direct_exact = same(legacy$owner_item, file$item_id),
  artifact_kind_direct_exact = same(legacy$artifact_kind, file$file_role),
  authority_stage_direct_exact = same(legacy$authority_stage,
                                      file$authority_status),
  granularity_direct_exact = same(legacy$granularity, file$record_grain),
  producer_direct_exact = same(legacy$producer, file$producer_id),
  note_exact = same(legacy$note, file$note),
  stringsAsFactors = FALSE
)
for (field in setdiff(names(preview)[grepl("_exact$", names(preview))],
                      c("id_exact", "path_exact"))) {
  preview[[field]][is.na(index)] <- NA
}
write.csv(preview, file.path(here, "artifact_derivation_preview.csv"),
          row.names = FALSE, na = "")

fields <- c("id_exact", "path_exact", "storage_zone_from_path_exact",
            "registration_from_item_exact", "owner_item_direct_exact",
            "artifact_kind_direct_exact", "authority_stage_direct_exact",
            "granularity_direct_exact", "producer_direct_exact", "note_exact")
summarize <- function(scope) {
  x <- preview[scope, , drop = FALSE]
  data.frame(field = fields,
             exact = vapply(fields, function(k) sum(x[[k]] %in% TRUE), integer(1L)),
             compared = vapply(fields, function(k) sum(!is.na(x[[k]])), integer(1L)),
             stringsAsFactors = FALSE)
}
paper_summary <- summarize(is_paper_public)
shared_summary <- summarize(!is_paper_public)
fmt <- function(x) paste0(x$exact, "/", x$compared)
ambiguity <- function(keys, legacy_field) {
  key <- do.call(paste, c(unname(file[is_paper_public, keys, drop = FALSE]),
                          sep = "\036"))
  old <- legacy[[legacy_field]][is_paper_public]
  grouped <- split(old, key)
  ambiguous <- names(grouped)[vapply(grouped, function(x)
    length(unique(x)) > 1L, logical(1L))]
  c(groups = length(ambiguous), rows = sum(key %in% ambiguous))
}
kind_ambiguity <- ambiguity(c("file_role", "content_role"), "artifact_kind")
stage_ambiguity <- ambiguity(c("stage", "authority_status", "file_role"),
                             "authority_stage")
grain_ambiguity <- ambiguity(c("record_grain", "content_role"), "granularity")
owner_mismatch <- preview$artifact_id[is_paper_public &
                                      !preview$owner_item_direct_exact]
lines <- c(
  "# Artifact catalog derivation preview",
  "",
  "This report compares `artifacts.csv` with the new per-folder and shared file",
  "registries by stable ID and exact path. The preview does not modify the",
  "legacy catalog or its field routes.",
  "",
  sprintf("Matched %d paper/public artifact rows and %d shared/global rows.",
          sum(is_paper_public), sum(!is_paper_public & !is.na(index))),
  sprintf("Legacy shared/global rows absent from the new active file registry: %s.",
          if (length(missing_shared)) paste(missing_shared, collapse = ", ") else "none"),
  "",
  "| Legacy field or candidate derivation | Paper/public exact | Shared/global exact |",
  "| --- | ---: | ---: |"
)
for (i in seq_along(fields)) {
  lines <- c(lines, sprintf("| `%s` | %s | %s |", fields[[i]],
                            fmt(paper_summary[i, ]), fmt(shared_summary[i, ])))
}
lines <- c(lines,
  "",
  "## Migration interpretation",
  "",
  "`artifact_id`, `path`, and `storage_zone` can be derived losslessly for",
  "paper/public artifacts when the counts above are exact. `registration_status`",
  "can be derived by joining the live pilot item public TSV paths, independent",
  "of `file_role`. `owner_item` should be compared with the new `item_id`; a",
  "difference may reflect a newly explicit relationship rather than an error.",
  sprintf("The current owner-item exception is `%s`: the old catalog assigns",
          paste(owner_mismatch, collapse = ", ")),
  "Kaufman's shared A1–A14 citation lookup to A3 alone; the new file registry",
  "correctly leaves its single-owner field blank.",
  "",
  "Do not silently equate `artifact_kind` with `file_role`, `authority_stage`",
  "with `authority_status`, `granularity` with `record_grain`, or the legacy",
  "free-text `producer` with `producer_id`. These fields have different",
  "vocabularies or purposes. Use an explicit translation, retain a small",
  "exception overlay, or update catalog consumers to query the new names.",
  "The `note` is editorial text and may legitimately differ; keep a chosen",
  "single source of truth instead of copying both versions.",
  sprintf("Even `(file_role, content_role)` leaves %d ambiguous artifact-kind",
          kind_ambiguity[["groups"]]),
  sprintf("groups affecting %d rows. `(stage, authority_status, file_role)`",
          kind_ambiguity[["rows"]]),
  sprintf("leaves %d ambiguous authority-stage groups affecting %d rows.",
          stage_ambiguity[["groups"]], stage_ambiguity[["rows"]]),
  sprintf("`(record_grain, content_role)` leaves %d ambiguous legacy-grain",
          grain_ambiguity[["groups"]]),
  sprintf("groups affecting %d rows. These are real distinctions in the old",
          grain_ambiguity[["rows"]]),
  "vocabulary, not values that a direct rename can recover.",
  "",
  "The shared/global artifacts present in `shared_pipeline_files.csv` can be",
  "derived there. The three missing `__merging_*` outputs are intentionally",
  "excluded from the active no-merge registry and remain legacy audit rows.",
  "Paper/public rows can come from the ten `pipeline_files.csv` files.",
  "Once field routes are checked against the derived IDs, `artifacts.csv` can become",
  "a generated compatibility export rather than a hand-maintained registry."
)
writeLines(lines, file.path(here, "ARTIFACT_DERIVATION_PREVIEW.md"), useBytes = TRUE)
cat("Artifact derivation preview:", sum(is_paper_public),
    "paper/public,", sum(!is_paper_public & !is.na(index)),
    "shared/global matched,", length(missing_shared),
    "legacy downstream-only omitted\n")
