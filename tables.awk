function mask(b, h, i, x) {
	for (i = 1; i <= length(b); i += 4) {
		x = substr(b, i,   1) * 8 + \
		    substr(b, i+1, 1) * 4 + \
		    substr(b, i+2, 1) * 2 + \
		    substr(b, i+3, 1)
		h = h sprintf("%X", x)
	}
	return "UINT64_C(0x"h")"
}

END {
	GROUP = 64; n += GROUP*GROUP - n % (GROUP*GROUP) - 1 # round up

	printf "const uint_least%u_t uc_%sr[] = {", BITS, NAME
	prev = "*" # not a C expression
	for (i = k = 0; i <= n; i++) {
		if (value[i] = ((x = value[i]) != prev)) {
			printf "%s%2u,",
			       k++ % 10 ? " " : sprintf("\n\t/* %4u */ ", k-1),
			       prev = x
		}
	}
	printf "\n};\n"
	octets += t = k * BITS/8
	printf "sizeof uc_%sr\t= %u\n", NAME, t | "cat >&2"

	k = 0 # masks and bases total

	base = b = 0
	for (i = 0; i <= n; i += GROUP) {
		prev = b; b = 0; s = ""
		for (j = i; j < i + GROUP; j++) {
			s = s !!value[j]; b += !!value[j]
		}
		if (b || prev) {
			value[i] = ++k
			maskv[k] = mask(s); basev[k] = base
			base += b
		}
	}

	k0 = k # masks and bases on bottom level

	base = b = 0
	for (i = 0; i <= n; i += GROUP*GROUP) {
		prev = b; b = 0; s = ""
		for (j = i; j < i + GROUP*GROUP; j += GROUP) {
			s = s !!value[j]; b += !!value[j]
		}
		if (b || prev) {
			value[i] = ++k
			maskv[k] = mask(s); basev[k] = base
			base += b
		}
	}

	printf "const uint_least16_t uc_%sb[] = {", NAME
	for (i = 1; i <= k; i++) {
		printf "%s%5u,",
		       (i-1) % 10 ? "" : sprintf("\n\t/* %3u */", i-1),
		       i+k0 <= k ? basev[i+k0] + k - k0 : basev[i+k0-k]
	}
	printf "\n};\n"
	octets += t = k * 2
	printf "sizeof uc_%sb\t= %u = %u + %u\n", NAME,
	       t, k0 * 2, (k - k0) * 2 | "cat >&2"

	printf "const uint_least%s_t uc_%sm[] = {", GROUP, NAME # FIXME 64-bit type?
	for (i = 1; i <= k; i++) {
		printf "%s%s,",
		       (i-1) % 2 ? " " : sprintf("\n\t/* %3u */ ", i-1),
		       maskv[i+k0 <= k ? i+k0 : i+k0-k]
	}
	printf "\n};\n"
	octets += t = k * GROUP/8
	printf "sizeof uc_%sm\t= %u = %u + %u\n", NAME,
	       t, k0 * GROUP/8, (k - k0) * GROUP/8 | "cat >&2"

	printf "const uint_least8_t uc_%si[] = {", NAME
	for (i = k = 0; i <= n; i += GROUP*GROUP) {
		printf "%s%3u,",
		       k++ % 8 ? "" : sprintf("\n\t/* 0x%.6X */", i),
		       value[i] ? (x = value[i] - k0 - 1) : x
		if (x > 255) exit 1
	}
	printf "\n};\n"
	octets += t = k
	printf "sizeof uc_%si\t= %u\n", NAME, t | "cat >&2"

	printf "// all uc_%s?\t= %u\n", NAME, octets | "cat >&2"
}
