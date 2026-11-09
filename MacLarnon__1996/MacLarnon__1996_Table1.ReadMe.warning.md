copilot: The rabbit weights don't match (F05). Mink's cord weight (3.945 g) matches MacLarnon 1996's male rabbits. Its body and brain weights (2,480 g and 9.755 g) match her females. Also, MacLarnon's column headed "Body weight (mg)" in your snapshot and CSV actually holds brain weights.

check and if confirm flag it
both cite the same source:
61	LATIMER, H. B., AND P. B. SAWIN. The weight of the brain, of its parts, and the weight and length of the spinal cord in the rabbit (race X). J. Comp. Neurol. 103: 513-539, 1955.

---
RESOLVED 6 Nov 2026 (Copilot; checked on the page images of Latimer & Sawin 1955, PDF in Latimer_Sawin_1955/)

Confirmed, and the error is in Mink et al. (1981), not in MacLarnon (1996).
- MacLarnon (1996) Table 1 is correct. Its small-subspecies rabbit rows are Latimer & Sawin's normal (non-dwarf) means, gross body weight: males (n = 35) body 1972.3 g (Table 1, panel B), cord 3.945 g (Table 7), brain 9.265 g (Table 4); females (n = 30) 2480.0 g (Table 1, panel C), 4.537 g (Table 7), 9.755 g (Table 5).
- Mink et al. (1981) Table 1, rabbit row (ref 61), prints the female body and brain weights (2,480.0 and 9.755) with the male cord weight (3.945). Flagged as erratum Mink_etal_1981-E005 (publication_error, proposed 4.537 g for a female row). Mink's CSV keeps the printed value; the flag shows in its README errata block and in the definitions note for spinal_cord_weight.g. Mink's derived spinal metabolism, CNS metabolism and metabolic ratio for the rabbit inherit the mixed pairing.
- The "Body weight (mg)" header was our transcription error: MacLarnon prints "Brain weight (mg)" (Table 1, p. 73). Fixed in MacLarnon__1996_Table1.R (snapshot unchanged) and recorded as erratum MacLarnon__1996-E001. The CSV and public TSV were rewritten by a Python mirror (R NOT RUN): please run the script to confirm.
- Not edited: __ReadMe.xlsx.
