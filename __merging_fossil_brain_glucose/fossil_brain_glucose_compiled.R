# =====================================================================
# fossil_brain_glucose_compiled.R
# ---------------------------------------------------------------------
# House-style R equivalent of build_fossil_brain_glucose_merge.py. Compiles
# fossil-hominin whole-brain glucose utilization (BGU, umol/min) from three
# estimators (Seymour carotid flow; Boyer BGU~ACA+ECV; s4 volume x rCMRGlc)
# into long / wide / unfiltered merges, resolved on the modern-human-relative
# ratio. See README__merging.md for rationale, scope and volume-convention notes.
#
# Both builders implement the same pipeline; the .py is the tested builder that
# produced the shipped CSVs (R was unavailable in the build environment, same
# arrangement as __merging_cerebral_metabolic_rate/).
# =====================================================================

suppressPackageStartupMessages({ library(stats) })

## paths: run from this folder (or anywhere -- resolves to script dir) --------
here <- tryCatch(dirname(sub("^--file=", "",
          grep("^--file=", commandArgs(FALSE), value = TRUE)[1])),
          error = function(e) getwd())
if (is.na(here) || here == "") here <- getwd()
IN  <- file.path(here, "inputs")
rd  <- function(f) read.csv(file.path(IN, f), stringsAsFactors = FALSE,
                            check.names = FALSE, comment.char = "#", encoding = "UTF-8")

## constants / modern-human anchors -------------------------------------------
BGU_MODH <- 428.55; ACA_HOMO <- 159.81
Q_MODH   <- 7.34;   R_MODH   <- 0.302; ECV_MODH <- 1493
S4_MODH  <- 328.51

## 1. Boyer BGU calibration (log-log OLS + Duan smearing) ---------------------
cal <- rd("Boyer_Harrington_2018_Table2.csv")
fit <- lm(log(BGU_umol_min) ~ log(ACA_mm2) + log(ECV_cc), data = cal)
smf <- mean(exp(residuals(fit)))
boyer <- function(aca, ecv)
  exp(predict(fit, data.frame(ACA_mm2 = aca, ECV_cc = ecv))) * smf

## 2. catarrhine ACA~ECV allometry (ecvpred upper bound) ----------------------
t1 <- rd("Boyer_Harrington_2018_Table1.csv")
t1$ACA_mm2 <- as.numeric(t1$ACA_mm2); t1$ECV_cc <- as.numeric(t1$ECV_cc)
t1 <- t1[is.finite(t1$ACA_mm2) & is.finite(t1$ECV_cc), ]
ct  <- t1[t1$Taxonomic_group %in% c("Hominoidea", "Cercopithecoidea"), ]
fitA <- lm(log(ACA_mm2) ~ log(ECV_cc), data = ct); smA <- mean(exp(residuals(fitA)))
aca_from_ecv <- function(ecv) exp(predict(fitA, data.frame(ECV_cc = ecv))) * smA
BGU_boyer_modH <- boyer(ACA_HOMO, ECV_MODH)

## 3. taxon-group tag ---------------------------------------------------------
group_of <- function(sp) ifelse(grepl("neanderthal", sp, ignore.case = TRUE), "Neanderthal",
  ifelse(grepl("^H\\. sapiens", sp), "H. sapiens (early/recent)",
  ifelse(grepl("erectus|heidelberg|rudolf|habilis|georgicus|naledi|floresiensis", sp, ignore.case = TRUE),
         "early Homo", ifelse(grepl("^A\\.", sp), "Australopithecus", "other"))))

## 3b. intra-species temporal grade ------------------------------------------
# Generic within-species temporal level; only H. sapiens graded here (extend
# GRADE_BY_SPECIMEN for other taxa). early = 4 Kochiyama EH fossils + BC1, LH 18
# (early H. sapiens in Seymour/Boyer, not Kochiyama); recent = Bushmen;
# modern_reference = AS8078 anchor; NA = no intra-species grade.
GRADE_BY_SPECIMEN <- c("Qafzeh 9"="early", "Skhul 5"="early", "Mladeč 1"="early",
  "Cro-Magnon 1"="early", "BC1"="early", "LH 18"="early",
  "M3-A343"="recent", "M4-A344"="recent", "AS8078"="modern_reference")
grade_of <- function(spec_key) ifelse(spec_key %in% names(GRADE_BY_SPECIMEN),
                                       GRADE_BY_SPECIMEN[spec_key], "NA")

## 4. arterial estimates (Seymour specimens) ---------------------------------
sey <- rd("Seymour_etal_2017_TableS1.csv")
for (c in c("Foramen_radius_cm","Total_QICA_cm3_s","Brain_volume_cm3"))
  sey[[c]] <- as.numeric(sey[[c]])
sey$Group     <- group_of(sey$Species)
sey$ACA_scaled<- ACA_HOMO * (sey$Foramen_radius_cm / R_MODH)^2
sey$ACA_ecv   <- aca_from_ecv(sey$Brain_volume_cm3)
sey$Seymour_flow      <- BGU_MODH * sey$Total_QICA_cm3_s / Q_MODH
sey$Boyer_ACA_scaled  <- boyer(sey$ACA_scaled, sey$Brain_volume_cm3)
sey$Boyer_ACA_ecvpred <- boyer(sey$ACA_ecv,    sey$Brain_volume_cm3)
sey$r_Seymour_flow      <- sey$Total_QICA_cm3_s / Q_MODH
sey$r_Boyer_ACA_scaled  <- sey$Boyer_ACA_scaled  / BGU_boyer_modH
sey$r_Boyer_ACA_ecvpred <- sey$Boyer_ACA_ecvpred / BGU_boyer_modH

## 5. s4 volume estimates (own specimen set) ---------------------------------
s4 <- rd("s4_specimen_budgets.csv")
s4$budget_umol_min <- as.numeric(s4$budget_umol_min)
s4$budget_ratio_MH <- as.numeric(s4$budget_ratio_MH)

canon <- c("Gibraltar (Forbes Quarry)" = "Forbes' Quarry 1",
           "La Chapelle-aux-Saints"    = "La Chapelle-aux-Saints 1",
           "Skhul 5"                   = "Skhul 5")
sey$Specimen_key <- ifelse(sey$Specimen %in% names(canon), canon[sey$Specimen], sey$Specimen)
s4$Specimen_key  <- s4$specimen

meta <- list(
  Seymour_flow      = c(Scope="whole_brain",        Volume_basis="endocranial_capacity", Source="Seymour_etal_2017",             filtered=TRUE),
  Boyer_ACA_scaled  = c(Scope="whole_brain",        Volume_basis="endocranial_capacity", Source="Boyer_Harrington_2018",         filtered=TRUE),
  Boyer_ACA_ecvpred = c(Scope="whole_brain",        Volume_basis="endocranial_capacity", Source="Boyer_Harrington_2018",         filtered=FALSE),
  s4_volume         = c(Scope="cortical+cerebellar",Volume_basis="brain_tissue_GMWM",    Source="Kochiyama_2018 x Heiss_2004 (s4)", filtered=TRUE))

## 6. LONG (one row per Specimen x Team) -------------------------------------
recs <- list()
add <- function(key, species, group, team, value, ratio) {
  if (!is.finite(value)) return(invisible())
  m <- meta[[team]]
  recs[[length(recs)+1]] <<- data.frame(
    Specimen=key, Species=species, Group=group, sapiens_grade=grade_of(key),
    Measure="BGU", Units="umol/min",
    Value=round(value,1), Ratio_MH=round(ratio,3),
    Scope=m["Scope"], Volume_basis=m["Volume_basis"], Team=team, Source=m["Source"],
    filtered=as.logical(m["filtered"]), stringsAsFactors=FALSE)
}
for (i in seq_len(nrow(sey))) {
  add(sey$Specimen_key[i], sey$Species[i], sey$Group[i], "Seymour_flow",      sey$Seymour_flow[i],      sey$r_Seymour_flow[i])
  add(sey$Specimen_key[i], sey$Species[i], sey$Group[i], "Boyer_ACA_scaled",  sey$Boyer_ACA_scaled[i],  sey$r_Boyer_ACA_scaled[i])
  add(sey$Specimen_key[i], sey$Species[i], sey$Group[i], "Boyer_ACA_ecvpred", sey$Boyer_ACA_ecvpred[i], sey$r_Boyer_ACA_ecvpred[i])
}
s4grp <- c(NT="Neanderthal", EH="H. sapiens (early/recent)")
s4sp  <- c(NT="Homo neanderthalensis", EH="Homo sapiens")
for (i in seq_len(nrow(s4))) {
  g <- trimws(s4$group[i])
  add(s4$Specimen_key[i], ifelse(g %in% names(s4sp), s4sp[g], ""),
      ifelse(g %in% names(s4grp), s4grp[g], "other"),
      "s4_volume", s4$budget_umol_min[i], s4$budget_ratio_MH[i])
}
long_all <- do.call(rbind, recs); rownames(long_all) <- NULL
long_all$note <- ifelse(long_all$Team=="Boyer_ACA_ecvpred",
                        "ECV-predicted ACA (upper bound; unfiltered only)", "")
long_filt <- long_all[long_all$filtered, setdiff(names(long_all), c("filtered","note"))]

write.csv(long_filt, file.path(here,"fossil_brain_glucose_long.csv"), row.names=FALSE)
write.csv(long_all[, setdiff(names(long_all),"filtered")],
          file.path(here,"fossil_brain_glucose_unfiltered.csv"), row.names=FALSE)

## 7. WIDE (one row per Specimen) + consensus --------------------------------
FILT <- c("Seymour_flow","Boyer_ACA_scaled","s4_volume")
specs <- sort(unique(long_filt$Specimen))
wide <- do.call(rbind, lapply(specs, function(k) {
  sub <- long_filt[long_filt$Specimen==k, ]
  sp  <- sub$Species[sub$Species!=""][1]; gp <- sub$Group[sub$Group!=""][1]
  grd <- sub$sapiens_grade[!is.na(sub$sapiens_grade)][1]
  d <- data.frame(Specimen=k, Species=ifelse(is.na(sp),"",sp), Group=ifelse(is.na(gp),"",gp),
                  sapiens_grade=ifelse(is.na(grd),"NA",grd), stringsAsFactors=FALSE)
  ratios <- c(); teams <- c()
  for (t in FILT) {
    r <- sub[sub$Team==t, ]
    if (nrow(r)) { d[[paste0(t,"__BGU")]] <- r$Value[1]; d[[paste0(t,"__ratio_MH")]] <- r$Ratio_MH[1]
                   ratios <- c(ratios, r$Ratio_MH[1]); teams <- c(teams, t) }
    else { d[[paste0(t,"__BGU")]] <- NA; d[[paste0(t,"__ratio_MH")]] <- NA }
  }
  d$n_teams <- length(teams); d$teams <- paste(teams, collapse="; ")
  d$consensus_ratio_MH    <- round(mean(ratios),3)
  d$consensus_ratio_sd    <- if (length(ratios)>1) round(sd(ratios),3) else NA
  d$consensus_BGU_umol_min<- round(mean(ratios)*BGU_MODH,1)
  d
}))
wide <- wide[order(-wide$consensus_ratio_MH), ]
write.csv(wide, file.path(here,"fossil_brain_glucose_wide.csv"), row.names=FALSE)

cat(sprintf("[merge] specimens=%d  long(filtered)=%d  unfiltered=%d\n",
            length(specs), nrow(long_filt), nrow(long_all)))
cat(sprintf("[merge] anchors: whole-brain %.1f | Boyer-pred %.1f | s4 6-region %.1f\n",
            BGU_MODH, BGU_boyer_modH, S4_MODH))
