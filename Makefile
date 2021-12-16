AWK = awk
ARFLAGS  = -cr
CPPFLAGS = -std=c89 -Wall -Wimplicit-fallthrough -pedantic -U_FORTIFY_SOURCE
CFLAGS   = -fno-asynchronous-unwind-tables -fno-ident -fomit-frame-pointer \
           -fno-stack-protector -O2

.c.o:
	$(CC) -I include $(CPPFLAGS) $(CFLAGS) -c -o $@ $<

all clean check: ;
maintainer-clean: clean ;

OBJECTS_UC = uc_gcn.o uc_p32.o uc_p64.o uc_ty.o uc_tym.o
all: libuc.a
libuc.a: $(OBJECTS_UC)
	$(AR) $(ARFLAGS) $@ $(OBJECTS_UC)
	if [ "$(RANLIB)" ]; then ranlib $@; fi
$(OBJECTS_UC): include/uc_cnf.h
uc_gcn.o uc_ty.o uc_tym.o: include/uctype.h
uc_tym.o: uc_tym.g
clean: clean-libuc
clean-libuc: ; rm -f libuc.a $(OBJECTS_UC)

SOURCES_TYM = ucd/data/extracted/DerivedGeneralCategory.txt \
              ucd/data/DerivedCoreProperties.txt \
              ucd/data/PropList.txt \
              ucd/data/extracted/DerivedNumericValues.txt \
              data/HexDigitValues.txt
uc_tym.g: ucdssv.awk uc_tym.awk values.awk tables.awk $(SOURCES_TYM)
	> $@ $(AWK) -f ucdssv.awk -f uc_tym.awk -f values.awk -f tables.awk \
	$(SOURCES_TYM)
maintainer-clean: maintainer-clean-uc_tym
maintainer-clean-uc_tym: ; rm -f uc_tym.g

check: check-isualp
check-isualp: check/isualp check/isualp.tsv
	check/isualp | diff -u check/isualp.tsv -
check/isualp: check/isualp.o libuc.a
	$(CC) $(LDFLAGS) -o $@ check/isualp.o libuc.a $(LOADLIBES) $(LDLIBS)
check/isualp.o: include/uc_cnf.h include/uctype.h
clean: clean-check-isualp
clean-check-isualp: ; rm -f check/isualp check/isualp.o

check/isualp.tsv: ucdssv.awk check/isualp.awk ucd/data/DerivedCoreProperties.txt
	> $@ $(AWK) -f ucdssv.awk -f check/isualp.awk ucd/data/DerivedCoreProperties.txt
maintainer-clean: maintainer-clean-check-isualp
maintainer-clean-check-isualp: ; rm -f check/isualp.tsv

check: check-mincat
check-mincat: check/mincat check/mincat.tsv
	cut -f1 check/mincat.tsv | check/mincat | diff -u check/mincat.tsv -
check/mincat: check/mincat.o libuc.a
	$(CC) $(LDFLAGS) -o $@ check/mincat.o libuc.a $(LOADLIBES) $(LDLIBS)
check/mincat.o: include/uc_cnf.h include/uctype.h
clean: clean-check-mincat
clean-check-mincat: ; rm -f check/mincat check/mincat.o

check/mincat.tsv: ucdssv.awk check/mincat.awk ucd/data/UnicodeData.txt
	> $@ $(AWK) -f ucdssv.awk -f check/mincat.awk ucd/data/UnicodeData.txt
maintainer-clean: maintainer-clean-check-mincat
maintainer-clean-check-mincat: ; rm -f check/mincat.tsv
