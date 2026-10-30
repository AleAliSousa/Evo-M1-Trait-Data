# Usage: Rscript _checks/social_variables/check_population_censuses.R BEFORE.rds AFTER.rds
args<-commandArgs(TRUE);stopifnot(length(args)==2)
b<-readRDS(args[1]);a<-readRDS(args[2]);al<-read.csv('_keys/species_display_aliases.csv')
norm<-function(x){i<-match(x,al$variant);ifelse(is.na(i),x,al$canonical[i])}
b$Species<-norm(b$Species);a$Species<-norm(a$Species)
co<-read.csv('_keys/species_cohorts.csv');evo<-unique(norm(co$species_sci[co$cohort=='EvoM1']))
patterns<-c(social_group='^Social_group_size',population_group='^Population_group_size',either_group='^(Social_group_size|Population_group_size)',including_den_occupancy='^(Social_group_size|Population_group_size|Den_occupancy_mean_)',social_categories='^Social_(organization|system)')
rows<-list()
for(kind in names(patterns)) for(scope in c('All species','EvoM1')) {
 get<-function(d){i<-grepl(patterns[[kind]],d$Variable);if(kind!='social_categories')i<-i & !is.na(d$Value_num);x<-unique(d$Species[i]);if(scope=='EvoM1')intersect(x,evo) else x}
 old<-get(b);new<-get(a)
 rows[[length(rows)+1]]<-data.frame(measure=kind,scope,before=length(old),after=length(new),additional_species=length(setdiff(new,old)))
}
s<-do.call(rbind,rows);print(s);write.csv(s,'_checks/social_variables/population_census_coverage.csv',row.names=FALSE)
cat_labels<-c('Social_organization_Jaeggi2020 (category)','Social_organization_Qiu2022 (category)')
stopifnot(sum(a$Variable==cat_labels[1])==100,sum(a$Variable==cat_labels[2])==64,all(is.na(a$Value_num[a$Variable %in% cat_labels])))
vals<-c('Social_group_size_population_mean_Ziege2016 (count)'=4.14,'Population_group_size_colony_Modlinska2016 (count)'=50,'Den_occupancy_mean_Norbury1998 (count)'=43/41)
for(l in names(vals))stopifnot(sum(a$Variable==l)==1,abs(a$Value_num[a$Variable==l]-vals[[l]])<1e-8)
# Additions per source, versus pre-pass category availability; not independent study counts.
old<-unique(b$Species[grepl(patterns[['social_categories']],b$Variable)])
addition<-do.call(rbind,lapply(cat_labels,function(l){sp<-unique(a$Species[a$Variable==l]);data.frame(label=l,species=length(sp),additional_category_species=length(setdiff(sp,old)),EvoM1_species=length(intersect(sp,evo)),additional_EvoM1_species=length(setdiff(intersect(sp,evo),old)))}))
print(addition);write.csv(addition,'_checks/social_variables/population_category_additions.csv',row.names=FALSE)
m<-read.csv('__merging_supplementary/supplementary_long.csv')
i<-grepl('Jaeggi2020|Qiu2022|Ziege2016|Modlinska2016|Norbury1998',m$Measure)
stopifnot(sum(i)==167,all(m$n_sources[i]==1),all(m$n_teams[i]==1),sum(m$primary_used[i])==3)
write.csv(a[grepl('Jaeggi2020|Qiu2022|Ziege2016|Modlinska2016|Norbury1998',a$Variable),],'_checks/social_variables/population_census_app_values.csv',row.names=FALSE)
cat('PASS: 164 categorical summaries; three distinct numerical metrics; source roles and one-team weighting verified.\n')
