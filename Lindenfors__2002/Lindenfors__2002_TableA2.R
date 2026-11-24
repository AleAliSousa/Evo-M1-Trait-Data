## Lindenfors 2002 Appendix 2 / Table A2: frozen supplement -> CSV and public TSV.
a <- grep('^--file=', commandArgs(FALSE), value=TRUE)
if (!length(a)) stop('Run with Rscript')
folder <- dirname(normalizePath(sub('^--file=', '', a[1])))
item_name <- tools::file_path_sans_ext(basename(sub('^--file=', '', a[1])))
root <- dirname(folder)
base <- file.path(folder, item_name)
source <- utils::read.csv(paste0(base, '_snapshot.csv'), header=FALSE,
                          skip=2, colClasses='character', na.strings=NULL,
                          check.names=FALSE, fileEncoding='UTF-8')
stopifnot(ncol(source) == 19L, nrow(source) == 204L,
          grepl('^Data sources:', source[204L, 1L]))
source <- source[1:203, , drop=FALSE]
source[is.na(source)] <- ''

to_num <- function(x) {
  x <- trimws(x)
  x[x == ''] <- NA_character_
  if (!all(is.na(x) | grepl('^[0-9]+([.][0-9]+)?$', x)))
    stop('Non-numeric value in a numeric Table A2 column')
  as.numeric(x)
}
fields <- c('male_body_mass_g', 'female_body_mass_g', 'group_size',
  'female_age_sexual_maturity_months', 'female_age_first_birth_years',
  'gestation_days', 'offspring_per_litter', 'interbirth_interval_years',
  'birth_rate_offspring_per_year', 'maximum_recorded_lifespan_years',
  'neonate_body_mass_g', 'male_neonate_body_mass_g',
  'female_neonate_body_mass_g', 'weaning_age_days',
  'weaning_body_mass_g', 'foetal_growth_rate_source',
  'postnatal_growth_rate_source')
numeric_values <- as.data.frame(lapply(source[3:19], to_num),
                                check.names=FALSE)
names(numeric_values) <- fields
# The printed adult and weaning weights are kg; project body-mass units are g.
numeric_values[c('male_body_mass_g', 'female_body_mass_g',
                 'weaning_body_mass_g')] <-
  lapply(numeric_values[c('male_body_mass_g', 'female_body_mass_g',
                         'weaning_body_mass_g')], `*`, 1000)

source_has_traits <- apply(source[, 2:19, drop=FALSE], 1L,
                           function(x) any(nzchar(x)))
stopifnot(sum(source_has_traits) == 194L,
          !anyDuplicated(source[[1L]]),
          identical(source[[1L]][c(1L, 203L)], c('Lemur catta', 'Gorilla gorilla')))
final.dataframe <- data.frame(
  source_row=seq_len(nrow(source)),
  species_as_published=source[[1L]],
  Species=source[[1L]],
  mating_system_as_published=ifelse(nzchar(source[[2L]]), source[[2L]], NA_character_),
  numeric_values,
  source_has_traits=source_has_traits,
  data_role='secondary literature compilation',
  taxonomic_resolution='verbatim historical source label; unharmonized',
  primary_pool_eligible=FALSE,
  check.names=FALSE, stringsAsFactors=FALSE)

# Check two source-defined rate relations using the printed, rounded values.
# These checks only assess consistency; they never replace the source rates.
birth <- final.dataframe$birth_rate_offspring_per_year
litter <- final.dataframe$offspring_per_litter
interval <- final.dataframe$interbirth_interval_years
birth_ok <- !is.na(birth) & !is.na(litter) & !is.na(interval) & interval > 0
birth_difference <- max(abs(litter[birth_ok] / interval[birth_ok] - birth[birth_ok]))
foetal <- final.dataframe$foetal_growth_rate_source
neonate <- final.dataframe$neonate_body_mass_g
gestation <- final.dataframe$gestation_days
foetal_ok <- !is.na(foetal) & !is.na(neonate) & !is.na(litter) &
  !is.na(gestation) & gestation > 0
foetal_difference <- max(abs(neonate[foetal_ok] * litter[foetal_ok] /
                             gestation[foetal_ok] - foetal[foetal_ok]))
table_checks <- data.frame(
  check_id=c('birth_rate_relation', 'foetal_growth_relation'),
  basis=c('litter size / interbirth interval vs birth rate',
          'neonate mass x litter size / gestation days vs foetal growth rate'),
  observed=c(birth_difference, foetal_difference), printed=c(0, 0),
  difference=c(birth_difference, foetal_difference), tolerance=c(0.03, 0.006),
  status=ifelse(c(birth_difference, foetal_difference) <= c(0.03, 0.006),
                'pass', 'mismatch'),
  note=c(paste(sum(birth_ok), 'rows with all operands; tolerance allows rounded source cells'),
         paste(sum(foetal_ok), 'rows with all operands; tolerance allows rounded source cells')),
  stringsAsFactors=FALSE)
if (any(table_checks$status == 'mismatch'))
  warning('A source-defined rate relation exceeds its rounding tolerance')
utils::write.csv(final.dataframe, paste0(base, '.csv'),
                 row.names=FALSE, na='', fileEncoding='UTF-8')
reg <- readxl::read_excel(file.path(root, '__ReadMeAddON.xlsx'), sheet='Sheet1')
hit <- which(reg[['Item name']] == item_name)
if (length(hit) != 1L) stop('Expected exactly one AddON registry row')
item_encoded <- as.character(reg[['Item encoded']][hit])
if (!nzchar(item_encoded) || grepl('_$', item_encoded)) stop('Invalid Item encoded')
utils::write.table(final.dataframe,
  file.path(root, '__Public', 'comparative-data', paste0(item_encoded, '.tsv')),
  sep='\t', row.names=FALSE, na='', fileEncoding='UTF-8')
cat(item_name, ': ', nrow(final.dataframe), ' species rows; ',
    sum(source_has_traits), ' with traits; ',
    sum(!is.na(final.dataframe$female_body_mass_g)),
    ' female body masses\n', sep='')
