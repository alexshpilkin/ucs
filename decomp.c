#include "uc_cnf.h"
#include "uccomp.h"

#include <stddef.h>

/* FIXME WET, does not NULL-terminate */
int decomp(uint_least32_t *uc_restrict s, size_t n, uint_least32_t uc) {
	const unsigned i = uc >> uc_dc_shift1,
	               j = uc >> uc_dc_shift2 & uc_dc_mask1,
	               k = uc                 & uc_dc_mask2;
	if unlikely(i >= sizeof uc_dci / sizeof uc_dci[0]) {
identity:
		if (n) { *s = uc; } return 1;
	} else if (0xAC00 <= uc && uc < 0xAC00 + 19 * 21 * 28) {
		const unsigned sy = uc - 0xAC00,
		               lv = sy / 28, t = sy % 28,
		               l  = lv / 21, v = lv % 21,
		               m  = 2 + !!t;
		switch (m > n ? n : m) {
		case 3:  s[2] = 0x11A7 + t; uc_fallthrough;
		case 2:  s[1] = 0x1161 + v; uc_fallthrough;
		case 1:  s[0] = 0x1100 + l; uc_fallthrough;
		case 0:  return m;
		default: uc_unreachable;
		}
	} else {
		unsigned x = uc_dci[i], y, z, m;
		uc_static_assert((uc_dc_mask1 + 1) / (uc_dc_mask2 + 1) == 2);
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
			switch (m > n ? n : m) {
			case 3:  s[2] = t[2]; uc_fallthrough;
			case 2:  s[1] = t[1]; uc_fallthrough;
			case 1:  s[0] = t[0]; uc_fallthrough;
			case 0:  return m;
			default: uc_unreachable;
			}
		} else {
			unsigned m = 0, r = uc_dcs[z-1] - UC_BMPTOP;
			do {
				/* int may be less than 32 bits */
				uc = (uint_least32_t)uc_dcl[r][0] << 16 |
				     uc_dcl[r][1] << 8 | uc_dcl[r][2];
				r++; if (m++ < n) *s++ = uc & 0x7FFFFF;
			} while (!(uc & 0x800000));
			return m;
		}
	}
}
