# download_animaltraits_mammalia.R
# Downloads all raw Mammalia files for brain size, metabolic rate, and body size
# from animaltraits/animaltraits.github.io

if (!requireNamespace("jsonlite", quietly = TRUE)) install.packages("jsonlite")
if (!requireNamespace("httr2", quietly = TRUE)) install.packages("httr2")
library(httr2)

repo <- "animaltraits/animaltraits.github.io"
out_dir <- "animaltraits_raw_Mammalia"
dir.create(out_dir, showWarnings = FALSE, recursive = TRUE)

# Helper for GitHub API, with optional token to avoid rate limits
# Set it once in R with: Sys.setenv(GITHUB_PAT = "your_token")
gh_get <- function(url) {
  req <- request(url) |> req_user_agent("animaltraits-download-R")
  pat <- Sys.getenv("GITHUB_PAT")
  if (nzchar(pat)) req <- req |> req_auth_bearer_token(pat)
  req |> req_perform() |> resp_body_json()
}

# 1. Find default branch
repo_info <- gh_get(paste0("https://api.github.com/repos/", repo))
branch <- repo_info$default_branch
message("Default branch: ", branch)

# 2. Get full recursive file tree
tree <- gh_get(
  sprintf("https://api.github.com/repos/%s/git/trees/%s?recursive=1", repo, branch)
)
paths <- vapply(tree$tree, function(x) x$path, character(1))
types <- vapply(tree$tree, function(x) x$type, character(1))
files <- paths[types == "blob"]

# 3. Filter to Mammalia + the three traits
lower <- tolower(files)
keep <- grepl("^data/raw/", lower) &
  grepl("mammalia", lower) &
  grepl("\\.csv$", lower) &
  (grepl("brain", lower) | grepl("metabolic", lower) | grepl("body", lower))

mammalia_files <- files[keep]

message("Found ", length(mammalia_files), " matching files")
print(mammalia_files)

if (length(mammalia_files) == 0) {
  message("No matches. Here is everything under data/raw/ to inspect:")
  print(files[grepl("^data/raw/", lower)])
  stop("No Mammalia files matched. Check the printed list and adjust the filter.")
}

# 4. Download each file from raw.githubusercontent.com
for (f in mammalia_files) {
  # Keep structure after data/raw/ so names do not collide
  rel <- sub("^data/raw/", "", f)
  dest <- file.path(out_dir, rel)
  dir.create(dirname(dest), showWarnings = FALSE, recursive = TRUE)
  
  raw_url <- paste0(
    "https://raw.githubusercontent.com/",
    repo, "/", branch, "/", utils::URLencode(f, reserved = TRUE)
  )
  
  tryCatch(
    {
      download.file(raw_url, dest, mode = "wb", quiet = TRUE)
      message("OK: ", rel)
    },
    error = function(e) message("FAILED: ", rel, " - ", conditionMessage(e))
  )
  Sys.sleep(0.1)
}

# 5. Verify
downloaded <- list.files(out_dir, pattern = "\\.csv$", recursive = TRUE, full.names = TRUE)
verification <- data.frame(
  file = downloaded,
  size_bytes = file.size(downloaded),
  row.names = NULL
)
print(verification)
message("Done. Files saved to: ", normalizePath(out_dir))