"""Devillard et al. 2003 colony size: constructed snapshot from the Methods prose.

The value is stated in prose, not tabulated, so the FROZEN SOURCE is the author sentences
themselves -- one row per reported value, each carrying the verbatim passage and its locator, so a
reviewer can find the number on the page and read it in the paper's own words. Preserving the
printed wording (and the paper's "70 feral cats", not a cleaned "70") is what lets a human catch a
transcription slip.
"""
import csv, re
from pathlib import Path
import fitz

P = Path(__file__).resolve().parent
PDF = P / "Devillard-2003-Dispersal pattern of domestic c.pdf"

doc = fitz.open(PDF)
text = " ".join(" ".join(pg.get_text().split()) for pg in doc)
doc.close()

SIZE = ("The studied population of 70 feral cats resides in a hospital park in the centre of "
        "Lyon (France).")
GROUP = ("Cats formed a large stable social group characterized by a dominance hierarchy both for "
         "females and males (Say et al. 2001), as has been described in other such high-density "
         "populations (Natoli & De Vito 1991).")
FEED = ("Cats were fed mainly with canteen waste by hospital staff, but they could hunt birds and "
        "small rodents anywhere.")
# An input problem must fail, not print: refuse to freeze a passage the PDF does not contain.
for q in (SIZE, GROUP, FEED):
    assert " ".join(q.split()) in text, "passage not found verbatim in the source PDF: " + q[:60]

rows = [dict(
    source_location='Materials and methods, first paragraph (printed p. 204)',
    species_as_printed='feral cats (Felis catus)',
    population_as_printed='a hospital park in the centre of Lyon (France)',
    colony_size_as_printed='70 feral cats',
    social_unit_as_printed='a large stable social group characterized by a dominance hierarchy',
    verbatim_size_passage=SIZE,
    verbatim_social_group_passage=GROUP,
    verbatim_provisioning_passage=FEED)]

with (P / "Devillard_etal_2003_ColonySize_snapshot.csv").open("w", newline="") as f:
    w = csv.DictWriter(f, list(rows[0])); w.writeheader(); w.writerows(rows)
print("Devillard_etal_2003_ColonySize_snapshot.csv:", len(rows), "row; all passages verified against the PDF")
