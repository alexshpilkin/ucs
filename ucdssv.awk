BEGIN { FS = "[ \t]*;[ \t]*"; OFS = "\t" }
{ sub("[ \t]*#.*$", "", $0) } /^$/ { next }

BEGIN { for (i = 0; i < 16; i++) hextab[sprintf("%X", i)] = i }
function hex(s, i, x) {
	x = 0
	for (i = 1; i <= length(s); i++)
		x = x*16 + hextab[substr(s, i, 1)]
	return x
}

e = index($1, "..") { n0 = hex(substr($1, 1, e-1)) }
{ n = hex(substr($1, e ? e+2 : 1)) }
!e && $2 !~ /^<.*, Last>$/ { n0 = n }
!e && $2 ~ /^<.*, First>$/ { next }
{ if (nn < n) nn = n } END { n0 = 0; n = nn }

function set(a, x, i) { if (x == "") x = 1; for (i = n0; i <= n; i++) a[i] = x }
function list(x, a, i) {
	for (i = n0; i <= n; i++) if (i in a)
		printf "%.4X%s\n", i, a[i] != x ? "\t" a[i] : ""
	for (i in a) return # array argument was present
	for (i = n0; i <= n; i++)
		printf "%.4X%s\n", i, x ? "\t" x : ""
}
