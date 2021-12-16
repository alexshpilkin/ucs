#include "uc_cnf.h"
#include "uctype.h"

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
