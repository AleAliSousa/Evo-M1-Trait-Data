# Updating the Shiny app from your computer

Whenever you change any data in this repo (a spreadsheet, a merge, a source
table), run the updater and it will refresh the live app for you.

## The one thing to run

- **macOS** — double-click **`Update_ShinyApp.command`**
- **Windows** — double-click **`Update_ShinyApp.bat`**

Or, from a terminal in this folder:

```bash
Rscript update_shinyapp.R
```

That's it. A window opens and shows its progress, then says `✅ Finished`.

## What it does (three steps)

1. **Rebuild** the derived data (`__ShinyApp/build_data.R`).
2. **Push** the changes to GitHub — this is what actually updates the **live
   data**, because the app reads its data straight from GitHub at runtime.
3. **Deploy** the app to shinyapps.io (only needed when the app code or its
   offline fallback data changes; done every run to be safe).

## Options

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

## First-time setup (once per computer)

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

> The older `deploy_shiny.command` / `deploy_shiny.R` scripts still work, but
> `update_shinyapp.R` is the recommended entry point: it auto-installs missing
> packages, retries the push on flaky networks, gives clear guidance if the
> account isn't set up, and runs on both macOS and Windows.
