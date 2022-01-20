# Primes to try: ... 349 353 359 367 389 397 ...
BEGIN { NAME = "rc"; SIZE = 367 }

function pack(x) {
	if (x % 65536 >= 16384) exit 1
	if ((x = x % 16384 + int(x / 65536) * 16384) >= 65536) exit 1
	return x
}

$2 == "Full_Composition_Exclusion" { set(fce) }
$6 ~ /^[^<]/ && !fce[n] {
	if (split($6, a, " ") != 2) exit 1
	m++
	fst[m] = pack(hex(a[1]))
	snd[m] = pack(hex(a[2]))
	val[m] = pack(n) + fst[m] * 65536
}

BEGIN { state = 1 } # fixed seed for reproducibility
function rand15() { # 16-bit LCG, crappy but good enough
	state = (state * 1237 + 12343) % 2^16
	return int(state / 2)
}

BEGIN {
	for (x = 0; x < 16; x++) for (y = 0; y < 16; y++) {
		z = 0
		for (k = 0; k < 4; k++) {
			if (int(x / 2^k) % 2 != int(y / 2^k) % 2) z += 2^k
		}
		eortab[x,y] = z
	}
}
function eor(x, y, k, z) { # avoid collision with Gawk's xor()
	for (k = 7; k >= 0; k--)
		z = z * 16 + eortab[int(x / 16^k) % 16, int(y / 16^k) % 16]
	return z
}

END {
	PARTS = 3 # minimal size overhead (about 1.23x)

	for (;;) {
		for (j = 1; j <= PARTS; j++) {
			a[j] = rand15(); b[j] = 2^(7+j) - 1
		}

		for (v = 1; v <= PARTS * SIZE; v++)
			head[v] = degree[v] = 0

		for (i = 1; i <= m; i++) {
			dead[i] = 0
			for (j = 1; j <= PARTS; j++) {
				h  = (a[j] * fst[i] + b[j] * snd[i]) % 65536
				h  = int(h * SIZE / 65536)
				h += (j - 1) * SIZE + 1
				degree[evert[i,j] = h]++
				elink[i,j] = head[h]; head[h] = i
			}
		}

		for (v = 1; v <= PARTS * SIZE; v++) {
			if (degree[v] != 1) continue
			pop[v] = top; top = v
		}

		left = m
		while (v = top) {
			top = pop[top]
			k = int((v - 1) / SIZE) + 1
			for (i = head[v]; i; i = elink[i,k]) {
				if (dead[i]++) continue
				# no more than one edge past here
				edgev[left] = i; partv[left] = k; left--
				for (j = 1; j <= PARTS; j++) {
					if (--degree[evert[i,j]] != 1) continue
					pop[evert[i,j]] = top; top = evert[i,j]
				}
			}
		}
		if (left) continue # cyclic graph, try again

		for (i = 1; i <= m; i++) {
			x = val[edgev[i]]
			for (j = 1; j <= PARTS; j++)
				x = eor(x, label[evert[edgev[i],j]])
			label[evert[edgev[i],partv[i]]] = x
		}

		for (j = 1; j <= PARTS; j++) {
			printf "uc_static_assert(UC_%s_A%d == %5d && " \
			                        "UC_%s_B%d == %4d);\n",
			       toupper(NAME), j, a[j], toupper(NAME), j, b[j]
		}
		printf "const uint_least%d_t uc_%sh[%d] = {",
		       32, NAME, PARTS * SIZE
		for (v = 1; v <= PARTS * SIZE; v++) {
			printf "%s0x%.8X,",
			       (v-1) % 5 ? " " : sprintf("\n\t/* %4d */ ", v-1),
			       label[v]
		}
		printf "\n};\n"
		octets += t = PARTS * SIZE * 4
		printf "sizeof uc_%sh\t= %u\n", NAME, t | "cat >&2"

		printf "// all uc_%s?\t= %u\n", NAME, octets | "cat >&2"
		break
	}
}
