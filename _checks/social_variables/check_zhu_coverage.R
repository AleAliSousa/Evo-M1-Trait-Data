# Usage: Rscript _checks/social_variables/check_zhu_coverage.R BEFORE.rds AFTER.rds
args <- commandArgs(TRUE); stopifnot(length(args)==2)
b <- readRDS(args[1]); a <- readRDS(args[2])
p <- '_checks/social_variables'
al <- read.csv('_keys/species_display_aliases.csv')
norm <- function(s) { m <- match(s,al$variant); ifelse(is.na(m),s,al$canonical[m]) }
co <- read.csv('_keys/species_cohorts.csv')
evo <- unique(norm(co$species_sci[co$cohort=='EvoM1'])); stopifnot(length(evo)==25)
labels <- c('Social_organization_Zhu2023 (category)','Solitary_living_Zhu2023 (category)',
            'Pair_living_Zhu2023 (category)','Group_living_Zhu2023 (category)')
z <- a[a$Variable==labels[1],]
stopifnot(nrow(z)==1008, !anyDuplicated(z$Species),
          all(is.na(a$Value_num[a$Variable %in% labels])))
for(l in labels) stopifnot(sum(a$Variable==l)==1008)
# Compare availability, not equivalence: these legacy codes combine social/mating concepts.
legacy <- c('Social_system','Social_system_Zimmermann2017 (category)')
old <- unique(b$Species[b$Variable %in% legacy])
old_group <- unique(b$Species[grepl('^Social_group_size',b$Variable)])
summary <- list()
for(scope in c('All species','EvoM1 (25)')) {
 within <- function(s) if(scope=='All species') unique(s) else intersect(s,evo)
 for(kind in c('Zhu social organization (new label)','Any social organization/system category (availability only)','Numerical group size')) {
  before <- switch(kind,'Zhu social organization (new label)'=character(),
                   'Numerical group size'=old_group,old)
  after <- switch(kind,'Zhu social organization (new label)'=z$Species,
                  'Numerical group size'=old_group,union(old,z$Species))
  before<-within(before);after<-within(after)
  summary[[length(summary)+1]]<-data.frame(scope,measure=kind,before=length(before),after=length(after),additional_species=length(setdiff(after,before)))
 }
}
s <- do.call(rbind,summary);print(s,row.names=FALSE)
write.csv(s,file.path(p,'Zhu_coverage_summary.csv'),row.names=FALSE)
detail <- data.frame(Species=evo,previous_category_available=evo %in% old,
                    Zhu_available=evo %in% z$Species,
                    Zhu_value=z$Value[match(evo,z$Species)],
                    additional_category_coverage=evo %in% setdiff(z$Species,old))
write.csv(detail,file.path(p,'Zhu_EvoM1_coverage.csv'),row.names=FALSE,na='')
write.csv(b[b$Variable %in% legacy,c('Species','Variable','Value','Source')],file.path(p,'Zhu_baseline_categories.csv'),row.names=FALSE)
write.csv(merge(z[,c('Species','Value','Source')],b[b$Variable %in% legacy,c('Species','Variable','Value','Source')],by='Species',all.x=TRUE,suffixes=c('_Zhu','_existing')),file.path(p,'Zhu_category_overlap_audit.csv'),row.names=FALSE,na='')
# Original source rows remain linked even when taxonomy is resolved for app display.
m <- read.csv('__merging_supplementary/supplementary_long.csv')
m <- m[m$Measure=='Social_organization_Zhu2023',]
source <- read.csv('Zhu_etal_2023/Zhu_etal_2023_SocialOrganization.csv')
source$species_printed <- gsub('_',' ',source$SpeciesName,fixed=TRUE)
joined <- merge(m,source,by='species_printed',all.x=TRUE)
stopifnot(nrow(joined)==1008,!anyNA(joined$source_item),sum(joined$primary_used)==5,
          all(joined$n_sources==1),all(joined$n_teams==1))
write.csv(joined,file.path(p,'Zhu_provenance_audit.csv'),row.names=FALSE,na='')
print(detail,row.names=FALSE)
cat('PASS: 1008 species x 4 categorical labels; 5 explicitly primary social records; no duplicate weighting.\n')
