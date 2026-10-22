# Manger et al. 2012 - Table 1 (species, brain mass, gyrification index; elephants, cetaceans, other mammals)

Manger PR, Prowse M, Haagensen M, Hemingway J (2012). *Quantitative analysis of neocortical gyrencephaly in African elephants and six species of cetaceans: comparison with other mammals.* J Comp Neurol 520(11):2430-2439. doi:10.1002/cne.23046

## Source -> snapshot -> CSV
`Manger_etal_2012.pdf` (EndNote 2098), Table 1 on PDF p.3 (journal p.2432). `..._Table1_snapshot.csv` is a constructed snapshot read by eye from a 2.2x render: order sub-heading rows, the three elephant individuals, and the final 'Primates' range row all kept as printed. `..._Table1.R` -> `..._Table1.csv`: 30 animal rows (sub-headings carried down as `order_group`; primate range row dropped). TSV skipped until the registry row is pasted into `__ReadMe.xlsx`.

## Fidelity checks (all pass)
- Elephant mean GI (4.01, 3.85, 3.81) = 3.89 and mean brain mass 5,076.67 g, as stated in the text.
- Six cetaceans: mean GI 5.43, range 5.23-5.70, brain mass 577-5,617 g, as stated.
- Carnivores 13 + 2 pinnipeds = 15; 4 artiodactyls; text counts agree (72 species / 91 individuals including the 44 primates not listed individually).

## Provenance - read before pooling
GI_source 1 = measured in this study (elephants, hyrax, manatee, cetaceans, most small carnivores, pinnipeds); 2 = Pillay & Manger 2007 (pig, deer, llama, zebu, meerkat, cat, hyena, lion, polar bear) - secondary; 3 = Zilles 1989 (primates, not itemised).

## Lewitus 2014 (ref 73)
The comparable quantities are `GI` and `brain_mass_g`. Lewitus' GI cells are NOT all equal to this table: e.g. Loxodonta 3.84 (here 3.81-4.01, mean 3.89), Tursiops 4.76 (here 5.63), Trichechus 1.019 (here 1.07), Procavia 1.368 (here 1.38).

## Overlaps in repo (`__merging_gyrification/gyrification_long.csv`)
Sources there: Lewitus_etal_2014_TableS1/TableS8 and Zilles_etal_2013_Table1; no Manger 2012 rows. Species already present: Loxodonta (Zilles 3.81 = elephant LA3 here), Ursus maritimus 2.04, Panthera leo 1.85, Felis catus 1.5, Crocuta 1.74, Sus scrofa 2.16 (the Pillay & Manger copies agree), Phoca vitulina 2.38, Tursiops (Zilles 4.47 vs 5.63 here), Trichechus, Procavia. New species likely absent: Kogia sima, Delphinus, Delphinapterus, Orcinus, Megaptera, Odocoileus, Lama, Bos indicus, small mustelids, Zalophus (not exhaustively checked per species). Because three elephant individuals and secondary copies share a dependency group, pool with care.

## Caveats
Species stay as printed; three rows are the same species (individuals). Brain-mass definition not stated in the table.

## RA check still to do
Side-by-side read of the render against the snapshot (35 lines x 5 columns).
