Compare and combine data from Summer Alznati, Jack Gaston and Rachael Robinson's dissertations

A comparison of Summer and Rachael found them to be almost identical, except that Summer had Total_neocortex added. So of these two, Summer's will be used.

GENERAL:
krubitzer_kaas_1990
The cortical connections of the middle temporal visual area,
MT, were investigated in six squirrel monkeys (Saimiri sciureus),
three owl monkeys (Aotus trivirgatus), two marmosets (Callithrix
jacchus), and three galagos (Galago senegalensis)
MST: middle superior temporal area
Surface areas PERCENTAGE OF NEOCORTEX are listed in Table 1 for the 4 species -- this can be used as a check

> # which Species have non NA values for MST...8?
> summer$Species[!is.na(summer$MST...8)]
[1] "Galago_senegalensis" "Otolemur_garnettii" 
> summer$MST...8[summer$Species == "Galago_senegalensis"]
[1] 9.89256

Galago bush baby; 
MST	pixels		9.892559609	mm2
Rachael listed source: krubitzer_kaas_1990
Found in paper: Figs 22, 23, 24 MST adjacent to MT

> summer$MST...8[summer$Species == "Otolemur_garnettii"]
[1] 9.89256

Otolemur_garnettii
MST	pixels		6.719371385	mm2
Rachael listed source: Kaas, Gharbawie & Stepniewska, 2011
Kaas, J. H., Gharbawie, O., & Stepniewska, I. (2011). The organization and evolution of dorsal stream multisensory motor pathways in primates. Frontiers in neuroanatomy, 5, 34.

> 
> # which Species have non NA values for MST...8?
> summer$Species[!is.na(summer$MST...28)]
[1] "Aotus_trivirgatus" "Macaca_mulatta"   
> summer$MST...28[summer$Species == "Aotus_trivirgatus"]
[1] 16.45345
> summer$MST...28[summer$Species == "Macaca_mulatta"]
[1] 32.18557


Owl monkey (Aotus trivirgatus)

II. 
A. Each species row combines data from multiple sources. Thsi has been confirmed by looking at the data in. Sources are not always clear (e.g. figure number copied from old file and not updatetd)
B. Some sources might not be usable because the schematic is nota. flat map and is not the full surface area

