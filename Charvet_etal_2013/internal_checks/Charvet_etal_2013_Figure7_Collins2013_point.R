## Table-derived Collins et al. 2013 source point for Charvet Figure 7.
a <- grep('^--file=',commandArgs(FALSE),value=TRUE)
if(!length(a))stop('Run with Rscript')
folder <- dirname(normalizePath(sub('^--file=','',a[1])))
root <- dirname(dirname(folder))
s <- utils::read.csv(file.path(root,'Collins_etal_2013','Collins_etal_2013_Table1.csv'),
                     stringsAsFactors=FALSE)
v <- s[s$Species=='Macaca mulatta' & s$structure=='V1',]
mass <- v[v$measure=='mass',]
neurons <- v[v$measure=='neurons',]
stopifnot(nrow(mass)==1L,nrow(neurons)==1L,
          mass$measurement_scope=='single hemisphere',
          neurons$measurement_scope=='single hemisphere')
density_g_per_cm3 <- 1.036 # Charvet Figure 8 caption; inferred reuse for Figure 7.
out <- data.frame(source_item='Collins_etal_2013_Table1',
  species_as_published=mass$species_as_published,Species=mass$Species,
  n_individuals=mass$n_individuals,n_hemispheres=mass$n_hemispheres,
  V1_mass_g=mass$value,V1_mass_SD_g=mass$sd,
  V1_neurons=neurons$value,V1_neurons_SD=neurons$sd,
  inferred_V1_volume_mm3=mass$value/density_g_per_cm3*1000,
  inferred_V1_volume_SD_mm3=mass$sd/density_g_per_cm3*1000,
  conversion_g_per_cm3=density_g_per_cm3,
  volume_status='inferred from mass using Charvet Figure 8 density; not directly measured volume',
  stringsAsFactors=FALSE)
utils::write.csv(out,file.path(folder,'Charvet_etal_2013_Figure7_Collins2013_point.csv'),
                 row.names=FALSE,na='',fileEncoding='UTF-8')
print(out[c('V1_mass_g','V1_neurons','inferred_V1_volume_mm3')])
