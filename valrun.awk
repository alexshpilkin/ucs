END {
	for (i = 0; i <= n; i++) {
		if ((x = i in value ? value[i] : value[""]) != prev) {
			prev = value[i] = x
		} else if (i in value) {
			delete value[i]
		}
	}
	delete value[""]

	for (i = 0; i <= n; i += GROUP) {
		m = "0"; any = i in value
		s = (i in value ? last = value[i] : last) ","
		for (j = i + 1; j < i + GROUP; j++) {
			m = m (j in value); any = any || j in value
			if (j in value) {
				s = s (last = value[j]) ","; delete value[j]
			}
		}
		if (any || prev) { value[i] = s; masks[i] = m }
		prev = m != none
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

	BITS = 1
}
