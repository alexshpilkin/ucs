#include "uc_cnf.h"
#include "ucnorm.h"

/* FIXME duplicate of uc_ty() */
uc_const uint_least32_t uc_qc(uint_least32_t uc) {
	const unsigned i = uc >> UC_QC_SHIFT1,
	               j = uc >> UC_QC_SHIFT2 & UC_QC_MASK1,
	               k = uc                 & UC_QC_MASK2;
	if unlikely(i >= sizeof uc_qci / sizeof uc_qci[0]) {
		return UC_QC_NEUTRAL;
	} else {
		unsigned x = uc_qci[i], y, z;
		y = uc_qcb[x] + UC_RANK64(uc_qcm[x], j);
		z = uc_qcb[y] + UC_RANK64(uc_qcm[y], k);
		return uc_qcv[uc_qcr[z]];
	}
}
