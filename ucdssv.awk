BEGIN { FS = "[ \t]*;[ \t]*"; OFS = "\t" }
{ sub("[ \t]*#.*$", "", $0) } /^$/ { next }

BEGIN { for (i = 0; i < 16; i++) hex[sprintf("%X", i)] = i }
function xtoi(s, i, x) {
	x = 0
	for (i = 1; i <= length(s); i++)
		x = x*16 + hex[substr(s, i, 1)]
	return x
}

e = index($1, "..") { n0 = xtoi(substr($1, 1, e-1)) }
{ n = xtoi(substr($1, e ? e+2 : 1)) }
!e && $2 !~ /^<.*, Last>$/ { n0 = n }
!e && $2 ~ /^<.*, First>$/ { next }
{ if (nn < n) nn = n } END { n = nn }

function set(a, x, i) { for (i = n0; i <= n; i++) a[i] = x }
