#include "uc_cnf.h"
#include "uctype.h"

uc_const uint_least32_t uc_ty(uint_least32_t uc) {
	const unsigned i =  uc >> 12, /* FIXME */
	               j = (uc >>  6) & 63,
	               k =  uc        & 63;
	if unlikely(i >= sizeof uc_tyi / sizeof uc_tyi[0]) {
		return 0;
	} else {
		unsigned x = uc_tyi[i], y, z, w;
		y = uc_tyb[x] + UC_RANK64(uc_tym[x], j);
		z = uc_tyb[y] + UC_RANK64(uc_tym[y], k);
		w = uc_tyr[z];
		return uc_tyv[(w >> 1) ^ (uc & w & 1)];
	}
}
