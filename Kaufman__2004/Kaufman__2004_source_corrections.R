# Checked correction overlay for Kaufman Appendix A1-A14 frozen snapshots.
#
# The snapshots remain verbatim evidence.  This helper repairs only defects
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
    expected_old <- c(
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
    raw$Reference[i]  <- "(Sokoloff et al., 1977)"
    raw$n[i]          <- "10"
    raw$Anesthesia[i] <- "none"
    raw$Mode[i]       <- x[["mode"]]
    raw$Glucose[i]    <- x[["value"]]
    raw$Glucose_SD[i] <- x[["sd"]]
    raw$Oxygen[i]     <- ""
    raw$Oxygen_SD[i]  <- ""
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
    set_reference(58, "1993)", "(Delgado-Zygmunt et al., 1993)")
    set_reference(105, "1998)", "(Poindessous-Jazat et al., 1998)")
    set_reference(106, "1998)", "(Poindessous-Jazat et al., 1998)")
    set_reference(87, "(Grome and McCulloch, 1983) 6", "(Grome and McCulloch, 1983)"); set_n(87, "", 6)
    set_reference(108, "(Schwartz and Crosby, 1985) 6", "(Schwartz and Crosby, 1985)"); set_n(108, "", 6)
    set_reference(111, "(Grome and McCulloch, 1981) 16", "(Grome and McCulloch, 1981)"); set_n(111, "", 16)
    repair_exact_row(
      60,
      c(Species="Sus", Reference="(Manohar, 1986)", n="6",
        Anesthesia="Sevoflurane", Mode="MicTospheres", Glucose="", Glucose_SD="",
        Oxygen="", Oxygen_SD="", BloodFlow="86.0", BloodFlow_SD="7.3"),
      c(Mode="Microspheres")
    )
    repair_exact_row(
      120,
      c(Species="Mus", Reference="(Zocchi et al., 2001)", n="4",
        Anesthesia="none", Mode="Sokoloff", Glucose="73", Glucose_SD="4",
        Oxygen="5.2", Oxygen_SD="", BloodFlow="", BloodFlow_SD=""),
      c(Glucose="73.4", Glucose_SD="5.2", Oxygen="")
    )
  }
  if (table == "TableA3") {
    set_reference(31, "’resent Study", "Present Study")
    set_reference(45, "’resent Study", "Present Study")
    repair_omitted_or_collapsed_measurements(
      52, "M mulatta", "inlund et al., 1997)", 4, "Ketamine, N 20",
      c(Oxygen="245.0", Oxygen_SD="34.0", BloodFlow="70.5", BloodFlow_SD="15.0"),
      mode_token="PET"
    )
    repair_omitted_or_collapsed_measurements(
      59, "Sus", "(Manohar, 1986)", 6, "none 76.8 4.5",
      c(Anesthesia="none", BloodFlow="76.8", BloodFlow_SD="4.5")
    )
    repair_omitted_or_collapsed_measurements(
      60, "Sus", "(Manohar, 1986)", 6, "Sevoflurane 46.2 3.0",
      c(Anesthesia="Sevoflurane", BloodFlow="46.2", BloodFlow_SD="3.0")
    )
    repair_omitted_or_collapsed_measurements(
      61, "Sus", "(Manohar, 1986)", 6, "Sevoflurane 59.0 5.5",
      c(Anesthesia="Sevoflurane", BloodFlow="59.0", BloodFlow_SD="5.5")
    )
    repair_omitted_or_collapsed_measurements(
      69, "Meriones", "(Mies et al., 1990)", 4, "Halothane",
      c(BloodFlow="139.5", BloodFlow_SD="22.0"), mode_token="Sokoloff"
    )
  }
  if (table == "TableA6") {
    set_reference(74, "Hovda", "(Hovda et al., 1996)")
    set_reference(75, "Petitjean 82", "(Petitjean et al., 1982)")
    set_reference(76, "Triolo 90", "(Triolo et al., 1990)")
    repair_omitted_or_collapsed_measurements(
      67, "Sus", "(Manohar, 1986)", 6, "342.0 20.1 108.2 6.3",
      c(Anesthesia="", Oxygen="342.0", Oxygen_SD="20.1",
        BloodFlow="108.2", BloodFlow_SD="6.3")
    )
    repair_omitted_or_collapsed_measurements(
      68, "Sus", "(Manohar, 1986)", 6,
      "Sevoflurane 171.9 7.6 68.4 3.5",
      c(Anesthesia="Sevoflurane", Oxygen="171.9", Oxygen_SD="7.6",
        BloodFlow="68.4", BloodFlow_SD="3.5")
    )
    repair_omitted_or_collapsed_measurements(
      69, "Sus", "(Manohar, 1986)", 6,
      "Sevoflurane 162.5 19.2 77.7 8.7",
      c(Anesthesia="Sevoflurane", Oxygen="162.5", Oxygen_SD="19.2",
        BloodFlow="77.7", BloodFlow_SD="8.7")
    )
    repair_omitted_or_collapsed_measurements(
      71, "Lepus", "(Drummond et al., 1986)", 12, "Morphine 55.0 12.0",
      c(Anesthesia="Morphine", BloodFlow="55.0", BloodFlow_SD="12.0")
    )
    repair_omitted_or_collapsed_measurements(
      72, "Lepus", "(Kaieda et al., 1989)", 8, "Halothane 69.0 23.0",
      c(Anesthesia="Halothane", BloodFlow="69.0", BloodFlow_SD="23.0")
    )
    repair_omitted_or_collapsed_measurements(
      73, "Lepus", "(Kaieda et al., 1989)", 8, "Isoflurane 41.0 16.0",
      c(Anesthesia="Isoflurane", BloodFlow="41.0", BloodFlow_SD="16.0")
    )
  }
  if (table == "TableA7") {
    set_reference(40, "Yamaki 96", "(Yamaki et al., 1996)")
    stopifnot(trimws(raw$Reference[101]) == "(Moore et al., 2000)",
              trimws(raw$n[101]) == "6",
              trimws(raw$Anesthesia[101]) == "‘ none",
              trimws(raw$Mode[101]) == "Sokoloff",
              trimws(raw$Glucose[101]) == "79.0",
              trimws(raw$Glucose_SD[101]) == "9.7")
    set_anesthesia(101, "‘ none", "none")
  }
  if (table == "TableA8") set_reference(46, "(Perlmutter et al., 2987)", "(Perlmutter et al., 1987)")
  if (table == "TableA11") {
    set_reference(110, "1981)", "(Nowaczyk and Des Rosiers, 1981)")
    repair_omitted_or_collapsed_measurements(
      75, "Rattus", "(Dam et al., 1990)", 5, "none Sokoldff 92.0 17.9",
      c(Anesthesia="none", Mode="Sokoloff", Glucose="92.0", Glucose_SD="17.9")
    )
    repair_exact_row(
      99,
      c(Species="Rattus", Reference="(Poindessous-Jazat et al., 1998)", n="",
        Anesthesia="none", Mode="Sokoloff", Glucose="83.3", Glucose_SD="10.0",
        Oxygen="", Oxygen_SD="", BloodFlow="", BloodFlow_SD=""),
      c(n="5")
    )
  }
  if (table == "TableA10") {
    stopifnot(trimws(raw$Reference[5]) == "(Schwartzman et al., 1988)",
              trimws(raw$n[5]) == "", trimws(raw$Anesthesia[5]) == "6 none",
              trimws(raw$Mode[5]) == "Sokoloff", trimws(raw$Glucose[5]) == "70.3",
              trimws(raw$Glucose_SD[5]) == "12.2")
    set_n(5, "", 6)
    set_anesthesia(5, "6 none", "none")
    stopifnot(trimws(raw$Reference[6]) == "(Choki et al., 1984)",
              trimws(raw$n[6]) == "", trimws(raw$Anesthesia[6]) == "3 none",
              trimws(raw$Mode[6]) == "Sokoloff", trimws(raw$Glucose[6]) == "79.0",
              trimws(raw$Glucose_SD[6]) == "12.0")
    set_n(6, "", 3)
    set_anesthesia(6, "3 none", "none")
  }
  if (table == "TableA14") {
    repair_exact_row(
      84,
      c(Species="Canis", Reference="(Zimmer, 1975)", n="13",
        Anesthesia="& Ethylene urea", Mode="Kety-Schmidt",
        Glucose="27.67", Glucose_SD="3.99", Oxygen="167.40", Oxygen_SD="53.00",
        BloodFlow="45.60", BloodFlow_SD="7.20"),
      c(Anesthesia="Allobarbital, Urethan, & Ethylene urea")
    )
    repair_exact_row(
      111,
      c(Species="Canis", Reference="(Boarini et al., 1984)", n="10",
        Anesthesia="N 20", Mode="Kety-Schmidt", Glucose="", Glucose_SD="",
        Oxygen="218.75", Oxygen_SD="20", BloodFlow="57.00", BloodFlow_SD="4.00"),
      c(Oxygen_SD="0.20")
    )
    repair_omitted_or_collapsed_measurements(
      195, "Capra", "(Schwedler et al., 1982)", 17,
      "none Probe 192.40 16.10 77.00 7.00",
      c(Anesthesia="none", Mode="Probe", Oxygen="192.40", Oxygen_SD="16.10",
        BloodFlow="77.00", BloodFlow_SD="7.00")
    )
    repair_omitted_or_collapsed_measurements(
      196, "Capra", "(Stanley and Chemiack, 1976)", 6,
      "none Probe 154.46 4.50",
      c(Anesthesia="none", Mode="Probe", Oxygen="154.46", Oxygen_SD="4.50")
    )
    stopifnot(trimws(raw$Reference[102]) == "(McPherson and Traystman,")
    set_reference(103, "1988)", "(McPherson and Traystman, 1988)")
    raw <- raw[-102, , drop=FALSE]
  }
  if (table == "TableA13") {
    repair_exact_row(
      13,
      c(Species="Homo", Reference="(Langsjo et al., 2003)", n="10",
        Anesthesia="none", Mode="PET", Glucose="27.2", Glucose_SD="185.0",
        Oxygen="", Oxygen_SD="", BloodFlow="", BloodFlow_SD=""),
      c(Glucose="", Glucose_SD="", Oxygen="185.0", Oxygen_SD="27.2")
    )
    repair_exact_row(
      14,
      c(Species="Homo", Reference="(Perlmutter et al., 1987)", n="32",
        Anesthesia="none", Mode="PET", Glucose="31.9", Glucose_SD="111.6",
        Oxygen="", Oxygen_SD="", BloodFlow="", BloodFlow_SD=""),
      c(Glucose="", Glucose_SD="", Oxygen="111.6", Oxygen_SD="31.9")
    )
    repair_exact_row(
      15,
      c(Species="Homo", Reference="(Sasaki et al., 1986)", n="7",
        Anesthesia="none", Mode="PET", Glucose="21.1", Glucose_SD="155.8",
        Oxygen="", Oxygen_SD="", BloodFlow="", BloodFlow_SD=""),
      c(Glucose="", Glucose_SD="", Oxygen="155.8", Oxygen_SD="21.1")
    )
  }

  attr(raw, "kaufman_source_corrections_applied") <- TRUE
  raw
}
