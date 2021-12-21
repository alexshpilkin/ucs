$3 != "Cn" { set(cat, $3) }
END {
	for (i = 0; i <= n; i++) if (i in cat)
		printf "%.4X\t%s\n", i, cat[i]
}
