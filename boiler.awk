BEGIN {
	printf ".c.o:\n\t$(CC) -I include $(CPPFLAGS) $(CFLAGS) -c -o $@ $<\n\n"
	# Calling makefile must sequence clean before maintainer-clean
	printf "all clean maintainer-clean: ;\n"
}

$1 !~ /:$/ && !delay { print; next }

!delay { printf "\n" } { printf "# %s\n", $0; sub("^[ \t]*", "") }
/\\$/ { delay = delay substr($0, 1, length - 1); next }
{ $0 = delay $0; delay = "" }

{
	sub(/:$/, "", $1)
	stem = $1; sub(/\.[^.]*$/, "", stem)
	name = $1; gsub(/[^A-Za-z0-9_]/, "-", name)
}

$0 ~ /\.awk/ {
	guard = ""
	for (dir in dirs) delete dirs[dir]
	for (i = 2; i <= NF; i++) if ($i !~ /=/ && $i ~ "/") {
		dir = $i; sub("/[^/]*$", "", dir)
		if (!(dir in dirs)) guard = guard "-d " (dirs[dir] = dir) " "
	}

	printf "%s: invoke", $1
	for (i = 2; i <= NF; i++) if ($i !~ /=/) printf " %s", $i
	printf "\n\t$(SHELL) ./invoke -o $@ %s-- \\\n\t$(AWK)", guard
	for (i = 2; i <= NF; i++) if ($i  ~ /=|\.awk$/)
		printf " %s%s", $i ~ /=/ ? "" : "-f ", $i
	for (i = 2; i <= NF; i++) if ($i !~ /=|\.awk$/)
		printf " \\\n\t%s", $i
	printf "\n"

	for (i = 2; i <= NF; i++) if ($i ~ "/") printf "%s:\n", $i
	printf "maintainer-clean: maintainer-clean-%s\n", name
	printf "maintainer-clean-%s:\n", name
	printf "\t$(SHELL) ./invoke %s-- rm -f %s\n", guard, $1

	next
}

{
	printf "all: %s\n", name
	printf "%s: %s.ref %s.out\n\tcmp %s.ref %s.out\n",
	       name, stem, stem, stem, stem
	printf "%s.out: %s %s.ref\n\t%s < %s.ref > $@\n",
	       stem, $1, stem, $1, stem

	printf "%s: %s.o", $1, stem
	for (i = 2; i <= NF; i++) if ($i !~ /\.h$/) printf " %s", $i
	printf "\n\t$(CC) $(LDFLAGS) -o $@ %s.o", stem
	for (i = 2; i <= NF; i++) if ($i !~ /\.h$/) printf " %s", $i
	printf " $(LOADLIBES) $(LDLIBS)\n"
	printf "%s.o:", stem
	for (i = 2; i <= NF; i++) if ($i  ~ /\.h$/) printf " %s", $i
	printf "\n"

	printf "clean: clean-%s\n", name
	printf "clean-%s: ; rm -f %s.out %s %s.o\n", name, stem, $1, stem
}
