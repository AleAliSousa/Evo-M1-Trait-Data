#!/usr/bin/env python3
"""Build Heuer_etal_2019_Table1_snapshot.xlsx - a hand-verified capture of the printed Table 1.

Table 1 ("List of species included") is printed on p. 3 of the article. It is a PRINTED source,
so a snapshot is required (__HOWTO_build_a_dataset_file.md sec 0a invariant 1). The PDF's text
layer has lost all intra-cell spaces ("Daubentoniamadagascariensis"), so an automatic parse would
have to re-insert word breaks by guesswork. The values below are therefore TRANSCRIBED BY HAND
from the rendered page, keeping the printed grade rows, printed row order, and the multi-valued
cells exactly as printed (e.g. "No,Yes,Yes" / "BC,PL,PDE" for the pooled macaque rows).

Checks that the transcription satisfies (asserted below, so a typo cannot pass silently):
  * 34 species rows - the paper's "34 primate species"
  * N sums to 65      - the paper's "65 individuals"
"""

import os

from openpyxl import Workbook

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "Heuer_etal_2019_Table1_snapshot.xlsx")

# Caption transcribed verbatim, including the paper's own "Nationale" (the p. 1 affiliation
# says "National") and its U+2019 apostrophe. Do not correct either - fidelity beats tidiness.
CAPTION = ("Table 1 - List of species included. ABIDE1: Autism Brain Imaging Data Exchange 1. "
           "BC: Brain Catalogue. MNHN: Muséum Nationale d’Histoire Naturelle de Paris. "
           "NCBR: National Chimpanzee Brain Resource. PL: Pruszynski Lab. "
           "PDE: PRIMate Data Exchange (PRIME-DE).")
HEADER = ["Name", "Binomial Name (GenBank)", "N", "In vivo", "Extracted", "Provenance"]

# (Name, Binomial, N, In vivo, Extracted, Provenance) - None marks a printed grade row
ROWS = [
    ("Lemuriformes", None, None, None, None, None),
    ("Aye-aye", "Daubentonia madagascariensis", 1, "No", "No", "MNHN"),
    ("Black-and-white ruffed lemur", "Varecia variegata variegata", 1, "No", "No", "MNHN"),
    ("Coquerel's mouse lemur", "Mirza coquereli", 1, "No", "No", "MNHN"),
    ("Grey mouse lemur", "Microcebus murinus", 1, "No", "No", "MNHN"),
    ("Mongoose lemur", "Eulemur mongoz", 1, "No", "No", "MNHN"),
    ("Red-tailed sportive lemur", "Lepilemur ruficaudatus", 1, "No", "No", "MNHN"),
    ("Ring-tailed lemur", "Lemur catta", 1, "No", "Yes", "MNHN"),
    ("Loridae", None, None, None, None, None),
    ("Red slender loris", "Loris tardigradus", 1, "No", "Yes", "MNHN"),
    ("Galagonidae", None, None, None, None, None),
    ("Demidoff's galago", "Galago demidoff", 1, "No", "No", "MNHN"),
    ("Cebidae", None, None, None, None, None),
    ("Black-pencilled marmoset", "Callithrix penicillata", 1, "No", "Yes", "MNHN"),
    ("Cotton-top tamarin", "Saguinus oedipus", 1, "No", "Yes", "MNHN"),
    ("Douroucouli", "Aotus trivirgatus", 1, "No", "No", "MNHN"),
    ("Squirrel monkey", "Saimiri sciureus", 2, "No", "Yes", "MNHN"),
    ("Tufted capuchin", "Cebus apella", 1, "No", "No", "MNHN"),
    ("White-faced sapajou", "Cebus capucinus", 1, "No", "Yes", "MNHN"),
    ("Atelidae", None, None, None, None, None),
    ("Black spider monkey", "Ateles paniscus", 2, "No", "No", "MNHN"),
    ("Woolly monkey", "Lagothrix lagotricha", 1, "No", "Yes", "MNHN"),
    ("Cercopithecini", None, None, None, None, None),
    ("Green monkey", "Chlorocebus sabaeus", 1, "No", "Yes", "MNHN"),
    ("Moustached guenon", "Cercopithecus cephus cephus", 1, "No", "Yes", "MNHN"),
    ("Papionini", None, None, None, None, None),
    ("Crab-eating macaque", "Macaca fascicularis", 8, "No,Yes,Yes", "Yes,No,No", "BC,PL,PDE"),
    ("Grey-cheeked mangabey", "Lophocebus albigena", 1, "No", "Yes", "MNHN"),
    ("Hamadryas baboon", "Papio hamadryas", 1, "No", "Yes", "MNHN"),
    ("Rhesus monkey", "Macaca mulatta", 6, "No,Yes,Yes", "Yes,No,No", "MNHN,PL,PDE"),
    ("Sooty mangabey", "Cercocebus atys", 1, "No", "Yes", "MNHN"),
    ("Colobinae", None, None, None, None, None),
    ("Hanuman langur", "Semnopithecus entellus", 1, "No", "Yes", "MNHN"),
    ("Indochinese lutung", "Trachypithecus germaini", 1, "No", "No", "MNHN"),
    ("King colobus", "Colobus polykomos", 1, "No", "Yes", "MNHN"),
    ("Hominoidea", None, None, None, None, None),
    ("Bonobo", "Pan paniscus", 1, "Yes", "No", "NCBR"),
    ("Chimpanzee", "Pan troglodytes troglodytes", 9, "Yes", "No", "NCBR"),
    ("Gibbon", "Hylobates lar", 1, "Yes", "No", "NCBR"),
    ("Gorilla", "Gorilla beringei", 1, "No", "Yes", "BC"),
    ("Gorilla", "Gorilla gorilla", 1, "Yes", "No", "NCBR"),
    ("Human", "Homo sapiens", 10, "Yes", "No", "ABIDE1"),
    ("Orangutan", "Pongo pygmaeus", 1, "No", "No", "MNHN"),
]


def main():
    species = [r for r in ROWS if r[1] is not None]
    assert len(species) == 34, "expected 34 species rows, got %d" % len(species)
    total_n = sum(r[2] for r in species)
    assert total_n == 65, "expected N to sum to 65 individuals, got %d" % total_n

    wb = Workbook()
    ws = wb.active
    ws.title = "Table1"
    ws.append([CAPTION] + [None] * (len(HEADER) - 1))
    ws.append(HEADER)
    for r in ROWS:
        ws.append(list(r))
    wb.save(OUT)
    print("%s: %d species rows, N = %d individuals"
          % (os.path.basename(OUT), len(species), total_n))


if __name__ == "__main__":
    main()
