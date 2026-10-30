# Stephan_etal_1970_crosstable_QA.R
# Standalone cross-table validator for the split Stephan 1970 tables.
# Was internal to the old bundled build; now that each printed table is its own item,
# the components-vs-total check lives here.
#
# Check: the 7 telencephalon COMPONENTS (Tables 4-6) sum to the Telencephalon TOTAL
# (Tables 1-3), per species. Tolerance: rounding of the source (~<0.5%).
suppressPackageStartupMessages({ library(readr); library(dplyr); library(purrr); library(tidyr) })

folder <- tryCatch(dirname(normalizePath(sub("^--file=", "",
           grep("^--file=", commandArgs(FALSE), value = TRUE)[1]))),
           error = function(e) getwd())
setwd(folder)

# totals: telencephalon_mm3 from the fundamental tables (1-3)
totals <- map_dfr(1:3, ~ read_csv(sprintf("Stephan_etal_1970_Table%d.csv", .x), show_col_types = FALSE)) %>%
  transmute(species, telencephalon_total = telencephalon_mm3)

# components: sum the 7 telencephalon-component columns from tables 4-6
comp_cols <- c("bulbus_olfactorius_mm3","palaeocortex_plus_amygdala_mm3","septum_mm3",
               "striatum_mm3","schizocortex_mm3","hippocampus_mm3","neocortex_mm3")
comps <- map_dfr(4:6, ~ read_csv(sprintf("Stephan_etal_1970_Table%d.csv", .x), show_col_types = FALSE)) %>%
  rowwise() %>% mutate(comp_sum = sum(c_across(all_of(comp_cols)), na.rm = TRUE)) %>%
  ungroup() %>% select(species, comp_sum)

qa <- totals %>% inner_join(comps, by = "species") %>%
  mutate(abs_diff = comp_sum - telencephalon_total,
         pct_diff = 100 * abs_diff / telencephalon_total)

cat(sprintf("Stephan 1970 telencephalon components vs total: n=%d species\n", nrow(qa)))
cat(sprintf("  max |%% diff| = %.3f%%  median = %.3f%%\n",
            max(abs(qa$pct_diff)), median(abs(qa$pct_diff))))
worst <- qa %>% arrange(desc(abs(pct_diff))) %>% head(5)
print(as.data.frame(worst), row.names = FALSE)
write_csv(qa, "Stephan_etal_1970_crosstable_QA.csv")
fail <- qa %>% filter(abs(pct_diff) > 0.5)
if (nrow(fail)) warning(sprintf("%d species exceed 0.5%% tolerance", nrow(fail))) else
  cat("PASS: all species within 0.5%% tolerance\n")
