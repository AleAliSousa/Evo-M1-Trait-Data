"""Extract the bibliography paragraphs from the untouched author DOCX."""
import csv
from pathlib import Path
import xml.etree.ElementTree as ET
from zipfile import ZipFile

folder = Path(__file__).resolve().parent
source = folder / "evo13128-sup-0001-suppmat.docx"
target = folder / "Martin_etal_2017_SupportingInformationS1_snapshot.csv"
ns = {"w": "http://schemas.openxmlformats.org/wordprocessingml/2006/main"}
with ZipFile(source) as archive:
    root = ET.fromstring(archive.read("word/document.xml"))
paragraphs = ["".join(t.text or "" for t in p.findall(".//w:t", ns)).strip()
              for p in root.findall(".//w:p", ns)]
paragraphs = [p for p in paragraphs if p]
assert paragraphs[:2] == ["Electronic Supporting Information",
                          "Supporting Information  S1. List of references for frequency data."]
references = paragraphs[2:]
assert len(references) == 147
with target.open("w", newline="", encoding="utf-8") as stream:
    writer = csv.writer(stream)
    writer.writerow(["source_paragraph", "citation_verbatim"])
    writer.writerows((i + 3, ref) for i, ref in enumerate(references))
print(f"{target.name}: {len(references)} bibliography entries")
