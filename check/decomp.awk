$6 ~ /^[^<]/ {
	if (n0 != n) exit 1
	k = dm[n] = split($6, cs, " ")
	for (i = 1; i <= k; i++) dm[n,i] = hex(cs[i])
}

BEGIN {
	LBASE = hex("1100"); VBASE = hex("1161"); TBASE = hex("11A7")
	SBASE = hex("AC00")

	for (l = 0; l < 19; l++) for (v = 0; v < 21; v++) {
		lv = SBASE + (l * 21 + v) * 28
		dm[lv] = 2; dm[lv,1] = LBASE + l; dm[lv,2] = VBASE + v
		for (t = 1; t < 28; t++) { # TBASE itself is not a valid T
			sy = lv + t
			dm[sy] = 2; dm[sy,1] = lv; dm[sy,2] = TBASE + t
		}
	}
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
