#!/usr/bin/env python3
"""Extract Baron, Stephan & Frahm (1996) Table 5 ("Average body weights (BoW)
and brain weights (BrW) of 342 species and/or subspecies of bats", PDF pp.
22-32, printed pp. 284-294) from the PDF text layer.

Companion to Baron_etal_1996_extract_snapshots.py (Tables 10/32) and
Baron_etal_1996_Table2_extract.py (Table 2). Unlike Table 2, this table's
text layer IS one-species-per-line (no crammed multi-species lines), which
makes line-based parsing straightforward - but each species can have
between 1 and 4 printed lines:

  1. The species' own first line - the "standard" (bold-faced in print).
     Per the table's own notes: "If there is more than one line for a
     species, the first line includes the pairs of body and brain weights
     used to establish the standards." THIS is the only line built here.
  2. Optional "males" / "females" / "median inter sexes" sub-lines - sex-
     differentiated detail already folded into the standard line above.
  3. Optional bare-numeric continuation lines with no species name at all -
     literature-comparison values "which more strongly deviate and were
     therefore not included in the standards" (per the same notes).

Sub-lines and bare-numeric continuations are recognized and skipped: a line
is only treated as a new species if its first character is an uppercase
letter (or the section-sign footnote marker); anything starting with a
digit or with a known continuation keyword (males/female/median/presumed)
is skipped.

Each species' data run has up to 7 fields, several independently optional:
BoW, [CV_BoW], BrW, [CV_BrW], [n_BoW, n_BrW | n], Source. CV values (always
one decimal place, e.g. "9.5") are distinguished from BoW/BrW (which may or
may not have a decimal point) purely by checking for a decimal point in the
position where a CV would fall - BrW is never itself printed with a decimal
point in this table, so this rule is unambiguous. Source is always the
line's last token and may be a letter code, a bare citation-index digit, or
a comma-joined list (e.g. "10,12,S"); it never needs disambiguating from n
because the state machine tracks how many trailing tokens remain (1: Source
only; 2: shared n + Source; 3: n_BoW, n_BrW, Source).

One species (*Mosia nigrescens*) is printed with a footnote marker but NO
weight data at all (only a "see addendum" reference) - it is kept as a row
with blank measurement fields, since it is one of the source's own stated
342 species/subspecies and dropping it silently would misrepresent the
table's total.

The snapshot preserves the source's own printed family/subfamily ALL-CAPS
section headings (e.g. "PTEROPODIDAE", "PTEROPODINAE (cont.)") as their own
rows (`is_header=TRUE`, all measurement fields blank), rather than
discarding them, so the snapshot reads as a faithful visual mirror of the
printed table's taxonomic groupings - useful for a human skimming the file,
and trivially filterable (`is_header` blank) for anything that wants
species rows only. These header rows are NOT carried into the analysis CSV
(Baron_etal_1996_Table5.R strips them before writing the final output).

A small number of species names have a confirmed, image-verified OCR
letterform correction applied (documented in NAME_FIXES below) - each was
cross-checked either directly against a rendered page image, or against the
same species' independently image-verified spelling in the sibling
Baron_etal_1996_Table2 build (same source book, same species, already
verified there against its own page images). Cosmetic spacing/letterform
artifacts that were NOT independently confirmed are left as printed.

Output: Baron_etal_1996_Table5_snapshot.csv, 342 species rows plus their
interspersed section-heading rows, matching the table's own stated
species/subspecies count exactly, from Eidolon helvum through Cheiromeles
torquatus.
"""

import re

SKIP_LINE_PATTERNS = [
    r'^\d+\s+Brains of Chiroptera',
    r'^>\s*Table 5',
    r'^Table 5\.',
    r'^and/or subspecies',
    r'^BoW\s+CV\s+BrW',
    r'^in g in %',
    r'^Notes to Table 5',
    r'^If there is more than one line',
    r'^pairs of body and brain',
    r'^either single values',
    r'^females and median',
    r'^the preceding lines',
    r'^more strongly deviate',
    r'^are bold-faced',
    r'^\*\) Median values',
    r'^significant sex differences',
    r'^§\) See addendum',
    r'^The standards are bold',
    r'^CV = coefficient',
    r'^n = number of specimens',
    r'^Key to the source',
    r'^\d+: ',   # numbered source-key list lines like "1: M Weber (1896); 2: ..."
    r'^\*\*\) Doubtful determination',
]

def is_skip_line(line):
    s = line.strip()
    if not s:
        return True
    for pat in SKIP_LINE_PATTERNS:
        if re.match(pat, s):
            return True
    return False


def is_all_caps_header(line):
    s = line.strip()
    letters = re.sub(r'[^A-Za-z]', '', s)
    if len(letters) < 3:
        return False
    return letters.isupper()


CONTINUATION_STARTS = ('males', 'male', 'females', 'female', 'median', 'presumed')

# Species-name OCR corrections, each individually confirmed against a
# rendered page image (either Table 5's own page, or - for species shared
# with Table 2 - that item's already image-verified spelling). Applied as
# whole-name literal replacements after the name/data split, so they never
# touch numeric data.
NAME_FIXES = {
    'Pteropus alec to': 'Pteropus alecto',
    'Pteropus maerotis': 'Pteropus macrotis',
    'Pteropus neohibernieus': 'Pteropus neohibernicus',
    'Pteropus polioeephalus *)': 'Pteropus poliocephalus *)',
    'Pteropus seapulatus': 'Pteropus scapulatus',
    'Pteropus temmineki': 'Pteropus temmincki',
    'Mieropteropus pusillus': 'Micropteropus pusillus',
    'Seotonyeteris zenkeri': 'Scotonycteris zenkeri',
    'Casinyeteris argynnis *)': 'Casinycteris argynnis *)',
    'Chi ron ax melanocephalus': 'Chironax melanocephalus',
    'Nycteris macro tis': 'Nycteris macrotis',
    'Megaderma spasm a': 'Megaderma spasma',
    'Sturn ira ludovici': 'Sturnira ludovici',
    'Sturn ira tildae': 'Sturnira tildae',
    'Tadarida leu co stigma': 'Tadarida leucostigma',
    'Ametrida centuria': 'Ametrida centurio',
    'Miniopterus infiatus': 'Miniopterus inflatus',
    'D. moluee. magna \u00a7)': 'D. molucc. magna \u00a7)',
    'D. moluee. anderseni *) \u00a7)': 'D. molucc. anderseni *) \u00a7)',
}


def clean_ocr(text):
    # 'I' standalone -> '1' (common OCR misread of digit 1)
    text = re.sub(r'(?<![A-Za-z])I(?![A-Za-z.])', '1', text)
    # letter O misread for digit 0 in a source-key citation token (e.g. "1O,S" -> "10,S")
    text = text.replace('1O,S', '10,S')
    return text


# PDF page 23 (printed p. 285) has a page-wide OCR confusion of the letter
# "S" for the digit "5" - confirmed by the page's own column header being
# misread as "50urce" instead of "Source", and independently confirmed by
# rendering the page at high resolution: every occurrence of a bare "5" (or
# a "5" at the end of a comma-joined Source code) in the Source column on
# this page is printed as "S" in the source, not the citation-index digit 5.
# This is scoped to this one page only - the same "5" pattern on other pages
# (e.g. p. 293's Barbastella barbastellus, Plecotus auritus) was separately
# confirmed by image to be a genuine citation-index 5, since those pages'
# headers show no such corruption.
S_FOR_5_PAGE = 23


def fix_source_s_for_5(source, page_num):
    if source is None or page_num != S_FOR_5_PAGE:
        return source
    if source == '5':
        return 'S'
    if source.endswith(',5'):
        return source[:-1] + 'S'
    return source


NUM_RE = re.compile(r'^-?\d+(\.\d+)?$')
DEC_RE = re.compile(r'^-?\d+\.\d+$')


def parse_species_line(line, page_num):
    line = clean_ocr(line.strip())
    tokens = line.split()
    # Walk from the left: name tokens are everything until we hit a pure number
    name_tokens = []
    i = 0
    while i < len(tokens) and not NUM_RE.match(tokens[i]):
        name_tokens.append(tokens[i])
        i += 1
    name = ' '.join(name_tokens).strip()
    name = NAME_FIXES.get(name, name)
    data = tokens[i:]

    if not data:
        return {'species_printed': name, 'source_pdf_page': page_num,
                'BoW_g': None, 'CV_BoW_pct': None, 'BrW_mg': None, 'CV_BrW_pct': None,
                'n_BoW': None, 'n_BrW': None, 'Source': None, 'no_data': True}

    pos = 0
    BoW = data[pos]; pos += 1
    CV_BoW = None
    if pos < len(data) and DEC_RE.match(data[pos]):
        CV_BoW = data[pos]; pos += 1
    BrW = None
    if pos < len(data) and NUM_RE.match(data[pos]):
        BrW = data[pos]; pos += 1
    CV_BrW = None
    if pos < len(data) and DEC_RE.match(data[pos]):
        CV_BrW = data[pos]; pos += 1

    tail = data[pos:]
    n_BoW = n_BrW = Source = None
    if len(tail) == 3:
        n_BoW, n_BrW, Source = tail
    elif len(tail) == 2:
        n_BoW = n_BrW = tail[0]
        Source = tail[1]
    elif len(tail) == 1:
        Source = tail[0]
    elif len(tail) == 0:
        pass
    else:
        # unexpected - flag
        return {'species_printed': name, 'source_pdf_page': page_num,
                'BoW_g': BoW, 'CV_BoW_pct': CV_BoW, 'BrW_mg': BrW, 'CV_BrW_pct': CV_BrW,
                'n_BoW': None, 'n_BrW': None, 'Source': None,
                'issue': f'unexpected tail {tail}'}

    Source = fix_source_s_for_5(Source, page_num)

    return {'species_printed': name, 'source_pdf_page': page_num,
            'BoW_g': BoW, 'CV_BoW_pct': CV_BoW, 'BrW_mg': BrW, 'CV_BrW_pct': CV_BrW,
            'n_BoW': n_BoW, 'n_BrW': n_BrW, 'Source': Source}


def parse_page(text, page_num):
    rows = []
    no_data_species = []
    issues = []
    in_key_section = False
    for raw_line in text.splitlines():
        s = raw_line.strip()
        if not s:
            continue
        if re.match(r'^Key to the source', s):
            in_key_section = True
            continue
        if in_key_section:
            continue
        if is_skip_line(s):
            continue
        # strip trailing stray punctuation-only tokens (OCR artifacts)
        s = re.sub(r"\s+['\"]+$", '', s)
        # family/subfamily section headings, e.g. "PTEROPODIDAE (cont.)" -
        # preserved as their own header rows rather than discarded, and
        # indented to mirror the printed page's own visual hierarchy:
        # family names (ending "-IDAE") sit flush left in print; subfamily
        # names (ending "-INAE") are printed with a small indent; species
        # rows (below) get a further indent, matching how they appear
        # italicised and inset under their subfamily in the book.
        stripped_of_cont = re.sub(r'\s*\((cont|cant)\.\)\s*$', '', s)
        if is_all_caps_header(stripped_of_cont):
            clean_heading = re.sub(r'\s+', ' ', s).strip()
            indent = '  ' if stripped_of_cont.rstrip().endswith('INAE') else ''
            rows.append({
                'species_printed': indent + clean_heading,
                'source_pdf_page': page_num,
                'BoW_g': None, 'CV_BoW_pct': None, 'BrW_mg': None, 'CV_BrW_pct': None,
                'n_BoW': None, 'n_BrW': None, 'Source': None,
                'is_header': True,
            })
            continue
        first_word = s.split()[0].lower()
        if first_word in CONTINUATION_STARTS:
            continue
        # continuation numeric-only lines (no leading species name) start with a digit
        if re.match(r'^-?\d', s):
            continue
        # must start with an uppercase letter to be a species line
        if not re.match(r'^[A-Z\u00a7]', s):
            continue
        row = parse_species_line(s, page_num)
        if row.get('no_data'):
            no_data_species.append(row['species_printed'])
            continue
        if row.get('issue'):
            issues.append((row['species_printed'], row['issue'], page_num))
            continue
        row['is_header'] = None
        # indent species rows one level further than subfamily headers,
        # mirroring the printed page's own inset/italic species listing
        row['species_printed'] = '    ' + row['species_printed']
        rows.append(row)
    return rows, no_data_species, issues


def build_all():
    all_rows = []
    for pidx in range(21, 32):
        with open(f'page{pidx}.txt', encoding='utf-8') as f:
            text = f.read()
        rows, no_data, issues = parse_page(text, pidx + 1)
        if issues:
            raise RuntimeError(f'Unresolved issues on page {pidx+1}: {issues}')
        all_rows.extend(rows)
        for name in no_data:
            all_rows.append({
                'species_printed': '    ' + name, 'source_pdf_page': pidx + 1,
                'BoW_g': None, 'CV_BoW_pct': None, 'BrW_mg': None, 'CV_BrW_pct': None,
                'n_BoW': None, 'n_BrW': None, 'Source': None, 'is_header': None,
            })

    species_rows = [r for r in all_rows if not r.get('is_header')]
    if len(species_rows) != 342:
        raise RuntimeError(f'Expected 342 species rows, got {len(species_rows)}')
    if species_rows[0]['species_printed'].strip() != 'Eidolon helvum':
        raise RuntimeError('Unexpected first species')
    if species_rows[-1]['species_printed'].strip() != 'Cheiromeles torquatus':
        raise RuntimeError('Unexpected final species')
    return all_rows


if __name__ == '__main__':
    import csv
    rows = build_all()
    n_species = sum(1 for r in rows if not r.get('is_header'))
    n_headers = sum(1 for r in rows if r.get('is_header'))
    print(f'TOTAL ROWS: {len(rows)} ({n_species} species + {n_headers} section headers)')
    # species_printed (with its printed-hierarchy indentation) leads the file
    # so the snapshot reads like the original page at a glance; species_row
    # is still included for reference, just not the lead column - see README.
    fieldnames = ['species_printed', 'is_header', 'source_pdf_page',
                  'BoW_g', 'CV_BoW_pct', 'BrW_mg', 'CV_BrW_pct', 'n_BoW', 'n_BrW', 'Source',
                  'species_row']
    with open('Baron_etal_1996_Table5_snapshot.csv', 'w', newline='', encoding='utf-8-sig') as f:
        w = csv.DictWriter(f, fieldnames=fieldnames, quoting=csv.QUOTE_ALL)
        w.writeheader()
        for i, r in enumerate(rows, 1):
            out = {'species_row': i, **r}
            out['is_header'] = 'TRUE' if r.get('is_header') else ''
            w.writerow(out)
    print('Wrote Baron_etal_1996_Table5_snapshot.csv')
