BEGIN { NAME = "qc"; BITS = 32 }

$2 ~ /^[0-9]+$/ && $2 != 0              { set(cmbcls, $2) }
$2 == "Full_Composition_Exclusion"      { set(fce) }
$2 == "NFD_QC"  && $3 != "Y"            { set(nfdqc,  $3) }
$2 == "NFC_QC"  && $3 != "Y"            { set(nfcqc,  $3) }
$2 == "NFKD_QC" && $3 != "Y"            { set(nfkdqc, $3) }
$2 == "NFKC_QC" && $3 != "Y"            { set(nfkcqc, $3) }

$6 ~ /^[^<]/ {
	k = dm[n] = split($6, a, " ")
	for (j = 1; j <= k; j++) dm[n,j] = hex(a[j])
}

END {
	# Because Hangul jamo have combining class NR, syllable decompositions
	# (which are not listed in UnicodeData.txt) don't need to be taken into
	# account for lcc and tcc.

	for (i = 0; i <= 19; i++) if (hex("1100") + i in cmbcls) exit 1 # L
	for (i = 0; i <= 21; i++) if (hex("1161") + i in cmbcls) exit 1 # V
	for (i = 0; i <= 28; i++) if (hex("11A7") + i in cmbcls) exit 1 # T

	for (i = 0; i <= n; i++) {
		for (j = i; j in dm; j = dm[j,1]) continue
		if (j in cmbcls) lcc[i] = cmbcls[j]
		for (j = i; j in dm; j = dm[j,dm[j]]) continue
		if (j in cmbcls) tcc[i] = cmbcls[j]
	}

	value[""] = "UC_CMBCLS_(0)"
	for (i = 0; i <= n; i++) {
		value_  = "UC_CMBCLS_("(i in cmbcls ? cmbcls[i] : 0)")" \
		          (i in lcc    ? " | UC_LCC_("lcc[i]")" : "") \
		          (i in tcc    ? " | UC_TCC_("tcc[i]")" : "") \
		          (i in fce    ? " | UC_FCE"            : "") \
		          (i in nfdqc  ? " | UC_DQ"  nfdqc[i]   : "") \
		          (i in nfcqc  ? " | UC_CQ"  nfcqc[i]   : "") \
		          (i in nfkdqc ? " | UC_KDQ" nfkdqc[i]  : "") \
		          (i in nfkcqc ? " | UC_KCQ" nfkcqc[i]  : "") \
		          ""
		if (value_ != value[""]) value[i] = value_
	}
}
