# Weaver 2005 — not built (no new extractable data table)

Weaver AGH (2005). *Reciprocal evolution of the cerebellum and neocortex in fossil humans.* PNAS
102(10):3576–3580. doi:10.1073/pnas.0500692102.

## Decision: documented skip (like Fu 2013) — no data files produced.

Reviewed the PDF for an extractable trait table; there is none:

1. **Table 1** ("Neocortical regions with reciprocal cerebellar connections") is **qualitative** — a
   list of cortical regions/Brodmann areas and their selected cognitive functions. No measurements.

2. The paper's quantitative content is the **cerebellar quotient (CQ = actual / predicted cerebellar
   volume)** and its comparison across mammalian orders (Figure 1) and among fossil/recent humans.
   CQ is a **derived size index/ratio**, which per `__HOWTO_build_a_dataset_file.md` §7 is **not
   transcribed** — such indices are recomputed downstream from the pooled volumes, not captured here.
   The values also live only in the figure and running text, not a table.

3. The underlying **per-specimen volumetric data (PCF, CBLM, NetBrain)** is the author's PhD
   dissertation, **Weaver 2001**, which is **already built in this repo**:
   `Weaver_2001/` → `Weaver__2001_TableA-11` (PCF & CBLM volumes from MRI) and
   `Weaver__2001_TableA-15` (raw + derived variables). Weaver 2005 re-uses that data, so building it
   would duplicate Weaver 2001.

## Fossil-vs-extant grade (for whoever uses Weaver 2001 downstream)
Weaver's sample mixes fossil hominins (Neandertals, Cro-Magnon 1, early *Homo*) with recent humans.
Per the house rule, fossil *Homo sapiens* / hominin values are a **temporal grade** and must **never
be pooled into the extant *Homo sapiens* mean** (they are decomposable to named specimens). This
applies when consuming the Weaver 2001 tables.

## If a datum is ever wanted from Weaver 2005 specifically
Only Figure 1's per-order CQ means would be new here, and those are derived indices (see point 2).
Digitising them would be a deliberate exception to §7 and should be flagged as such.
