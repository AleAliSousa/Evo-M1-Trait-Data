This README.txt file was generated on 2022-05-02 by Matthew Murphy

GENERAL INFORMATION

1. Title of Dataset: Data from: Evolutionary history limits species' ability to match color sensitivity to available habitat light

2. Author Information:
	Corresponding Investigator
		Name: Matthew J Murphy
		Institution: University of Arkansas, Fayetteville, AR, USA
		Institution email: mjm052@uark.edu
		Personal email: m.jos.murphy@gmail.com

	Co-investigator 1
		Name: Dr Erica L Westerman
		Institution: University of Arkansas
		Email: ewesterm@uark.edu

3. Date of data collection: 2017 - 2021

4. Geographic location of data collection: Global

5. Funding sources that supported the collection of the data: 
	Arkansas Biosciences Institute
	University of Arkansas

6. Recommended citation for this dataset: Matthew J Murphy and Erica L Westerman (2022), Data from: Evolutionary history limits species' ability to match color sensitivity to available habitat light, Dryad, Dataset

DATA & FILE OVERVIEW

1. Description of dataset

These data were compiled from multiple sources for a meta-analysis that investigated the effects of phylogeny and habitat on the animal visual systems.


2. File List:
	File 1 Name: aquatic_final.csv
	File 1 Description: Comma-delimited dataset of aquatic species; their maximum and minimum wavelengths of maximum sensitivity; information pertaining to maximum, minimum, average, and range in depth; and fine-scale habitat information

	File 2 Name: terrestrial_final.csv
	File 2 Description: Comma-delimited dataset of aquatic species; their maximum and minimum wavelengths of maximum sensitivity; and fine-scale habitat information

	File 3 Name: wide_data_102021.csv
	File 3 Description: Comma-delimited dataset of all species; their maximum and minimum wavelengths of maximum sensitivity; their coarse lineage data; and coarse habitat data. Includes Open Tree of Life ottids

	File 4 Name: excluded_ottids_processed.csv
	File 4 Description: Comma-delimited dataset of species whose ottids were excluded from phylogenetic analysis due to being _incertae cedis_

METHODOLOGICAL INFORMATION

Opsin sensitivity data were collected via two Google Scholar searches in 2017 and 2018 using the following search parameters, excluding citations and patents: (1) “visual pigment” OR opsin OR “absorbance spectrum” “λ max” -human -man -men -woman -women -“Homo sapiens” -disease -regeneration; (2) visual pigment, opsin sensitivity, absorbance spectrum. The lambda-max of all opsins were recorded. The longest and shortest lambda max for each species was identified.

Habitat data were collected using field guides, public databases (BugGuide, <bugguide.net>, Butterflies and Moths of North America, <butterfliesandmoths.org>, FishBase <fishbase.org>, SealifeBase <sealifebase.org>, IUCN Redlist <iucnredlist.org>) and online encyclopaedias ( Animal Diversity Web <animaldiversity.org> and Encyclopedia of Life (<eol.org>).

Phylogenetic positions for each species were downloaded from the Open Tree of Life (<tree.opentreeoflife.org>).

DATA-SPECIFIC INFORMATION FOR: aquatic_final.csv
1. Number of variables: 22

2. Number of rows: 170

3. Variable list: 
	species_ottid: Open Tree of Life Taxon ID for the species
	o_max: Lambda-max of longest-wavelength opsin
	o_min: Lambda-max of shortest-wavelength opsin
	o_range: o_max - o_min
	d_min: Minimum habitat depth
	d_max: Maximum habitat depth
	d_avg: Average depth; (d_max + d_min)/ 2
	d_range: Depth range; (d_max - d_min)
	biome: Raw biome code used to prepare dummy variables, below
	lotic: Is this species lotic; yes = 1, no = 0
	limnetic: " " " limnetic; yes = 1, no = 0
	neritic: " " " neritic; yes = 1, no = 0
	estuarine: " " " estuarine; yes = 1, no = 0
	coastal: " " " coastal; yes = 1, no = 0
	open_marine: " " an open marine species; yes = 1, no = 0
	deepwater_aphotic: Does this species live in a lightless habitat; yes = 1, no = 0
	aquatic: Is this species aquatic; yes = 1, no = 0
	forest: Does this species live in closed-canopy forests; yes = 1, no = 0
	intermediate: " " " " woodlands; yes = 1, no = 0
	open: " " " " open terrestrial habitats; yes = 1, no = 0
	lake.river: " " " " lakes or rivers; yes = 1, no = 0
	habitat: Habitat code used for generating figures

4. Missing data codes:
	NA

5. Abbreviations used:
	N/A; not applicable

6. Other relevant information:
	N/A; not applicable

DATA-SPECIFIC INFORMATION FOR: terrestrial_final.csv
1. Number of variables: 22

2. Number of rows: 78

3. Variable list:
	species_ottid: Open Tree of Life Taxon ID for the species
	o_max: Lambda-max of longest-wavelength opsin
	o_min: Lambda-max of shortest-wavelength opsin
	o_range: o_max - o_min
	d_min: Minimum habitat depth
	d_max: Maximum habitat depth
	d_avg: Average depth; (d_max + d_min)/ 2
	d_range: Depth range; (d_max - d_min)
	biome: Raw biome code used to prepare dummy variables, below
	lotic: Is this species lotic; yes = 1, no = 0
	limnetic: " " " limnetic; yes = 1, no = 0
	neritic: " " " neritic; yes = 1, no = 0
	estuarine: " " " estuarine; yes = 1, no = 0
	coastal: " " " coastal; yes = 1, no = 0
	open_marine: " " an open marine species; yes = 1, no = 0
	deepwater_aphotic: Does this species live in a lightless habitat; yes = 1, no = 0
	aquatic: Is this species aquatic; yes = 1, no = 0
	forest: Does this species live in closed-canopy forests; yes = 1, no = 0
	intermediate: " " " " woodlands; yes = 1, no = 0
	open: " " " " open terrestrial habitats; yes = 1, no = 0
	lake.river: " " " " lakes or rivers; yes = 1, no = 0
	habitat: Habitat code used for generating figures

4. Missing data codes:
	NA

5. Abbreviations used:
	N/A; not applicable

6. Other relevant information:
	N/A; not applicable


DATA-SPECIFIC INFORMATION FOR: wide_data_102021.csv
1. Number of variables: 7

2. Number of rows: 435

3. Variable list:
	genus_species: Binomial names separated with underscore
	tip_name: Open Tree of Life tip name
	o_max: Lambda-max of longest-wavelength opsin
	o_min: Lambda-max of shortest-wavelength opsin
	o_range: o_max - o_min	
	invertebrate: Coarse taxon (Is this an invertebrate); Y/N
	terrestrial: Coarse habitat (Does this animal live on land): Y/N

4. Missing data codes:
	NA

5. Abbreviations used:
	Y: Yes
	N: No

6. Other relevant information:
	N/A; not applicable

DATA-SPECIFIC INFORMATION FOR: excluded_ottids_processed.csv
1. Number of variables: 22

2. Number of rows: 26

3. Variable list:
	species_ottid: Open Tree of Life Taxon ID for the species
	o_max: Lambda-max of longest-wavelength opsin
	o_min: Lambda-max of shortest-wavelength opsin
	o_range: o_max - o_min
	d_min: Minimum habitat depth
	d_max: Maximum habitat depth
	d_avg: Average depth; (d_max + d_min)/ 2
	d_range: Depth range; (d_max - d_min)
	biome: Raw biome code used to prepare dummy variables, below
	lotic: Is this species lotic; yes = 1, no = 0
	limnetic: " " " limnetic; yes = 1, no = 0
	neritic: " " " neritic; yes = 1, no = 0
	estuarine: " " " estuarine; yes = 1, no = 0
	coastal: " " " coastal; yes = 1, no = 0
	open_marine: " " an open marine species; yes = 1, no = 0
	deepwater_aphotic: Does this species live in a lightless habitat; yes = 1, no = 0
	aquatic: Is this species aquatic; yes = 1, no = 0
	forest: Does this species live in closed-canopy forests; yes = 1, no = 0
	intermediate: " " " " woodlands; yes = 1, no = 0
	open: " " " " open terrestrial habitats; yes = 1, no = 0
	lake.river: " " " " lakes or rivers; yes = 1, no = 0
	habitat: Habitat code used for generating figures

4. Missing data codes:
	NA

5. Abbreviations used:
	N/A; not applicable

6. Other relevant information:
	N/A; not applicable