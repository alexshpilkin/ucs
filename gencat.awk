BEGIN { NAME = "uc_gc%s"; WORD_BIT = 5; CHUNK_BIT = 8 }
$2 != "Cn" && $3 != "Cn" { set(cat, $3 ? $3 : $2) }

END {
	cat[-1] = -1 # sentinel
	for (i = 0; i <= n+1; i++) {
		if (cat[i] != cat[i-1]) rle[bit[i] = ++m] = i
	}

	printf "#define CHUNK_BIT %u\n", CHUNK_BIT # FIXME
	WORD = 2^WORD_BIT; CHUNK = 2^CHUNK_BIT
	WFMT = sprintf("0x%%.%ulXul", WORD / 4)

	printf "const uint_least8_t "NAME"[] = {", "v"
	for (i = 1; i <= m; i++) {
		printf "%s%s,",
		       (i - 1) % 10 ? " " : sprintf("\n\t/* %4u */ ", i - 1),
		       cat[rle[i]] ? cat[rle[i]] : "Cn"
	}
	printf "\n};\n"
	octets += t = m
	printf "sizeof "NAME"\t= %u\n", "v", t | "cat >&2"

	for (i = 0; i <= n; i += WORD) {
		w = 0
		for (j = i; j < i + WORD; j++) {
			rank2[j] = rank2[j-1] + !!bit[j]
			w = w*2 + !!bit[j]
		}
		if (!(word2[i] = word[w = sprintf(WFMT, w)])) {
			word2[i] = word[w] = ++wordc
			wordv[wordc] = w
			wordp[wordc] = rank2[i+WORD-1] - rank2[i-1]
		}
	}

	for (i = 0; i <= n; i += CHUNK) {
		if (rank2[i+CHUNK-1] == rank2[i-1] &&
		    rank2[i-CHUNK-1] == rank2[i-1])
		{ continue }
		chunkv[chunk[i] = ++chunkc] = i
	}

	for (i = 0; i <= n; i += CHUNK * WORD) {
		w = 0
		for (j = i; j < i + CHUNK * WORD; j += CHUNK) {
			rank1[j] = rank1[j-CHUNK] + !!chunk[j]
			w = w*2 + !!chunk[j]
		}
		if (!(word1[i] = word[w = sprintf(WFMT, w)])) {
			word1[i] = word[w] = ++wordc
			wordv[wordc] = w
			wordp[wordc] = rank1[i+CHUNK*WORD-CHUNK] - rank1[i-CHUNK]
		}
	}

	printf "const uint_least%u_t "NAME"[] = {", WORD, "w"
	for (i = k = 0; i <= WORD; i++) {
		for (j = 1; j <= wordc; j++) {
			if (wordp[j] != i) continue
			printf "%s%s,",
			       k % 4 ? " " : sprintf("\n\t/* %3u */ ", k),
			       wordv[j]
			k++; wordi[j] = popf[i]++
		}
	}
	printf "\n};\n"
	octets += t = k * WORD / 8
	printf "sizeof "NAME"\t= %u\n", "w", t | "cat >&2"

	printf "const uint_least16_t "NAME"[] = {", "i"
	for (i = p = 0; i <= WORD && p < wordc; i++) {
		printf "%s%3u,", i % 8 ? " " : sprintf("\n\t/* %2u */ ", i), p
		p += popf[i]
	}
	printf "\n};\n"
	octets += t = i * 2
	printf "sizeof "NAME"\t= %u\n", "i", t | "cat >&2"

	printf "const struct { uint_least16_t off; struct wordref dat[%u]; } " \
	       NAME"[] = {", CHUNK / WORD + 1, "2"
	for (i = 1; i <= chunkc; i++) {
		printf "\n\t/* %.4X..%.4X */ {\n\t\t%u, {",
		       chunkv[i], chunkv[i] + CHUNK - 1, rank2[chunkv[i]-1]
		p = 0
		for (j = chunkv[i]; j < chunkv[i] + CHUNK; j += WORD) {
			printf "%s{%3u,%3u},",
			       j % (4 * WORD) ? " " : "\n\t\t\t",
			       p, wordi[word2[j]]
			p += wordp[word2[j]]
		}
		printf "%s{%3u, -1}", j % (4 * WORD) ? " " : "\n\t\t\t", p
		printf "\n\t\t}\n\t},"
	}
	printf "\n};\n"
	octets += t = chunkc * (1 + CHUNK / WORD + 1) * 2
	printf "sizeof "NAME"\t= %u\n", "2", t | "cat >&2"

	printf "const struct wordref "NAME"[] = {", "1"
	for (i = p = 0; i <= n; i += CHUNK * WORD) {
		printf "%s{%3u,%3u},",
		       i % (5 * CHUNK * WORD) ? " " : \
		       sprintf("\n\t/* %6.4X */ ", i),
		       p, wordi[word1[i]]
		p += wordp[word1[i]]
	}
	printf "%s{%3u, -1}",
	       i % (5 * CHUNK * WORD) ? " " : \
	       sprintf("\n\t/* %6.4X */ ", i),
	       p
	printf "\n};\n"
	octets += t = (i / CHUNK / WORD + 1) * 2
	printf "sizeof "NAME"\t= %u\n", "1", t | "cat >&2"

	printf "// all "NAME"\t= %u\n", "?", octets | "cat >&2"
}
