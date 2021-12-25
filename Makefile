AWK = awk
ARFLAGS  = -cr
CPPFLAGS = -std=c89 -Wall -Wimplicit-fallthrough -pedantic -U_FORTIFY_SOURCE
CFLAGS   = -fno-asynchronous-unwind-tables -fno-ident -fomit-frame-pointer \
           -fno-stack-protector -O2

.c.o:
	$(CC) -I include $(CPPFLAGS) $(CFLAGS) -c -o $@ $<

all clean check: ;
maintainer-clean: clean ;

OBJECTS_UC = decomp.o uc_dcm.o uc_gcn.o uc_p32.o uc_p64.o uc_ty.o uc_tym.o uc_qcm.o
all: libuc.a
libuc.a: $(OBJECTS_UC)
	$(AR) $(ARFLAGS) $@ $(OBJECTS_UC)
	if [ "$(RANLIB)" ]; then ranlib $@; fi
$(OBJECTS_UC): include/uc_cnf.h
decomp.o uc_dcm.o: include/uccomp.h
uc_gcn.o uc_ty.o uc_tym.o: include/uctype.h
uc_dcm.o: uc_dcm.g
uc_tym.o: uc_tym.g
uc_qcm.o: uc_qcm.g
clean: clean-libuc
clean-libuc: ; rm -f libuc.a $(OBJECTS_UC)

SOURCES_DCM = ucd/data/UnicodeData.txt
uc_dcm.g: invoke ucdssv.awk uc_dcm.awk pctrie.awk $(SOURCES_DCM)
	$(SHELL) ./invoke -o $@ -d ucd/data \
	$(AWK) -f ucdssv.awk -f uc_dcm.awk -f pctrie.awk \
	$(SOURCES_DCM)
$(SOURCES_DCM):
maintainer-clean: maintainer-clean-uc_dcm
maintainer-clean-uc_dcm: ; test -d ucd/data && rm -f uc_dcm.g

SOURCES_TYM = ucd/data/extracted/DerivedGeneralCategory.txt \
              ucd/data/DerivedCoreProperties.txt \
              ucd/data/PropList.txt \
              ucd/data/extracted/DerivedNumericValues.txt \
              data/HexDigitValues.txt
uc_tym.g: invoke ucdssv.awk uc_tym.awk values.awk valrun.awk pctrie.awk $(SOURCES_TYM)
	$(SHELL) ./invoke -o $@ -d ucd/data -- \
	$(AWK) -f ucdssv.awk -f uc_tym.awk -f values.awk -f valrun.awk -f pctrie.awk \
	$(SOURCES_TYM)
$(SOURCES_TYM):
maintainer-clean: maintainer-clean-uc_tym
maintainer-clean-uc_tym: ; test -d ucd/data && rm -f uc_tym.g

SOURCES_QCM = ucd/data/UnicodeData.txt \
              ucd/data/extracted/DerivedCombiningClass.txt \
              ucd/data/DerivedNormalizationProps.txt
uc_qcm.g: invoke ucdssv.awk uc_qcm.awk values.awk valrun.awk pctrie.awk $(SOURCES_QCM)
	$(SHELL) ./invoke -o $@ -d ucd/data -- \
	$(AWK) -f ucdssv.awk -f uc_qcm.awk -f values.awk -f valrun.awk -f pctrie.awk \
	$(SOURCES_QCM)
$(SOURCES_QCM):
maintainer-clean: maintainer-clean-uc_qcm
maintainer-clean-uc_qcm: ; test -d ucd/data && rm -f uc_qcm.g

check: check-decomp
check-decomp: check/decomp check/decomp.tsv
	check/decomp | cmp check/decomp.tsv -
check/decomp: check/decomp.o libuc.a
	$(CC) $(LDFLAGS) -o $@ check/decomp.o libuc.a $(LOADLIBES) $(LDLIBS)
check/decomp.o: include/uc_cnf.h include/uccomp.h
clean: clean-check-decomp
clean-check-decomp: ; rm -f check/decomp check/decomp.o

check/decomp.tsv: invoke ucdssv.awk check/decomp.awk ucd/data/UnicodeData.txt
	$(SHELL) ./invoke -o $@ -d ucd/data -- \
	$(AWK) -f ucdssv.awk -f check/decomp.awk \
	ucd/data/UnicodeData.txt
ucd/data/UnicodeData.txt:
maintainer-clean: maintainer-clean-check-decomp
maintainer-clean-check-decomp: ; test -d ucd/data && rm -f check/decomp.tsv

check: check-isualp
check-isualp: check/isualp check/isualp.tsv
	check/isualp | cmp check/isualp.tsv -
check/isualp: check/isualp.o libuc.a
	$(CC) $(LDFLAGS) -o $@ check/isualp.o libuc.a $(LOADLIBES) $(LDLIBS)
check/isualp.o: include/uc_cnf.h include/uctype.h
clean: clean-check-isualp
clean-check-isualp: ; rm -f check/isualp check/isualp.o

check/isualp.tsv: invoke ucdssv.awk check/isualp.awk ucd/data/DerivedCoreProperties.txt
	$(SHELL) ./invoke -o $@ -d ucd/data -- \
	$(AWK) -f ucdssv.awk -f check/isualp.awk \
	ucd/data/DerivedCoreProperties.txt
ucd/data/DerivedCoreProperties.txt:
maintainer-clean: maintainer-clean-check-isualp
maintainer-clean-check-isualp: ; test -d ucd/data && rm -f check/isualp.tsv

check: check-mincat
check-mincat: check/mincat check/mincat.tsv
	check/mincat | cmp check/mincat.tsv -
check/mincat: check/mincat.o libuc.a
	$(CC) $(LDFLAGS) -o $@ check/mincat.o libuc.a $(LOADLIBES) $(LDLIBS)
check/mincat.o: include/uc_cnf.h include/uctype.h
clean: clean-check-mincat
clean-check-mincat: ; rm -f check/mincat check/mincat.o

check/mincat.tsv: invoke ucdssv.awk check/mincat.awk ucd/data/UnicodeData.txt
	$(SHELL) ./invoke -o $@ -d ucd/data -- \
	$(AWK) -f ucdssv.awk -f check/mincat.awk \
	ucd/data/UnicodeData.txt
ucd/data/UnicodeData.txt:
maintainer-clean: maintainer-clean-check-mincat
maintainer-clean-check-mincat: ; test -d ucd/data && rm -f check/mincat.tsv
