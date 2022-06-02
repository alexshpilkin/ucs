END {
	valuev[0] = value[""]
	for (i = 0; i <= n; i++) if (i in value) {
		if (!((s = value[i]) in values))
			valuev[values[s] = ++valuec] = s
		if (INTERLEAVED &&
		    i-3 in value && i-1 in value && value[i-3] == value[i-1] &&
		    i-2 in value && value[i-2] == value[i] &&
		    value[i-1] != value[i] &&
		    !(value[i-1] in pair) && !(value[i] in pair))
		{
			pair[value[i-1]] = value[i]
			pair[value[i]] = value[i-1]
		}
	}

	for (i = 0; i <= valuec; i++)
		delete values[valuev[i]]
	for (i = k = 0; i <= valuec; i++) if (valuev[i] in pair) {
		if (valuev[i] in values) continue
		values[valuev[i]]       = k++
		values[pair[valuev[i]]] = k++
	}
	for (i = 0; i <= valuec; i++) if (!(valuev[i] in pair))
		values[valuev[i]] = k++
	for (s in values)
		valuev[values[s]] = s

	value[""] = values[value[""]] * (INTERLEAVED ? 2 : 1)
	for (i = 0; i <= n; i++) if (i in value) {
		x = value[i] = values[s = value[i]] * (INTERLEAVED ? 2 : 1)
		if (!(pair[s] && i-2 in value && i-1 in value)) continue
		y = values[pair[s]] * 2
		if (value[i-2] == x && value[i-1] == y)
			value[i-2] = value[i-1] = i % 2 ? y + 1 : x + 1
		if (  i % 2  && value[i-1] == y + 1) value[i] = y + 1
		if (!(i % 2) && value[i-1] == x + 1) value[i] = x + 1
	}

	printf "const uint_least%s_t uc_%sv[] = {", BITS, NAME
	for (i = 0; i <= valuec; i++)
		printf "\n\t/* %2d */ %s,", i, valuev[i]
	printf "\n};\n"
	octets += t = (valuec + 1) * BITS / 8
	printf "sizeof uc_%sv\t= %u\n", NAME, t | "cat >&2"

	k = INTERLEAVED ? valuec * 2 + 1 : valuec
	for (BITS = 8; k >= 2^BITS; BITS *= 2) continue
}
