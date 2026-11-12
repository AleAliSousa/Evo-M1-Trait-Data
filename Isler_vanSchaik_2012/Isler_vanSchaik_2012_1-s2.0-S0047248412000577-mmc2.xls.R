## Frozen source -> analysis CSV + registry-coded public TSV.
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value=TRUE)
  if(length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  of <- tryCatch(sys.frames()[[1]]$ofile, error=function(e) NULL)
  if(!is.null(of) && nzchar(of)) return(normalizePath(of))
  if(requireNamespace("rstudioapi", quietly=TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if(nzchar(p)) return(normalizePath(p))
  }
  stop("Run this saved script with Rscript or Source it in RStudio")
})
folder <- dirname(.sp)
item_name <- tools::file_path_sans_ext(basename(.sp))
base <- dirname(folder)
library(readxl)
filecodes <- read_excel(file.path(base,"__ReadMe.xlsx"), sheet="Sheet1", col_types="text")
i <- which(!is.na(filecodes$`Item name`) & filecodes$`Item name` == item_name)
stopifnot(length(i)==1L)
item_encoded <- filecodes$`Item encoded`[i]
stopifnot(!is.na(item_encoded), nzchar(item_encoded), !grepl("_$",item_encoded))
tsv_dir <- file.path(base,"__Public","comparative-data")
source(file.path(base,"_keys","resolve_species.R"))
num <- function(x) suppressWarnings(as.numeric(gsub("[ ,]","",x)))

snap <- read_excel(file.path(folder,paste0(item_name,"_snapshot.xls")),sheet="Sheet1",col_names=FALSE,col_types="text",.name_repair="minimal")
stopifnot(nrow(snap)==447L,ncol(snap)==25L,
          snap[[19]][2]=="Brain size [g or cc]")
dat <- snap[3:nrow(snap),]
printed <- as.character(dat[[3]])
rs <- resolve_species(gsub("_"," ",printed,fixed=TRUE),source_publication=basename(folder))
## Another paper's key must not re-identify this paper's names: this paper's own key rows are unresolved (blank accepted_name),
## so a name that only matches by variant_name (match_level "variant", e.g. via Grabowski_etal_2023 since 2026-11-10)
## stays as printed and "unresolved", as in the committed CSV/TSV. Rows keyed to this paper (or the hub) are unaffected.
v <- rs$match_level=="variant"
rs$accepted_name[v] <- species_normalise(gsub("_"," ",printed[v],fixed=TRUE)); rs$species_basis[v] <- "unresolved"; rs$reidentified[v] <- FALSE
final.dataframe <- data.frame(Species=rs$accepted_name,species_as_published=printed,
 group_as_published=dat[[1]],species_number=as.integer(dat[[2]]),source_excel_row=seq.int(3L,447L),
 allonursing=num(dat[[4]]),communal_nesting_babysitting_retrieval=num(dat[[5]]),protection=num(dat[[6]]),
 provisioning_male=num(dat[[7]]),provisioning_others=num(dat[[8]]),carrying_male=num(dat[[9]]),carrying_others=num(dat[[10]]),
 PC1=num(dat[[11]]),PC2=num(dat[[12]]),provisioning_mothers=num(dat[[13]]),gregariousness=num(dat[[14]]),
 diet_code=num(dat[[15]]),activity_code=num(dat[[16]]),substrate_code=num(dat[[17]]),
 body_mass_g=num(dat[[18]]),brain_size_as_published=as.character(dat[[19]]),brain_size_numeric=num(dat[[19]]),
 brain_size_unit_as_published="g or cc",brain_measurement_basis="unresolved_per_row",
 fertility_offspring_per_year=num(dat[[20]]),gestation_length_days=num(dat[[21]]),weaning_age_days=num(dat[[22]]),
 age_at_first_reproduction_years=num(dat[[23]]),maximum_lifespan_years=num(dat[[24]]),remarks=as.character(dat[[25]]),
 brain_body_source_ref_keys="Isler and van Schaik 2009a",brain_body_source_reference_id="doi:10.1016/j.jhevol.2009.04.009",
 source_granularity="secondary_compilation_primary_lineage_unresolved",primary_reference_id="",
 sex_scope="sex-specific preferred female per methods; per-row sex not supplied",
 data_role="secondary",primary_pool_eligible=FALSE,species_basis=rs$species_basis,reidentified=rs$reidentified,
 check.names=FALSE,stringsAsFactors=FALSE)
stopifnot(nrow(final.dataframe)==445L,identical(final.dataframe$species_number,1:445),
          !anyNA(final.dataframe$brain_size_numeric),!anyDuplicated(printed))
## Do not convert the mixed g/cc column to mg or mm3 until its original type is established.

## ---- Item-scoped reference tables (reference_tables/) and the social_ecology_life_history_ref_keys column ----
## Reconstructed from the frozen source-scope / bibliography snapshots of the two sibling items
## SupplementaryInformation1.3 and SupplementaryInformation4.References (a data dependency: their values end up in this
## item's CSV/TSV and reference_tables). This does not infer experimental primaries from author/year.
refdir <- file.path(folder,"reference_tables")
ws <- "(*UTF)[\\s\\x{1c}-\\x{1f}\\x{85}\\x{a0}\\x{1680}\\x{2000}-\\x{200a}\\x{2028}\\x{2029}\\x{202f}\\x{205f}\\x{3000}]+"
squish <- function(x) gsub("^ +| +$","",gsub(ws," ",enc2utf8(x),perl=TRUE))
py_split <- function(pat,x) {
  m <- gregexpr(pat,x,perl=TRUE)[[1]]
  if(m[1]==-1L) return(x)
  st <- as.integer(m); ln <- attr(m,"match.length")
  substring(x,c(1L,st+ln),c(st-1L,nchar(x)))
}
rx <- function(pat,x) regmatches(x,regexec(pat,x,perl=TRUE))[[1]]
norm <- function(s) tolower(gsub("[^A-Za-z0-9]","",stringi::stri_trans_nfkd(s)))
sid <- function(x) paste0("citation:",substr(as.character(openssl::sha256(charToRaw(enc2utf8(x)))),1L,16L))
citation_type <- function(x) {
  if(grepl("\\b(In:|\\(eds?\\)|Handbook|Field Guide|Accounts|Encyclopedia|Mammals of|Mammals:)",x,perl=TRUE)) return(c("secondary","book_chapter_or_reference_compilation"))
  if(grepl("\\b(thesis|University Press|Academic Press|Edicions)\\b",x,perl=TRUE,ignore.case=TRUE)) return(c("unverified","book_or_thesis"))
  c("unverified","journal_article_primary_status_unchecked")
}
read_text <- function(f) read.csv(f,check.names=FALSE,stringsAsFactors=FALSE,fileEncoding="UTF-8-BOM",colClasses="character",na.strings=character(0))
## CSV text as the committed files have it: UTF-8, CRLF, a field is quoted only when it holds , " CR or LF.
csv_field <- function(x) { x <- enc2utf8(as.character(x)); x[is.na(x)] <- ""; q <- grepl("[\",\r\n]",x)
  x[q] <- paste0("\"",gsub("\"","\"\"",x[q],fixed=TRUE),"\""); x }
write_csv_crlf <- function(df,file,bom=FALSE) {
  lines <- do.call(paste,c(unname(lapply(df,csv_field)),sep=","))
  con <- file(file,"wb"); on.exit(close(con))
  if(bom) writeBin(as.raw(c(0xef,0xbb,0xbf)),con)
  writeBin(charToRaw(paste0(paste(c(paste(csv_field(names(df)),collapse=","),lines),collapse="\r\n"),"\r\n")),con)
}
pub <- basename(folder)
refs <- read_text(file.path(folder,paste0(pub,"_SupplementaryInformation4.References_snapshot.csv")))
refs$citation <- squish(refs$citation_as_printed)
refs$year <- vapply(refs$citation,function(c) rx("\\((\\d{4}(?:[a-z]|-\\d{4})?)\\)",c)[2],"")
refs$first <- vapply(refs$citation,function(c) rx("^(.+?)\\s+[A-Z]",c)[2],"")
by_author_year <- split(seq_len(nrow(refs)),paste(norm(refs$first),refs$year,sep="\r"))
scopes <- read_text(file.path(folder,paste0(pub,"_SupplementaryInformation1.3_snapshot.csv")))
## Explicit aliases/year discrepancies remain visible; no automatic author/year collision merge.
aliases <- list("Gubernick 1981"=c("gubernick","1981"),"K\u00f6nig 2006"=c("konig","2006"))
parsed <- list()
for(b in seq_len(nrow(scopes))) {
  block <- scopes[b,]
  text <- squish(block$references_as_printed)
  ## The Rodentia block contains two separate number-restricted source statements.
  for(chunk in py_split(";\\s*|(?<=2007) (?=Blumstein)|(?<=\\)) (?=Blumstein)",text)) {
    restrict <- rx("\\(([\\d,\\- ]+)\\)",chunk)
    numbers <- if(length(restrict)) restrict[2] else block$species_numbers_as_printed
    key <- sub(";+$","",trimws(gsub("\\s*\\([\\d,\\- ]+\\)","",chunk,perl=TRUE)))
    keys <- if(key=="Owens and Owens 1979a, b, 1996") c("Owens and Owens 1979a","Owens and Owens 1979b","Owens and Owens 1996") else key
    for(key in keys) parsed[[length(parsed)+1L]] <- data.frame(scope_row=block$source_row,scope_key=block$scope_key,
      scope_as_printed=block$scope_as_printed,species_numbers_as_printed=numbers,reference_raw=chunk,ref_key=key,
      source_pdf_page=block$source_pdf_page,stringsAsFactors=FALSE)
  }
}
parsed <- do.call(rbind,parsed)
## Resolve item-cited sources, not all 143 bibliography works.
lookup <- list(); issues <- list()
for(key in parsed$ref_key) {
  if(!is.null(lookup[[key]])) next
  m <- regexpr("(\\d{4}(?:[a-z]|-\\d{4})?)$",key,perl=TRUE)
  year <- if(m>0L) substring(key,m,m+attr(m,"match.length")-1L) else ""
  author <- if(m>0L) py_split(" et al\\.| and ",trimws(substr(key,1L,m-1L)))[1] else ""
  ay <- if(!is.null(aliases[[key]])) aliases[[key]] else c(norm(author),year)
  cand <- by_author_year[[paste(ay,collapse="\r")]]
  if(length(cand)==1L) { citation <- refs$citation[cand]; status <- "resolved_to_local_bibliography"; loc <- paste0("mmc1 PDF p.",refs$source_pdf_page[cand]) }
  else { citation <- ""; status <- if(!length(cand)) "unresolved" else "author_year_collision"; loc <- ""
    issues[[length(issues)+1L]] <- data.frame(reference_raw=key,issue=status,candidate_citations=paste(refs$citation[cand],collapse=" | "),
      note="No guessed substitution applied",stringsAsFactors=FALSE) }
  lt <- if(nzchar(citation)) citation_type(citation) else c("unresolved","unresolved")
  lookup[[key]] <- data.frame(ref_key=key,cited_in_column="social_ecology_life_history_ref_keys",citation=citation,
    note="Section 1.3 candidate source scope, not a brain-size citation and not a variable-specific source assertion",
    source_reference_id=sid(if(nzchar(citation)) citation else key),reference_level=lt[1],source_type=lt[2],primary_reference_id="",
    resolution_status=status,evidence_locator=loc,stringsAsFactors=FALSE)
}
brainkey <- "Isler and van Schaik 2009a"
lookup[[brainkey]] <- data.frame(ref_key=brainkey,cited_in_column="brain_body_source_ref_keys",
  citation="Isler, K., van Schaik, C.P., 2009a. The expensive brain: a framework for explaining evolutionary changes in brain size. J. Hum. Evol. 57, 392-400.",
  note="Main article Methods/Data names 2009a for brain/body and life-history compilation; original per-species sources not supplied by the 2012 workbook",
  source_reference_id="doi:10.1016/j.jhevol.2009.04.009",reference_level="secondary",source_type="secondary_compilation",primary_reference_id="",
  resolution_status="resolved_citation_primary_chain_open",evidence_locator="main PDF pp.2 and 11",stringsAsFactors=FALSE)
lookup_df <- do.call(rbind,unname(lookup))
data <- data.frame(source_excel_row=as.character(final.dataframe$source_excel_row),species_number=as.character(final.dataframe$species_number),
  species_as_published=final.dataframe$species_as_published,group_as_published=final.dataframe$group_as_published,Species=final.dataframe$Species,stringsAsFactors=FALSE)
data$group_as_published[is.na(data$group_as_published)] <- ""
hub <- read_text(file.path(base,"_keys","species_reference.csv"))
family <- hub$Family_resolved[match(data$Species,hub$accepted_name)]; family[is.na(family)] <- ""
expand <- function(s) { out <- integer(0)
  for(t in strsplit(gsub(" ","",s),",",fixed=TRUE)[[1]]) { if(!nzchar(t)) next
    if(grepl("-",t,fixed=TRUE)) { ab <- as.integer(strsplit(t,"-",fixed=TRUE)[[1]]); out <- c(out,ab[1]:ab[2]) } else out <- c(out,as.integer(t)) }
  out }
## Lower taxon scopes are expanded only where membership is explicit and stable.
clades <- list(
 Cercopithecinae=strsplit("Allenopithecus Cercocebus Cercopithecus Chlorocebus Erythrocebus Lophocebus Macaca Mandrillus Papio Theropithecus"," ")[[1]],
 Colobinae=strsplit("Colobus Nasalis Piliocolobus Presbytis Procolobus Pygathrix Rhinopithecus Semnopithecus Simias Trachypithecus"," ")[[1]],
 Tarsiidae=c("Tarsius","Cephalopachus","Carlito"),
 Platyrrhini=strsplit("Alouatta Aotus Ateles Brachyteles Cacajao Callicebus Callimico Callithrix Cebuella Cebus Chiropotes Lagothrix Leontopithecus Pithecia Saguinus Saimiri"," ")[[1]],
 Lemuriformes=strsplit("Avahi Cheirogaleus Daubentonia Eulemur Hapalemur Indri Lemur Lepilemur Microcebus Mirza Phaner Propithecus Varecia"," ")[[1]])
genus <- sub("_.*$","",data$species_as_published)
links <- list()
for(k in seq_len(nrow(parsed))) {
  p <- parsed[k,]
  if(nzchar(p$species_numbers_as_printed)) { sel <- match(expand(p$species_numbers_as_printed),as.integer(data$species_number)); stopifnot(!anyNA(sel)); assignment <- "explicit_species_number" }
  else { scope <- p$scope_key; assignment <- "published_taxonomic_scope"
    sel <- which(scope=="all_mammals" | data$group_as_published==scope | family==scope | genus %in% clades[[scope]] |
      (scope=="Insectivora" & family %in% c("Erinaceidae","Soricidae","Talpidae","Chrysochloridae","Tenrecidae"))) }
  if(!length(sel)) next
  ref <- lookup[[p$ref_key]]
  links[[length(links)+1L]] <- data.frame(compilation_id=item_name,source_row=data$source_excel_row[sel],species_number=data$species_number[sel],
    species_as_published=data$species_as_published[sel],Species=data$Species[sel],field_scope="social_behavior_ecology_life_history",
    source_reference_id=ref$source_reference_id,primary_reference_id="",reference_raw=p$reference_raw,ref_key=p$ref_key,
    reference_role="candidate_scope_source",assignment_basis=assignment,source_scope_row=p$scope_row,
    source_locator=paste0("mmc1 PDF p.",p$source_pdf_page),primary_pool_eligible="False",stringsAsFactors=FALSE)
}
social_links <- do.call(rbind,links)
brain_links <- data.frame(compilation_id=item_name,source_row=data$source_excel_row,species_number=data$species_number,
  species_as_published=data$species_as_published,Species=data$Species,field_scope="brain_size; body_mass",
  source_reference_id=lookup[[brainkey]]$source_reference_id,primary_reference_id="",reference_raw=brainkey,ref_key=brainkey,
  reference_role="direct_reported_secondary_source",assignment_basis="main_article_Methods_Data",source_scope_row="",
  source_locator="main PDF p.2",primary_pool_eligible="False",stringsAsFactors=FALSE)
all_links <- rbind(social_links,brain_links)
stopifnot(all(all_links$source_reference_id %in% lookup_df$source_reference_id),
          all(all_links$primary_reference_id==""),all(all_links$primary_pool_eligible=="False"))
write_csv_crlf(lookup_df,file.path(refdir,paste0(item_name,"_references.csv")),bom=TRUE)
write_csv_crlf(all_links,file.path(refdir,paste0(item_name,"_value_reference_links.csv")),bom=TRUE)
write_csv_crlf(parsed,file.path(refdir,paste0(item_name,"_source_scope_reference_links.csv")),bom=TRUE)
write_csv_crlf(if(length(issues)) do.call(rbind,issues) else data.frame(reference_raw=character(),issue=character(),candidate_citations=character(),note=character()),
  file.path(refdir,paste0(item_name,"_reference_issues.csv")),bom=TRUE)
write_csv_crlf(lookup_df[0,],file.path(refdir,paste0(item_name,"_primary_references.csv")),bom=TRUE)
## Convenience keys are derived from the authoritative links, with the raw scope preserved.
keys <- split(social_links$ref_key,social_links$species_number)
tmp_csv <- tempfile(fileext=".csv")
write.csv(final.dataframe,tmp_csv,row.names=FALSE,na="",fileEncoding="UTF-8")
out <- read.csv(tmp_csv,check.names=FALSE,stringsAsFactors=FALSE,colClasses="character",na.strings=character(0),fileEncoding="UTF-8")
out$social_ecology_life_history_ref_keys <- vapply(as.character(final.dataframe$species_number),
  function(n) paste(sort(unique(keys[[n]]),method="radix"),collapse="; "),"")
write_csv_crlf(out,file.path(folder,paste0(item_name,".csv")))
cat(length(lookup),"cited-source keys,",nrow(all_links),"value/scope links,",length(issues),"unresolved aliases, 0 primary-eligible values\n")
final.dataframe <- read.csv(file.path(folder,paste0(item_name,".csv")),check.names=FALSE,stringsAsFactors=FALSE,
                           colClasses=c(brain_size_as_published="character",primary_reference_id="character"))
write.table(final.dataframe,file.path(tsv_dir,paste0(item_encoded,".tsv")),sep="\t",row.names=FALSE,na="",quote=TRUE,fileEncoding="UTF-8")
cat(item_name,":",nrow(final.dataframe),"rows; secondary provenance only, not added to primary merges\n")
