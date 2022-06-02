#include "uc_cnf.h"
#include "uctype.h"

uc_const uint_least32_t uc_ty(uint_least32_t uc) {
	const unsigned i = uc >> UC_TY_SHIFT1,
	               j = uc >> UC_TY_SHIFT2 & UC_TY_MASK1,
	               k = uc                 & UC_TY_MASK2;
	if unlikely(i >= sizeof uc_tyi / sizeof uc_tyi[0]) {
		return UC_TY_NEUTRAL;
	} else {
		unsigned x = uc_tyi[i], y, z, w;
		y = uc_tyb[x] + UC_RANK64(uc_tym[x], j);
		z = uc_tyb[y] + UC_RANK64(uc_tym[y], k);
		w = uc_tyr[z];
		return uc_tyv[(w >> 1) ^ (uc & w & 1)];
	}
}
