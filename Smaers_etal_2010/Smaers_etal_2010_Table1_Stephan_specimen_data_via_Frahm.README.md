# Smaers et al. (2010): specimen data attributed to Stephan/Frahm

`Smaers_etal_2010_Table1_Stephan_specimen_data_via_Frahm.csv` isolates the
specimen-level values printed in Smaers et al. (2010), Table 1, and attributed
in that table caption to individual-specific data underlying Stephan et al.
(1981), supplied by H. Frahm.

These are **not new independent measurements by Smaers et al.** They are a
published route to previously unpublished specimen-level Stephan data. The
source of record for the extracted cells is therefore Smaers et al. (2010),
DOI `10.1371/journal.pone.0009123`, with the underlying-data attribution
retained in separate provenance columns.

## Included values

- 16 specimens with neopallium and total-brain volumes.
- 11 of those specimens with basal-ganglia volume.
- Basal ganglia is defined by Smaers et al. as striatum plus pallidum.
- Printed specimen numbers are retained as `catalogue_number`.

The bonobo and orangutan rows in Smaers Table 1 are excluded because they have
no Stephan/Frahm neopallium or basal-ganglia value. The caption attributes their
brain-size values to MacLeod et al. (2003).

The CSV is regenerated from `Smaers_etal_2010_Table1.csv` by the companion R
script. A later comparison against genuinely unpublished Frahm specimen files
belongs in the restricted repository; it should not be written into this public
folder.
