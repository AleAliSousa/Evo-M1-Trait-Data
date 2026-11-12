#!/usr/bin/env python3
"""Extract the two registered supplementary reference items; no numeric data.

Uses the hanging-indent bibliography and reads the two-column single-species
list column by column. Species numbers are data-row identifiers, not citations.
"""
import csv
import io
import re
from pathlib import Path
import pdfplumber

folder = Path(__file__).resolve().parent
publication = folder.name


def freeze(item, rows):
    s = io.StringIO()
    w = csv.DictWriter(s, fieldnames=list(rows[0]), lineterminator="\n")
    w.writeheader()
    w.writerows(rows)
    p = folder / (item + "_snapshot.csv")
    if p.exists() and p.read_text(encoding="utf-8-sig") != s.getvalue():
        raise RuntimeError("Refusing differing snapshot overwrite: " + str(p))
    p.write_text(s.getvalue(), encoding="utf-8-sig")


with pdfplumber.open(folder / "1-s2.0-S0047248412000577-mmc1.pdf") as doc:
    refs = []
    active = False
    for pi in range(10, 18):
        for line in doc.pages[pi].extract_text_lines(layout=False):
            txt = line["text"]
            if txt == "4. References":
                active = True
                continue
            if not active or line["top"] < 45 or line["top"] > 790:
                continue
            if line["x0"] < 78:
                refs.append(dict(source_row=len(refs)+1, source_pdf_page=str(pi+1), citation_as_printed=txt))
            elif refs:
                refs[-1]["citation_as_printed"] += "\n" + txt
                if str(pi+1) not in refs[-1]["source_pdf_page"].split(";"):
                    refs[-1]["source_pdf_page"] += ";" + str(pi+1)
    assert all(re.search(r"\(\d{4}(?:[a-z]|-\d{4})?\)", r["citation_as_printed"]) for r in refs)
    freeze(publication + "_SupplementaryInformation4.References", refs)

    # First preserve the printed taxon/group-level scope blocks.
    lines = []
    for pi in [2, 3]:
        for line in doc.pages[pi].extract_text_lines(layout=False):
            if line["top"] < 45:
                continue
            if pi == 3 and line["top"] >= 289:
                break
            lines.append((pi+1, line["text"]))
    scopes = {"Mammals in general, various species:": "all_mammals", "Rodentia": "Rodentia",
              "Carnivora": "Carnivora", "Primates": "Primates"}
    prefix_scopes = {"Canidae": "Canidae", "Mustelidae": "Mustelidae", "Cercopithecines": "Cercopithecinae",
                     "Colobines": "Colobinae", "Tarsiers": "Tarsiidae", "Platyrrhines": "Platyrrhini",
                     "Lemurs": "Lemuriformes", "Lagomorpha": "Lagomorpha", "‘Insectivora’": "Insectivora"}
    blocks = []
    for page, txt in lines:
        if txt in scopes:
            blocks.append(dict(source_row=len(blocks)+1, source_pdf_page=page,
                               scope_as_printed=txt, scope_key=scopes[txt], species_numbers_as_printed="",
                               references_as_printed=""))
        elif any(txt.startswith(k + ":") for k in prefix_scopes):
            key, txt = txt.split(":", 1)
            blocks.append(dict(source_row=len(blocks)+1, source_pdf_page=page,
                               scope_as_printed=key, scope_key=prefix_scopes[key], species_numbers_as_printed="",
                               references_as_printed=txt.strip()))
        elif blocks:
            blocks[-1]["references_as_printed"] += ("\n" if blocks[-1]["references_as_printed"] else "") + txt

    # Then the explicitly numbered species citations, left column then right.
    for lo, hi in [(65, 330), (330, 575)]:
        text = doc.pages[3].crop((lo, 303, hi, 765)).extract_text(x_tolerance=1)
        pending = ""
        for line in text.splitlines():
            pending += ("\n" if pending else "") + line
            m = re.match(r"^(.+?)\s*\(([\d, ]+)\)$", pending, re.S)
            if m:
                blocks.append(dict(source_row=len(blocks)+1, source_pdf_page=4,
                                   scope_as_printed="Single species", scope_key="explicit_species_numbers",
                                   species_numbers_as_printed=m[2], references_as_printed=m[1]))
                pending = ""
        assert not pending.strip(), pending
    assert len([r for r in blocks if r["scope_key"] == "explicit_species_numbers"]) == 51
    freeze(publication + "_SupplementaryInformation1.3", blocks)
    print(f"{len(refs)} bibliography entries; {len(blocks)} source-scope blocks")
