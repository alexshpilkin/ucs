#include "uc_cnf.h"
#include "uccomp.h"

#include <stddef.h>

/* FIXME WET, does not NULL-terminate */
int decomp(uint_least32_t *uc_restrict s, size_t n, uint_least32_t uc) {
	const unsigned i =  uc >> 11, /* FIXME */
	               j = (uc >>  5) & 63,
	               k =  uc        & 31;
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
		unsigned x = uc_dci[i], y, z, m; uint_least32_t a, b;
		y = uc_dcb[x] + UC_RANK64(uc_dcm[x], j);
		a = UC_HI32(uc_dcm[y]) >> (31-k); /* FIXME UC_RANK32 ? */
		b = UC_LO32(uc_dcm[y]) >> (31-k);
		m = (a & 1) * 2 + (b & 1);
		if unlikely(!m)
			goto identity;
		z = uc_dcb[y] + UC_P32(a >> 1) * 2 + UC_P32(b >> 1);
		if (uc_dcs[z] < 0xD800) {
			switch (m > n ? n : m) { /* FIXME BITS-dependent */
			case 3:  s[2] = uc_dcs[z+2]; uc_fallthrough;
			case 2:  s[1] = uc_dcs[z+1]; uc_fallthrough;
			case 1:  s[0] = uc_dcs[z];   uc_fallthrough;
			case 0:  return m;
			default: uc_unreachable;
			}
		} else {
			unsigned m = 0, r = uc_dcs[z] - 0xD800;
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
