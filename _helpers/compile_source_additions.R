# Source-aware additions: keep protocol, source row, raw values, and exclusion decisions.
# This helper is called by domain scripts; it never treats compilations as replicates.
compile_source_additions <- function(base, domain) {
  suppressPackageStartupMessages({library(dplyr);library(tidyr);library(readr)})
  specs <- jsonlite::fromJSON(file.path(base,'_keys/source_builds/nick_fran_2026.json'),simplifyVector=FALSE)
  source(file.path(base,'_keys/resolve_species.R'))
  rows <- list(); exclusions <- list()
  add <- function(x,d,i,code,measure=code,unit='',role=x$role,priority=10,context='',value=NULL,n=1,reason='') {
    if(is.null(value)) {
      value <- d[[code]][i]
      if(is.na(value) || !nzchar(value)) {
        lo <- paste0(code,'_lower');hi<-paste0(code,'_upper');qu<-paste0(code,'_qualifier')
        l<-if(lo %in% names(d)) d[[lo]][i] else ''; h<-if(hi %in% names(d)) d[[hi]][i] else ''
        q<-if(qu %in% names(d)) d[[qu]][i] else ''
        if(nzchar(l) && nzchar(h)) value<-paste0(l,'–',h)
        else if(nzchar(l)) value<-paste0(q,l) else if(nzchar(h)) value<-paste0(q,h) else return(invisible(NULL))
      }
    }
    sp<-if('species_as_published' %in% names(d)) d$species_as_published[i] else ''
    if(x$folder=='Smaers_etal_2011_b') sp<-sub(' \\([^)]*\\)$','',d$species_and_specimen_as_published[i])
    if(x$folder=='Smaers_etal_2013') sp<-trimws(sub(' \\(.*','',sp))
    sp<-gsub('[ᵃᵇ]','',sp)
    rr<-resolve_species(sp,source_publication=x$folder)
    src_ref <- if('references_raw' %in% names(d)) d$references_raw[i] else if('references_exceptions' %in% names(d)) d$references_exceptions[i] else ''
    rows[[length(rows)+1]]<<-data.frame(Species=rr$accepted_name,species_printed=sp,accepted_name=rr$accepted_name,species_basis=rr$species_basis,reidentified=rr$reidentified,
      Measure=measure,Units=unit,Value=as.character(value),Source_item=x$item,source_row=as.character(d$source_row[i]),Code=code,role=role,priority=priority,
      Context=context,n_observations=n,reference_keys=src_ref,selection_note=reason,stringsAsFactors=FALSE)
  }
  for(x in specs) {
    f<-x$folder; d<-read.csv(file.path(base,f,paste0(x$item,'.csv')),check.names=FALSE,colClasses='character',na.strings=NULL)
    if(domain=='taste') {
      if(x$kind=='taste') for(i in seq_len(nrow(d))) for(c in x$columns[2:6]) {
        self<-(f=='Norlen_etal_2019' && d$species_as_published[i]=='Pan troglodytes verus') || (f=='RedinHurtado_etal_2023' && d$species_as_published[i]=='Pithecia pithecia')
        endpoint<-if(d$species_as_published[i]=='Homo sapiens') 'detection' else 'preference'
        add(x,d,i,c$code,sub('_threshold.mM',paste0('_',endpoint,'_threshold'),c$code,fixed=TRUE),'mM',if(self)'primary' else 'secondary',if(self)100 else if(f=='RedinHurtado_etal_2023')30 else 20,'two-bottle preference except human detection',reason='Shared compilation reports are not independent; later compilation is a reporting priority, not an extra study.')
      }
      if(f=='Simmen_Hladik_1998') for(i in seq_len(nrow(d))) add(x,d,i,'Quinine_HCl_threshold.mM','Quinine_HCl_legacy_threshold','mM','secondary',10,'legacy methods; see source-specific references',reason='Sweet endpoints covered by later compilations; quinine added separately with source multiplier 0.1 mM.')
      if(f=='Laska_etal_2009') for(i in seq_len(nrow(d))) for(c in x$columns[-1]) add(x,d,i,c$code,sub('.mM','_30mM_sucrose_background',c$code,fixed=TRUE),'mM','primary',100,'2-min two-bottle avoidance; 30 mM sucrose background')
      if(f=='Laska_etal_2003') for(i in seq_len(nrow(d))) for(c in x$columns[-1]) add(x,d,i,c$code,sub('.mM','_preference_over_50mM_sucrose',c$code,fixed=TRUE),'mM','primary',100,'citric-acid/sucrose mixture; reference 50 mM sucrose')
      if(f=='Simmen_Charlot_2003') for(i in seq_len(nrow(d))) {
        c<-x$columns[[2]];m<-if(x$locus=='Figure1')'Fructose_preference_threshold' else 'Tannic_acid_inhibition_threshold'
        add(x,d,i,c$code,m,'mM','primary',100,'reported threshold interval',reason='Primary interval retained instead of compiled midpoint.')
      }
      if(f=='Norlen_etal_2019' && x$locus=='Figure3') for(i in seq_len(nrow(d))) add(x,d,i,'Sucrose_Weber_ratio',paste0('Sucrose_Weber_ratio_reference_',d$reference_sucrose.mM[i],'mM'),'ratio','primary',100,'three chimpanzees; species threshold')
      if(f=='Norlen_etal_2019' && x$locus=='Figure2') for(i in seq_len(nrow(d))) add(x,d,i,'result',paste0('Relative_preference_',d$preferred_sugar[i],'_over_',d$comparison_sugar[i],'_',d$equimolar_concentration.mM[i],'mM'),'category','primary',100,'significant contrasts explicitly reported; other contrasts not inferred')
      if(f=='Laska_etal_2008') for(i in seq_len(nrow(d))) add(x,d,i,'Weber_ratio_range',paste0(d$compound[i],'_Weber_ratio_across_tested_conditions'),'ratio','primary',100,'reported range across subjects and concentrations; not a mean')
    }
    if(domain=='social_mirror_play') {
      if(f %in% c('Carnes_etal_2011','Lindenfors_etal_2007')) for(i in seq_len(nrow(d))) for(c in x$columns) {
        if(c$code %in% c('Adult_males.N','Adult_females.N','Breeding_season.d','Estrus_duration.d','Expected_overlap','Seasonality_r'))
          add(x,d,i,c$code,c$code,c$unit,'secondary',if(f=='Carnes_etal_2011')30 else 20,'published compilation',reason='Select Carnes2011 where present; retain Lindenfors2007 as alternative, never average reused group-composition reports.')
      }
      if(f=='Kerney_etal_2017' && x$locus=='OnlineResource2') for(i in seq_len(nrow(d))) add(x,d,i,'Play_time.pct','Play_time_all_activity_Kerney2017','percent','secondary',30,'mixed age/sex classes and sources; derivation in OnlineResource1')
      if(f=='Bartlett__2003' && x$locus=='Figure4') for(i in seq_len(nrow(d))) add(x,d,i,'Play_share_of_social_activity.pct',paste0('Play_share_of_social_activity_',d$age_class[i],'_Bartlett2003'),'percent','primary',100,'age groups overlap; denominator social activity')
      if(f=='Bartlett__2003' && x$locus=='Figure5') for(i in seq_len(nrow(d))) for(code in c('Play_time.pct','Groom_time.pct')) add(x,d,i,code,paste0(code,'_',d$month[i],'_Bartlett2003_digitized'),'percent','primary',100,'digitized stacked bar; approximate ±0.2 percentage point; monthly, not annual')
      if(f=='Mallavarapu__2001') for(i in seq_len(nrow(d))) add(x,d,i,'Play_composition.pct',paste0(gsub(' ','_',d$behaviour[i]),'_share_of_play_time_infants_Mallavarapu2001'),'percent','primary',100,'five infants; denominator play time',n=5)
      if(f=='Povinelli_etal_1993') add(x,d,1,'mark_test_result','Mirror_mark_pass_fraction_Povinelli1993','proportion','primary',100,'30 subjects; Table5 only, prior SR grouping not used as outcome',value=sum(d$mark_test_result=='Passed')/nrow(d),n=nrow(d))
      if(f=='Suddendorf_CollierBaker_2009') {
        a<-d[!grepl('Arjuna \\(2\\)',d$subject_demographics),]
        for(sp in unique(a$species_as_published)) {g<-a[a$species_as_published==sp,];add(x,g,1,'head_mark','Mirror_head_mark_pass_fraction_Suddendorf2009','proportion','primary',100,'first test per subject; repeat Arjuna excluded',value=sum(g$head_mark=='pass')/nrow(g),n=nrow(g))}
      }
      if(f=='Lethmate_Ducker_1973') for(i in which(d$Autor=='eigene Untersuchungen' & d$Farbmarkierungstest!='nicht getestet')) add(x,d,i,'Farbmarkierungstest','Mirror_mark_result_Lethmate1973','category','primary',100,'current-study rows only',value=if(d$Farbmarkierungstest[i]=='+')'positive' else 'negative')
      if(f=='InoueNakamura__1997') for(i in which(grepl('*',d$references_raw,fixed=TRUE))) add(x,d,i,'Self_directed_behaviour','Mirror_self_directed_behaviour_Inoue1997','category','primary',100,'present study; not a mark-test outcome',value=if(grepl('○',d$Self_directed_behaviour[i],fixed=TRUE))'positive' else 'negative; see footnote b where present')
      if((f=='Chang_etal_2015' && x$locus=='Figure2') || (f=='Chang_etal_2017' && x$locus=='Figure2')) add(x,d,1,'dye_mark_test_result',paste0('Mirror_dye_mark_pass_fraction_',if(f=='Chang_etal_2015')'Chang2015_somatosensory_trained_home_cage' else 'Chang2017_proprioceptive_trained'),'proportion','primary',100,d$training[1],value=sum(d$dye_mark_test_result=='passed')/nrow(d),n=nrow(d))
      if(f=='Chang_etal_2017' && x$locus=='Table1') for(i in which(!(d$behaviour_as_published %in% c('GR','GU','Total')))) for(group in c('C','M')) {
        cols<-paste0(group,1:3,'_count'); vals<-as.numeric(d[i,cols]);if(all(is.na(vals)))next
        add(x,d,i,cols[1],paste0('Mirror_',gsub('[^A-Za-z0-9]+','_',d$behaviour_as_published[i]),'_Chang2017_',if(group=='M')'trained' else 'control'),'mean count/subject','primary',100,'five 1-hour observations; group mean from the three named subjects; totals excluded',value=mean(vals),n=3)
      }
      if(f=='Suarez_Gallup_1981' && x$locus=='Table2') for(i in seq_len(nrow(d))) for(c in x$columns[-1]) add(x,d,i,c$code,paste0('Mirror_',c$code,'_',d$subject[i],'_Suarez1981'),'count','primary',100,'William brow mark accidentally lost; zero is not a pass/fail classification')
      if(f=='Suarez_Gallup_1981' && x$locus %in% c('Figure3','Figure7','Figure11')) for(i in seq_len(nrow(d))) add(x,d,i,if(x$locus=='Figure3') 'result' else 'mark_test_result',paste0('Mirror_mark_result_',d$subject[i],'_Suarez1981'),'category','primary',100,'exact stated result; Dyak inconclusive; individual experiment retained')
      if(f=='Chang_etal_2015' && x$locus=='Figure4') for(i in seq_len(nrow(d))) add(x,d,i,'events_in_5_days_mean',paste0('Mirror_',d$behaviour_class[i],'_Chang2015_',d$group[i]),'mean count/subject','primary',100,'five one-hour observations; different training-to-test delays; same subjects as Figure2',n=as.numeric(d$subjects.N[i]))
      if(f=='Posada_Colell_2007') for(i in which(d$behaviour!='Total')) for(c in x$columns) if(grepl('_count$',c$code)) add(x,d,i,c$code,paste0('Mirror_',gsub('-','_',d$behaviour[i]),'_',c$code,'_Xebo_Posada2007'),'count','primary',100,'one subject; different phase durations; published table total/percent errors retained')
      if(f=='Gallup__1970') for(i in seq_len(nrow(d))) add(x,d,i,'mark_directed_response',paste0('Mirror_mark_response_Gallup1970_',gsub(' ','_',d$cohort[i])),'category','primary',100,d$exposure[i],n=as.numeric(d$subjects.N[i]))
      if(f=='Westergaard_Hyatt_1994') add(x,d,1,'self_inspection_subjects.N','Mirror_self_inspection_fraction_Westergaard1994','proportion','primary',100,'self-inspection; dye mark test not administered',value=as.numeric(d$self_inspection_subjects.N)/as.numeric(d$subjects.N),n=9)
      if(f=='Reiss_Marino_2001') add(x,d,1,'first_behaviour_mark_oriented.N','Mirror_mark_orientation_session_fraction_Reiss2001_subject1_phase2','proportion','primary',100,'6 oriented, 2 ambiguous; eight sessions on one dolphin, not eight animals',value=6/8,n=8)
      if(f=='Plotnik_etal_2006') for(c in x$columns[-(1:3)]) add(x,d,1,c$code,paste0('Mirror_',c$code,'_Happy_first_mark_day_Plotnik2006'),'count','primary',100,'one elephant, first mark day; mark/sham and repeated tests separate')
    }
    if(domain=='claustrum_cerebellar') {
      if(f=='Kowianski_etal_1999') for(i in seq_len(nrow(d))) for(c in x$columns) if(grepl('^Claustrum',c$code)) add(x,d,i,c$code,paste0(c$code,'_Kowianski1999_fixed_tissue'),c$unit,'primary',100,'fixed tissue; published mean ± SEM; density-derived neuron number; hemisphere basis retained')
      if(f=='Smaers_etal_2011_b') for(i in seq_len(nrow(d))) for(code in c('CC','SC','FL')) add(x,d,i,code,paste0(c(CC='Cerebrocerebellum',SC='Spinocerebellum',FL='Flocculonodular_lobe')[[code]],'_volume_Smaers2011'),'mm3','primary',100,'current-study structures only; source specimen retained')
      if(f=='Smaers_etal_2013') for(i in seq_len(nrow(d))) for(code in c('Left_PCH','Right_PCH')) add(x,d,i,code,paste0(code,'_volume_Smaers2013'),'mm3','primary',100,paste('specimen',d$individual[i],'; left/right kept separate'))
    }
  }
  obs<-bind_rows(rows);stopifnot(nrow(obs)>0,all(nzchar(obs$Species)))
  # Only within-source specimen replicates are averaged (PCH). Everything else selects a report.
  if(domain=='claustrum_cerebellar') {
    agg<-obs |> group_by(Species,Measure,Units,Source_item,role,priority) |>
      summarise(Value=as.character(mean(as.numeric(Value))),species_printed=paste(unique(species_printed),collapse='; '),accepted_name=accepted_name[1],species_basis=species_basis[1],reidentified=any(reidentified),source_row=paste(source_row,collapse='; '),Code=Code[1],Context=paste(Context,collapse='; '),n_observations=n(),reference_keys=paste(unique(reference_keys),collapse='; '),selection_note='Within-source mean only; hemisphere and anatomical boundary retained',.groups='drop')
  } else agg<-obs
  groups<-split(agg,interaction(agg$Species,agg$Measure,drop=TRUE))
  out<-bind_rows(lapply(groups,function(g) {
    g<-g[order(-g$priority,g$Source_item),];chosen<-g[1,];conflict<-length(unique(g$Value))>1
    # Same-source multiple intervals are not turned into an arbitrary selected number.
    if(length(unique(g$Source_item))==1 && nrow(g)>1 && conflict) {chosen$Value<-paste(unique(g$Value),collapse='; ');chosen$selection_note<-'Multiple source observations retained; not averaged'}
    if(domain=='taste' && conflict && chosen$role=='secondary') { chosen$Value<-paste(unique(g$Value),collapse=' or ');chosen$selection_note<-'Unresolved secondary-report conflict; no single numeric estimate selected' }
    data.frame(Species=chosen$Species,Measure=chosen$Measure,Units=chosen$Units,Value=chosen$Value,
      n_sources=1L,n_reports=length(unique(g$Source_item)),Teams=chosen$Source_item,roles=chosen$role,Source_item=chosen$Source_item,
      source_rows=paste(g$source_row,collapse='; '),n_observations=chosen$n_observations,conflicting_reports=conflict,
      alternative_values=paste(unique(paste(g$Source_item,g$Value,sep=': ')),collapse='; '),selection_note=chosen$selection_note,Context=chosen$Context,
      species_printed=chosen$species_printed,accepted_name=chosen$accepted_name,species_basis=chosen$species_basis,reidentified=chosen$reidentified)
  })) |> arrange(Species,Measure)
  folder<-switch(domain,taste='__merging_sensory',social_mirror_play='__merging_behaviour',claustrum_cerebellar='__merging_volumes')
  write_csv(obs,file.path(base,folder,paste0(domain,'_observations_long.csv')))
  write_csv(out,file.path(base,folder,paste0(domain,'_long.csv')))
  write_csv(out |> select(Species,Measure,Value) |> pivot_wider(names_from=Measure,values_from=Value),file.path(base,folder,paste0(domain,'_wide.csv')))
  message(domain,': ',nrow(obs),' observations -> ',nrow(out),' selected cells; ',sum(out$conflicting_reports),' cells retain conflicting/alternative reports')
  invisible(out)
}
