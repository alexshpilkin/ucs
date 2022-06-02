AWK = awk
INSTALL = install

ARFLAGS  = -cr
CPPFLAGS = -std=c89 -Wall -Wimplicit-fallthrough -pedantic -U_FORTIFY_SOURCE
CFLAGS   = -fno-asynchronous-unwind-tables -fno-ident -fomit-frame-pointer \
           -fno-stack-protector -O2
MFLAGS   = AWK="$(AWK)" CPPFLAGS="$(CPPFLAGS)" CFLAGS="$(CFLAGS)" LDFLAGS="$(LDFLAGS)"

.c.o:
	$(CC) -I include $(CPPFLAGS) $(CFLAGS) -c -o $@ $<

all install clean force: ;
maintainer-clean: clean ;

boiler.mk: boiler.awk boiler.in
	$(AWK) -f boiler.awk boiler.in > $@
check: all boiler.mk
	$(MAKE) $(MFLAGS) -f boiler.mk
clean: clean-boiler
clean-boiler: boiler.mk
	$(MAKE) $(MFLAGS) -f boiler.mk clean
maintainer-clean: maintainer-clean-boiler
maintainer-clean-boiler: boiler.mk
	$(MAKE) $(MFLAGS) -f boiler.mk maintainer-clean
	rm -f boiler.mk

OBJECTS_UC = decomp.o recomp.o uc_dcm.o uc_gcn.o uc_p32.o uc_p64.o uc_qc.o uc_qcm.o uc_rch.o uc_ty.o uc_tym.o ucsdec.o
INCLUDES_UC = include/uc_cnf.h include/ucnorm.h include/uctype.h
all: libuc.a
libuc.a: $(OBJECTS_UC)
	$(AR) $(ARFLAGS) $@ $(OBJECTS_UC)
	if [ "$(RANLIB)" ]; then $(RANLIB) $@; fi
$(OBJECTS_UC): include/uc_cnf.h
decomp.o recomp.o uc_dcm.o uc_qc.o uc_qcm.o uc_rch.o ucsdec.o: include/ucnorm.h
uc_gcn.o uc_ty.o uc_tym.o: include/uctype.h
uc_dcm.o: uc_dcm.g
uc_dcm.g: boiler.mk force ; $(MAKE) $(MFLAGS) -f boiler.mk $@
uc_rch.o: uc_rch.g
uc_rch.g: boiler.mk force ; $(MAKE) $(MFLAGS) -f boiler.mk $@
uc_tym.o: uc_tym.g
uc_tym.g: boiler.mk force ; $(MAKE) $(MFLAGS) -f boiler.mk $@
uc_qcm.o: uc_qcm.g
uc_qcm.g: boiler.mk force ; $(MAKE) $(MFLAGS) -f boiler.mk $@
install: install-libuc
install-libuc: $(INCLUDES_UC) libuc.a
	$(INSTALL) -d $(DESTDIR)$(prefix)/include/
	$(INSTALL) -m 0644 $(INCLUDES_UC) $(DESTDIR)$(prefix)/include/
	$(INSTALL) -d $(DESTDIR)$(prefix)/lib/
	$(INSTALL) -m 0644 libuc.a $(DESTDIR)$(prefix)/lib/
clean: clean-libuc
clean-libuc: ; rm -f libuc.a $(OBJECTS_UC)
