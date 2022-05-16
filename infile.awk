BEGIN {
	FS = "@"; OFS = ""
	for (i = 0; i < ARGC; i++) if (ARGV[i] ~ /=/) {
		s = ARGV[i]; delete ARGV[i]; j = index(s, "=")
		vars[substr(s, 1, j - 1)] = substr(s, j + 1)
	}
}
{
	for (i = 2; i <= NF; i += 2) $i = $i in vars ? vars[$i] : "@" $i "@"
	print
}
