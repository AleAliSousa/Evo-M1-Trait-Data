# Usage: Rscript _checks/social_variables/check_social_expansion.R BEFORE.rds AFTER.rds
args <- commandArgs(TRUE); stopifnot(length(args)==2)
b <- readRDS(args[1]); a <- readRDS(args[2])
al <- read.csv('_keys/species_display_aliases.csv')
norm <- function(s) {m<-match(s,al$variant);ifelse(is.na(m),s,al$canonical[m])}
b$Species<-norm(b$Species);a$Species<-norm(a$Species)
co<-read.csv('_keys/species_cohorts.csv');evo<-unique(norm(co$species_sci[co$cohort=='EvoM1']))
patterns<-c(social_group='^Social_group_size',population_group='^Population_group_size',either='^(Social_group_size|Population_group_size)')
rows<-list()
for(kind in names(patterns)) for(scope in c('All species','EvoM1')) {
 get<-function(d) {x<-unique(d$Species[grepl(patterns[[kind]],d$Variable)&!is.na(d$Value_num)]);if(scope=='EvoM1')intersect(x,evo) else x}
 old<-get(b);new<-get(a)
 rows[[length(rows)+1]]<-data.frame(measure=kind,scope,before=length(old),after=length(new),additional_species=length(setdiff(new,old)))
}
out<-do.call(rbind,rows);write.csv(out,'_checks/social_variables/social_expansion_coverage.csv',row.names=FALSE);print(out)
new<-a[grepl('Wiafe2019|Devillard2003',a$Variable),]
stopifnot(nrow(new)==5,all(!is.na(new$Value_num)))
write.csv(new,'_checks/social_variables/social_expansion_new_values.csv',row.names=FALSE)
z<-a[grepl('Zhu2023',a$Variable),];stopifnot(nrow(z)==4032,all(is.na(z$Value_num)))
u<-read.csv('__merging_supplementary/supplementary_unresolved_species.csv');stopifnot(!any(grepl('Zhu',apply(u,1,paste,collapse=' '))))
cat('PASS: five numerical additions; 4032 categorical Zhu rows; no unresolved Zhu rows.\n')
