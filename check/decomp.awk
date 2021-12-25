$6 && $6 !~ /^</ {
	if (n0 != n) exit 1
	k = dm[n] = split($6, cs, " ")
	for (i = 1; i <= k; i++) dm[n,i] = xtoi(cs[i])
}

BEGIN {
	LBASE = xtoi("1100"); LCOUNT = 19
	VBASE = xtoi("1161"); VCOUNT = 21
	TBASE = xtoi("11A7"); TCOUNT = 28
	SBASE = xtoi("AC00"); SCOUNT = LCOUNT * VCOUNT * TCOUNT

	for (i = 0; i < SCOUNT; i++) {
		dm[SBASE+i] = 2
		lv = int(i / TCOUNT); t = i % TCOUNT
		if (t) {
			dm[SBASE+i,1] = SBASE + lv * TCOUNT
			dm[SBASE+i,2] = TBASE + t
		} else {
			dm[SBASE+i,1] = LBASE + int(lv / VCOUNT)
			dm[SBASE+i,2] = VBASE + lv % VCOUNT
		}
	}

	# Example from the Unicode standard, "Conjoining Jamo behaviour"

	if (dm[xtoi("D4DB")] != 2) exit 1
	if (dm[xtoi("D4DB"),1] != xtoi("D4CC")) exit 1
	if (dm[xtoi("D4DB"),2] != xtoi("11B6")) exit 1
	if (dm[xtoi("D4CC")] != 2) exit 1
	if (dm[xtoi("D4CC"),1] != xtoi("1111")) exit 1
	if (dm[xtoi("D4CC"),2] != xtoi("1171")) exit 1
}

function collect(i, s, j) {
	if (!(i in dm)) { printf "%s%.4X", s, i; return }
	for (j = 1; j <= dm[i]; j++) collect(dm[i,j], j-1 ? " " : s)
}

END {
	for (i = 0; i <= n; i++) if (i in dm) {
		printf "%.4X", i; collect(i, "\t"); printf "\n"
	}
}
