#include "uc_cnf.h"
#include "ucnorm.h"

#include <stddef.h>

/* FIXME similar to uc_ty() */
/* does not NUL-terminate */
size_t decomp(uint_least32_t *uc_restrict s, size_t n, uint_least32_t uc) {
	const unsigned i = uc >> UC_DC_SHIFT1,
	               j = uc >> UC_DC_SHIFT2 & UC_DC_MASK1,
	               k = uc                 & UC_DC_MASK2;
	if unlikely(i >= sizeof uc_dci / sizeof uc_dci[0]) {
identity:
		if (n) { *s = uc; } return 1;
	} else if (0xAC00 <= uc && uc < 0xAC00 + 19 * 21 * 28) {
		const unsigned sy = uc - 0xAC00,
		               lv = sy / 28, t = sy % 28,
		               l  = lv / 21, v = lv % 21,
		               m  = 2 + !!t;
		switch (m <= n ? m : n) {
		case 3:  s[2] = 0x11A7 + t; uc_fallthrough;
		case 2:  s[1] = 0x1161 + v; uc_fallthrough;
		case 1:  s[0] = 0x1100 + l; uc_fallthrough;
		case 0:  return m;
		default: uc_unreachable;
		}
	} else {
		unsigned x = uc_dci[i], y, z, m;
		uc_static_assert((UC_DC_MASK1 + 1) / (UC_DC_MASK2 + 1) == 2);
		y = uc_dcb[x] + UC_RANK64(uc_dcm[x], j);
		m = UC_FLAG32(UC_HI32(uc_dcm[y]), k) * 2 +
		    UC_FLAG32(UC_LO32(uc_dcm[y]), k);
		if unlikely(!m)
			goto identity;
		z = uc_dcb[y] +
		    UC_RANK32(UC_HI32(uc_dcm[y]), k) * 2 +
		    UC_RANK32(UC_LO32(uc_dcm[y]), k);
		if (uc_dcs[z-1] < UC_BMPTOP) {
			const uint_least16_t *t = &uc_dcs[z-m];
			switch (m <= n ? m : n) {
			case 3:  s[2] = t[2]; uc_fallthrough;
			case 2:  s[1] = t[1]; uc_fallthrough;
			case 1:  s[0] = t[0]; uc_fallthrough;
			case 0:  return m;
			default: uc_unreachable;
			}
		} else {
			unsigned r = uc_dcs[z-1] - UC_BMPTOP; m = 0;
			do {
				uc = (uint_least32_t)uc_dcl[r][0] << 16 |
				     (uint_least32_t)uc_dcl[r][1] <<  8 |
				     uc_dcl[r][2];
				r++; if (m++ < n) *s++ = uc & 0x7FFFFF;
			} while (!(uc & 0x800000));
			return m;
		}
	}
}
