#!/usr/bin/env python3
"""
build_species_taxonomy.py -- assemble _keys/species_taxonomy.csv (Species, Order,
Family) for every species in the compiled datasets, so the Shiny app can filter /
colour plots by clade. Order/Family are NOT measurements — this keeps them out of
the trait table and in a taxonomy lookup instead.

Sources, in priority: _keys/species_reference.csv (resolved Order+Family) ->
per-paper Order/Family (Granatosky, interlaminar astrocytes, ...) ->
explicit taxonomy in the checked-in AnAge, amniote and metabolic databases ->
EltonTraits Family (Wilman MamFuncDat, ~all mammals) -> Family->Order map (learned
+ a standard-family supplement) -> genus->Family / genus->Order propagation.

Run from the repo root:  python3 _keys/build_species_taxonomy.py
"""
import csv, re, glob, os, json, openpyxl, warnings
from collections import defaultdict
warnings.filterwarnings("ignore")
REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
def p(*a): return os.path.join(REPO, *a)

def clean(s):
    s = re.sub(r'[\*]', '', str(s or '')).strip().replace('_', ' ')
    return re.sub(r'\s+', ' ', s)

# Normalize before testing agreement, so historical names for the same order
# do not create artificial conflicts during family/genus propagation.
ORDER_NORMALIZE = {'Soricomorpha': 'Eulipotyphla', 'Erinaceomorpha': 'Eulipotyphla',
                   'Crocodilia': 'Crocodylia'}
def order_name(s):
    s = clean(s)
    return ORDER_NORMALIZE.get(s, s)

tax = {}
bases = {}
for r in csv.DictReader(open(p('_keys/species_reference.csv'))):
    o = r.get('Order_resolved', '').strip(); f = r.get('Family_resolved', '').strip()
    bases[r['accepted_name'].strip()] = r.get('taxonomy_source', '')
    tax[r['accepted_name'].strip()] = {'Order': '' if o in ('', 'NA') else order_name(o),
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
    if o and clean(o).lower() not in ('', 'na', 'nan', 'unknown') and not t['Order']: t['Order'] = order_name(o)
    if f and clean(f) not in ('', 'Na') and not t['Family']: t['Family'] = clean(f)

# Offline, dated NCBI snapshot. Existing authored name aliases above are
# restricted to unambiguous mappings. No network lookup is needed to rebuild.
snapshot = list(csv.DictReader(open(p('_keys/ncbi_taxonomy_snapshot.csv'))))
for r in snapshot:
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

# Include the current compiled species universe BEFORE taxonomy completion.
# Formerly this happened after the lookups were learned: new compiled genera
# and most non-mammals never had their published classification consulted.
comp = set()
paths = sorted(glob.glob(p('__merging_*/*_long.csv'))) + [p('__ShinyApp/data/evom1_traits_long.csv')]
for fp in paths:
    with open(fp, encoding='utf-8-sig') as fh:
        for r in csv.DictReader(fh):
            if r.get('Species', '').strip(): comp.add(clean(r['Species']))
comp.update(tax)

# Deliberately specified schemas: an epithet must be combined with its genus,
# and a common-name classification must never become a species identity alias.
# Ambiguous names are left unresolved. No trait values are read or pooled here.
published = defaultdict(set)
published_genera = defaultdict(set)
family_evidence, genus_evidence = defaultdict(set), defaultdict(set)
scientific_genera = {s.split(' ')[0] for s in tax}
backbone_families = defaultdict(set)
backbone_genera = defaultdict(set)
for s, t in tax.items():
    if t['Family'] and t['Order']: backbone_families[t['Family']].add(t['Order'])
    if t['Order']: backbone_genera[s.split(' ')[0]].add(t['Order'])
backbone_order = {f: next(iter(orders)) for f, orders in backbone_families.items() if len(orders) == 1}
backbone_genus_order = {g: next(iter(orders)) for g, orders in backbone_genera.items() if len(orders) == 1}
# Synonyms in the existing snapshot can classify a source label without
# changing which species identity the project uses for that label.
for r in snapshot:
    if not r['order']: continue
    for name in json.loads(r['names_json']):
        published[name.casefold()].add((order_name(r['order']), r['family'], r['source_url']))
        if re.fullmatch(r'[A-Z][a-z]+ [a-z]+', name):
            scientific_genera.add(name.split()[0])
            published_genera[name.casefold()].add(name.split()[0])
taxonomy_tables = [
    ('10.1093%2Fnar%2Fgkad927_anagedata.txt.tsv', 'Genus', 'Species', 'Order', 'Family', 'Common_name'),
    ('10.1890%2F15-0846r.1_AmnioteDatabaseAug2015.tsv', 'genus', 'species', 'order', 'family', 'common_name'),
    ('10.1038%2Fs41597-025-05868-y_SciDataPub.tsv', 'Genus', 'SpeciesAcceptedName', 'Order', 'Family', None),
    ('10.1038%2Fs41597-022-01364-9_Observations.tsv', 'genus', 'species', 'order', 'family', None),
]
for filename, gc, sc, oc, fc, cc in taxonomy_tables:
    with open(p('__Public/comparative-data', filename), encoding='utf-8-sig') as fh:
        for r in csv.DictReader(fh, delimiter='\t'):
            o, f, g = order_name(r[oc]), clean(r[fc]), clean(r[gc])
            if o.lower() in ('', 'na', 'unknown'): continue
            # This source preserves some misspelled/higher-rank order labels.
            # Leave those rows for the existing family/genus evidence instead.
            if filename.endswith('_Observations.tsv') and o in {
                'Chrioptera', 'Orthoperta', 'Phollidota', 'Rondentia',
                'Spheniscoformes', 'Spheniscoiformes', 'Stringiformes',
                'Macroscelidae', 'Xenarthra', 'Heteroptera', 'Cetartiodactyla'}: continue
            if f.lower() in ('na', 'unknown'): f = ''
            # Preserve the project's resolved family classification where the
            # older publication uses a different order circumscription.
            o = backbone_order.get(f, backbone_genus_order.get(g, o))
            if g.lower() in ('', 'na', 'unknown'): continue
            scientific_genera.add(g)
            name = clean(r[sc])
            if name.lower() in ('', 'na', 'unknown'): continue
            if not name.startswith(g + ' '): name = g + ' ' + name
            evidence = (o, f, filename)
            published[resolve(name).casefold()].add(evidence)
            published_genera[resolve(name).casefold()].add(g)
            if cc and r[cc].strip():
                common = clean(r[cc]).casefold()
                published[common].add(evidence)
                published_genera[common].add(g)
            if f: family_evidence[f].add(o)
            genus_evidence[g].add((o, f))

for s in sorted(comp):
    candidates = published.get(s.casefold(), set())
    orders = {r[0] for r in candidates}
    families = {r[1] for r in candidates if r[1]}
    if len(orders) == 1:
        previous = tax.get(s, {}).get('Order')
        add(s, next(iter(orders)), next(iter(families)) if len(families) == 1 else '')
        if not previous:
            bases[resolve(s)] = 'Published taxonomy (exact label): ' + '; '.join(sorted({r[2] for r in candidates}))

# Family -> Order (learned from species with both, + standard supplement)
family_orders = defaultdict(set)
for t in tax.values():
    if t['Family'] and t['Order']: family_orders[t['Family']].add(t['Order'])
for f, orders in family_evidence.items():
    if f not in family_orders: family_orders[f].update(orders)
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
for g, records in genus_evidence.items():
    genus_orders[g].update(o for o, f in records)
    genus_families[g].update(f for o, f in records if f)
for s, t in tax.items():
    g = s.split(' ')[0]
    if g not in scientific_genera: continue
    if t['Family']: genus_families[g].add(t['Family'])
    if t['Order']: genus_orders[g].add(t['Order'])
# An authored fallback also covers extinct genera without an NCBI entry.
# It fills navigation metadata only, never species identity or measurements.
fallbacks = {}
fallback_files = [p('_keys/genus_taxonomy_fallbacks.csv')]
cached_navigation = p('_keys/genus_navigation_taxonomy.csv')
if os.path.exists(cached_navigation): fallback_files.append(cached_navigation)
for filename in fallback_files:
    with open(filename, encoding='utf-8') as fh:
        for r in csv.DictReader(fh):
            if r['Genus'] in fallbacks: raise ValueError('Duplicate fallback genus: ' + r['Genus'])
            fallbacks[r['Genus']] = r
            scientific_genera.add(r['Genus'])
            if r['Family']: genus_families[r['Genus']].add(r['Family'])
            if r['Order']: genus_orders[r['Genus']].add(order_name(r['Order']))
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

# Paper-scoped keys may disagree on species but still agree on order. Use that
# agreement for classification only, preserving the original compiled label.
# In particular, never infer an order from a shared common-name first word
# ("Tree shrew" and "Tree swallow" do not share a taxonomic genus).
label_targets = defaultdict(set)
for filename in sorted(glob.glob(p('_keys/*/species_key.csv'))):
    with open(filename, encoding='utf-8-sig') as fh:
        for r in csv.DictReader(fh):
            if r['variant_name'] and r['accepted_name']:
                label_targets[clean(r['variant_name']).casefold()].add(clean(r['accepted_name']))
for s in sorted(comp):
    targets = label_targets.get(s.casefold(), set())
    orders = {ord_of(target) for target in targets}
    families = {fam_of(target) for target in targets}
    if orders and '' not in orders and len(orders) == 1 and not ord_of(s):
        add(s, next(iter(orders)), next(iter(families)) if len(families) == 1 else '')
        bases[resolve(s)] = 'Source-label keys agree on classification: ' + '; '.join(sorted(targets))

# Missing NCBI entries continue through the multi-database lookup ladder. These
# are source-label classifications, not species-identity redirects. They fill
# gaps only; existing resolved classifications retain their original authority.
navigation_fallbacks = {}
fallback_path = p('_keys/order_navigation_fallbacks.csv')
if os.path.exists(fallback_path):
    with open(fallback_path, encoding='utf-8') as fh:
        for r in csv.DictReader(fh):
            s = r['Species']
            if s in navigation_fallbacks: raise ValueError('Duplicate navigation fallback label: ' + s)
            navigation_fallbacks[s] = r
            if not ord_of(s) and r['Order']:
                add(s, r['Order'], r['Family'])
                bases[resolve(s)] = ('Navigation taxonomy fallback (' + r['Authority'] + '): ' +
                    r['Source'] + '; ' + r['Match_basis'] + '; matched ' + r['Matched_name'])

def order_basis(s):
    if resolve(s) != s and ord_of(s):
        return 'Classification via unambiguous name key: ' + resolve(s)
    if tax.get(s, {}).get('Order'):
        basis = bases.get(s) or 'recorded taxonomy'
        return basis if basis.startswith(('Published taxonomy', 'Source-label keys', 'Navigation taxonomy')) else 'Species reference: ' + basis
    g = s.split(' ')[0]
    if g in fallbacks and fallbacks[g]['Order'] and ord_of(s) == order_name(fallbacks[g]['Order']):
        return 'Curated genus fallback: ' + fallbacks[g]['Source']
    if fam_of(s) in fam2ord:
        return 'Family-to-order lookup (' + fam_of(s) + '; species reference / published taxonomy)'
    if g in gen2ord:
        return 'Inferred from genus (one recorded order; species reference / published taxonomy)'
    if s in SPECIES_PATCH:
        return 'Curated spelling / synonym fallback'
    return 'Not recorded'

def genus_of(s):
    if s in navigation_fallbacks and navigation_fallbacks[s]['Genus']:
        return navigation_fallbacks[s]['Genus']
    genus = resolve(s).split(' ')[0]
    if genus in scientific_genera: return genus
    candidates = published_genera.get(s.casefold(), set())
    if len(candidates) == 1: return next(iter(candidates))
    targets = label_targets.get(s.casefold(), set())
    genera = {resolve(t).split(' ')[0] for t in targets}
    if len(genera) == 1 and next(iter(genera)) in scientific_genera: return next(iter(genera))
    return ''

# normalise synonymous order names to one label
comp.update(tax)
rows = [{'Species': s,
         'Order': ORDER_NORMALIZE.get(ord_of(s), ord_of(s)),
         'Family': fam_of(s), 'Order_basis': order_basis(s), 'Genus': genus_of(s)} for s in sorted(comp)]
with open(p('_keys/species_taxonomy.csv'), 'w', newline='', encoding='utf-8') as fh:
    w = csv.DictWriter(fh, fieldnames=['Species', 'Order', 'Family', 'Order_basis', 'Genus']); w.writeheader(); w.writerows(rows)

nO = sum(1 for r in rows if r['Order'])
print("species:", len(rows), "| with Order:", nO, f"({100*nO//len(rows)}%)",
      "| with Family:", sum(1 for r in rows if r['Family']))
print("missing Order (first 30):", sorted(r['Species'] for r in rows if not r['Order'])[:30])
