END {
	printf "#define CHUNK_BIT %u\n", CHUNK_BIT # FIXME
	printf "#define GROUP_BIT %u\n", GROUP_BIT
	CHUNK = 2^CHUNK_BIT; GROUP = 2^GROUP_BIT

	n += GROUP - n % GROUP - 1 # round up to multiple of GROUP

	for (i = 0; i <= n; i += CHUNK) {
		data = ","
		for (j = i; j < i + CHUNK; j++)
			data = data (value[j] ? value[j] : value[""]) ","
		if (!(chunki[i] = chunks[data]))
			chunkv[chunki[i] = chunks[data] = ++chunkc] = data
	}

	for (m = chunkc; m > 1; m -= 2) {
		max = -1; left = right = ""
		for (i in chunkv) for (j in chunkv) {
			i += 0; j += 0
			if (i == j) continue
			if (overlap[i,j] == "") {
				l = chunkv[i]; r = chunkv[j]
				for (k = 1; k <= length(l); k++) {
					if (substr(l, k, length(r)) == \
					    substr(r, 1, length(l)-k+1))
					{ break }
				}
				l = substr(l, k, length(r))
				overlap[i,j] = gsub(",", ",", l) - 1
				ovstart[i,j] = k
			}
			if (max <  overlap[i,j] || \
			    max == overlap[i,j] && left <  i || \
			    max == overlap[i,j] && left == i && right < j)
			{
				left = i; right = j
				max = overlap[i,j]; start = ovstart[i,j]
			}
		}
		data = substr(chunkv[left], 1, start-1) chunkv[right]
		if (!(super = chunks[data])) {
			chunkv[super = chunks[data] = ++chunkc] = data; m++
		}
		parent[left] = parent[right] = super
		l = substr(chunkv[left], 1, start-1)
		offset[left] = 0; offset[right] = gsub(",", ",", l)
		delete chunkv[left]; delete chunkv[right]
	}
	for (i in chunkv) i = i # runs once
	chunkc = split(substr(chunkv[i], 2), chunkv, ",") - 1

	printf "const uint_least%s_t uc_%sv[] = {", BITS, NAME
	for (i = 1; i <= chunkc; i++) {
		printf "%s%2s,",
		       (i-1) % 10 ? " " : sprintf("\n\t/* %5u */ ", i-1),
		       chunkv[i]
	}
	printf "\n};\n"
	octets += t = chunkc * BITS / 8
	printf "sizeof uc_%sv\t= %u\n", NAME, t | "cat >&2"

	for (i = 0; i <= n; i += GROUP) {
		data = ""
		for (j = i; j < i + GROUP; j += CHUNK) {
			o = 0
			for (k = chunki[j]; parent[k]; k = parent[k])
				o += offset[k]
			data = data o ","
		}
		if (!(groupi[i] = groups[data]))
			groupv[groupi[i] = groups[data] = ++groupc] = data
	}

	printf "const uint_least16_t uc_%sc[][1 << GROUP_BIT - CHUNK_BIT] = {", NAME # FIXME
	for (i = 1; i <= groupc; i++) {
		grpc = split(groupv[i], grpv, ",") - 1
		printf "\n\t/* %u */ {", i-1
		for (j = 1; j <= grpc; j++) {
			printf "%s%5s,",
			       (j-1) % 4 ? " " : \
			       sprintf("\n\t\t/* 0x%.3X */ ", (j-1) * CHUNK),
			       x = grpv[j]
			if (x > 65535) exit 1
		}
		printf "\n\t},"
	}
	printf "\n};\n"
	octets += t = groupc * GROUP/CHUNK * 2
	printf "sizeof uc_%sc\t= %u\n", NAME, t | "cat >&2"

	printf "const uint_least8_t uc_%sg[] = {", NAME
	for (i = k = 0; i <= n; i += GROUP) {
		printf "%s%2u,",
		       k++ % 8 ? " " : sprintf("\n\t/* 0x%.6X */ ", i),
		       x = groups[groupv[groupi[i]]] - 1
		if (x - 1 > 255) exit 1
	}
	printf "\n};\n"
	octets += t = k
	printf "sizeof uc_%sg\t= %u\n", NAME, t | "cat >&2"

	printf "// all uc_%s?\t= %u\n", NAME, octets | "cat >&2"
}
