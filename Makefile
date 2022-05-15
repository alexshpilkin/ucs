AWK = awk
INSTALL = install

ARFLAGS  = -cr
CPPFLAGS = -std=c89 -Wall -Wimplicit-fallthrough -pedantic -U_FORTIFY_SOURCE
CFLAGS   = -fno-asynchronous-unwind-tables -fno-ident -fomit-frame-pointer \
           -fno-stack-protector -O2

.c.o:
	$(CC) -I include $(CPPFLAGS) $(CFLAGS) -c -o $@ $<

all check install clean: ;
maintainer-clean: clean ;

OBJECTS_UC = decomp.o recomp.o uc_dcm.o uc_gcn.o uc_p32.o uc_p64.o uc_qc.o uc_qcm.o uc_rch.o uc_ty.o uc_tym.o
INCLUDES_UC = include/uc_cnf.h include/uccomp.h include/uctype.h
all: libuc.a
libuc.a: $(OBJECTS_UC)
	$(AR) $(ARFLAGS) $@ $(OBJECTS_UC)
	if [ "$(RANLIB)" ]; then $(RANLIB) $@; fi
$(OBJECTS_UC): include/uc_cnf.h
decomp.o recomp.o uc_dcm.o uc_rch.o uc_qc.o uc_qcm.o: include/uccomp.h
uc_gcn.o uc_ty.o uc_tym.o: include/uctype.h
uc_dcm.o: uc_dcm.g
uc_rch.o: uc_rch.g
uc_tym.o: uc_tym.g
uc_qcm.o: uc_qcm.g
install: install-libuc
install-libuc: $(INCLUDES_UC) libuc.a
	$(INSTALL) -d $(DESTDIR)$(prefix)/include/
	$(INSTALL) -m 0644 $(INCLUDES_UC) $(DESTDIR)$(prefix)/include/
	$(INSTALL) -d $(DESTDIR)$(prefix)/lib/
	$(INSTALL) -m 0644 libuc.a $(DESTDIR)$(prefix)/lib/
clean: clean-libuc
clean-libuc: ; rm -f libuc.a $(OBJECTS_UC)

SOURCES_DCM = ucd/data/UnicodeData.txt
uc_dcm.g: invoke ucdssv.awk uc_dcm.awk pctrie.awk $(SOURCES_DCM)
	$(SHELL) ./invoke -o $@ -d ucd/data \
	$(AWK) -f ucdssv.awk -f uc_dcm.awk -f pctrie.awk \
	$(SOURCES_DCM)
$(SOURCES_DCM):
maintainer-clean: maintainer-clean-uc_dcm
maintainer-clean-uc_dcm:
	$(SHELL) ./invoke -d ucd/data -- rm -f uc_dcm.g

SOURCES_QCM = ucd/data/UnicodeData.txt \
              ucd/data/extracted/DerivedCombiningClass.txt \
              ucd/data/DerivedNormalizationProps.txt
uc_qcm.g: invoke ucdssv.awk uc_qcm.awk values.awk valrun.awk pctrie.awk $(SOURCES_QCM)
	$(SHELL) ./invoke -o $@ -d ucd/data -- \
	$(AWK) -f ucdssv.awk -f uc_qcm.awk -f values.awk -f valrun.awk -f pctrie.awk \
	$(SOURCES_QCM)
$(SOURCES_QCM):
maintainer-clean: maintainer-clean-uc_qcm
maintainer-clean-uc_qcm:
	$(SHELL) ./invoke -d ucd/data -- rm -f uc_qcm.g

SOURCES_RCH = ucd/data/DerivedNormalizationProps.txt \
              ucd/data/UnicodeData.txt
uc_rch.g: invoke ucdssv.awk uc_rch.awk $(SOURCES_RCH)
	$(SHELL) ./invoke -o $@ -d ucd/data -- \
	$(AWK) -f ucdssv.awk -f uc_rch.awk \
	$(SOURCES_RCH)
$(SOURCES_RCH):
maintainer-clean: maintainer-clean-uc_rch
maintainer-clean-uc_rch:
	$(SHELL) ./invoke -d ucd/data -- rm -f uc_rch.g

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
maintainer-clean-uc_tym:
	$(SHELL) ./invoke -d ucd/data -- rm -f uc_tym.g

check: check-cmbcls
check-cmbcls: check/cmbcls.ref check/cmbcls.out
	cmp check/cmbcls.ref check/cmbcls.out
check/cmbcls.out: check/cmbcls
	check/cmbcls > $@
check/cmbcls: check/cmbcls.o uc_qc.o uc_qcm.o
	$(CC) $(LDFLAGS) -o $@ check/cmbcls.o uc_qc.o uc_qcm.o $(LOADLIBES) $(LDLIBS)
check/cmbcls.o: include/uc_cnf.h include/uccomp.h
clean: clean-check-cmbcls
clean-check-cmbcls: ; rm -f check/cmbcls.out check/cmbcls check/cmbcls.o

check/cmbcls.ref: invoke ucdssv.awk check/cmbcls.awk ucd/data/UnicodeData.txt
	$(SHELL) ./invoke -o $@ -d ucd/data -- \
	$(AWK) -f ucdssv.awk -f check/cmbcls.awk \
	ucd/data/UnicodeData.txt
ucd/data/UnicodeData.txt:
maintainer-clean: maintainer-clean-check-cmbcls
maintainer-clean-check-cmbcls:
	$(SHELL) ./invoke -d ucd/data -- rm -f check/cmbcls.ref

check: check-decomp
check-decomp: check/decomp.ref check/decomp.out
	cmp check/decomp.ref check/decomp.out
check/decomp.out: check/decomp
	check/decomp > $@
check/decomp: check/decomp.o decomp.o uc_dcm.o
	$(CC) $(LDFLAGS) -o $@ check/decomp.o decomp.o uc_dcm.o $(LOADLIBES) $(LDLIBS)
check/decomp.o: include/uc_cnf.h include/uccomp.h
clean: clean-check-decomp
clean-check-decomp: ; rm -f check/decomp.out check/decomp check/decomp.o

check/decomp.ref: invoke ucdssv.awk check/decomp.awk ucd/data/UnicodeData.txt
	$(SHELL) ./invoke -o $@ -d ucd/data -- \
	$(AWK) -f ucdssv.awk -f check/decomp.awk \
	ucd/data/UnicodeData.txt
ucd/data/UnicodeData.txt:
maintainer-clean: maintainer-clean-check-decomp
maintainer-clean-check-decomp:
	$(SHELL) ./invoke -d ucd/data -- rm -f check/decomp.ref

check: check-isualp
check-isualp: check/isualp.ref check/isualp.out
	cmp check/isualp.ref check/isualp.out
check/isualp.out: check/isualp
	check/isualp > $@
check/isualp: check/isualp.o uc_ty.o uc_tym.o
	$(CC) $(LDFLAGS) -o $@ check/isualp.o uc_ty.o uc_tym.o $(LOADLIBES) $(LDLIBS)
check/isualp.o: include/uc_cnf.h include/uctype.h
clean: clean-check-isualp
clean-check-isualp: ; rm -f check/isualp.out check/isualp check/isualp.o

check/isualp.ref: invoke ucdssv.awk check/isualp.awk ucd/data/DerivedCoreProperties.txt
	$(SHELL) ./invoke -o $@ -d ucd/data -- \
	$(AWK) -f ucdssv.awk -f check/isualp.awk \
	ucd/data/DerivedCoreProperties.txt
ucd/data/DerivedCoreProperties.txt:
maintainer-clean: maintainer-clean-check-isualp
maintainer-clean-check-isualp:
	$(SHELL) ./invoke -d ucd/data -- rm -f check/isualp.ref

check: check-mincat
check-mincat: check/mincat.ref check/mincat.out
	cmp check/mincat.ref check/mincat.out
check/mincat.out: check/mincat
	check/mincat > $@
check/mincat: check/mincat.o uc_gcn.o uc_ty.o uc_tym.o
	$(CC) $(LDFLAGS) -o $@ check/mincat.o uc_gcn.o uc_ty.o uc_tym.o $(LOADLIBES) $(LDLIBS)
check/mincat.o: include/uc_cnf.h include/uctype.h
clean: clean-check-mincat
clean-check-mincat: ; rm -f check/mincat.out check/mincat check/mincat.o

check/mincat.ref: invoke ucdssv.awk check/mincat.awk ucd/data/UnicodeData.txt
	$(SHELL) ./invoke -o $@ -d ucd/data -- \
	$(AWK) -f ucdssv.awk -f check/mincat.awk \
	ucd/data/UnicodeData.txt
ucd/data/UnicodeData.txt:
maintainer-clean: maintainer-clean-check-mincat
maintainer-clean-check-mincat:
	$(SHELL) ./invoke -d ucd/data -- rm -f check/mincat.ref

check: check-recomp
check-recomp: check/recomp.ref check/recomp.out
	cmp check/recomp.ref check/recomp.out
check/recomp.out: check/recomp
	check/recomp > $@
check/recomp: check/recomp.o recomp.o uc_dcm.o uc_rch.o
	$(CC) $(LDFLAGS) -o $@ check/recomp.o recomp.o uc_dcm.o uc_rch.o $(LOADLIBES) $(LDLIBS)
check/recomp.o: include/uc_cnf.h include/uccomp.h
clean: clean-check-recomp
clean-check-recomp: ; rm -f check/recomp.out check/recomp check/recomp.o

check/recomp.ref: invoke ucdssv.awk check/recomp.awk ucd/data/CompositionExclusions.txt ucd/data/UnicodeData.txt
	$(SHELL) ./invoke -o $@ -d ucd/data -- \
	$(AWK) -f ucdssv.awk -f check/recomp.awk \
	ucd/data/CompositionExclusions.txt ucd/data/UnicodeData.txt
ucd/data/CompositionExclusions.txt ucd/data/UnicodeData.txt:
maintainer-clean: maintainer-clean-check-recomp
maintainer-clean-check-recomp:
	$(SHELL) ./invoke -d ucd/data -- rm -f check/recomp.ref
