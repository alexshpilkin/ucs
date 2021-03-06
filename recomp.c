#include "uc_cnf.h"
#include "uccomp.h"

#include <stdint.h>

#define hash(A, B, X, Y) \
	((uint_least32_t)(((A)*(X) + (B)*(Y)) & 0xFFFF) * UC_RC_SIZE >> 16)

uint_least32_t recomp(uint_least32_t fst, uint_least32_t snd) {
	if (0x1100 <= fst && fst < 0x1100 + 19) {
		unsigned l = fst - 0x1100, v;
		if (!(0x1161 <= snd && snd < 0x1161 + 21))
			return 0;
		v = snd - 0x1161;
		return 0xAC00 + (l * 21 + v) * 28;
	} else if (0xAC00 <= fst && fst < 0xAC00 + 19 * 21 * 28) {
		if ((unsigned)(fst - 0xAC00) % 28)
			return 0;
		/* TBASE itself is not a valid T */
		if (!(0x11A7 < snd && snd < 0x11A7 + 28))
			return 0;
		return fst + (unsigned)(snd - 0x11A7);
	} else {
		uint_least32_t u; unsigned i, j, k, x, y, z, m;
		uc_static_assert((UC_DC_MASK1 + 1) / (UC_DC_MASK2 + 1) == 2);

		if ((fst | snd) & ~(uint_least32_t)0x33FFF)
			return 0;
		x = (fst & 0x3FFF) | (fst & 0x30000) >> 2;
		y = (snd & 0x3FFF) | (snd & 0x30000) >> 2;

		u = uc_rch[hash(UC_RC_A1, UC_RC_B1, x, y)]
		  ^ uc_rch[hash(UC_RC_A2, UC_RC_B2, x, y) +   UC_RC_SIZE]
		  ^ uc_rch[hash(UC_RC_A3, UC_RC_B3, x, y) + 2*UC_RC_SIZE];
		if (u >> 16 != x) return 0;
		u = (u & 0x3FFF) | (u << 2 & 0x30000);

		/* FIXME Almost but not quite the same as decomp() */

		i = u >> UC_DC_SHIFT1;
		j = u >> UC_DC_SHIFT2 & UC_DC_MASK1;
		k = u                 & UC_DC_MASK2;

		if (i >= sizeof uc_dci / sizeof uc_dci[0])
			return 0;

		x = uc_dci[i];
		y = uc_dcb[x] + UC_RANK64(uc_dcm[x], j);
		m = UC_FLAG32(UC_HI32(uc_dcm[y]), k) * 2 +
		    UC_FLAG32(UC_LO32(uc_dcm[y]), k);
		if (!m) return 0;
		z = uc_dcb[y] +
		    UC_RANK32(UC_HI32(uc_dcm[y]), k) * 2 +
		    UC_RANK32(UC_LO32(uc_dcm[y]), k);
		if (uc_dcs[z-1] < UC_BMPTOP) {
			if (uc_dcs[z-1] != snd) return 0;
		} else {
			uint_least32_t v; unsigned r = uc_dcs[z-1] - UC_BMPTOP;
			do {
				v = (uint_least32_t)uc_dcl[r][0] << 16 |
				    (uint_least32_t)uc_dcl[r][1] <<  8 |
				    uc_dcl[r][2];
				r++;
			} while (!(v & 0x800000));
			if ((v & 0x7FFFFF) != snd) return 0;
		}

		if (!u) uc_unreachable; /* NUL is not decomposable */
		return u;
	}
}
