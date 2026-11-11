#!/usr/bin/env python3
"""
build_species_taxonomy.py -- assemble _keys/species_taxonomy.csv (Species, Order,
Family) for every species in the compiled datasets, so the Shiny app can filter /
colour plots by clade. Order/Family are NOT measurements — this keeps them out of
the trait table and in a taxonomy lookup instead.

Sources, in priority: _keys/species_reference.csv (resolved Order+Family) ->
per-paper Order/Family (Granatosky, interlaminar astrocytes, ...) ->
EltonTraits Family (Wilman MamFuncDat, ~all mammals) -> Family->Order map (learned
+ a standard-family supplement) -> genus->Family / genus->Order propagation.

Run from the repo root:  python3 _keys/build_species_taxonomy.py
"""
import csv, re, glob, os, openpyxl, warnings
from collections import defaultdict
warnings.filterwarnings("ignore")
REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
def p(*a): return os.path.join(REPO, *a)

def clean(s):
    s = re.sub(r'[\*]', '', str(s or '')).strip().replace('_', ' ')
    return re.sub(r'\s+', ' ', s)

tax = {}
bases = {}
for r in csv.DictReader(open(p('_keys/species_reference.csv'))):
    o = r.get('Order_resolved', '').strip(); f = r.get('Family_resolved', '').strip()
    bases[r['accepted_name'].strip()] = r.get('taxonomy_source', '')
    tax[r['accepted_name'].strip()] = {'Order': '' if o in ('', 'NA') else o,
                                       'Family': '' if f in ('', 'NA') else f}
variants = defaultdict(set)
for fn in [p('_keys/Stephan/species_key.csv'), p('_keys/species_display_aliases.csv')]:
    for r in csv.DictReader(open(fn)):
        v = r.get('variant_name', r.get('variant', '')).strip().lower()
        a = r.get('accepted_name', r.get('canonical', '')).strip()
        if v and a: variants[v].add(a)
keymap = {v: next(iter(a)) for v, a in variants.items() if len(a) == 1}
reflow = {a.lower(): a for a in tax}
def resolve(n):
    c = clean(n)
    if c in tax: return c
    if c.lower() in reflow: return reflow[c.lower()]
    if c.lower() in keymap: return keymap[c.lower()]
    return c
def add(sp, o, f):
    sp = resolve(sp)
    if not sp: return
    t = tax.setdefault(sp, {'Order': '', 'Family': ''})
    if o and clean(o) not in ('', 'Na') and not t['Order']: t['Order'] = clean(o)
    if f and clean(f) not in ('', 'Na') and not t['Family']: t['Family'] = clean(f)

# Offline, dated NCBI snapshot. Existing authored name aliases above are
# restricted to unambiguous mappings. No network lookup is needed to rebuild.
for r in csv.DictReader(open(p('_keys/ncbi_taxonomy_snapshot.csv'))):
    sp = r['ncbi_name']
    previous_order = tax.get(sp, {}).get('Order')
    add(sp, r.get('order', ''), r.get('family', ''))
    if not previous_order and tax[resolve(sp)]['Order']: bases[resolve(sp)] = 'NCBI snapshot ' + r['checked_on'] + ': ' + r['source_url']

# per-paper Order/Family
gcsv = p('Granatosky__2018/Granatosky__2018_TableS1.csv')
if os.path.exists(gcsv):
    for r in csv.DictReader(open(gcsv)):
        add(r['Species'], r.get('Order', ''), r.get('Family', ''))
for f in glob.glob(p('____EvoM1_TraitTable/*.xlsx')):
    ws = openpyxl.load_workbook(f, read_only=True, data_only=True).worksheets[0]
    rows = list(ws.iter_rows(values_only=True))
    if not rows: continue
    hdr = [str(h).strip() if h else '' for h in rows[0]]
    if 'Species' not in hdr: continue
    si = hdr.index('Species')
    oi = hdr.index('Order') if 'Order' in hdr else None
    fi = hdr.index('Family') if 'Family' in hdr else None
    if oi is None and fi is None: continue
    for r in rows[1:]:
        if r[si]: add(str(r[si]), r[oi] if oi is not None else '', r[fi] if fi is not None else '')
# EltonTraits Family for ~all mammals
elt = p('Wilman_etal_2014/MamFuncDat.txt')
if os.path.exists(elt):
    for r in csv.DictReader(open(elt, encoding='latin1'), delimiter='\t'):
        add(r['Scientific'], '', r.get('MSWFamilyLatin', ''))

# Family -> Order (learned from species with both, + standard supplement)
family_orders = defaultdict(set)
for t in tax.values():
    if t['Family'] and t['Order']: family_orders[t['Family']].add(t['Order'])
fam2ord = {f: next(iter(v)) for f, v in family_orders.items() if len(v) == 1}
SUPP = {'Antilocapridae':'Artiodactyla','Bradypodidae':'Pilosa','Burramyidae':'Diprotodontia',
'Caenolestidae':'Paucituberculata','Castoridae':'Rodentia','Cyclopedidae':'Pilosa',
'Dasypodidae':'Cingulata','Dasyproctidae':'Rodentia','Delphinidae':'Cetacea','Dinomyidae':'Rodentia',
'Erethizontidae':'Rodentia','Eupleridae':'Carnivora','Geomyidae':'Rodentia',
'Hypsiprymnodontidae':'Diprotodontia','Manidae':'Pholidota','Mephitidae':'Carnivora',
'Microbiotheriidae':'Microbiotheria','Moschidae':'Artiodactyla','Myocastoridae':'Rodentia',
'Myrmecobiidae':'Dasyuromorphia','Mystacinidae':'Chiroptera','Nandiniidae':'Carnivora',
'Ornithorhynchidae':'Monotremata','Orycteropodidae':'Tubulidentata','Peramelidae':'Peramelemorphia',
'Petauridae':'Diprotodontia','Phalangeridae':'Diprotodontia','Phascolarctidae':'Diprotodontia',
'Phocidae':'Carnivora','Potoroidae':'Diprotodontia','Pseudocheiridae':'Diprotodontia',
'Rhinocerotidae':'Perissodactyla','Tachyglossidae':'Monotremata','Tapiridae':'Perissodactyla',
'Tarsipedidae':'Diprotodontia','Tragulidae':'Artiodactyla','Trichechidae':'Sirenia',
'Viverridae':'Carnivora','Vombatidae':'Diprotodontia','Otariidae':'Carnivora','Odobenidae':'Carnivora',
'Balaenopteridae':'Cetacea','Physeteridae':'Cetacea','Ziphiidae':'Cetacea','Monodontidae':'Cetacea',
'Phocoenidae':'Cetacea','Camelidae':'Artiodactyla','Suidae':'Artiodactyla','Bovidae':'Artiodactyla',
'Cervidae':'Artiodactyla','Giraffidae':'Artiodactyla','Hippopotamidae':'Artiodactyla',
'Equidae':'Perissodactyla','Ursidae':'Carnivora','Procyonidae':'Carnivora','Ailuridae':'Carnivora',
'Sciuridae':'Rodentia','Cricetidae':'Rodentia','Muridae':'Rodentia','Spalacidae':'Rodentia',
'Gliridae':'Rodentia','Aplodontiidae':'Rodentia','Vespertilionidae':'Chiroptera',
'Molossidae':'Chiroptera','Rhinolophidae':'Chiroptera','Pteropodidae':'Chiroptera',
'Phyllostomidae':'Chiroptera','Soricidae':'Eulipotyphla','Erinaceidae':'Eulipotyphla',
'Talpidae':'Eulipotyphla','Tapiridae ':'Perissodactyla','Elephantidae':'Proboscidea',
'Macropodidae':'Diprotodontia','Dasyuridae':'Dasyuromorphia'}
for f, o in SUPP.items(): fam2ord.setdefault(f, o)

# genus -> Family / Order propagation
genus_families, genus_orders = defaultdict(set), defaultdict(set)
for s, t in tax.items():
    g = s.split(' ')[0]
    if t['Family']: genus_families[g].add(t['Family'])
    if t['Order']: genus_orders[g].add(t['Order'])
# An authored fallback also covers extinct genera without an NCBI entry.
# It fills navigation metadata only, never species identity or measurements.
fallbacks = {}
with open(p('_keys/genus_taxonomy_fallbacks.csv'), encoding='utf-8') as fh:
    for r in csv.DictReader(fh):
        if r['Genus'] in fallbacks: raise ValueError('Duplicate fallback genus: ' + r['Genus'])
        fallbacks[r['Genus']] = r
        genus_families[r['Genus']].add(r['Family'])
        genus_orders[r['Genus']].add(r['Order'])
with open(p('_keys/genus_family.csv'), encoding='utf-8') as fh:
    for r in csv.DictReader(fh):
        genus_families[r['Genus']].add(r['Family'])
gen2fam = {g: next(iter(v)) for g, v in genus_families.items() if len(v) == 1}
gen2ord = {g: next(iter(v)) for g, v in genus_orders.items() if len(v) == 1}

# species-level patch for printed typos / synonyms EltonTraits/keys don't catch
SPECIES_PATCH = {
 'Applodontia rufa':('Rodentia','Aplodontiidae'),      # sp. Aplodontia rufa
 'Cebuella pygmaea':('Primates','Callitrichidae'),
 'Glis glis':('Rodentia','Gliridae'),
 'Llama glama':('Artiodactyla','Camelidae'),            # sp. Lama glama
 'Nannospalax ehrenbergi':('Rodentia','Spalacidae'),
 'Neogale vison':('Carnivora','Mustelidae'),            # syn. Neovison vison
 'Plecturocebus moloch':('Primates','Pitheciidae'),     # syn. Callicebus moloch
 'Scutisorex somereni':('Eulipotyphla','Soricidae'),
 'Horpyiocepalus leucogostra':('Chiroptera','Vespertilionidae'),  # garbled Harpiocephalus
}
def fam_of(s):
    t = tax.get(resolve(s), {})
    if t.get('Family'): return t['Family']
    g = gen2fam.get(resolve(s).split(' ')[0], '')
    if g: return g
    return SPECIES_PATCH.get(s, ('', ''))[1]
def ord_of(s):
    t = tax.get(resolve(s), {})
    if t.get('Order'): return t['Order']
    fam = fam_of(s)
    if fam in fam2ord: return fam2ord[fam]
    g = gen2ord.get(resolve(s).split(' ')[0], '')
    if g: return g
    return SPECIES_PATCH.get(s, ('', ''))[0]

# Read the canonical compiled files. The old app/data copies were removed in
# September 2026; reading those left almost the whole species universe out.
comp = set()
paths = glob.glob(p('__merging_*/*_long.csv')) + [p('__ShinyApp/data/evom1_traits_long.csv')]
for fp in paths:
    if os.path.exists(fp):
        for r in csv.DictReader(open(fp, encoding='utf-8-sig')):
            if r.get('Species', '').strip(): comp.add(clean(r['Species']))
# Keep keyed species available even if their measurements are currently absent.
comp.update(tax)

def order_basis(s):
    if resolve(s) != s and ord_of(s):
        return 'Classification via unambiguous name key: ' + resolve(s)
    if tax.get(s, {}).get('Order'):
        return 'Species reference: ' + (bases.get(s) or 'recorded taxonomy')
    g = s.split(' ')[0]
    if g in fallbacks and ord_of(s) == fallbacks[g]['Order']:
        return 'Curated genus fallback: ' + fallbacks[g]['Source']
    if fam_of(s) in fam2ord:
        return 'Family-to-order lookup (' + fam_of(s) + ')'
    if g in gen2ord:
        return 'Inferred from genus (one recorded order)'
    if s in SPECIES_PATCH:
        return 'Curated spelling / synonym fallback'
    return 'Not recorded'

# normalise synonymous order names to one label
ORDER_NORMALIZE = {'Soricomorpha': 'Eulipotyphla'}
rows = [{'Species': s,
         'Order': ORDER_NORMALIZE.get(ord_of(s), ord_of(s)),
         'Family': fam_of(s), 'Order_basis': order_basis(s)} for s in sorted(comp)]
with open(p('_keys/species_taxonomy.csv'), 'w', newline='', encoding='utf-8') as fh:
    w = csv.DictWriter(fh, fieldnames=['Species', 'Order', 'Family', 'Order_basis']); w.writeheader(); w.writerows(rows)

nO = sum(1 for r in rows if r['Order'])
print("species:", len(rows), "| with Order:", nO, f"({100*nO//len(rows)}%)",
      "| with Family:", sum(1 for r in rows if r['Family']))
print("missing Order (first 30):", sorted(r['Species'] for r in rows if not r['Order'])[:30])
