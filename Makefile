AWK = awk
CPPFLAGS = -std=c89 -Wall -pedantic -U_FORTIFY_SOURCE
CFLAGS   = -fno-asynchronous-unwind-tables -fno-ident -fomit-frame-pointer \
           -fno-stack-protector -O2

all clean test: ;
maintainer-clean: clean ;

all: gencat
clean: clean-gencat
clean-gencat: ; rm -f gencat gencat.o
maintainer-clean: maintainer-clean-gencat
maintainer-clean-gencat: ; rm -f gencat.g
gencat: gencat.o
	$(CC) $(LDFLAGS) -o $@ gencat.o $(LOADLIBES) $(LDLIBS)
gencat.o: gencat.g

gencat.g: ucdssv.awk gencat.awk ucd/data/UnicodeData.txt
	> $@ $(AWK) -f ucdssv.awk -f gencat.awk ucd/data/UnicodeData.txt

test: test-gencat
maintainer-clean: maintainer-clean-test-gencat
maintainer-clean-test-gencat: ; rm -f gctest.tsv
test-gencat: gencat gctest.tsv
	cut -f1 gctest.tsv | ./gencat | diff -u gctest.tsv -
gctest.tsv: ucdssv.awk gctest.awk ucd/data/UnicodeData.txt
	> $@ $(AWK) -f ucdssv.awk -f gctest.awk ucd/data/UnicodeData.txt
