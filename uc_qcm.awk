BEGIN { NAME = "qc"; BITS = 32 }

$2 ~ /^[0-9]+$/ && $2 != 0              { set(cmbcls, $2) }
$2 == "NFD_QC"  && $3 != "Y"            { set(nfdqc,  $3) }
$2 == "NFC_QC"  && $3 != "Y"            { set(nfcqc,  $3) }
$2 == "NFKD_QC" && $3 != "Y"            { set(nfkdqc, $3) }
$2 == "NFKC_QC" && $3 != "Y"            { set(nfkcqc, $3) }

# FIXME check that cmbcls[dm[i,*]] == 0 implies lcc[i] == 0

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

	classes[0] = 1; maxclass = 0
	for (i = 0; i <= n; i++) if (i in cmbcls) {
		classes[cmbcls[i]] = 1
		if (maxclass < cmbcls[i]) maxclass = cmbcls[i]
	}
	for (i = 0; i <= maxclass; i++) if (i in classes)
		classes[i] = classc++
	printf "uc_static_assert(UC_CLASSES >= %d);\n", classc

	for (i = 0; i <= n; i++) {
		for (j = i; j in dm; j = dm[j,1]) continue
		if (j in cmbcls) lcc[i] = classes[cmbcls[j]]
		for (j = i; j in dm; j = dm[j,dm[j]]) continue
		if (j in cmbcls) tcc[i] = classes[cmbcls[j]]
	}

	value[""] = "UC_LCC_(UC_CLASSES) | " \
	            "UC_DQY | UC_CQY | UC_KDQY | UC_KCQY | UC_STARTER"
	for (i = 0; i <= n; i++) {
		nfdqc_  = !(i in nfdqc)  ? "Y" : nfdqc[i]  != "N" ? nfdqc[i]  : ""
		nfcqc_  = !(i in nfcqc)  ? "Y" : nfcqc[i]  != "N" ? nfcqc[i]  : ""
		nfkdqc_ = !(i in nfkdqc) ? "Y" : nfkdqc[i] != "N" ? nfkdqc[i] : ""
		nfkcqc_ = !(i in nfkcqc) ? "Y" : nfkcqc[i] != "N" ? nfkcqc[i] : ""
		value_  = "UC_LCC_("(i in lcc ? lcc[i] : "UC_CLASSES")")"   \
		          (i in tcc    ? " | UC_TCC_("tcc[i]")"       : "") \
		          (i in cmbcls ? " | UC_CMBCLS_("cmbcls[i]")" : "") \
		          (nfdqc_      ? " | UC_DQ" nfdqc_            : "") \
		          (nfcqc_      ? " | UC_CQ" nfcqc_            : "") \
		          (nfkdqc_     ? " | UC_KDQ" nfkdqc_          : "") \
		          (nfkcqc_     ? " | UC_KCQ" nfkcqc_          : "") \
		          (!(i in lcc) ? " | UC_STARTER"              : "") \
		          ""
		if (value_ != value[""]) value[i] = value_
	}
}
