#!/usr/bin/env python3
"""Build the Kirk & Kay 2004 Table 1 + Table 2 snapshots (chapter 20 of Ross & Kay, eds,
Anthropoid Origins: New Visions, Kluwer/Plenum, pp. 539-602; doi:10.1007/978-1-4419-8873-7_20).

Faithful capture per __HOWTO_make_a_snapshot.md: printed strings verbatim — ranges kept as
printed ("50.0-77.0" with an en dash), substrate qualifiers kept inside the value string
("2.5 (air); 3.3 (water)"), printed misspellings kept (Camelus bactrius, Zalophus californicus,
Eumetopias jubata, Sciurus caroliniensis, "Gervaif fruit eating bat"), genus-level rows kept as
"... sp.". Wrapped cells (Lagenorhynchus obliquidens; multi-reference sources) are joined with a
single space. Nothing is corrected here; the species crosswalk carries the resolutions and the
.R does the typing/splitting.

Run:  python3 Kirk_Kay_2004_extract_snapshot.py [--verify]
--verify re-extracts the PDF text (pdftotext -layout, per page) and asserts every transcribed
token of every row appears on that row's page — the transcription audit. Wrapped-cell joins mean
tokens are checked individually, not as whole cells.
"""
import csv, os, subprocess, sys, unicodedata

HERE = os.path.dirname(os.path.abspath(__file__))
PDF  = os.path.join(HERE, "kirk_kay_2004.pdf")
EN   = "–"  # en dash as printed in ranges

# (scientific name, common name, activity pattern, visual acuity (c/deg), source)
T1 = [
 ("Homo sapiens","Human","Diurnal",f"50.0{EN}77.0","Cavonius and Robbins, 1973; DeValois et al., 1974"),
 ("Macaca mulatta","Rhesus macaque","Diurnal",f"46.2{EN}53.6","Cowey and Ellis, 1967; Cavonius and Robbins, 1973"),
 ("Macaca nemestrina","Pig-tailed macaque","Diurnal","46.0","DeValois et al., 1974"),
 ("Macaca fascicularis","Crab-eating macaque","Diurnal","46.0","DeValois et al., 1974"),
 ("Saimiri sciureus","Squirrel monkey","Diurnal","40.5","Cowey and Ellis, 1967"),
 ("Equus caballus","Domestic horse","Cathemeral",f"10.9{EN}23.3","Timney and Keil, 1992"),
 ("Aotus trivirgatus","Northern owl monkey","Nocturnal","10.0","Jacobs, 1977"),
 ("Camelus bactrius","Bactrian camel","Cathemeral","10.0","Harman et al., 2001"),
 ("Felis catus","Domestic cat","Cathemeral",f"5.0{EN}8.9","Bisti and Maffei, 1974; Blake et al., 1974; Jacobson et al., 1976"),
 ("Lemur catta","Ring-tailed lemur","Diurnal",f"6.0{EN}6.7","Neuringer et al., 1981"),
 ("Suricata suricatta","Meerkat","Diurnal","6.3","Moran et al., 1983"),
 ("Otolemur crassicaudatus","Fat-tailed bush baby","Nocturnal",f"4.8{EN}6.0","Langston et al., 1986"),
 ("Zalophus californicus","California sea lion","Cathemeral",f"5.4{EN}5.7","Schusterman and Balliet, 1970b"),
 ("Myrmecobius fasciatus","Numbat","Diurnal","5.2","Arrese et al., 2000"),
 ("Lagenorhynchus obliquidens","Pacific white-sided dolphin","Cathemeral","5.0","Spong and White, 1971"),
 ("Eumetopias jubata","Stellar sea lion","Cathemeral","4.2 (water)","Schusterman and Balliet, 1970a"),
 ("Spermophilus beecheyi","California ground squirrel","Diurnal","4.0","Jacobs et al., 1980"),
 ("Sciurus griseus","Western gray squirrel","Diurnal","3.9","Jacobs et al., 1982"),
 ("Sciurus niger","Fox squirrel","Diurnal","3.9","Jacobs et al., 1982"),
 ("Sciurus caroliniensis","Eastern gray squirrel","Diurnal","3.9","Jacobs et al., 1982"),
 ("Tursiops truncatus","Bottlenose dolphin","Cathemeral",f"1.6{EN}2.5 (air); 2.5{EN}3.8 (water)","Herman et al., 1975"),
 ("Phoca vitulina","Harbour seal","Cathemeral","3.6","Schusterman and Balliet, 1970a"),
 ("Pteropus giganteus","Indian flying fox","Nocturnal","3.5","Neuweiler, 1962; cited in Pettigrew et al., 1988"),
 ("Oryctolagus cuniculus","Old World rabbit","Cathemeral",f"1.5{EN}3.0","Van Hof, 1967; Vaney, 1980"),
 ("Dasyurus hallucatus","Quoll","Nocturnal",f"2.3{EN}2.8","Harman et al., 1986"),
 ("Amblonyx cinerea","Asian clawless otter","Cathemeral",f"1.9{EN}2.2 (air); 2.0 (water)","Balliet and Schusterman, 1971"),
 ("Sminthopsis crassicaudata","Fat-tailed dunnart","Nocturnal","2.4","Arrese et al., 1999"),
 ("Tupaia belangeri","Tree shrew","Diurnal",f"1.2{EN}2.4","Petry et al., 1984"),
 ("Mustela putorius","European polecat","Cathemeral",f"1.2{EN}1.9","Neumann and Schmidt, 1959, cited in Mass and Supin, 2000"),
 ("Mustela erminea","Ermine","Cathemeral",f"1.2{EN}1.9","Neumann and Schmidt, 1959, cited in Mass and Supin, 2000"),
 ("Rattus norvegicus","Pigmented laboratory rat","Nocturnal",f"1.2{EN}1.6","Birch and Jacobs, 1979; Seymoure and Juraska, 1997"),
 ("Tarsipes rostratus","Honey possum","Cathemeral","0.6","Arrese et al., 2002"),
 ("Mus musculus","House mouse","Cathemeral","0.5","Sinex et al., 1979; Prusky et al., 2000"),
 ("Mesocricetus auratus","Golden hamster","Nocturnal","0.5","Emerson, 1980"),
 ("Phyllostomus hastatus","Greater spear-nosed bat","Nocturnal",f"0.1{EN}0.4","Suthers, 1966"),
 ("Artibeus jamaicensis","Jamaican fruit-eating bat","Nocturnal",f"0.1{EN}0.4","Suthers, 1966"),
 ("Myotis lucifugus","Little brown bat","Nocturnal",f"0.05{EN}0.1","Suthers, 1966"),
]
T2 = [
 ("Homo sapiens","Human","Diurnal",f"47.0{EN}86.0","Hirsch and Curcio, 1989; Curcio et al., 1990"),
 ("Cebus apella","Tufted capuchin","Diurnal",f"38.8{EN}54.8","Andrade da Costa and Hokoç, 2000"),
 ("Callithrix jacchus","Common marmoset","Diurnal","30.0","Troilo et al., 1993"),
 ("Equus caballus","Domestic horse","Cathemeral",f"16.4{EN}20.4","Timney and Keil, 1992"),
 ("Camelus dromedarius","Dromedary camel","Cathemeral","10.4","Harman et al., 2001"),
 ("Aotus azarae","Azara’s owl monkey","Nocturnal or Cathemeral","8.3","Yamada et al., 2001"),
 ("Felis catus","Domestic cat","Cathemeral","8.1","Hughes, 1975"),
 ("Otolemur crassicaudatus","Fat-tailed bush baby","Nocturnal",f"6.2{EN}7.5","DeBruyn et al., 1980; Dkhissi-Benyahya et al., 2001"),
 ("Callorhinus ursinus","Northern fur seal","Cathemeral",f"5.6{EN}7.1","Mass and Supin, 1992"),
 ("Myrmecobius fasciatus","Numbat","Diurnal","6.3","Arrese et al., 2000"),
 ("Pteropus poliocephalus","Gray-headed flying fox","Nocturnal","5.5","Pettigrew et al., 1988"),
 ("Microcebus murinus","Gray mouse lemur","Nocturnal","4.9","Dkhissi-Benyahya et al., 2001"),
 ("Trichosurus vulpecula","Brush-tailed possum","Nocturnal","4.8","Freeman and Tancred, 1978"),
 ("Enhydra lutris","Sea otter","Diurnal","4.2 (air and water)","Mass and Supin, 2000"),
 ("Balaenoptera acutorostrata","Minke whale","Cathemeral",f"3.9{EN}4.2 (water)","Murayama et al., 1992"),
 ("Loxodonta africana","African elephant","Cathemeral","4.1","Stone and Halasz, 1989"),
 ("Pteropus scapulatus","Little red flying fox","Nocturnal","4.0","Pettigrew et al., 1988"),
 ("Odobenus rosmarus","Pacific walrus","Cathemeral","3.8","Mass, 1992"),
 ("Delphinus delphis","Common dolphin","Cathemeral","3.8 (water)","Dral, 1983"),
 ("Pseudorca crassidens","False killer whale","Cathemeral","3.3 (water)","Murayama and Somiya, 1998"),
 ("Tursiops truncatus","Bottlenose dolphin","Cathemeral","2.5 (air); 3.3 (water)","Mass and Supin, 1995"),
 ("Rousettus sp.","Rousette fruit bat","Nocturnal","3.0","Marks, 1980; cited in Pettigrew et al., 1988"),
 ("Phocoena phocoena","Harbor porpoise","Cathemeral","2.1 (air); 2.7 (water)","Mass and Supin, 1986"),
 ("Eschrichtius robustus","Gray whale","Cathemeral","2.7 (water)","Mass and Supin, 1997"),
 ("Lagenorhynchus obliquidens","Pacific white-sided dolphin","Cathemeral","2.7 (water)","Murayama and Somiya, 1998"),
 ("Delphinapterus leucas","Beluga whale","Cathemeral","2.6 (water)","Murayama and Somiya, 1998"),
 ("Dasyurus hallucatus","Quoll","Nocturnal","2.6","Harman et al., 1986"),
 ("Phocoenoides dalli","Dall’s porpoise","Cathemeral",f"2.5{EN}2.6 (water)","Murayama et al., 1992, 1995"),
 ("Phascolarctos cinereus","Koala","Cathemeral","2.4","Schmid et al., 1992"),
 ("Sminthopsis crassicaudata","Fat-tailed dunnart","Nocturnal","2.3","Arrese et al., 1999"),
 ("Macroderma gigas","Australian false vampire bat","Nocturnal","1.9","Pettigrew et al., 1988"),
 ("Mesocricetus auratus","Golden hamster","Nocturnal","1.8","Tiao and Blakemore, 1976"),
 ("Megaderma lyra","Greater false vampire bat","Nocturnal","1.5","Pettigrew et al., 1988"),
 ("Artibeus cinereus","Gervaif fruit eating bat","Nocturnal","1.4","Pettigrew et al., 1988"),
 ("Taphozous georgianus","Brown sheath-tailed bat","Nocturnal","1.3","Pettigrew et al., 1988"),
 ("Sotalia fluviatilis","River dolphin (tucuxi)","Cathemeral","0.9 (air); 1.2 (water)","Mass and Supin, 1999"),
 ("Saccopteryx sp.","White-lined bat","Nocturnal","1.0","Marks, 1980; cited in Pettigrew et al., 1988"),
 ("Tarsipes rostratus","Honey possum","Cathemeral","0.8","Dunlop et al., 1994"),
 ("Inia geoffrensis","Amazon dolphin (boutos)","Cathemeral","0.6 (air); 0.8 (water)","Mass and Supin, 1989, 1999"),
 ("Eptesicus sp.","Big brown bat","Nocturnal","0.7","Marks, 1980; cited in Pettigrew et al., 1988"),
 ("Nyctophilus gouldi","Gould’s long-eared bat","Nocturnal","0.6","Pettigrew et al., 1988"),
 ("Rhinolophus rouxi","Horseshoe bat","Nocturnal","0.4","Pettigrew et al., 1988"),
]
HDR = ["scientific_name","common_name","activity_pattern","visual_acuity_cdeg_as_printed","source_as_printed"]

def write():
    for name, rows in (("Table1", T1), ("Table2", T2)):
        p = os.path.join(HERE, f"Kirk_Kay_2004_{name}_snapshot.csv")
        with open(p, "w", newline="", encoding="utf-8") as f:
            w = csv.writer(f); w.writerow(HDR); w.writerows(rows)
        print(f"wrote {os.path.basename(p)}: {len(rows)} rows")

def norm(s):
    s = unicodedata.normalize("NFKD", s).replace("\u2019", "'").replace("\u2018", "'")
    return "".join(c for c in s if not unicodedata.combining(c))

def verify():
    pages = {}
    def page_text(p):
        if p not in pages:
            pages[p] = norm(subprocess.run(["pdftotext","-layout","-f",str(p),"-l",str(p),PDF,"-"],
                                           capture_output=True, text=True).stdout)
        return pages[p]
    # locate table pages
    span = {}
    for p in range(1, 65):
        t = page_text(p)
        if "Behavioral measurements of visual acuity" in t: span.setdefault("Table1", []).append(p)
        if "Table 1." in t and "Continued" in t and "Table1" in span: span["Table1"].append(p)
        if "Anatomical estimates of visual acuity" in t: span.setdefault("Table2", []).append(p)
        if "Table 2." in t and "Continued" in t and "Table2" in span: span["Table2"].append(p)
    bad = 0
    for name, rows in (("Table1", T1), ("Table2", T2)):
        ps = sorted(set(span[name])); text = "\n".join(page_text(p) for p in ps)
        for r in rows:
            for cell in r:
                for tok in norm(cell.replace(";"," ").replace("("," ").replace(")"," ")).split():
                    if tok not in text:
                        print(f"  !! {name} token not found: {tok!r} (row {r[0]})"); bad += 1
        print(f"{name}: pages {ps} verified" + ("" if not bad else f" with {bad} misses"))
    sys.exit(1 if bad else 0)

if __name__ == "__main__":
    write()
    if "--verify" in sys.argv: verify()
