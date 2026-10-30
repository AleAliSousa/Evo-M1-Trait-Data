# Cross-paper descriptive correlations; no inferential claim at n = 4.
args <- commandArgs(trailingOnly = FALSE)
script <- sub('^--file=', '', args[grepl('^--file=', args)][1])
if (is.na(script) || !nzchar(script)) stop('Run with Rscript')
folder <- dirname(normalizePath(script))
root <- dirname(folder)
s <- read.csv(file.path(folder, 'Sherwood_etal_2020_SuppTable2.csv'), check.names = FALSE)
k <- read.csv(file.path(root, 'Karl_etal_2024/Karl_etal_2024_TABLE1.csv'), check.names = FALSE)
s$species <- gsub('_', ' ', s$species_as_published, fixed = TRUE)
p <- merge(s, k, by.x = 'species', by.y = 'Species', sort = FALSE)
p <- p[order(p$species), ]
if (nrow(p) != 4L || !identical(p$species, c('Homo sapiens','Lemur catta','Pan troglodytes','Papio anubis'))) stop('Unexpected species overlap')
p$Karl_synapses_per_neuron_areal <- p[['Synapse density (mm2)']] / p[['Neuron density (mm2)']]
paired <- data.frame(species = p$species, Karl_brain_mass_g = p[['Brain mass (g)']], Sherwood_brain_mass_g = p$brain_mass_g,
  Karl_synapse_density_per_mm2 = p[['Synapse density (mm2)']], Karl_neuron_density_per_mm2 = p[['Neuron density (mm2)']],
  Karl_synapses_per_neuron_areal = p$Karl_synapses_per_neuron_areal,
  Sherwood_V1_II_III_synapse_density_per_mm3 = p$synapse_density_V1_II_III_per_mm3,
  Sherwood_V1_V_VI_synapse_density_per_mm3 = p$synapse_density_V1_V_VI_per_mm3,
  Sherwood_V1_II_III_neuron_density_per_mm3 = p$neuron_density_V1_II_III_per_mm3,
  Sherwood_V1_V_VI_neuron_density_per_mm3 = p$neuron_density_V1_V_VI_per_mm3,
  Sherwood_V1_II_III_synapses_per_neuron = p$synapses_per_neuron_V1_II_III,
  Sherwood_V1_V_VI_synapses_per_neuron = p$synapses_per_neuron_V1_V_VI)
write.csv(paired, file.path(folder, 'Sherwood2020_Karl2024_correlation_pairs.csv'), row.names = FALSE)
measures <- list(
  brain_mass = c('Karl_brain_mass_g','Sherwood_brain_mass_g'),
  synapse_density_V1_II_III = c('Karl_synapse_density_per_mm2','Sherwood_V1_II_III_synapse_density_per_mm3'),
  synapse_density_V1_V_VI = c('Karl_synapse_density_per_mm2','Sherwood_V1_V_VI_synapse_density_per_mm3'),
  neuron_density_V1_II_III = c('Karl_neuron_density_per_mm2','Sherwood_V1_II_III_neuron_density_per_mm3'),
  neuron_density_V1_V_VI = c('Karl_neuron_density_per_mm2','Sherwood_V1_V_VI_neuron_density_per_mm3'),
  synapses_per_neuron_V1_II_III = c('Karl_synapses_per_neuron_areal','Sherwood_V1_II_III_synapses_per_neuron'),
  synapses_per_neuron_V1_V_VI = c('Karl_synapses_per_neuron_areal','Sherwood_V1_V_VI_synapses_per_neuron'))
results <- do.call(rbind, lapply(names(measures), function(name) {
  pair <- measures[[name]]; x <- paired[[pair[1]]];y <- paired[[pair[2]]]
  loo <- vapply(seq_along(x), function(i) cor(log10(x[-i]),log10(y[-i])), 0.0)
  data.frame(measure = name, n = length(x), Karl_column = pair[1], Sherwood_column = pair[2],
    pearson_r_log10 = cor(log10(x),log10(y)), spearman_rho = cor(x,y,method='spearman'),
    leave_one_species_out_r_min = min(loo), leave_one_species_out_r_max = max(loo))
}))
write.csv(results, file.path(folder, 'Sherwood2020_Karl2024_correlations.csv'), row.names = FALSE)
print(results[,c('measure','n','pearson_r_log10','spearman_rho','leave_one_species_out_r_min','leave_one_species_out_r_max')], row.names=FALSE)
# Visual check: four species only; two Sherwood layers per Karl specimen.
png(file.path(folder, 'Sherwood2020_Karl2024_density_scatter.png'), width = 1400, height = 650, res = 150)
par(mfrow = c(1,2), mar = c(5,5,3,1), family = 'sans')
labels <- c('Human','Lemur','Chimp','Baboon')[match(paired$species, c('Homo sapiens','Lemur catta','Pan troglodytes','Papio anubis'))]
for (what in c('synapse','neuron')) {
  x <- paired[[paste0('Karl_',what,'_density_per_mm2')]]
  y1 <- paired[[paste0('Sherwood_V1_II_III_',what,'_density_per_mm3')]]
  y2 <- paired[[paste0('Sherwood_V1_V_VI_',what,'_density_per_mm3')]]
  plot(rep(x,2), c(y1,y2), type='n', log='xy', xlim=range(x)*c(.88,1.15), ylim=range(c(y1,y2))*c(.85,1.18), xlab='Karl 2024, per mm²',
       ylab='Sherwood 2020, per mm³', main=paste('V1',what,'density (4 species)'))
  points(x,y1,pch=16,col='#1f77b4',cex=1.2)
  points(x,y2,pch=17,col='#d95f02',cex=1.2)
  text(x,y1,labels,pos=ifelse(x==max(x),2,3),cex=.68,offset=.35)
  legend(if (what=='synapse') 'topleft' else 'bottomright',legend=c('Sherwood II–III','Sherwood V–VI'),pch=c(16,17),col=c('#1f77b4','#d95f02'),bty='n',cex=.75)
}
dev.off()
