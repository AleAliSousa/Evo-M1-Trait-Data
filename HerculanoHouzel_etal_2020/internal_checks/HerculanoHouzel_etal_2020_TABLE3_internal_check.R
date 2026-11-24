## HerculanoHouzel_etal_2020_TABLE3_internal_check.R -- cross-item check (build HOWTO 7b)
##
## Herculano-Houzel, S., da Cunha, F. B., Reed, J. L., Kaswera-Kyamakya, C., Gillissen, E., & Manger, P. R. (2020). Microchiropterans have a diminutive cerebral cortex, not an enlarged cerebellum, compared to megachiropterans and other mammals. J Comp Neurol, 528(17), 2978-2993. doi:10.1002/cne.24985
##
## QUESTION. Methods 2.1: for every species except Chaerephon pumilus only one hemisphere was
## available and "data are necessarily expressed as twice the numbers obtained for the available
## hemisphere". Table 1 marks each species "(1H each)" or "(2H each)". Is the brain mass of
## Table 1 (MBRAIN) a whole brain as weighed, or is it on the same basis as the neuron numbers,
## i.e. the sum of the dissected structures (2 x one hemisphere for the "(1H each)" species)?
##
## WHAT THE THREE TABLES ALLOW. Table 2 prints, per structure (cerebral cortex CX, cerebellum CB,
## rest of brain RoB), the number of neurons N and the neuronal density DN (neurons/mg), so each
## structure mass is implied: M = N / DN. Table 3 prints MCX and MCB as percentages of the brain
## mass. If MBRAIN is the sum of the dissected structures, then
##     MBRAIN = NCX/DN,CX + NCB/DN,Cb + NRoB/DN,RoB                         (brain_mass_sum)
##     100    = MCX/MBR + MCB/MBR + 100 x (NRoB/DN,RoB) / MBRAIN            (mass_closure)
## exactly, up to rounding, for a single animal. For a species MEAN over two animals the
## quotient of two means is not the mean of the quotients, so a small difference is expected
## that rounding cannot explain. A brain weighed whole, independently of the dissection, has no
## reason to equal the sum at all. The "(2H each)" species (both hemispheres measured, nothing
## doubled) is the control: it shows how large the difference is when no doubling is involved.
## The other rows check that Table 3 agrees with Tables 1 and 2 (fractions and ratios), and that
## NBRAIN of Table 1 is the sum of the three neuron numbers of Table 2.
##
## Tolerances: only what rounding of the printed cells can explain (half a unit of the last
## printed decimal of every cell used). Reads only the three snapshots; writes only
## HerculanoHouzel_etal_2020_TABLE3_internal_check.csv in this folder. Never changes a value; a
## mismatch is warned and kept as printed.

## 0. PATHS --------------------------------------------------------
.sp <- local({
  a <- grep("^--file=", commandArgs(FALSE), value = TRUE)
  if (length(a)) return(normalizePath(sub("^--file=", "", a[1])))
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    p <- rstudioapi::getSourceEditorContext()$path
    if (!nzchar(p)) p <- rstudioapi::getActiveDocumentContext()$path
    if (nzchar(p)) return(normalizePath(p))
  }
  stop("Run with Rscript file.R, or open in RStudio and click Source (save first).", call. = FALSE)
})
check_dir <- dirname(.sp)                                 # <Paper>/internal_checks
folder    <- dirname(check_dir)                           # <Paper>
item_name <- sub("_internal_check$", "", tools::file_path_sans_ext(basename(.sp)))   # "HerculanoHouzel_etal_2020_TABLE3"
base <- local({
  d <- folder
  while (dirname(d) != d && !file.exists(file.path(d, "__ReadMe.xlsx"))) d <- dirname(d)
  if (file.exists(file.path(d, "__ReadMe.xlsx"))) d else NA_character_
})
snapshot_csv        <- file.path(folder, paste0(item_name, "_snapshot.csv"))
table1_snapshot_csv <- file.path(folder, sub("TABLE3$", "TABLE1_snapshot.csv", item_name))
table2_snapshot_csv <- file.path(folder, sub("TABLE3$", "TABLE2_snapshot.csv", item_name))
check_csv           <- file.path(check_dir, paste0(item_name, "_internal_check.csv"))

## 1. LOAD (read-only) ------------------------------------------------
rd  <- function(f) read.csv(f, colClasses = "character", check.names = FALSE, stringsAsFactors = FALSE)
t3  <- rd(snapshot_csv); t1 <- rd(table1_snapshot_csv); t2 <- rd(table2_snapshot_csv)
num <- function(x) as.numeric(gsub(",", "", x))
stopifnot(nrow(t1) == 13L, nrow(t2) == 13L, nrow(t3) == 13L,
          identical(t1$Species, t2$Species), identical(t1$Species, t3$Species))
species <- t1$Species
sp_id   <- gsub(" ", "_", species)
one_h   <- grepl("1H", t1$n, fixed = TRUE)                # Table 1, n column: "(1H each)"
two_h   <- grepl("2H", t1$n, fixed = TRUE)                # "(2H each)": both hemispheres measured
stopifnot(all(xor(one_h, two_h)))
basis_printed <- ifelse(one_h, "(1H each)", "(2H each)")

MBR <- num(t1$`MBRAIN, g`); NBR <- num(t1$NBRAIN)
NCX <- num(t2$NCX); NCB <- num(t2$NCB); NRoB <- num(t2$NRoB)
DCX <- num(t2$`DN,CX`); DCB <- num(t2$`DN,Cb`); DRoB <- num(t2$`DN,RoB`)
pMCX <- num(t3$`MCX/MBR`); pNCX <- num(t3$`NCX/NBR`); pMCB <- num(t3$`MCB/MBR`); pNCB <- num(t3$`NCB/NBR`)
rM   <- num(t3$`MCX/MCB`); rN <- num(t3$`NCB/NCX`)

## 2. IMPLIED STRUCTURE MASSES (g) ------------------------------------
# M = N / DN, DN in neurons per mg. Rounding: N is printed to the neuron, DN to 1 neuron/mg, so the
# implied mass carries a relative uncertainty of 0.5 / DN.
MCX <- NCX / DCX / 1000; MCB <- NCB / DCB / 1000; MRoB <- NRoB / DRoB / 1000
uCX <- MCX * 0.5 / DCX;  uCB <- MCB * 0.5 / DCB;  uRoB <- MRoB * 0.5 / DRoB
Msum <- MCX + MCB + MRoB
rel  <- 100 * (Msum - MBR) / MBR                          # percent of MBRAIN

mk <- function(id, basis, observed, printed, tolerance, note, digits) data.frame(
  check_id = paste0(id, "_", sp_id), basis = paste0(basis, ", row ", species),
  observed = round(observed, digits), printed = printed,
  difference = round(observed - printed, digits), tolerance = round(tolerance, digits),
  status = ifelse(abs(observed - printed) <= tolerance, "pass", "mismatch"),
  note = note, stringsAsFactors = FALSE)

## 3. CHECKS ------------------------------------------------------------
# 3.1 NBRAIN (Table 1) = NCX + NCB + NRoB (Table 2)
c_neurons <- mk("neurons_sum", "Table 2 NCX + NCB + NRoB vs Table 1 NBRAIN",
                NCX + NCB + NRoB, NBR, 1.5,
                "three printed means, each rounded to the neuron", 0)

# 3.2 MBRAIN (Table 1) = sum of the implied structure masses (Table 2)
tol_mass <- 0.0005 + uCX + uCB + uRoB
within   <- abs(Msum - MBR) <= tol_mass
control_rel <- rel[two_h]
c_mass <- mk("brain_mass_sum",
             "Table 2 NCX/DN,CX + NCB/DN,Cb + NRoB/DN,RoB (g) vs Table 1 MBRAIN (g)",
             Msum, MBR, tol_mass,
             paste0("Table 1 n: ", t1$n, ". Relative difference ", sprintf("%+.2f", rel), "% of MBRAIN. ",
                    ifelse(within,
                           "Equal within rounding: MBRAIN is the sum of the dissected structures, on the same basis as the neuron numbers.",
                           paste0("Outside rounding, but small: as expected for a mean over two animals if MBRAIN is the sum of the dissected structures ",
                                  "(the both-hemisphere control differs by ", sprintf("%+.2f", control_rel[1]), "%); this row alone cannot rule out a brain weighed whole.")),
                    ifelse(two_h, " CONTROL: both hemispheres measured, nothing doubled.", "")),
             6)

# 3.3 Table 3 mass fractions vs Tables 1 and 2
c_fcx <- mk("mass_fraction_CX", "100 x (NCX/DN,CX)/1000 / MBRAIN (Tables 2, 1) vs Table 3 MCX/MBR",
            100 * MCX / MBR, pMCX, 0.05 + 100 * (uCX / MBR + MCX * 0.0005 / MBR^2),
            "tolerance = rounding of the printed cells; a mean over two animals can differ by more", 3)
c_fcb <- mk("mass_fraction_CB", "100 x (NCB/DN,Cb)/1000 / MBRAIN (Tables 2, 1) vs Table 3 MCB/MBR",
            100 * MCB / MBR, pMCB, 0.05 + 100 * (uCB / MBR + MCB * 0.0005 / MBR^2),
            "tolerance = rounding of the printed cells; a mean over two animals can differ by more", 3)
c_rm  <- mk("mass_ratio_CX_CB", "(NCX/DN,CX) / (NCB/DN,Cb) (Table 2) vs Table 3 MCX/MCB",
            MCX / MCB, rM, 0.005 + (MCX / MCB) * (0.5 / DCX + 0.5 / DCB),
            "tolerance = rounding of the printed cells; a mean over two animals can differ by more", 4)

# 3.4 Mass closure: printed CX and CB fractions plus the implied rest-of-brain fraction = 100
closure <- pMCX + pMCB + 100 * MRoB / MBR
c_close <- mk("mass_closure", "Table 3 MCX/MBR + MCB/MBR + 100 x (NRoB/DN,RoB)/1000 / MBRAIN vs 100",
              closure, 100, 0.05 + 0.05 + 100 * (uRoB / MBR + MRoB * 0.0005 / MBR^2),
              paste0("Table 1 n: ", t1$n, ". If MBRAIN is the sum of the dissected structures the three fractions close to 100; ",
                     "the rest-of-brain fraction is not printed and is implied from Table 2"), 3)

# 3.5 Table 3 neuron fractions and ratio vs Tables 1 and 2
c_ncx <- mk("neuron_fraction_CX", "100 x NCX (Table 2) / NBRAIN (Table 1) vs Table 3 NCX/NBR",
            100 * NCX / NBR, pNCX, 0.05 + 100 * (0.5 / NBR + NCX * 0.5 / NBR^2), "tolerance = rounding of the printed cells", 3)
c_ncb <- mk("neuron_fraction_CB", "100 x NCB (Table 2) / NBRAIN (Table 1) vs Table 3 NCB/NBR",
            100 * NCB / NBR, pNCB, 0.05 + 100 * (0.5 / NBR + NCB * 0.5 / NBR^2), "tolerance = rounding of the printed cells", 3)
c_rn  <- mk("neuron_ratio_CB_CX", "NCB / NCX (Table 2) vs Table 3 NCB/NCX",
            NCB / NCX, rN, 0.005 + (NCB / NCX) * (0.5 / NCB + 0.5 / NCX), "tolerance = rounding of the printed cells", 4)

# 3.6 The basis of MBRAIN, over all species
one <- function(id, basis, observed, printed, tolerance, status, note, digits) data.frame(
  check_id = id, basis = basis, observed = round(observed, digits), printed = round(printed, digits),
  difference = round(observed - printed, digits), tolerance = tolerance, status = status, note = note,
  stringsAsFactors = FALSE)
c_all <- rbind(
  one("brain_mass_basis_species_equal_within_rounding",
      "number of species whose MBRAIN equals the sum of the implied structure masses within rounding, of all species",
      sum(within), length(species), 0, ifelse(all(within), "pass", "mismatch"),
      paste0("equal within rounding: ", paste(species[within], collapse = "; "),
             ". The relation is exact only for one animal or when the two animals are alike; the other species are means over two animals"), 0),
  one("brain_mass_basis_one_hemisphere_vs_control",
      "median absolute relative difference (% of MBRAIN) of the '(1H each)' species vs the absolute relative difference of the '(2H each)' control",
      median(abs(rel[one_h])), abs(control_rel[1]), NA,
      ifelse(median(abs(rel[one_h])) <= abs(control_rel[1]), "pass", "mismatch"),
      paste0("pass = the one-hemisphere species differ from the sum no more than the species measured on both sides. '(1H each)' species (n = ", sum(one_h),
             "): mean ", sprintf("%+.2f", mean(rel[one_h])), "%, SD ", sprintf("%.2f", sd(rel[one_h])), "%, largest ", sprintf("%+.2f", rel[one_h][which.max(abs(rel[one_h]))]),
             "% (", species[one_h][which.max(abs(rel[one_h]))], "); control (", paste(species[two_h], collapse = "; "), "): ", sprintf("%+.2f", control_rel[1]),
             "%. Doubling one half of a bisected brain adds no spread that the control lacks, so MBRAIN is on the same basis as the structure data"), 3))

table_checks <- rbind(c_neurons, c_mass, c_close, c_fcx, c_fcb, c_rm, c_ncx, c_ncb, c_rn, c_all)

## 4. REPORT + WRITE ----------------------------------------------------
print(aggregate(status ~ sub("_[A-Z][a-z]+_[a-z]+$", "", check_id), data = table_checks,
                FUN = function(s) paste(sum(s == "pass"), "pass /", sum(s == "mismatch"), "mismatch")), row.names = FALSE)
if (any(table_checks$status != "pass"))
  warning(sum(table_checks$status != "pass"), " check(s) outside rounding -- kept as printed (see the note column).", call. = FALSE)
write.csv(table_checks, check_csv, row.names = FALSE, na = "", fileEncoding = "UTF-8")
