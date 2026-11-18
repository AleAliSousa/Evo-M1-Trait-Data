# Checked correction overlay for Kaufman Appendix A1-A14 snapshots.
#
# The snapshots are transcriptions that may contain OCR errors. This helper repairs defects
# confirmed against the dissertation table pages before an analysis CSV is
# written.  `raw` is the character data.frame read from one snapshot and row
# numbers below are 1-based data rows (the CSV header is excluded).

apply_kaufman_source_corrections <- function(raw, item_name) {
  table <- sub("^Kaufman__2004_", "", item_name)

  sokoloff <- list(
    TableA1  = c(row="109", value="84.5",   sd="2.5",  mode="Sokoloff", old_oxygen="84.5",  old_oxygen_sd="2.5"),
    TableA2  = c(row="69",  value="79.0",   sd="1.0",  mode="Sokoloff", old_oxygen="79.0",  old_oxygen_sd="1.0"),
    TableA3  = c(row="111", value="104.0",  sd="2.0",  mode="Sokoloff", old_oxygen="104.0", old_oxygen_sd="2.0"),
    TableA4  = c(row="77",  value="61.0",   sd="2.0",  mode="Sokoloff", old_oxygen="61.0",  old_oxygen_sd="2.0"),
    TableA5  = c(row="73",  value="36.0",   sd="2.0",  mode="Sokoloff", old_oxygen="36.0",  old_oxygen_sd="2.0"),
    TableA6  = c(row="130", value="124.4",  sd="3.6",  mode="Sokoloff", old_oxygen="124.4", old_oxygen_sd="3.6"),
    TableA7  = c(row="109", value="112.0",  sd="4.0",  mode="Sokoloff", old_oxygen="",      old_oxygen_sd=""),
    TableA8  = c(row="97",  value="110.0",  sd="3.0",  mode="Sokoloff", old_oxygen="110.0", old_oxygen_sd="3.0"),
    TableA10 = c(row="39",  value="163.0",  sd="4.0",  mode="Sokoloff", old_oxygen="",      old_oxygen_sd=""),
    TableA11 = c(row="103", value="113.0",  sd="4.0",  mode="Sokoloff", old_oxygen="",      old_oxygen_sd=""),
    TableA12 = c(row="64",  value="124.00", sd="3.00", mode="PET",      old_oxygen="",      old_oxygen_sd="")
  )
  if (table %in% names(sokoloff)) {
    x <- sokoloff[[table]]
    i <- as.integer(x[["row"]])
    stopifnot(i >= 1L, i <= nrow(raw))
    corrected_snapshot <- table %in% paste0("TableA", c(1:8, 10:12))
    expected_old <- if (corrected_snapshot) c(
      Species="Rattus", Reference="(Sokoloff et al., 1977)", n="10", Anesthesia="none",
      Mode=x[["mode"]], Glucose=x[["value"]], Glucose_SD=x[["sd"]],
      Oxygen="", Oxygen_SD="", BloodFlow="", BloodFlow_SD=""
    ) else c(
      Species="Rattus", Reference="(", n="", Anesthesia="", Mode="Sokoloff",
      Glucose="1977", Glucose_SD="10", Oxygen=x[["old_oxygen"]],
      Oxygen_SD=x[["old_oxygen_sd"]], BloodFlow="", BloodFlow_SD=""
    )
    observed_old <- vapply(
      names(expected_old),
      function(field) trimws(as.character(raw[[field]][i])),
      character(1)
    )
    stopifnot(identical(unname(observed_old), unname(expected_old)))
    if (!corrected_snapshot) {
    raw$Reference[i]  <- "(Sokoloff et al., 1977)"
    raw$n[i]          <- "10"
    raw$Anesthesia[i] <- "none"
    raw$Mode[i]       <- x[["mode"]]
    raw$Glucose[i]    <- x[["value"]]
    raw$Glucose_SD[i] <- x[["sd"]]
    raw$Oxygen[i]     <- ""
    raw$Oxygen_SD[i]  <- ""
    }
  }

  set_reference <- function(row, expected, value) {
    stopifnot(row <= nrow(raw), trimws(raw$Reference[row]) == expected)
    raw$Reference[row] <<- value
  }
  set_n <- function(row, expected, value) {
    stopifnot(row <= nrow(raw), trimws(raw$n[row]) == expected)
    raw$n[row] <<- as.character(value)
  }
  set_anesthesia <- function(row, expected, value) {
    stopifnot(row <= nrow(raw), trimws(raw$Anesthesia[row]) == expected)
    raw$Anesthesia[row] <<- value
  }
  repair_exact_row <- function(row, expected, replacements) {
    stopifnot(row >= 1L, row <= nrow(raw), setequal(names(expected), names(raw)))
    expected <- expected[names(raw)]
    observed <- vapply(
      names(expected),
      function(field) trimws(as.character(raw[[field]][row])),
      character(1)
    )
    stopifnot(identical(unname(observed), unname(expected)))
    for (field in names(replacements)) raw[[field]][row] <<- replacements[[field]]
  }
  repair_omitted_or_collapsed_measurements <- function(
      row, species, reference, n, anesthesia_token, replacements, mode_token="") {
    expected <- c(
      Species=species, Reference=reference, n=as.character(n),
      Anesthesia=anesthesia_token, Mode=mode_token, Glucose="", Glucose_SD="",
      Oxygen="", Oxygen_SD="", BloodFlow="", BloodFlow_SD=""
    )
    repair_exact_row(row, expected, replacements)
  }

  if (table == "TableA1") {
    stopifnot(trimws(raw$Reference[58]) == "(Delgado-Zygmunt et al., 1993)",
              trimws(raw$Reference[105]) == "(Poindessous-Jazat et al., 1998)",
              trimws(raw$Reference[106]) == "(Poindessous-Jazat et al., 1998)")
    stopifnot(trimws(raw$Reference[87]) == "(Grome and McCulloch, 1983)", raw$n[87] == "6",
              trimws(raw$Reference[108]) == "(Schwartz and Crosby, 1985)", raw$n[108] == "6",
              trimws(raw$Reference[111]) == "(Grome and McCulloch, 1981)", raw$n[111] == "16")
    repair_exact_row(
      60,
      c(Species="Sus", Reference="(Manohar, 1986)", n="6",
        Anesthesia="Sevoflurane", Mode="Microspheres", Glucose="", Glucose_SD="",
        Oxygen="", Oxygen_SD="", BloodFlow="86.0", BloodFlow_SD="7.3"),
      c()
    )
    repair_exact_row(
      120,
      c(Species="Mus", Reference="(Zocchi et al., 2001)", n="4",
        Anesthesia="none", Mode="Sokoloff", Glucose="73.4", Glucose_SD="5.2",
        Oxygen="", Oxygen_SD="", BloodFlow="", BloodFlow_SD=""),
      c()
    )
  }
  if (table == "TableA3") {
    stopifnot(trimws(raw$Reference[31]) == "Present Study",
              trimws(raw$Reference[45]) == "Present Study")
    repair_exact_row(52, c(Species="M mulatta", Reference="(Enlund et al., 1997)", n="4",
      Anesthesia="Ketamine, N2O", Mode="PET", Glucose="", Glucose_SD="",
      Oxygen="245.0", Oxygen_SD="34.0", BloodFlow="70.5", BloodFlow_SD="15.0"), c())
    repair_exact_row(59, c(Species="Sus", Reference="(Manohar, 1986)", n="6",
      Anesthesia="none", Mode="", Glucose="", Glucose_SD="", Oxygen="", Oxygen_SD="",
      BloodFlow="76.8", BloodFlow_SD="4.5"), c())
    repair_exact_row(60, c(Species="Sus", Reference="(Manohar, 1986)", n="6",
      Anesthesia="Sevoflurane", Mode="", Glucose="", Glucose_SD="", Oxygen="", Oxygen_SD="",
      BloodFlow="46.2", BloodFlow_SD="3.0"), c())
    repair_exact_row(61, c(Species="Sus", Reference="(Manohar, 1986)", n="6",
      Anesthesia="Sevoflurane", Mode="", Glucose="", Glucose_SD="", Oxygen="", Oxygen_SD="",
      BloodFlow="59.0", BloodFlow_SD="5.5"), c())
    repair_exact_row(69, c(Species="Meriones", Reference="(Mies et al., 1990)", n="4",
      Anesthesia="Halothane", Mode="Sokoloff", Glucose="", Glucose_SD="", Oxygen="", Oxygen_SD="",
      BloodFlow="139.5", BloodFlow_SD="22.0"), c())
  }
  if (table == "TableA6") {
    set_reference(74, "Hovda", "(Hovda et al., 1996)")
    set_reference(75, "Petitjean 82", "(Petitjean et al., 1982)")
    set_reference(76, "Triolo 90", "(Triolo et al., 1990)")
    repair_exact_row(67, c(Species="Sus", Reference="(Manohar, 1986)", n="6",
      Anesthesia="", Mode="", Glucose="", Glucose_SD="", Oxygen="342.0", Oxygen_SD="20.1",
      BloodFlow="108.2", BloodFlow_SD="6.3"), c())
    repair_exact_row(68, c(Species="Sus", Reference="(Manohar, 1986)", n="6",
      Anesthesia="Sevoflurane", Mode="", Glucose="", Glucose_SD="", Oxygen="171.9", Oxygen_SD="7.6",
      BloodFlow="68.4", BloodFlow_SD="3.5"), c())
    repair_exact_row(69, c(Species="Sus", Reference="(Manohar, 1986)", n="6",
      Anesthesia="Sevoflurane", Mode="", Glucose="", Glucose_SD="", Oxygen="162.5", Oxygen_SD="19.2",
      BloodFlow="77.7", BloodFlow_SD="8.7"), c())
    repair_exact_row(71, c(Species="Lepus", Reference="(Drummond et al., 1986)", n="12",
      Anesthesia="Morphine", Mode="", Glucose="", Glucose_SD="", Oxygen="", Oxygen_SD="",
      BloodFlow="55.0", BloodFlow_SD="12.0"), c())
    repair_exact_row(72, c(Species="Lepus", Reference="(Kaieda et al., 1989)", n="8",
      Anesthesia="Halothane", Mode="", Glucose="", Glucose_SD="", Oxygen="", Oxygen_SD="",
      BloodFlow="69.0", BloodFlow_SD="23.0"), c())
    repair_exact_row(73, c(Species="Lepus", Reference="(Kaieda et al., 1989)", n="8",
      Anesthesia="Isoflurane", Mode="", Glucose="", Glucose_SD="", Oxygen="", Oxygen_SD="",
      BloodFlow="41.0", BloodFlow_SD="16.0"), c())
  }
  if (table == "TableA7") {
    set_reference(40, "Yamaki 96", "(Yamaki et al., 1996)")
    stopifnot(trimws(raw$Reference[101]) == "(Moore et al., 2000)",
              trimws(raw$n[101]) == "6",
              trimws(raw$Anesthesia[101]) == "none",
              trimws(raw$Mode[101]) == "Sokoloff",
              trimws(raw$Glucose[101]) == "79.0",
              trimws(raw$Glucose_SD[101]) == "9.7")
  }
  # These source rows were checked against the page images and migrated into
  # the snapshots. Retain assertions so accidental drift fails the build.
  check_snapshot <- function(row, expected) {
    actual <- vapply(names(expected), function(k) trimws(as.character(raw[[k]][row])), character(1))
    stopifnot(identical(unname(actual), unname(expected)))
  }
  if (table == "TableA10") {
    check_snapshot(5, c(Reference="(Schwartzman et al., 1988)", n="6", Anesthesia="none", Mode="Sokoloff", Glucose="70.3", Glucose_SD="12.2"))
    check_snapshot(6, c(Reference="(Choki et al., 1984)", n="3", Anesthesia="none", Mode="Sokoloff", Glucose="79.0", Glucose_SD="12.0"))
  }
  if (table == "TableA11") {
    check_snapshot(75, c(Reference="(Dam et al., 1990)", n="5", Anesthesia="none", Mode="Sokoloff", Glucose="92.0", Glucose_SD="17.9"))
    check_snapshot(99, c(Reference="(Poindessous-Jazat et al., 1998)", n="5", Glucose="83.3", Glucose_SD="10.0"))
    check_snapshot(110, c(Reference="(Nowaczyk and Des Rosiers, 1981)", n="4", Glucose="53.0", Glucose_SD="10.0"))
  }
  if (table == "TableA13") {
    check_snapshot(13, c(Reference="(Langsjo et al., 2003)", Glucose="", Glucose_SD="", Oxygen="185.0", Oxygen_SD="27.2"))
    check_snapshot(14, c(Reference="(Perlmutter et al., 1987)", Glucose="", Glucose_SD="", Oxygen="111.6", Oxygen_SD="31.9"))
    check_snapshot(15, c(Reference="(Sasaki et al., 1986)", Glucose="", Glucose_SD="", Oxygen="155.8", Oxygen_SD="21.1"))
  }
  if (table == "TableA14") {
    check_snapshot(84, c(Reference="(Zimmer, 1975)", Anesthesia="Allobarbital, Urethan, & Ethylene urea", Oxygen="167.40", BloodFlow="45.60"))
    check_snapshot(110, c(Reference="(Boarini et al., 1984)", Anesthesia="N2O", Oxygen="218.75", Oxygen_SD=".20", BloodFlow="57.00"))
    check_snapshot(194, c(Reference="(Schwedler et al., 1982)", Anesthesia="none", Mode="Probe", Oxygen="192.40", Oxygen_SD="16.10", BloodFlow="77.00", BloodFlow_SD="7.00"))
    check_snapshot(195, c(Reference="(Stanley and Cherniack, 1976)", Anesthesia="none", Mode="Probe", Oxygen="154.46", Oxygen_SD="4.50"))
    check_snapshot(102, c(Reference="(McPherson and Traystman, 1988)", Species="Canis", n="12"))
  }

  # Normalize only citation variants explicitly matched to the same primary
  # reference in the source-local catalog; unchecked OCR may remain in snapshots.
  citation_map <- read.csv(
    file.path(folder, "reference_tables", "Kaufman__2004_citation_corrections.csv"),
    colClasses = "character", check.names = FALSE, stringsAsFactors = FALSE
  )
  stopifnot(!anyDuplicated(citation_map$observed_reference),
            all(nzchar(citation_map$source_reference_id)))
  citation_index <- match(trimws(raw$Reference), citation_map$observed_reference)
  matched <- !is.na(citation_index)
  raw$Reference[matched] <- citation_map$corrected_reference[citation_index[matched]]

  attr(raw, "kaufman_source_corrections_applied") <- TRUE
  raw
}
