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
warnings.filterwarnings("ignore")
REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
def p(*a): return os.path.join(REPO, *a)

def clean(s):
    s = re.sub(r'[\*]', '', str(s or '')).strip().replace('_', ' ')
    return re.sub(r'\s+', ' ', s)

tax = {}
for r in csv.DictReader(open(p('_keys/species_reference.csv'))):
    o = r.get('Order_resolved', '').strip(); f = r.get('Family_resolved', '').strip()
    tax[r['accepted_name'].strip()] = {'Order': '' if o in ('', 'NA') else o,
                                       'Family': '' if f in ('', 'NA') else f}
keymap = {}
for r in csv.DictReader(open(p('_keys/Stephan/species_key.csv'))):
    v = r['variant_name'].strip().lower(); a = r['accepted_name'].strip()
    if v: keymap.setdefault(v, a)
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
fam2ord = {}
for t in tax.values():
    if t['Family'] and t['Order']: fam2ord.setdefault(t['Family'], t['Order'])
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
gen2fam, gen2ord = {}, {}
for s, t in tax.items():
    g = s.split(' ')[0]
    if t['Family']: gen2fam.setdefault(g, t['Family'])
    if t['Order']:  gen2ord.setdefault(g, t['Order'])

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
    t = tax.get(s, {})
    if t.get('Family'): return t['Family']
    g = gen2fam.get(s.split(' ')[0], '')
    if g: return g
    return SPECIES_PATCH.get(s, ('', ''))[1]
def ord_of(s):
    t = tax.get(s, {})
    if t.get('Order'): return t['Order']
    fam = fam_of(s)
    if fam in fam2ord: return fam2ord[fam]
    g = gen2ord.get(s.split(' ')[0], '')
    if g: return g
    return SPECIES_PATCH.get(s, ('', ''))[0]

# compiled species universe
comp = set()
for fn in ['volumes_long.csv', 'cellcounts_long.csv', 'evom1_traits_long.csv']:
    fp = p('__ShinyApp/data', fn)
    if os.path.exists(fp):
        for r in csv.DictReader(open(fp)):
            if r['Species'].strip(): comp.add(r['Species'].strip())

# normalise synonymous order names to one label
ORDER_NORMALIZE = {'Soricomorpha': 'Eulipotyphla'}
rows = [{'Species': s,
         'Order': ORDER_NORMALIZE.get(ord_of(s), ord_of(s)),
         'Family': fam_of(s)} for s in sorted(comp)]
with open(p('_keys/species_taxonomy.csv'), 'w', newline='', encoding='utf-8') as fh:
    w = csv.DictWriter(fh, fieldnames=['Species', 'Order', 'Family']); w.writeheader(); w.writerows(rows)

nO = sum(1 for r in rows if r['Order'])
print("species:", len(rows), "| with Order:", nO, f"({100*nO//len(rows)}%)",
      "| with Family:", sum(1 for r in rows if r['Family']))
print("missing Order:", sorted(r['Species'] for r in rows if not r['Order']))
