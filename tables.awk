BEGIN {
	for (i = 0; i < 16; i++) {
		nybble[int(i / 8) int(i % 8 / 4) int(i % 4 / 2) int(i % 2)] = \
			sprintf("%X", i)
	}
}

function mask(b, h, i) {
	for (i = 1; i <= length(b); i += 4)
		h = h nybble[substr(b, i, 4)]
	return "UC_UINT64_C(0x"substr(h, 1, 8)", 0x"substr(h, 9)")"
}

function pack(a, i, j, k, s, t) {
	k = 0; s = ","
	for (i = 0; i <= n; i++) if (i in a) {
		t = a[i]; j = index(t, ",")
		if (substr(s, length(s)-j) == "," substr(t, 1, j)) {
			s = s substr(t, j+1); k--
		} else {
			s = s t
		}
		a[i] = k; k += gsub(",", ",", t)
	}
	return substr(s, 2)
}

END {
	GROUP = 64; n += GROUP*GROUP - n % (GROUP*GROUP) - 1 # round up

	for (i = 0; i <= n; i++) {
		if ((x = i in value ? value[i] : value[""]) != prev) {
			prev = value[i] = x
		} else if (i in value) {
			delete value[i]
		}
	}

	for (i = prev = 0; i <= n; i += GROUP) {
		m = "0"; any = i in value
		s = (i in value ? last = value[i] : last) ","
		for (j = i + 1; j < i + GROUP; j++) {
			m = m (j in value); any = any || j in value
			if (j in value) {
				s = s (last = value[j]) ","; delete value[j]
			}
		}
		if (any || prev) { value[i] = s; masks[i] = m }
		prev = any
	}
	k = split(pack(value), a, ",") - 1

	printf "const uint_least%u_t uc_%sr[] = {", BITS, NAME
	for (i = 1; i <= k; i++) {
		printf "%s%3u,",
		       (i-1) % 10 ? " " : sprintf("\n\t/* %4u */ ", i-1),
		       a[i]
	}
	printf "\n};\n"
	octets += t = k * BITS/8
	printf "sizeof uc_%sr\t= %u\n", NAME, t | "cat >&2"

	for (i = 0; i <= n; i += GROUP) if (i in value)
		value[i] = masks[i] " " value[i]

	for (i = prev = 0; i <= n; i += GROUP*GROUP) {
		m = "0"; any = i in value
		s = (i in value ? last = value[i] : last) ","
		for (j = i + GROUP; j < i + GROUP*GROUP; j += GROUP) {
			m = m (j in value); any = any || j in value
			if (j in value) {
				s = s (last = value[j]) ","; delete value[j]
			}
		}
		if (any || prev) { value[i] = s; masks[i] = m }
		prev = any
	}
	k1 = split(pack(value), a1, ",") - 1

	for (i = 0; i <= n; i += GROUP*GROUP) if (i in value)
		value[i] = masks[i] " " value[i] ","
	k2 = split(pack(value), a2, ",") - 1

	for (i = 1; i <= k2; i++) {
		split(a2[i], p, " "); maskv[i] = p[1]; basev[i] = k2 + p[2]
	}
	for (i = 1; i <= k; i++) {
		split(a1[i], p, " "); maskv[k2+i] = p[1]; basev[k2+i] = p[2]
	}

	printf "const uint_least16_t uc_%sb[] = {", NAME
	for (i = 1; i <= k2 + k1; i++) {
		printf "%s%5u,",
		       (i-1) % 10 ? "" : sprintf("\n\t/* %3u */", i-1),
		       basev[i]
	}
	printf "\n};\n"
	octets += t = (k2 + k1) * 2
	printf "sizeof uc_%sb\t= %u = %u + %u\n", NAME,
	       t, k1 * 2, k2 * 2 | "cat >&2"

	printf "const uc_uint64_t uc_%sm[] = {", NAME
	for (i = 1; i <= k2 + k1; i++) {
		printf "\n\t/* %3u */ %s,", i-1, mask(maskv[i])
	}
	printf "\n};\n"
	octets += t = (k2 + k1) * GROUP/8
	printf "sizeof uc_%sm\t= %u = %u + %u\n", NAME,
	       t, k1 * GROUP/8, k2 * GROUP/8 | "cat >&2"

	printf "const uint_least8_t uc_%si[] = {", NAME
	for (i = k = 0; i <= n; i += GROUP*GROUP) {
		printf "%s%3u,",
		       k++ % 8 ? "" : sprintf("\n\t/* 0x%.6X */", i),
		       i in value ? x = value[i] : x
		if (x > 255) exit 1
	}
	printf "\n};\n"
	octets += t = k
	printf "sizeof uc_%si\t= %u\n", NAME, t | "cat >&2"

	printf "// all uc_%s?\t= %u\n", NAME, octets | "cat >&2"
}
