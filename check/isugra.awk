$3 && $3 !~ /^C[cs]$/ { set(catok) } $2 == "White_Space" { set(space) }
END {
	for (i = 0; i <= n; i++) if (i in catok && !(i in space))
		printf "%.4X\n", i
}
