#include "uc_cnf.h"
#include "uctype.h"

/* FIXME duplicate of uc_ty() */
uc_const uint_least32_t uc_qc(uint_least32_t uc) {
	const unsigned i = uc >> uc_qc_shift1,
	               j = uc >> uc_qc_shift2 & uc_qc_mask1,
	               k = uc                 & uc_qc_mask2;
	if unlikely(i >= sizeof uc_qci / sizeof uc_qci[0]) {
		return 0;
	} else {
		unsigned x = uc_qci[i], y, z, w;
		y = uc_qcb[x] + UC_RANK64(uc_qcm[x], j);
		z = uc_qcb[y] + UC_RANK64(uc_qcm[y], k);
		w = uc_qcr[z];
		return uc_qcv[(w >> 1) ^ (uc & w & 1)];
	}
}
