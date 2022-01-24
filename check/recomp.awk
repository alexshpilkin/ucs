NF == 1 { set(ce) }
$4 != 0 { set(ns) }
$6 ~ /^[^<]/ {
	if (n0 != n) exit 1
	if ((k = split($6, a, " ")) > 2) exit 1
	if (k == 2 && !(n in ce)) { # exclude singletons and exclusions
		cc[i = hex(a[1]), j = hex(a[2])] = n; pt[i] = pt[j] = 1
	}
}

BEGIN {
	LBASE = hex("1100"); VBASE = hex("1161"); TBASE = hex("11A7")
	SBASE = hex("AC00")

	for (l = 0; l < 19; l++) for (v = 0; v < 21; v++) {
		lv = SBASE + (l * 21 + v) * 28
		cc[LBASE+l,VBASE+v] = lv; pt[LBASE+l] = pt[VBASE+v] = 1
		for (t = 1; t < 28; t++) { # TBASE itself is not a valid T
			cc[lv,TBASE+t] = lv + t; pt[lv] = pt[TBASE+t] = 1
		}
	}
}

END {
	for (i in pt) if (m < i+0) m = i+0

	for (i = 0; i <= m; i++) if (i in pt)
	for (j = 0; j <= m; j++) if (j in pt && (i,j) in cc)
	if (!(i in ns) && !(cc[i,j] in ns)) { # exclude non-starter decompositions
		printf "%.4X\t%.4X\t%.4X\n", i, j, cc[i,j]
	}
}
