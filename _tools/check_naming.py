#!/usr/bin/env python3
"""Check the Author[_other]_Year naming convention across Evo-M1-Trait-Data.

    python3 _tools/check_naming.py                     # public repo only
    python3 _tools/check_naming.py --restricted PATH    # also scan the restricted companion
    python3 _tools/check_naming.py --quiet              # summary + exit code only

Writes _checks/naming_check.csv (one row per finding) and exits 1 if any in-scope
P1/P2 finding was found, 0 otherwise -- so it can gate a build.

THE CONVENTION comes from __ReadMe.xlsx Sheet1 column F, which is a formula:

    G & IF(H<>"", "_"&H, "_") & IF(I<>"", "_"&I, "_") & IF(B<>"", "_"&B, "")
    1st Author    other author(s)      year              optional sequence letter

A missing "other author(s)" leaves an empty slot, so the separators collapse into "__":
single author -> Armstrong__1979; two or more -> Bush_Allman_2003, Baron_etal_1983.
Item name (K) = TRIM(TEXTJOIN("_", FALSE, F, SUBSTITUTE(SUBSTITUTE(D," ",""),"_","")))

WHAT IT GOVERNS (always, no exceptions):
    - the folder name
    - the builder script for the csv/tsv
    - the csv and tsv themselves
Snapshots follow it too, bar a couple of known exceptions (see SNAPSHOT_EXCEPTIONS).

WHAT IT DOES NOT GOVERN:
    - the source paper PDF
    - publisher-supplied source tables (they arrive with their own names)
    - comparison inputs
  Those keep whatever name they came with -- which may differ from the publication key
  or lack an underscore entirely -- and are entered by hand in each script. This checker
  skips them, and also skips mentions of them inside otherwise-governed files.
"""
import os, re, csv, sys, zipfile, argparse, collections
from xml.etree import ElementTree as ET

NS = '{http://schemas.openxmlformats.org/spreadsheetml/2006/main}'
ROOT = os.environ.get("EVOM1_ROOT") or os.path.dirname(os.path.dirname(os.path.abspath(__file__)))

# ---------------------------------------------------------------- editable allowances
# (file, line) pairs that quote a wrong spelling ON PURPOSE, e.g. to document the mismatch.
DELIBERATE = {
    ('PUB', 'Weaver__2001/Weaver__2001_TableA-15.ReadMe.md', 11),
    ('PUB', '_keys/specimen_crosswalk/IDENTIFIER_JOIN_PASS_METHOD.md', 61),
    ('RES', 'specimen_registry/derived/RESTRICTED_identifier_join_results.md', 92),
}
# snapshot filenames that legitimately depart from the convention
SNAPSHOT_EXCEPTIONS = set()          # e.g. {'SomePaper_2001/odd_snapshot_name.xlsx'}
# dated archives and other frozen historical copies: reported at P4, never a build failure,
# because rewriting them would falsify the record they exist to preserve.
HISTORICAL_PREFIX = ('specimen_registry/archive/', '_checks/archive/')
HISTORICAL_DATED = re.compile(r'_(20\d{6}|20\d\d-\d\d-\d\d)\.(csv|md|tsv|xlsx)$')
SKIPDIR = {'.git', '__pycache__', '.Rproj.user', '.claude', 'node_modules'}
SELF_OUTPUT = ('naming_check', 'underscore_naming_audit', 'underscore_fixes_applied')

TEXT_EXT = {'.r', '.rmd', '.py', '.md', '.txt', '.csv', '.tsv', '.json', '.yml', '.yaml',
            '.sh', '.rproj', '.bib', '.log', '.qmd'}
SOURCE_EXT = {'.pdf'}
SRC_DATA_EXT = {'.xlsx', '.xls', '.xlsm', '.zip', '.docx', '.doc', '.rtf', '.dta', '.html', '.txt'}
NONGOV_SUFFIX = tuple(SOURCE_EXT | SRC_DATA_EXT)
MAX_BYTES = 40_000_000

YEAR = re.compile(r'^(1[89]\d\d|20\d\d)$')
TOKEN = re.compile(r'(?<![A-Za-z0-9_])([A-Za-z][A-Za-z0-9]*(?:_[A-Za-z0-9\-\.]*)+)')
QSTR = re.compile(r'["\']([^"\'\n]{3,200}?\.(?:csv|tsv|xlsx|xlsm|xls|txt|rds|RData|json|md|pdf|dta|R))["\']')


def norm(s):
    return re.sub(r'[^a-z0-9]', '', (s or '').lower())


def nu(s):
    """collapse runs of underscores -- the key under which spellings are compared"""
    return re.sub(r'_+', '_', s)


# ---------------------------------------------------------------- registry
def read_registry(root):
    z = zipfile.ZipFile(os.path.join(root, "__ReadMe.xlsx"))
    ss = [''.join(t.text or '' for t in si.iter(NS + 't'))
          for si in ET.fromstring(z.read('xl/sharedStrings.xml')).iter(NS + 'si')]

    def grid(path):
        sh = ET.fromstring(z.read(path)); out = []
        for row in sh.iter(NS + 'row'):
            d = {}
            for c in row.iter(NS + 'c'):
                col = ''.join(ch for ch in c.get('r') if ch.isalpha())
                v = c.find(NS + 'v'); isx = c.find(NS + 'is')
                if c.get('t') == 's' and v is not None:
                    val = ss[int(v.text)]
                elif isx is not None:
                    val = ''.join(t.text or '' for t in isx.iter(NS + 't'))
                elif v is not None:
                    val = v.text
                else:
                    val = None
                d[col] = val
            out.append(d)
        return out

    g = grid('xl/worksheets/sheet1.xml')
    hdr = g[0]
    COL = {v: k for k, v in hdr.items() if v}

    def cell(r, name):
        return (r.get(COL.get(name, '~')) or '').strip()

    rows = []
    for i, r in enumerate(g[1:], start=2):
        d = dict(xlrow=i, pub=cell(r, 'Publication name'), a=cell(r, '1st Author'),
                 o=cell(r, 'other author(s)'), y=cell(r, 'year'), seq=cell(r, 'sequence'),
                 item=cell(r, 'Item name'), snap=cell(r, 'Snapshot'),
                 stage=cell(r, 'Progress stage'))
        if any([d['pub'], d['a'], d['item'], d['y']]):
            rows.append(d)
    return rows


def expected_pub(d):
    """column F's formula, in Python"""
    out = d['a'] + ('_' + d['o'] if d['o'] else '_') + ('_' + d['y'] if d['y'] else '_')
    return out + ('_' + d['seq'] if d['seq'] else '')


def pubportion(fields):
    """fields = token.split('_') -> (pubname, rest) or None"""
    for i, f in enumerate(fields):
        if YEAR.match(f):
            j = i
            if i + 1 < len(fields) and re.fullmatch(r'[ab]|I{1,3}', fields[i + 1] or ''):
                j = i + 1
            return '_'.join(fields[:j + 1]), '_'.join(fields[j + 1:])
    return None


# ---------------------------------------------------------------- scope
# paths whose contents are written by a builder or a check script: a wrong spelling there is
# cleared by re-running the producer, never by hand-editing the file.
GENERATED_PREFIX = ('_checks/', '__merging_', '__energetics_comparison/',
                    '__Public/comparative-data/', '__ShinyApp/data/')
GENERATED_NAME = ('variable_catalog', 'packages_used', 'MIGRATED_INDEX',
                  '_triage_comparison_inputs', 'registry_snapshot', 'folder_audit',
                  'files_containing_rstudioapi', 'r_script_data_file_associations',
                  'csv_tsv_candidate_creators', 'csv_tsv_no_candidate_script_found',
                  'script_execution_log', 'script_failures_only')


def is_generated(rel):
    base = os.path.basename(rel)
    return rel.startswith(GENERATED_PREFIX) or any(n in base for n in GENERATED_NAME)


def governed(rel):
    """False for objects the convention does not govern."""
    parts = rel.split('/'); base = parts[-1]
    ext = os.path.splitext(base)[1].lower()
    low = base.lower()
    if rel in SNAPSHOT_EXCEPTIONS:
        return False
    if ext in SOURCE_EXT:
        return False
    if 'comparison' in parts[:-1]:
        return False
    if ext in SRC_DATA_EXT and len(parts) > 1:
        if 'snapshot' in low:
            return True
        return False          # publisher-supplied source table living in a paper folder
    return True


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--restricted', default=os.environ.get('EVOM1_RESTRICTED'),
                    help='path to the Evo-M1-Trait-Data-restricted repo (optional)')
    ap.add_argument('--quiet', action='store_true')
    ap.add_argument('--out', default=os.path.join(ROOT, '_checks', 'naming_check.csv'))
    args = ap.parse_args()

    repos = [('PUB', ROOT)]
    if args.restricted and os.path.isdir(args.restricted):
        repos.append(('RES', args.restricted))

    reg = read_registry(ROOT)

    # ---- canonical spellings: registry publication names + item-name prefixes + folder names
    canon = set()
    for d in reg:
        if d['pub']:
            canon.add(d['pub'])
        if d['item']:
            p = pubportion(d['item'].split('_'))
            if p:
                canon.add(p[0])
    for lab, root in repos:
        for x in os.listdir(root):
            if os.path.isdir(os.path.join(root, x)) and not x.startswith(('_', '.')):
                canon.add(x)
        rc = os.path.join(root, 'restricted_checks')
        if os.path.isdir(rc):
            for x in os.listdir(rc):
                if os.path.isdir(os.path.join(rc, x)) and not x.startswith(('_', '.')):
                    canon.add(x)
    canon = {c for c in canon if pubportion(c.split('_'))}
    cmap = collections.defaultdict(set)
    for c in canon:
        cmap[nu(c)].add(c)
    AUTH = {c.split('_')[0] for c in canon}

    def check_token(tok):
        """-> (canonical, found) when tok names a publication with the wrong underscores"""
        low = tok.lower()
        if low.endswith(NONGOV_SUFFIX) and 'snapshot' not in low:
            return None                     # names a source paper / source table
        tok = tok.rstrip('_.-')
        f = tok.split('_')
        if f[0] not in AUTH:
            return None
        p = pubportion(f)
        if not p:
            return None
        found = p[0]
        if found in canon:
            return None
        alts = cmap.get(nu(found))
        if alts and found not in alts:
            return (sorted(alts)[0], found)
        return None

    findings = []

    def add(sev, kind, lab, path, line, found, canonical, note):
        if path.startswith(HISTORICAL_PREFIX) or HISTORICAL_DATED.search(path):
            sev, note = 'P4', 'dated/archived copy -- left as-is on purpose; ' + note
        findings.append(dict(severity=sev, kind=kind, repo=lab, path=path, line=line,
                             found=found, canonical=canonical,
                             in_scope='yes' if governed(path) else 'no', note=note))

    # ---- 1. registry internal consistency ------------------------------------------
    for d in reg:
        if d['a'] and d['y'] and d['pub'] and d['pub'] != expected_pub(d):
            add('P1', 'registry_pub_name', 'PUB', '__ReadMe.xlsx', d['xlrow'], d['pub'],
                expected_pub(d), 'Publication name (F) != the F formula on G/H/I/B')
        if d['item'] and d['pub'] and not d['item'].startswith(d['pub'] + '_') \
                and d['item'] != d['pub']:
            add('P1', 'registry_item_name', 'PUB', '__ReadMe.xlsx', d['xlrow'], d['item'],
                d['pub'] + '_<item token>',
                'Item name (K) does not start with the Publication name -- a broken K formula '
                'here halts _tools/file_list.R for the whole sheet')
        for m in TOKEN.finditer(d['snap'] or ''):
            r = check_token(m.group(1))
            if r:
                add('P2', 'registry_snapshot_value', 'PUB', '__ReadMe.xlsx', d['xlrow'],
                    r[1], r[0], 'Snapshot column names a file with the wrong spelling')

    # ---- 2. folders, filenames, file contents --------------------------------------
    disk_base = collections.defaultdict(set)
    for lab, root in repos:
        for dp, dn, fn in os.walk(root):
            dn[:] = [d for d in dn if d not in SKIPDIR]
            for f in fn:
                disk_base[f].add((lab, os.path.relpath(os.path.join(dp, f), root)))
    base_nu = collections.defaultdict(set)
    for b in disk_base:
        base_nu[nu(b)].add(b)

    for lab, root in repos:
        for dp, dn, fn in os.walk(root):
            dn[:] = [d for d in dn if d not in SKIPDIR]
            for f in fn + [os.path.basename(dp)]:
                if f.startswith('.'):
                    continue
                rel = os.path.relpath(os.path.join(dp, f), root).replace(os.sep, '/')
                if any(s in rel for s in SELF_OUTPUT):
                    continue
                # -- filename / path components
                seen = set()
                for part in rel.split('/'):
                    for seg in part.split('.'):
                        for m in TOKEN.finditer(seg):
                            r = check_token(m.group(1))
                            if r and r not in seen:
                                seen.add(r)
                                add('P2', 'filename', lab, rel, '', r[1], r[0],
                                    'rename to the canonical spelling and update referrers')
                # -- file contents
                full = os.path.join(dp, f)
                if not os.path.isfile(full):
                    continue
                if os.path.splitext(f)[1].lower() not in TEXT_EXT:
                    continue
                try:
                    if os.path.getsize(full) > MAX_BYTES:
                        continue
                except OSError:
                    continue
                txt = None
                for enc in ('utf-8', 'latin-1'):
                    try:
                        txt = open(full, encoding=enc).read(); break
                    except (UnicodeDecodeError, OSError):
                        txt = None
                if txt is None or '\x00' in txt:
                    add('P4', 'unreadable', lab, rel, '', '', '',
                        'could not decode (cloud-only placeholder?) -- not checked')
                    continue
                is_code = rel.lower().endswith(('.r', '.rmd'))
                for ln, line in enumerate(txt.splitlines(), 1):
                    if '_' not in line:
                        continue
                    if (lab, rel, ln) in DELIBERATE:
                        continue
                    for m in TOKEN.finditer(line):
                        r = check_token(m.group(1))
                        if not r:
                            continue
                        if is_code:
                            sev = 'P4' if re.match(r'\s*#', line) else 'P2'
                            kind = 'code_comment' if sev == 'P4' else 'code_string'
                        elif rel.lower().endswith(('.csv', '.tsv')):
                            if is_generated(rel):
                                sev, kind = 'P3', 'generated_value'
                            else:
                                sev, kind = 'P2', 'data_value'
                        else:
                            sev, kind = 'P4', 'doc'
                        add(sev, kind, lab, rel, ln, r[1], r[0], line.strip()[:140])

                # -- quoted file references in R that resolve to nothing
                if is_code:
                    for ln, line in enumerate(txt.splitlines(), 1):
                        for m in QSTR.finditer(line):
                            ref = m.group(1)
                            if any(c in ref for c in '{}$*?') or ref.startswith(('http', '~')):
                                continue
                            b = os.path.basename(ref)
                            if b in disk_base or os.path.exists(os.path.join(dp, ref)):
                                continue
                            alt = sorted(x for x in base_nu.get(nu(b), ()) if x != b)
                            if alt:
                                add('P1', 'broken_path', lab, rel, ln, b, alt[0],
                                    'referenced file does not exist; an underscore variant does')

    # ---- report --------------------------------------------------------------------
    os.makedirs(os.path.dirname(args.out), exist_ok=True)
    with open(args.out, 'w', newline='', encoding='utf-8') as fh:
        w = csv.DictWriter(fh, fieldnames=['severity', 'kind', 'repo', 'path', 'line',
                                           'found', 'canonical', 'in_scope', 'note'])
        w.writeheader()
        for r in sorted(findings, key=lambda x: (x['severity'], x['repo'], x['path'], x['line'] or 0)):
            w.writerow(r)

    live = [f for f in findings if f['in_scope'] == 'yes' and f['severity'] in ('P1', 'P2')]
    if not args.quiet:
        print("repos checked      : %s" % ", ".join('%s=%s' % (l, r) for l, r in repos))
        print("registry rows      : %d   canonical spellings: %d" % (len(reg), len(canon)))
        print("findings           : %d in scope, %d skipped as source/comparison files"
              % (sum(1 for f in findings if f['in_scope'] == 'yes'),
                 sum(1 for f in findings if f['in_scope'] == 'no')))
        by = collections.Counter((f['severity'], f['kind']) for f in findings if f['in_scope'] == 'yes')
        for (sev, kind), n in sorted(by.items()):
            print("   %-3s %-22s %d" % (sev, kind, n))
        p1 = [f for f in live if f['severity'] == 'P1']
        if p1:
            print("\nP1 -- breaks execution or the registry:")
            for f in p1:
                print("   [%s] %s:%s  %s -> %s" % (f['repo'], f['path'], f['line'],
                                                   f['found'], f['canonical']))
        print("\nwrote %s" % args.out)
        print("VERDICT: %s" % ("FAIL (%d in-scope P1/P2)" % len(live) if live else "PASS"))
    return 1 if live else 0


if __name__ == '__main__':
    sys.exit(main())
