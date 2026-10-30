# Usage: Rscript _checks/social_variables/compare_coverage.R BEFORE.rds AFTER.rds
# Inputs are app.R's actual `compiled` tables loaded with EVOM1_SOURCE=local.
a <- commandArgs(TRUE); stopifnot(length(a)==2)
before <- if (grepl("\\.csv$", a[1])) read.csv(a[1], stringsAsFactors=FALSE) else readRDS(a[1])
after <- readRDS(a[2])
co <- read.csv('_keys/species_cohorts.csv',stringsAsFactors=FALSE)
al <- read.csv('_keys/species_display_aliases.csv',stringsAsFactors=FALSE)
normalize <- function(s) { m <- match(s,al$variant); ifelse(is.na(m),s,al$canonical[m]) }
co$species_sci <- normalize(co$species_sci)
evo <- unique(co$species_sci[co$cohort=='EvoM1']); stopifnot(length(evo)==25)
new_label <- 'Social_group_size_DunbarBever1998 (count)'
new <- after[after$Variable==new_label,]; stopifnot(nrow(new)>0, !anyDuplicated(new$Species))
# Broad availability includes the other source-specific group-size definitions;
# it is a coverage union, NOT a ruling that their measurements are interchangeable.
old_labels <- unique(before$Variable[grepl('^Social_group_size',before$Variable)])
old_group <- unique(before$Species[before$Variable %in% old_labels & !is.na(before$Value_num)])
new_group <- unique(new$Species)
old_system <- unique(before$Species[before$Variable=='Social_system'])
new_system <- unique(after$Species[after$Variable=='Social_system'])
stopifnot(setequal(old_system,new_system),all(is.na(after$Value_num[after$Variable=='Social_system'])),
          all(after$Value[after$Variable=='Social_system'] %in% c('Solitary','Monogamous','Multi-male','Harem')))
summary <- list(); k <- 0
for(scope in c('All species','EvoM1 (25)')) {
 subset <- function(s) if(scope=='All species') unique(s) else intersect(s,evo)
 for(kind in c('Dunbar & Bever source label','Any social-group-size source','Social-system category labels')) {
  b <- switch(kind,'Dunbar & Bever source label'=character(),'Any social-group-size source'=old_group,'Social-system category labels'=old_system)
  n <- switch(kind,'Dunbar & Bever source label'=new_group,'Any social-group-size source'=union(old_group,new_group),'Social-system category labels'=new_system)
  b<-subset(b); n<-subset(n); k<-k+1
  summary[[k]]<-data.frame(scope=scope,addition=kind,before=length(b),after=length(n),additional_species=length(setdiff(n,b)),species_added=paste(sort(setdiff(n,b)),collapse='; '))
 }
}
out <- '_checks/social_variables'
write.csv(do.call(rbind,summary),file.path(out,'coverage_summary.csv'),row.names=FALSE)
detail <- data.frame(Species=evo,group_size_before=evo %in% old_group,Dunbar_Bever_available=evo %in% new_group,group_size_after=evo %in% union(old_group,new_group),social_system_available=evo %in% new_system)
write.csv(detail,file.path(out,'EvoM1_species_coverage.csv'),row.names=FALSE)
# Preserve all existing values alongside the new values, rather than collapsing disagreements.
old <- before[before$Variable %in% old_labels & before$Species %in% new_group,c('Species','Variable','Value','Source')]
write.csv(merge(new[,c('Species','Value','Source')],old,by='Species',all.x=TRUE,suffixes=c('_DunbarBever','_existing')),file.path(out,'group_size_overlap_audit.csv'),row.names=FALSE)
write.csv(data.frame(Variable=old_labels),file.path(out,'baseline_group_size_labels.csv'),row.names=FALSE)
print(do.call(rbind,summary),row.names=FALSE)
