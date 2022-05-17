$3 ~ /^[PS].$/ { set(catok) } $2 == "Alphabetic" { set(alpha) }
END {
	for (i = 0; i <= n; i++) if (i in catok && !(i in alpha))
		printf "%.4X\n", i
}
