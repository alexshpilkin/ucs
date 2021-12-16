#include "uc_cnf.h"
#include "uctype.h"

#include <stddef.h>

/* FIXME keep in sync with mincat_t */

int strfromcat(char *uc_restrict s, size_t n, mincat_t c) {
	static const char name[PCTOTH+1] =
		"n"  "u"  "n"  "d"  "c"  "m"  "s"  "\0"
		"c"  "l"  "c"  "l"  "d"  "c"  "l"  "\0"
		"f"  "t"  "e"  "o"  "s"  "k"  "p"  "\0"
		"s"  "m"  "\0" "\0" "e"  "o"  "\0" "\0"
		"o"  "o"  "\0" "\0" "i"  "C"  "L"  "M"
		"N"  "P"  "S"  "Z"  "f"  "\0" "\0" "\0"
		"\0" "\0" "\0" "\0" "o";

	switch (n) {
	default: s[2] = '\0'; uc_fallthrough;
	case 2:  s[1] = name[c]; uc_fallthrough;
	case 1:  s[0] = (name + PCTINI + 1)[c & MAJCAT]; uc_fallthrough;
	case 0:  return 2;
	}
}

enum {
	Cn = OTHUNA, Cc = OTHCTL, Cf = OTHFMT, Cs = OTHSUR, Co = OTHPRI,
	Lu = LETUPR, Ll = LETLWR, Lt = LETTTL, Lm = LETMOD, Lo = LETOTH,
	Mn = MRKNON, Mc = MRKSPC, Me = MRKENC,
	Nd = NUMDEC, Nl = NUMLET, No = NUMOTH,
	Pc = PCTCON, Pd = PCTDSH, Ps = PCTOPN, Pe = PCTCLO, Pi = PCTINI,
	Pf = PCTFIN, Po = PCTOTH,
	Sm = SYMMTH, Sc = SYMCUR, Sk = SYMMOD, So = SYMOTH,
	Zs = SEPSPC, Zl = SEPLIN, Zp = SEPPAR
};
#define UC_XDIGIT_(X) (UC_XDIGIT | (UINT32_C(X) << UC_DIGIT_SHIFT))
#include "uc_ty.g"

uc_const uint_least32_t uc_ty(uint_least32_t uc) {
	const unsigned i =  uc >> 12, /* FIXME */
	               j = (uc >>  6) & 63,
	               k =  uc        & 63;
	if unlikely(i >= sizeof uc_tyi / sizeof uc_tyi[0]) {
		return 0;
	} else {
		unsigned p = uc_tyi[i], q, r, s;
		q = uc_tyb[p] + UC_RANK64(uc_tym[p], j);
		r = uc_tyb[q] + UC_RANK64(uc_tym[q], k);
		s = uc_tyr[r];
		return uc_tyv[(s >> 1) ^ (uc & s & 1)];
	}
}
