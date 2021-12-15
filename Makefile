AWK = awk
CPPFLAGS = -std=c89 -Wall -Wimplicit-fallthrough -pedantic -U_FORTIFY_SOURCE
CFLAGS   = -fno-asynchronous-unwind-tables -fno-ident -fomit-frame-pointer \
           -fno-stack-protector -O2

.c.o:
	$(CC) -I include $(CPPFLAGS) $(CFLAGS) -c -o $@ $<

all clean check: ;
maintainer-clean: clean ;

all: uc_ty.o
uc_ty.o: include/uctype.h uc_ty.g
clean: clean-uc_ty
clean-uc_ty: ; rm -f uc_ty.o

SOURCES_TY = ucd/data/extracted/DerivedGeneralCategory.txt \
             ucd/data/DerivedCoreProperties.txt \
             ucd/data/PropList.txt \
             ucd/data/extracted/DerivedNumericValues.txt \
             data/HexDigitValues.txt
uc_ty.g: ucdssv.awk uc_ty.awk values.awk tables.awk $(SOURCES_TY)
	> $@ $(AWK) -f ucdssv.awk -f uc_ty.awk -f values.awk -f tables.awk \
	$(SOURCES_TY)
maintainer-clean: maintainer-clean-uc_ty
maintainer-clean-uc_ty: ; rm -f uc_ty.g

check: check-isualp
check-isualp: check/isualp check/isualp.tsv
	check/isualp | diff -u check/isualp.tsv -
check/isualp: check/isualp.o uc_ty.o
	$(CC) $(LDFLAGS) -o $@ check/isualp.o uc_ty.o $(LOADLIBES) $(LDLIBS)
check/isualp.o: include/uctype.h
clean: clean-check-isualp
clean-check-isualp: ; rm -f check/isualp check/isualp.o

check/isualp.tsv: ucdssv.awk check/isualp.awk ucd/data/DerivedCoreProperties.txt
	> $@ $(AWK) -f ucdssv.awk -f check/isualp.awk ucd/data/DerivedCoreProperties.txt
maintainer-clean: maintainer-clean-check-isualp
maintainer-clean-check-isualp: ; rm -f check/isualp.tsv

check: check-mincat
check-mincat: check/mincat check/mincat.tsv
	cut -f1 check/mincat.tsv | check/mincat | diff -u check/mincat.tsv -
check/mincat: check/mincat.o uc_ty.o
	$(CC) $(LDFLAGS) -o $@ check/mincat.o uc_ty.o $(LOADLIBES) $(LDLIBS)
check/mincat.o: include/uctype.h
clean: clean-check-mincat
clean-check-mincat: ; rm -f check/mincat check/mincat.o

check/mincat.tsv: ucdssv.awk check/mincat.awk ucd/data/UnicodeData.txt
	> $@ $(AWK) -f ucdssv.awk -f check/mincat.awk ucd/data/UnicodeData.txt
maintainer-clean: maintainer-clean-check-mincat
maintainer-clean-check-mincat: ; rm -f check/mincat.tsv
