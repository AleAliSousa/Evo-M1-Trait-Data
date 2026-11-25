## Reconstruct the tabulated inputs to Charvet et al. Figure 8.
## Cross-item interpretation belongs here, not in an individual item reader.
a <- grep('^--file=', commandArgs(FALSE), value=TRUE)
if (!length(a)) stop('Run with Rscript')
folder <- dirname(dirname(normalizePath(sub('^--file=','',a[1]))))
root <- dirname(folder)
read_item <- function(item) {
  d <- utils::read.csv(file.path(root,sub('_(SITable|Table).*$','',item),paste0(item,'.csv')),
                       check.names=FALSE, stringsAsFactors=FALSE)
  if (!nrow(d)) stop('Empty item: ',item)
  d
}
density_g_per_cm3 <- 1.036 # Charvet Figure 8 caption, not a source-paper measurement.
make_rows <- function(source_item, source_row, species_label, species, order,
                      mass_g, neurons, mass_sd_g=NA_real_, neurons_sd=NA_real_,
                      sample_n=NA_real_, source_scope, cortex_definition) {
  stopifnot(length(source_row)==length(species_label),
            length(mass_g)==length(species_label),
            length(neurons)==length(species_label))
  unilateral_mass <- mass_g/2
  unilateral_neurons <- neurons/2
  volume_cm3 <- unilateral_mass/density_g_per_cm3
  data.frame(source_item,source_row,species_as_published=species_label,
             Species=species,Order=order,cortex_definition,source_scope,
             source_mass_g=mass_g,source_mass_SD_g=mass_sd_g,
             source_neurons=neurons,source_neurons_SD=neurons_sd,
             sample_n,unilateral_mass_g=unilateral_mass,
             unilateral_neurons=unilateral_neurons,
             volume_cm3=volume_cm3,ln_volume_cm3=log(volume_cm3),
             ln_neurons_million=log(unilateral_neurons/1e6),
             volume_conversion_g_per_cm3=density_g_per_cm3,
             plot_status='table-based source coordinate',stringsAsFactors=FALSE)
}

hh <- read_item('HerculanoHouzel_etal_2007_SITable2')
hh <- hh[hh$structure_as_published=='Cortex' & hh$Order=='Primata',]
stopifnot(nrow(hh)==6L)
hh_out <- make_rows('HerculanoHouzel_etal_2007_SITable2',hh$source_row,
                    hh$Species_as_published,hh$Species,hh$Order,
                    hh$mass_g,hh$neurons,hh$mass_g_SD,hh$neurons_SD,hh$Number,
                    'published bilateral estimate; one hemisphere measured then doubled',
                    'cerebral cortex including hippocampus and piriform cortex')
hh_out$series <- 'Primates — isotropic fractionator'

gabi <- read_item('Gabi_etal_2010_Table1')
stopifnot(nrow(gabi)==5L)
gabi_out <- make_rows('Gabi_etal_2010_Table1',seq_len(nrow(gabi)),
                      gabi[['Common name']],gabi$Species,gabi$Order,
                      gabi[['Cerebral cortex Mass, g']],
                      gabi[['Cerebral cortex N, n']],
                      sample_n=gabi$Number,
                      source_scope='published bilateral estimate; one hemisphere measured then doubled',
                      cortex_definition='cerebral cortex including limbic cortex')
gabi_out$series <- 'Primates — isotropic fractionator'

glires <- read_item('HerculanoHouzel_etal_2011_Table1')
rodent <- glires[glires$Order=='Rodentia',]
stopifnot(nrow(rodent)==10L,nrow(glires)==11L)
rodent_out <- make_rows('HerculanoHouzel_etal_2011_Table1',
                        match(rodent$Species,glires$Species),rodent[['Common name']],
                        rodent$Species,rodent$Order,
                        rodent[['Cerebral cortex Mass, g']],
                        rodent[['Cerebral cortex N, n']],
                        rodent[['Cerebral cortex Mass, g SD']],
                        rodent[['Cerebral cortex N, n SD']],rodent$Number,
                        'published bilateral estimate; measured both or doubled one hemisphere',
                        'cerebral cortex including hippocampus and piriform cortex')
rodent_out$series <- 'Rodents — isotropic fractionator'

own <- read_item('Charvet_etal_2013_Table2')
stopifnot(nrow(own)==6L)
own_out <- data.frame(source_item='Charvet_etal_2013_Table2',
  source_row=own$source_column,species_as_published=own$species_as_published,
  Species=own$Species,Order=ifelse(own$species_as_published %in%
    c('Capuchin','Owl monkey','Tamarin'),'Primata','Rodentia'),
  cortex_definition='isocortex, layers II–VI',source_scope='published unilateral estimate',
  source_mass_g=NA_real_,source_mass_SD_g=NA_real_,
  source_neurons=own$total_isocortical_neurons,source_neurons_SD=NA_real_,
  sample_n=1,unilateral_mass_g=NA_real_,
  unilateral_neurons=own$total_isocortical_neurons,
  volume_cm3=NA_real_,ln_volume_cm3=NA_real_,
  ln_neurons_million=log(own$total_isocortical_neurons/1e6),
  volume_conversion_g_per_cm3=NA_real_,
  plot_status='neuron coordinate only; isocortex volume not printed in Table 2',
  series=ifelse(own$species_as_published %in% c('Capuchin','Owl monkey','Tamarin'),
                'Primates — this study','Rodents — this study'),stringsAsFactors=FALSE)

final.dataframe <- rbind(hh_out,gabi_out,rodent_out,own_out)
final.dataframe <- final.dataframe[c('series',setdiff(names(final.dataframe),'series'))]
stopifnot(nrow(final.dataframe)==27L,
          sum(is.finite(final.dataframe$ln_volume_cm3))==21L,
          sum(is.na(final.dataframe$ln_volume_cm3))==6L,
          all(is.finite(final.dataframe$ln_neurons_million)))
out <- file.path(folder,'internal_checks','Charvet_etal_2013_Figure8_source_points.csv')
utils::write.csv(final.dataframe,out,row.names=FALSE,na='',fileEncoding='UTF-8')
cat('Figure 8 sources: ',nrow(final.dataframe),' rows; 21 full coordinates, 6 neuron-only\n',sep='')
