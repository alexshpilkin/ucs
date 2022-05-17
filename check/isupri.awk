$3 && $3 !~ /^C[cs]$/                      { set(catok) }
$2 == "White_Space"                        { set(space) }
$3 == "Zs" || $2 == "CHARACTER TABULATION" { set(blank) }
$3 == "Cc"                                 { set(cntrl) }

END {
	for (i = 0; i <= n; i++)
	if ((i in catok && !(i in space) || i in blank) && !(i in cntrl))
		printf "%.4X\n", i
}
