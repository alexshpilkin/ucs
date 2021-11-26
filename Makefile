AWK = awk
CPPFLAGS = -std=c89 -Wall -pedantic -U_FORTIFY_SOURCE
CFLAGS   = -fno-asynchronous-unwind-tables -fno-ident -fomit-frame-pointer \
           -fno-stack-protector -O2

all clean test: ;
maintainer-clean: clean ;

all: gencat
clean: clean-gencat
clean-gencat: ; rm -f gencat uc_ty.o
maintainer-clean: maintainer-clean-gencat
maintainer-clean-gencat: ; rm -f uc_ty.g
gencat: uc_ty.o
	$(CC) $(LDFLAGS) -o $@ uc_ty.o $(LOADLIBES) $(LDLIBS)
uc_ty.o: uc_ty.g

SOURCES_TY = ucd/data/extracted/DerivedGeneralCategory.txt \
             ucd/data/DerivedCoreProperties.txt \
             ucd/data/PropList.txt \
             ucd/data/extracted/DerivedNumericValues.txt \
             data/HexDigitValues.txt
uc_ty.g: ucdssv.awk uc_ty.awk values.awk tables.awk $(SOURCES_TY)
	> $@ $(AWK) -f ucdssv.awk -f uc_ty.awk -f values.awk -f tables.awk \
	$(SOURCES_TY)

test: test-gencat
maintainer-clean: maintainer-clean-test-gencat
maintainer-clean-test-gencat: ; rm -f gctest.tsv
test-gencat: gencat gctest.tsv
	cut -f1 gctest.tsv | ./gencat | diff -u gctest.tsv -
gctest.tsv: ucdssv.awk gctest.awk ucd/data/UnicodeData.txt
	> $@ $(AWK) -f ucdssv.awk -f gctest.awk ucd/data/UnicodeData.txt
