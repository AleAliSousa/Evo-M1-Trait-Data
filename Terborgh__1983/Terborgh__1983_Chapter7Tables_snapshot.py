#!/usr/bin/env python3
"""Frozen manual transcription of selected primary rows in Tables 7.1–7.5.

Checked in the institutional VLeBooks reader at ISBN 9781400857166.
Only the book's own New World study rows are included from Table 7.5;
its Old World comparison block is credited to Clutton-Brock & Harvey 1977a.
"""

import csv
from pathlib import Path

HERE = Path(__file__).resolve().parent
OUT = HERE / "Terborgh__1983_Chapter7Tables_snapshot.csv"
rows = []


def add(table, page, species, sample, values, note=""):
    for measure, unit, printed in values:
        rows.append(dict(source_order=len(rows) + 1, table_number=table,
                         source_print_page=page, species_as_printed=species,
                         sample_as_printed=sample, measure_as_printed=measure,
                         unit_as_printed=unit, value_as_printed=str(printed),
                         source_role="primary_study_summary",
                         source_note=note))


# Table 7.1, printed p. 131. Parenthesized densities are from the
# author's earlier census and carry the footnote, not an uncertainty SD.
t71 = [
    ("Cebus apella", "10", "40", "1.0", "80", "8.0", "2.5", "3.2"),
    ("Cebus albifrons", "15", "35", "0.8", "≥150", ">10.0", "2.9", "≥3.5"),
    ("Saimiri sciureus", "35", "60", "0.5", ">250", ">7.1", "2.0", ">3.6"),
    ("Saguinus imperator", "4", "(12)", "0.05", "30", "7.5", "7.5", "1.0"),
    ("Saguinus fuscicollis", "5", "(16)", "0.05", "30", "6.0", "6.0", "1.0"),
]
m71 = [("mean_troop_size", "individuals"), ("population_density", "individuals/km2"),
       ("biomass", "kg/ha"), ("home_range_size", "ha"),
       ("home_range_per_individual", "ha/individual"),
       ("area_per_individual", "ha/individual"), ("overlap_index", "ratio")]
for species, *values in t71:
    add("7.1", 131, species, "study summary",
        [(name, unit, value) for (name, unit), value in zip(m71, values)],
        "Parentheses on Saguinus density refer to 1974 census estimates; inequalities retained.")

# Table 7.2, printed p. 137; mean rows are published summaries of the
# preceding sampled months and must not be counted as extra independent samples.
t72 = [
    ("Cebus apella", "August", "7", "2620", "780"),
    ("Cebus apella", "October", "18", "2230", "420"),
    ("Cebus apella", "January", "14", "1630", "500"),
    ("Cebus apella", "June", "17", "1820", "480"),
    ("Cebus apella", "Mean", "", "2070", "540"),
    ("Cebus albifrons", "November", "14", "2170", "400"),
    ("Cebus albifrons", "March", "9", "1820", "400"),
    ("Cebus albifrons", "June", "13", "1460", "760"),
    ("Cebus albifrons", "Mean", "", "1820", "520"),
    ("Saimiri sciureus", "August", "6", "1630", "230"),
    ("Saguinus imperator", "April", "8", "1090", "210"),
    ("Saguinus imperator", "July", "3", "1540", "620"),
    ("Saguinus imperator", "Mean", "", "1420", "350"),
    ("Saguinus fuscicollis", "November", "7", "1160", "390"),
    ("Saguinus fuscicollis", "April", "8", "1220", "450"),
    ("Saguinus fuscicollis", "July", "4", "1290", "270"),
    ("Saguinus fuscicollis", "Mean", "", "1220", "370"),
    ("Callicebus moloch", "May", "4", "960", "210"),
]
for species, sample, n_days, mean, sd in t72:
    note = "Published mean across samples; do not pool with months" if sample == "Mean" else "Complete tracked days"
    if n_days:
        add("7.2", 137, species, sample, [("complete_days", "days", n_days)], note)
    add("7.2", 137, species, sample,
        [("daily_travel_mean", "m/day", mean), ("daily_travel_sd", "m/day", sd)], note)

# Table 7.3, printed p. 142. Two cumulative values have attached footnote
# glyphs that were not separable in the reader; preserve the visible string.
t73 = [
    ("Cebus apella", "August", "57"), ("Cebus apella", "October", "52"),
    ("Cebus apella", "January", "34"), ("Cebus apella", "June", "73"),
    ("Cebus apella", "Cumulative", "81"),
    ("Cebus albifrons", "November", "52"), ("Cebus albifrons", "March", ">55"),
    ("Cebus albifrons", "June", ">75"), ("Cebus albifrons", "Cumulative", "≥150"),
    ("Saguinus imperator", "August", "30"), ("Saguinus imperator", "April", "16"),
    ("Saguinus imperator", "July", "15"), ("Saguinus imperator", "Cumulative", "30,21"),
    ("Saguinus fuscicollis", "November", "7"), ("Saguinus fuscicollis", "April", "17"),
    ("Saguinus fuscicollis", "July", "15"), ("Saguinus fuscicollis", "Cumulative", "30,24"),
]
for species, sample, value in t73:
    note = "Cumulative total; attached footnote glyph not resolved" if value in ("30,21", "30,24") else "Area within envelope of extreme points"
    add("7.3", 142, species, sample, [("space_used", "ha", value)], note)

# Table 7.4, printed p. 146. Parentheses are ratios to the corresponding
# November–January value, not error bars; preserve them in source strings.
t74 = [
    ("area_covered", "ha", "34", "52", "73 (2.1)", "75 (1.6)"),
    ("fruit_trees_used", "trees", "225", "190", "50 (0.2)", "190 (1.1)"),
    ("feeding_time_per_day", "min/day", "115", "86", "45 (0.4)", "111 (1.3)"),
    ("mean_crown_diameter", "m", "22.5", "15.7", "12.7 (0.6)", "30 (1.9)"),
]
for measure, unit, ap_max, al_max, ap_min, al_min in t74:
    for species, sample, value in [
        ("Cebus apella", "maximum fruit abundance (November–January)", ap_max),
        ("Cebus albifrons", "maximum fruit abundance (November–January)", al_max),
        ("Cebus apella", "minimum fruit abundance (June)", ap_min),
        ("Cebus albifrons", "minimum fruit abundance (June)", al_min),
    ]:
        add("7.4", 146, species, sample, [(measure, unit, value)],
            "Parenthesized value is source ratio to corresponding maximum-abundance period; fruit trees exclude palms.")

# Table 7.5, printed p. 151. Only the four New World study rows are
# transcribed. Old World rows are secondary Clutton-Brock & Harvey 1977a.
t75 = [
    ("Cebus apella", "3.0", "80", "10", "40", "105", "0", "24", "76"),
    ("Cebus albifrons", "2.8", "≥150", "15", "35", "85", "0", "36", "64"),
    ("Saimiri sciureus", "0.8", ">250", "35", "60", "50", "0", "18", "82"),
    ("Saguinus spp.", "0.35", "30", "4", "28", "10", "0", "42", "58"),
]
m75 = [("adult_body_weight", "kg"), ("home_range_area", "ha"),
       ("mean_group_size", "individuals"), ("population_density", "individuals/km2"),
       ("biomass", "kg/km2"), ("diet_leaves_flowers", "% time"),
       ("diet_fruits_seeds", "% time"), ("diet_prey", "% time")]
for species, *values in t75:
    add("7.5", 151, species, "study summary",
        [(name, unit, value) for (name, unit), value in zip(m75, values)],
        "New World study row; group, density and range repeat Table 7.1; diet is proportion of time, not weight/volume.")

with OUT.open("w", newline="", encoding="utf-8") as stream:
    writer = csv.DictWriter(stream, fieldnames=list(rows[0]))
    writer.writeheader()
    writer.writerows(rows)
print(f"{len(rows)} source measurements across Tables 7.1–7.5 -> {OUT.name}")
