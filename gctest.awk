$2 != "Cn" && $3 != "Cn" { set(cat, $3 ? $3 : $2) }
END { for (i = 0; i <= n; i++) printf "%.4X\t%s\n", i, cat[i] ? cat[i] : "Cn" }
