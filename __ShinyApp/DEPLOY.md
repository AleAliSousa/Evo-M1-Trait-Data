# Evo-M1 Comparative Brain-Trait Data — Shiny app

A public web app to **search, filter, plot, and download** the comparative
brain-trait data compiled in this project.

This is the single reference for the app: how to update it, how it gets its
data, and how to run it locally.

---

## Updating the app after you change data

Whenever you change any data in this repo (a spreadsheet, a merge, a source
table), run the updater and it will refresh the live app for you.

- **macOS** — double-click **`Update_ShinyApp.command`** in the repo root
- **Windows** — double-click **`Update_ShinyApp.bat`** in the repo root

Or, from a terminal in the repo root:

```bash
Rscript update_shinyapp.R
```

That's it. A window opens and shows its progress, then says `✅ Finished`.

### What it does (three steps)

1. **Rebuild** the derived data (`__ShinyApp/build_data.R`).
2. **Push** the changes to GitHub — this is what actually updates the **live
   data**, because the app reads its data straight from GitHub at runtime.
3. **Deploy** the app to shinyapps.io (only strictly needed when the app code or
   its offline fallback data changes; done every run to be safe).

### Options

Add any of these after the command (they also work on the double-click
launchers if you run them from a terminal):

| Option | Effect |
|--------|--------|
| `--no-deploy` | Just refresh the data on GitHub; skip the shinyapps.io upload. Good for a plain data update — the live app picks it up automatically. |
| `--no-push` | Rebuild + deploy, but don't commit/push to GitHub. |
| `--no-build` | Skip the data rebuild; push/deploy what's already on disk. |
| `--help` | Show the built-in help. |

Example — refresh the live data without re-uploading the app:

```bash
Rscript update_shinyapp.R --no-deploy
```

### First-time setup (once per computer)

1. Install **R**: https://cran.r-project.org
2. The updater installs any missing R packages for you the first time it runs.
3. Configure your shinyapps.io account **once** (needed only for the deploy
   step). Log in at https://www.shinyapps.io → **Account → Tokens → Show →
   "Show secret" → Copy to clipboard**, then paste the copied line into R:

   ```r
   rsconnect::setAccountInfo(name = "...", token = "...", secret = "...")
   ```

   If you skip this, the updater still refreshes the data on GitHub and just
   reminds you to do the setup before it can deploy.

---

## What the app contains

- **Compiled database** — harmonized long tables across three dataset families:
  **brain-structure volumes**, **cell counts**, and the **EvoM1 trait table**
  (behavioural, ecological, life-history, and cellular traits — dexterity,
  corticospinal tract, gyrification, interlaminar astrocytes, locomotion, gait,
  manipulation, handedness, diet & foraging, vocal repertoire, V1 synapse /
  mitochondria / neuron density, and more). ~18,000 non-missing values across
  ~580 species and ~350 measurements. Filter by dataset, species, measurement,
  and source; download the current selection; scatter any two numeric variables
  (log-log with fit line).
- **Source tables** — every per-publication TSV in `__Public/comparative-data`
  (~195), each shown with its full citation and linked to its DOI / PubMed /
  ISBN / dissertation record (the identifier is the clickable link text), with
  source notes where available.
- **About tab** — dataset summary plus a CC BY 4.0 license and attribution
  notice.

## Files

```
repo root/
  update_shinyapp.R         the updater: build -> push -> deploy
  Update_ShinyApp.command   macOS double-click launcher for the updater
  Update_ShinyApp.bat       Windows double-click launcher for the updater

__ShinyApp/
  app.R                     the whole app (single file)
  build_data.R              regenerates the two derived files + fallback copies
  DEPLOY.md                 this file
  PHYLO_SETUP.md            optional mammal tree for PGLS
  data/                     <-- fallback cache only (do not hand-edit)
    evom1_traits_long.csv   DERIVED: melted from ____EvoM1_TraitTable/*.xlsx
    source_manifest.csv     DERIVED: source-table catalogue + citations
    volumes_long.csv        fallback copy of __merging_volumes/volumes_long.csv
    cellcounts_long.csv     fallback copy of __merging_cellcounts/cellcounts_long.csv
```

## Where the data comes from (GitHub, single source of truth)

At runtime the app reads its data over HTTP from the public GitHub repo
(`raw.githubusercontent.com/AleAliSousa/Evo-M1-Trait-Data/main/…`):

| Data | Fetched from (GitHub) |
|------|-----------------------|
| Brain-structure volumes | `__merging_volumes/volumes_long.csv` |
| Cell counts | `__merging_cellcounts/cellcounts_long.csv` |
| EvoM1 traits (derived) | `__ShinyApp/data/evom1_traits_long.csv` |
| Source-table catalogue (derived) | `__ShinyApp/data/source_manifest.csv` |
| The source tables | `__Public/comparative-data/…` (fetched on demand) |

Because it reads the repo directly, **the source tables are not duplicated in
the app at all**, and updating the data is just a `git push` — no redeploy
needed. If GitHub is briefly unreachable, the app falls back to the small local
copies in `data/` for the four startup files (the compiled database keeps
working; individual source-table views need the network).

Only two files are genuinely *derived* (the trait table is melted from `.xlsx`;
the manifest joins filenames to citations in `__ReadMe.xlsx`), so a small build
step is still needed. The updater above handles this. To do it by hand:

```r
install.packages("readxl")            # one time
```
```bash
Rscript __ShinyApp/build_data.R
git add __ShinyApp/data/evom1_traits_long.csv __ShinyApp/data/source_manifest.csv \
        __ShinyApp/data/volumes_long.csv __ShinyApp/data/cellcounts_long.csv
git commit -m "Refresh Shiny app data" && git push
```

> To point the app at a different branch or fork, set the `EVOM1_GH_BASE`
> environment variable (defaults to the `main` branch of this repo).

### Local repo or GitHub: `EVOM1_SOURCE`

The choice is made **once per run**, for every file, not per file. That matters
because these files are not independent: the compiled tables supply the variable
labels and `_keys/variable_definitions.csv` classifies them. Read the tables
from one vintage and the keys from another and every label the keys have not
caught up with shows as **"Unclassified → other"** — the data is there, the
meaning is missing. A per-file GitHub-then-local fallback produces exactly that
the moment a merge exists locally but has not been pushed.

| `EVOM1_SOURCE` | Reads |
|---|---|
| `auto` *(default)* | **local** when the app sits inside a repo checkout (`../_keys` exists) — that is the copy you are editing and the one `build_data.R` just wrote. **GitHub** otherwise, which is the deployed case on shinyapps.io. |
| `local` | The repo and `./data` only. Never touches the network. |
| `github` | GitHub only, with `./data` as a per-file fallback. Use this to preview what the **live** app will show before you push. |

So: after changing data, `Rscript __ShinyApp/build_data.R` is enough to see it
locally, but **the live app only changes when you push** — it has no access to
your working copy. `EVOM1_SOURCE=github` locally is the honest preview of that.

If the keys do not cover the data, the app now says so instead of leaving stray
"Unclassified" rows in the picker: a count and the first few labels on the
console at startup, and a warning banner on the Data Directory tab naming which
source the keys came from.

## Run locally

```r
install.packages(c("shiny", "bslib", "DT", "ggplot2", "ape"))  # ape = optional, for PGLS
shiny::runApp("__ShinyApp")   # in a repo checkout: reads the repo (EVOM1_SOURCE=auto)
shiny::runApp(".") # use this if already in ./__ShinyApp
```
```bash
# preview exactly what the deployed app shows (i.e. what is pushed)
EVOM1_SOURCE=github Rscript -e 'shiny::runApp("__ShinyApp")'
```

**Phylogenetic regression (PGLS)** is an optional Plot feature — it activates
once a mammal tree is added; see `PHYLO_SETUP.md`.

## Deploying by hand

`update_shinyapp.R` is the supported path and does all of this for you. If you
ever need to deploy without it — say the updater itself is broken, or you're
publishing from a machine that only has the app folder:

1. **Push first.** The deployed app reads data from GitHub, so make sure your
   latest data (and the two derived files) are committed and pushed to `main`.
2. Set up your shinyapps.io account once, as under **First-time setup** above.
3. Deploy from the repo root (the folder that contains `__ShinyApp/`):

   ```r
   rsconnect::deployApp(
     appDir      = "__ShinyApp",
     appName     = "evo-m1-brain-traits",
     appTitle    = "Evo-M1 Comparative Brain-Trait Data",
     forceUpdate = TRUE
   )
   ```

   `rsconnect` scans `app.R`, installs shiny/bslib/DT/ggplot2 (and `ape`, if you
   installed it locally, for PGLS) on the server, uploads the tiny `data/`
   fallback, and returns a public URL like
   `https://<your-account>.shinyapps.io/evo-m1-brain-traits/`.

To update later, re-run the same `deployApp(...)` call.

### Notes for shinyapps.io

- The free tier allows a limited number of active hours per month; the bundle
  here (~1.6 MB, the four `data/` fallback files) is well within limits.
- No secrets or credentials are needed — all data is static and public.
- If you prefer an institutional server (Posit Connect / self-hosted Shiny
  Server), the same `__ShinyApp/` folder deploys there unchanged.
