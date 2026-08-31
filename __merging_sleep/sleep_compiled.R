## Compile the comparative SLEEP & TORPOR dataset.
## Pattern mirrors __merging_gyrification / __merging_cerebral_metabolic_rate: read each source's
## public TSV, relabel columns via the stacked standardized-term map, stack to long, summarise to wide.
## One row per (species, source, trait) in long; one row per species in wide with a column per trait.
##
## Standardized terms (focal traits selected per source, house style — cf. EvoM1_read_gait/locomotion):
##   REM_sleep_pct     percent            per cent of total sleep in REM
##   Sleep_h_day       hours/day          total daily sleep
##   SWS_total_pct     percent of sleep   total slow-wave sleep
##   USWS_pctTST       percent of TST     unihemispheric SWS (= low- + high-amplitude USWS)
##   Torpor_type       DT|HIB             daily torpor vs hibernation
##   Torpor_Tb_min_C   deg C              minimum torpor body temperature
##   Torpor_bout_max_h hours              maximum torpor bout duration
## Finer breakdowns (hemispheric SWS, TMRmin/TMRrel, inter-bout euthermia, latitude, body/brain mass)
## stay in the source tables and can be promoted to terms later.
##
## Sources / teams (this build):
##   Eagleman_2021        Eagleman_Vaughn_2021_TABLE1   REM_sleep_pct        (25 primates; common names resolved)
##   HerculanoHouzel__2015 HerculanoHouzel__2015_Table1  Sleep_h_day          (24 mammals)
##   Lyamin_2008          Lyamin_etal_2008_Table2       SWS_total_pct, USWS  (4 cetaceans)
##   RufGeiser_2015       Ruf_Geiser_2015_Table1        Torpor_*             (213 birds & mammals)
## The four sources contribute DIFFERENT traits, so no within-trait averaging or citation-dependency
## conflict arises yet. When a 2nd source of the SAME trait is added (e.g. a populated Lyamin Table 1
## carries total_sleep_time + rem_sleep), apply the team-aware / citation-dependency rules in the README.
##
## NOTE: Lyamin et al. (2008) Table 1 is NOT a source here — in the paper Table 1 is muscle-jerk
## counts, and the scaffolded sleep-columned stub in that folder is empty. Cetacean sleep numbers
## come from Table 2.
##
## Outputs: sleep_long.csv, sleep_wide.csv, sleep_source_species_ids.csv
suppressWarnings(suppressMessages(library(tidyverse)))

.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable())
    return(normalizePath(rstudioapi::getActiveDocumentContext()$path))
  "."
})
setwd(dirname(.sp))
base   <- normalizePath(file.path(dirname(.sp), ".."))
tsvdir <- file.path(base, "__Public", "comparative-data")

codes <- readxl::read_excel(file.path(base, "__ReadMe.xlsx"), sheet = "Sheet1")
enc   <- function(nm) codes$`Item encoded`[match(nm, codes$`Item name`)]
read_src <- function(nm) {                       # read a source TSV; NULL + warn if not yet published
  f <- file.path(tsvdir, paste0(enc(nm), ".tsv"))
  if (is.na(enc(nm)) || !file.exists(f)) {
    warning("source TSV not found (run its source .R first): ", nm); return(NULL)
  }
  readr::read_tsv(f, show_col_types = FALSE)
}
num <- function(x) suppressWarnings(as.numeric(x))

## species helpers
res <- readr::read_csv("species_resolution_Eagleman.csv", show_col_types = FALSE)  # common->binomial
hh_alias <- c("Loxodonta Africana" = "Loxodonta africana")
fix_hh   <- function(s) ifelse(s %in% names(hh_alias), hh_alias[s], s)
ruf_clean <- function(s) trimws(sub("\\(.*$", "", s))     # strip subspecies parenthetical

long <- list()
row_ <- function(sp, printed, term, value, units, source, team, conf, dep)
  tibble(Species = sp, Species_printed = printed, Standardized_Term = term,
         Value = as.character(value), Units = units, source = source, team = team,
         ref = "Table", species_confidence = conf, dependency_group = dep) |>
    filter(!is.na(Value) & Value != "" & !(Value %in% c("NA")))

## --- Eagleman -> REM_sleep_pct -------------------------------------------
d <- read_src("Eagleman_Vaughn_2021_TABLE1")
if (!is.null(d)) {
  d <- d |> rename(Species_printed = Species) |> left_join(res, by = c("Species_printed" = "Species_common"))
  long[["eag"]] <- row_(d$Species, d$Species_printed, "REM_sleep_pct", num(d$REM_sleep_percent),
                        "percent", "Eagleman_Vaughn_2021_TABLE1", "Eagleman_2021",
                        d$species_confidence, "REM_pct")
}
## --- Herculano-Houzel -> Sleep_h_day -------------------------------------
d <- read_src("HerculanoHouzel__2015_Table1")
if (!is.null(d))
  long[["hh"]] <- row_(fix_hh(d$species), d$species, "Sleep_h_day", num(d$`daily.sleep..h.`),
                       "hours/day", "HerculanoHouzel__2015_Table1", "HerculanoHouzel__2015",
                       "high", "dailysleep")
## --- Lyamin Table2 -> SWS_total_pct + USWS_pctTST (low+high amp USWS) -----
d <- read_src("Lyamin_etal_2008_Table2")
if (!is.null(d)) {
  long[["lya_sws"]] <- row_(d$species, d$species, "SWS_total_pct", num(d$total_sws_pct),
                            "percent of sleep", "Lyamin_etal_2008_Table2", "Lyamin_2008", "high", "SWS")
  usws <- rowSums(cbind(num(d$low_amp_usws_pct_tst), num(d$high_amp_usws_pct_tst)), na.rm = TRUE)
  usws[is.na(num(d$low_amp_usws_pct_tst)) & is.na(num(d$high_amp_usws_pct_tst))] <- NA
  long[["lya_usws"]] <- row_(d$species, d$species, "USWS_pctTST", round(usws, 3),
                             "percent of TST", "Lyamin_etal_2008_Table2", "Lyamin_2008", "high", "SWS")
}
## --- Ruf & Geiser -> torpor family ---------------------------------------
d <- read_src("Ruf_Geiser_2015_Table1")
if (!is.null(d)) {
  sp <- ruf_clean(d$taxon); conf <- ifelse(sp == d$taxon, "high", "review")
  long[["ruf_t"]]  <- row_(sp, d$taxon, "Torpor_type",       trimws(d$torpor_type), "DT|HIB",
                           "Ruf_Geiser_2015_Table1", "RufGeiser_2015", conf, "torpor")
  long[["ruf_tb"]] <- row_(sp, d$taxon, "Torpor_Tb_min_C",   num(d$tb_min_c),  "deg C",
                           "Ruf_Geiser_2015_Table1", "RufGeiser_2015", conf, "torpor")
  long[["ruf_bd"]] <- row_(sp, d$taxon, "Torpor_bout_max_h", num(d$tbd_max_h), "hours",
                           "Ruf_Geiser_2015_Table1", "RufGeiser_2015", conf, "torpor")
}

long <- bind_rows(long)
readr::write_csv(long, "sleep_long.csv")
readr::write_csv(long |> transmute(source, Species, Species_printed, Standardized_Term, Value, species_confidence),
                 "sleep_source_species_ids.csv")

## --- wide: one row per species, one column per standardized term ----------
terms <- c("REM_sleep_pct","Sleep_h_day","SWS_total_pct","USWS_pctTST",
           "Torpor_type","Torpor_Tb_min_C","Torpor_bout_max_h")
wide <- long |>
  select(Species, Standardized_Term, Value) |>
  distinct(Species, Standardized_Term, .keep_all = TRUE) |>
  pivot_wider(names_from = Standardized_Term, values_from = Value)
for (t in terms) if (!t %in% names(wide)) wide[[t]] <- NA
wide <- wide |>
  mutate(n_traits = rowSums(!is.na(across(all_of(terms))))) |>
  select(Species, all_of(terms), n_traits) |>
  arrange(Species)
readr::write_csv(wide, "sleep_wide.csv")

message("sleep: ", nrow(long), " long rows, ", nrow(wide), " species; per term: ",
        paste(sprintf("%s=%d", terms, sapply(terms, function(t) sum(long$Standardized_Term == t))),
              collapse = ", "))
