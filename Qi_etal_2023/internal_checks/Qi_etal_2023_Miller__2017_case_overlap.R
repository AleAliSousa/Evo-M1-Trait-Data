# Cross-item identity check only. No measurements feed either analysis item.
root <- normalizePath('.')
qi1 <- read.csv(file.path(root,'Qi_etal_2023','Qi_etal_2023_TableS1_snapshot.csv'),check.names=FALSE,colClasses='character')
qi2 <- read.csv(file.path(root,'Qi_etal_2023','Qi_etal_2023_TableS2_snapshot.csv'),check.names=FALSE,colClasses='character')
m <- read.csv(file.path(root,'Miller__2017','Miller__2017_Table9_snapshot.csv'),check.names=FALSE,colClasses='character')
q <- rbind(data.frame(item='Qi_etal_2023_TableS1',case_qi=qi1[['Case #']],species_qi=qi1$Species),
           data.frame(item='Qi_etal_2023_TableS2',case_qi=qi2[['Case #']],species_qi=qi2$Species))
q$key <- gsub('-','_',q$case_qi,fixed=TRUE)
hit <- merge(m,q,by.x='Case',by.y='key',all=FALSE,sort=FALSE)
hit <- hit[order(hit$item,hit$case_qi),c('Case','Genus','item','case_qi','species_qi','Stain','Side','Degree','Recovery')]
names(hit) <- c('case_miller','genus_miller','item_qi','case_qi','species_qi','stain_miller','side_miller','degree_miller','recovery_days_miller')
stopifnot(nrow(hit)==18L,length(unique(hit$case_qi))==18L,
          sum(hit$item_qi=='Qi_etal_2023_TableS1')==1L,
          sum(hit$item_qi=='Qi_etal_2023_TableS2')==17L)
write.csv(hit,file.path(root,'Qi_etal_2023','internal_checks','Qi_etal_2023_Miller__2017_case_overlap.csv'),row.names=FALSE,na='')
cat(nrow(hit),'exact case-code overlaps after hyphen/underscore normalization\n')
