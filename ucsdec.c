#include "ucnorm.h"

#include <stddef.h>
#include <string.h>

/* These functions assume that the canonical decomposition of every character
   has zero or more starters followed by zero or more non-starters sorted by
   canonical combining class, that is, only the last combining character
   sequence has any non-starters. This does not seem to be guaranteed by the
   Unicode standard, but it is currently true. They also assume that NUL has the
   default decomposition mapping (identity) and canonical combining class (0),
   and the stability policy does guarantee this will remain true going forward.
   Both of these assumptions are checked by the generator in uc_dcm.awk. */

static int slowpath(uint_least32_t *uc_restrict *uc_restrict pdst,
                    size_t *uc_restrict pdn,
                    const uint_least32_t *uc_restrict *uc_restrict psrc,
                    size_t *uc_restrict psn)
{
	const uint_least32_t *uc_restrict src = *psrc; size_t sn = *psn;
	uint_least32_t *const uc_restrict dst = *pdst; const size_t dn = *pdn;
	size_t n;

	/* The obvious linear-time approach here would be a counting sort of
	   combining classes, but then both the initialization and the
	   cumulative sum would take UC_CLASSES time regardless of how many
	   classes there actually are (and there are usually only a couple).
	   So don't initialize the arrays and maintain a parallel sorted array
	   of classes we encountered, for a much slower but still constant-time
	   worst case (UC_CLASSES^2) but hopefully faster common case. */

	size_t size, base[UC_CLASSES];
	unsigned char k, count, order[UC_CLASSES];

	uint_least32_t cd[DECOMP_MAX];
	unsigned j, m; unsigned char cc;

	n = count = 0;

	m = decomp(cd, sizeof cd / sizeof cd[0], src[0]);
	for (j = size = base[0] = 0; j < m; j++, size++) {
		if ((cc = uc_tcc(cd[j])))
			goto nonstarter;
		if (size >= dn) { /* FIXME common exit? */
			/* no source characters were fully consumed */
			if (dst) *pdst = dst + dn;
			*pdn = 0; return U2BIG;
		}
		if (dst) dst[size] = cd[j];
	}

	/* decomposition of the first character contained only starters */
	src++; sn--;

	for (;; n++) {
		if (n >= sn) { /* FIXME common exit? */
			*psrc = src; *psn = sn;
			if (dst) *pdst = dst + size;
			*pdn = dn - size; return UMORE;
		}
		m = decomp(cd, sizeof cd / sizeof cd[0], src[n]);
		if (!(cc = uc_tcc(cd[0]))) break;
		j = 0;

nonstarter:

		/* This is silly but seems to be necessary if we are to abide by
		   the contract precisely: nonstarters of class 1 (Overlay) can
		   (and so must) be written out immediately.  The approach here
		   assumes that the only decompositions they can participate in
		   are singleton and starter-nonstarter ones.  This is not
		   guaranteed by the Unicode standard, but it is currently true
		   and checked by the generator in uc_dcm.awk. */

		if (cc == 1) {
			if (size >= dn) { /* FIXME common exit? */
				*psrc = src; *psn = sn;
				if (dst) *pdst = dst + dn;
				*pdn = 0; return U2BIG;
			}
			if (dst) dst[size] = cd[j];
			size++;
			if (!count) { src++; n--; sn--; }
			continue;
		}

		/* FIXME most of this is unnecessary when dst == NULL */
		for (;;) {
			for (k = count; k > 0 && order[k-1] > cc; k--)
				continue;
			if (k > 0 && order[k-1] == cc) {
				if unlikely((base[cc] += 1) < 1) base[cc] = -1;
			} else {
				base[cc] = 1; count++;
				for (; k < count; k++) {
					unsigned char tmp = order[k];
					order[k] = cc; cc = tmp;
				}
			}

			if (++j >= m) break;
			cc = uc_tcc(cd[j]);
		}
	}

	for (k = 0; k < count; k++) {
		size_t tmp = base[order[k]];
		base[order[k]] = size;
		if unlikely((size += tmp) < tmp) size = -1;
	}

	if (dst) {
		size_t i;
		/* starters and class-1 nonstarters are already written out */
		base[0] = base[1] = dn;

		for (i = 0; i < n; i++) {
			m = decomp(cd, sizeof cd / sizeof cd[0], src[i]);
			for (j = 0; j < m; j++) {
				cc = uc_tcc(cd[j]);
				/* base[cc] < dn <= SIZE_MAX */
				if (base[cc] < dn) dst[base[cc]++] = cd[j];
			}
		}
	}

	if (size <= dn) {
		*psrc = src + n; *psn = sn - n;
		if (dst) *pdst = dst + size;
		*pdn = dn - size; return 1;
	} else {
		*psrc = src; *psn = sn;
		if (dst) *pdst = dst + dn;
		*pdn = 0; return U2BIG;
	}
}

/* FIXME state */
/* FIXME return consumed not remaining */
ucerr_t ucsdec(uint_least32_t *uc_restrict dst,
               size_t *uc_restrict pdn,
               const uint_least32_t *uc_restrict src,
               size_t *uc_restrict psn)
{
	size_t sn = psn ? *psn : -1, dn = *pdn;

	for (;;) {
		int ret; size_t k, n; unsigned char tcc;

		for (k = n = tcc = 0;;) {
			uint_least32_t u, qc; unsigned char lcc;

			if (n >= sn) { ret = UMORE; break; }
			qc = uc_qc(u = src[n++]);
			lcc = qc >> UC_LCC_SHIFT & UC_CMBCLS;

			/* FIXME can look at more input than necessary */
			if ((lcc && tcc > lcc) || (qc & UC_DQN)) {
				if (!lcc) {
					if (n > dn) { k = dn; ret = U2BIG; break; }
					k = n - 1; /* commit before starter */
				}
				ret = 1; break; /* slowpath */
			}
			if (lcc <= 1) {
				if (n > dn) { k = dn; ret = U2BIG; break; }
				k = n; /* commit ccc <= 1 */
				if (!u) { ret = UDONE; break; }
			}
			tcc = qc >> UC_TCC_SHIFT & UC_CMBCLS;
		}

		if (dst) {
			/* k <= min(sn, sizeof src) <= SIZE_MAX / sizeof *src */
			memcpy(dst, src, k * sizeof *src); dst += k;
		}
		dn -= k; src += k; sn -= k;
		if (ret <= 0 || (ret = slowpath(&dst, &dn, &src, &sn)) <= 0) {
			*pdn = dn; if (psn) *psn = sn; return (ucerr_t)ret;
		}
	}
}
