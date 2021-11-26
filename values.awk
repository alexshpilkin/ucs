END {
	for (i = 0; i <= n; i++) {
		if ((s = value[i]) == "")
			continue
		if ((value[i] = values[s]) == "")
			valuev[value[i] = values[s] = ++valuec] = s
	}
	valuev[0] = value[""]; value[""] = 0

	printf "const uint_least%s_t uc_%s0[] = {", BITS, NAME
	for (i = 0; i <= valuec; i++)
		printf "\n\t/* %2d */ %s,", i, valuev[i]
	printf "\n};\n"
	octets += t = (valuec + 1) * BITS / 8
	printf "sizeof uc_%s0\t= %u\n", NAME, t | "cat >&2"

	while (BITS > 8 && 2^BITS > valuec+1) BITS /= 2
}
