# body_ecology fixture — frozen reference output

The last output of `__merging_body_ecology/build_body_ecology_merge.py` before that builder was
retired (2026-08-07). `body_ecology_compiled.R` was extended from body-mass-only to the Python's
full four-class scope, and these files are what it must reproduce.

Gzipped because the harvest table is 14 MB uncompressed. Regenerate the comparison with:

    Rscript run_all_scripts_v2.R            # or: EVOM1_ONLY='merging_body_ecology' Rscript run_all_scripts_v2.R
    python3 _checks/check_body_ecology_against_fixture.py

Reference figures from the Python run: 48 body-mass sources, 97,714 unfiltered rows,
88,753 long rows (5,622 species with body mass; 5,396 with Wilman diet/ecology;
838 with BMR), 397 `DISAGREEMENT>2x` flags.

The fixture is a historical artefact, not a live output — do not regenerate it. If the R is
deliberately changed so that it no longer matches, record why here and refresh the file.
