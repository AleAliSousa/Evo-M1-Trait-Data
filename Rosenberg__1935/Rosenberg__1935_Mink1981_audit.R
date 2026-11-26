#!/usr/bin/env Rscript
# Reproduce the comparison, without treating a cross-species extrapolation as
# a Rosenberg measurement. Read the built primary tables and Mink Table 1.
arg <- grep('^--file=',commandArgs(FALSE),value=TRUE)
if (!length(arg)) stop('Run with Rscript Rosenberg__1935_Mink1981_audit.R')
folder <- dirname(normalizePath(sub('^--file=','',arg[1])))
root <- dirname(folder)
tab1 <- read.csv(file.path(folder,'Rosenberg__1935_TableI.csv'),check.names=FALSE)
tab2 <- read.csv(file.path(folder,'Rosenberg__1935_TableII.csv'),check.names=FALSE)
mink <- read.csv(file.path(root,'Mink_etal_1981','Mink_etal_1981_TABLE1.csv'),
                 check.names=FALSE,na.strings=c('','NA'))
frog <- mink[mink$species_as_published=='Rana pipiens',,drop=FALSE]
stopifnot(nrow(frog)==1L, frog$ref_keys_spinal_metabolic_rate=='82',
          unique(tab1$species_as_published)=='Rana esculenta L.',
          unique(tab2$species_as_published)=='Rana esculenta L.')
brain_rate <- frog[['brain_metabolic_rate.cm3O2.100g.min']]
spinal_rate <- frog[['spinal_metabolic_rate.cm3O2.100g.min']]

# Table I compares only months with BOTH brain and cord means. Different
# experiments can underlie the two means, so this is a ratio of monthly means,
# not a paired-specimen estimate.
b <- tab1[tab1$tissue=='brain',c('month_as_published','oxygen_mm3_per_g_h')]
s <- tab1[tab1$tissue=='spinal_cord',c('month_as_published','oxygen_mm3_per_g_h')]
paired_months <- merge(b,s,by='month_as_published')
stopifnot(nrow(paired_months)==7L)
evidence <- list(data.frame(
  basis='Table I, seven common months, unweighted ratio of monthly means',
  brain_o2_mm3_per_g_h=mean(paired_months$oxygen_mm3_per_g_h.x),
  spinal_o2_mm3_per_g_h=mean(paired_months$oxygen_mm3_per_g_h.y),
  n_months=7L,stringsAsFactors=FALSE))
for (season in c('grenouilles d\'hiver','grenouilles de printemps')) {
  x <- tab2[tab2$statistic=='printed_mean' & tab2$season_as_published==season,]
  evidence[[length(evidence)+1L]] <- data.frame(
    basis=paste('Table II, printed means,',season),
    brain_o2_mm3_per_g_h=x$oxygen_mm3_per_g_h[x$tissue=='brain'],
    spinal_o2_mm3_per_g_h=x$oxygen_mm3_per_g_h[x$tissue=='spinal_cord'],
    n_months=NA_integer_,stringsAsFactors=FALSE)
}
x <- tab2[tab2$statistic=='printed_mean',]
evidence[[length(evidence)+1L]] <- data.frame(
  basis='Table II, pooled winter and spring printed means',
  brain_o2_mm3_per_g_h=mean(x$oxygen_mm3_per_g_h[x$tissue=='brain']),
  spinal_o2_mm3_per_g_h=mean(x$oxygen_mm3_per_g_h[x$tissue=='spinal_cord']),
  n_months=NA_integer_,stringsAsFactors=FALSE)
out <- do.call(rbind,evidence)
out$spinal_to_brain_ratio <- out$spinal_o2_mm3_per_g_h/out$brain_o2_mm3_per_g_h
out$mink_brain_rate_cm3_per_100g_min <- brain_rate
out$mink_implied_spinal_rate_cm3_per_100g_min <- brain_rate*out$spinal_to_brain_ratio
out$mink_printed_spinal_rate_cm3_per_100g_min <- spinal_rate
out$implied_minus_printed_cm3_per_100g_min <-
  out$mink_implied_spinal_rate_cm3_per_100g_min-spinal_rate
out$rosenberg_species <- 'Rana esculenta L.'
out$mink_species <- frog$species_as_published
out$source_basis <- 'Rosenberg: isolated tissue oxygen use, values normalized to 20 C; Mink: cross-species inferred rate'
write.csv(out,file.path(folder,'Rosenberg__1935_Mink1981_audit.csv'),
          row.names=FALSE,na='',fileEncoding='UTF-8')
print(out[,c('basis','spinal_to_brain_ratio',
             'mink_implied_spinal_rate_cm3_per_100g_min',
             'mink_printed_spinal_rate_cm3_per_100g_min')],row.names=FALSE)
