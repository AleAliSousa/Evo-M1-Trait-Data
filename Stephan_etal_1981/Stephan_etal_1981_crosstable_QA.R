# Stephan_etal_1981_crosstable_QA.R
# Standalone cross-table validator for the split Stephan 1981 tables (I-XVI).
# Was internal to the old bundled build; now that each printed table is its own item,
# the components-vs-total check lives here.
#
# Check: the 8 telencephalon COMPONENTS (Tables IV-VI, codes 11-18) sum to the fundamental
# Telencephalon TOTAL (Tables I-III, code 10), per species. Tolerance ~<0.5%.
# Tables I-VI span all three taxa, so this covers insectivores, prosimians and simians.
suppressPackageStartupMessages({ library(readr); library(dplyr); library(purrr) })

folder <- tryCatch(dirname(normalizePath(sub("^--file=", "",
           grep("^--file=", commandArgs(FALSE), value = TRUE)[1]))),
           error = function(e) getwd())
setwd(folder)   # run from 

# totals: Telencephalon from the fundamental tables I-III
totals <- map_dfr(c("I","II","III"), ~ read_csv(sprintf("Stephan_etal_1981_Table%s.csv", .x),
                                                show_col_types = FALSE)) %>%
  transmute(species, telencephalon_total = Telencephalon)

# components: sum the 8 telencephalon-component columns from tables IV-VI
comp_cols <- c("Bulbus_olfactorius","Bulbus_olfactorius_accessorius","Lobus_piriformis",
               "Septum","Striatum","Schizo_cortex","Hippocampus","Neocortex")
comps <- map_dfr(c("IV","V","VI"), ~ read_csv(sprintf("Stephan_etal_1981_Table%s.csv", .x),
                                              show_col_types = FALSE)) %>%
  rowwise() %>% mutate(comp_sum = sum(c_across(all_of(comp_cols)), na.rm = TRUE)) %>%
  ungroup() %>% select(species, comp_sum)

qa <- totals %>% inner_join(comps, by = "species") %>%
  mutate(abs_diff = comp_sum - telencephalon_total,
         pct_diff = 100 * abs_diff / telencephalon_total)

cat(sprintf("Stephan 1981 telencephalon components vs total: n=%d species\n", nrow(qa)))
cat(sprintf("  max |%% diff| = %.3f%%  median = %.3f%%\n",
            max(abs(qa$pct_diff)), median(abs(qa$pct_diff))))
worst <- qa %>% arrange(desc(abs(pct_diff))) %>% head(5)
print(as.data.frame(worst), row.names = FALSE)
write_csv(qa, "Stephan_etal_1981_crosstable_QA.csv")
fail <- qa %>% filter(abs(pct_diff) > 0.5)
if (nrow(fail)) warning(sprintf("%d species exceed 0.5%% tolerance", nrow(fail))) else
  cat("PASS: all species within 0.5%% tolerance\n")
