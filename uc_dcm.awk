BEGIN { NAME = "dc"; BITS = 2 }

$6 ~ /^[^<]/ {
	k = cdm[n] = split($6, a, " ")
	for (i = 1; i <= k; i++) cdm[n,i] = xtoi(a[i])
}

function collect(i, j, k) {
	if (!(j in cdm)) { cd[i,++cd[i]] = j; return }
	for (k = 1; k <= cdm[j]; k++) collect(i, cdm[j,k])
}

END {
	for (i = 0; i <= n; i++) if (i in cdm) {
		collect(i, i)
		if (cdmax < cd[i]) cdmax = cd[i]
	}
	printf "uc_static_assert(DECOMP_MAX >= %d);\n", cdmax
}

$4 != 0 { set(ccc, $4+0) }

END {
	for (i = 0; i <= n; i++) if (i in cd) {
		for (j = 2; j <= cd[i]; j++) {
			if (ccc[cd[i,j]] && ccc[cd[i,j-1]] > ccc[cd[i,j]])
				exit 1
		}
	}
}

END {
	# Per the roadmap to the BMP <https://www.unicode.org/roadmaps/bmp/>,
	# codepoints U+D800 to U+FFFF are allocated to various controls,
	# compatibility characters, and noncharacters---not the kind of thing
	# that should occur in decompositions, and indeed it does not.  (This
	# is an issue of table size, not of correctness.)  This gives us a
	# comfortable 10240 codepoints for long decompositions, more than the
	# total codepoints in full compatibility decompositions as of 12.0.

	BMPTOP = xtoi("D800")
	printf "uc_static_assert(UC_BMPTOP == 0x%.4X);\n", BMPTOP

	shortc = longc = 0
	for (i = 0; i <= n; i++) if (i in cd) {
		indir = cd[i] > 2^BITS - 1
		for (j = 1; j <= cd[i]; j++) if (cd[i,j] >= BMPTOP) indir = 1
		if (indir) {
			shortv[shortc++] = BMPTOP + longc
			for (j = 1; j <= cd[i]; j++)
				longv[longc++] = cd[i,j] + 2^23 * (j == cd[i])
		} else {
			for (j = 1; j <= cd[i]; j++)
				shortv[shortc++] = cd[i,j]
		}
		value[i] = shortc
	}

	while (!(n in value)) n--

	# packing doesn't help here, so don't bother

	printf "const uint_least16_t uc_%ss[] = {", NAME
	for (i = 0; i < shortc; i++) {
		printf "%s0x%.4X,",
		       i % 5 ? " " : sprintf("\n\t/* %4u */ ", i),
		       shortv[i]
	}
	printf "\n};\n"
	octets += t = shortc * 2;
	printf "sizeof uc_%ss\t= %u\n", NAME, t | "cat >&2"

	printf "const uint_least8_t uc_%sl[][3] = {", NAME
	for (i = 0; i < longc; i++) {
		printf "%s{0x%.2X, 0x%.2X, 0x%.2X},",
		       i % 3 ? " " : sprintf("\n\t/* 0x%.4X */ ", BMPTOP + i),
		       int(longv[i] / 2^16),
		       int(longv[i] % 2^16 / 2^8),
		       longv[i] % 2^8
	}
	printf "\n};\n"
	octets += t = longc * 3;
	printf "sizeof uc_%sl\t= %u\n", NAME, t | "cat >&2"

	# a bit stricter than necessary, but there's a lot of slack anyway
	if (BMPTOP + longc >= 65536) exit 1

	prev = 1

	for (i = last = 0; i < n + GROUP/BITS; i += GROUP/BITS) {
		base = last
		for (k = 1; k <= BITS; k++) mm[k] = ""
		for (j = i; j < i + GROUP/BITS; j++) {
			x = j in value ? value[j] - last : 0
			last += x; delete value[j]
			for (k = 1; k <= BITS; k++) {
				mm[k] = mm[k] x % 2; x = int(x / 2)
			}
		}
		for (k = 2; k <= BITS; k++) mm[1] = mm[k] mm[1]
		if (mm[1] != none || prev) value[i] = mm[1] " " base
		prev = mm[1] != none
	}
}
