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

static int slowpath(uint_least32_t *uc_restrict dst,
                    size_t *uc_restrict pdn,
                    const uint_least32_t *uc_restrict src,
                    size_t *uc_restrict psn)
{
	size_t sn = *psn, dn = *pdn;
	size_t s0 = 0, sm = 0, dm = 0;

	/* The obvious linear-time approach here would be a counting sort of
	   combining classes, but then both the initialization and the
	   cumulative sum would take UC_CLASSES time regardless of how many
	   classes there actually are (and there are usually only a couple).
	   So don't initialize the arrays and maintain a parallel sorted array
	   of classes we encountered, for a much slower but still constant-time
	   worst case (UC_CLASSES^2) but hopefully faster common case. */

	size_t base[UC_CLASSES];
	unsigned char k, count, order[UC_CLASSES];

	uint_least32_t cd[DECOMP_MAX];
	unsigned j, m; unsigned char cc;

	count = 0;

	m = decomp(cd, sizeof cd / sizeof cd[0], src[0]);
	for (j = 0; j < m; j++, dm++) {
		if ((cc = uc_tcc(cd[j]))) goto nonstarter;
		if (dm >= dn) { *psn = 0; return -1; }
		if (dst) dst[dm] = cd[j];
	}

	/* decomposition of the first character contained only starters */
	s0 = sm = 1;

	for (;; sm++) {
		if (sm >= sn) { *psn = s0; *pdn = dm; return -1; }
		m = decomp(cd, sizeof cd / sizeof cd[0], src[sm]);
		if (!(cc = uc_tcc(cd[j = 0]))) break;

nonstarter:

		/* This is silly but seems to be necessary if we are to abide by
		   the contract precisely: nonstarters of class 1 (Overlay) can
		   (and so must) be written out immediately.  The approach here
		   assumes that the only decompositions they can participate in
		   are singleton and starter-nonstarter ones.  This is not
		   guaranteed by the Unicode standard, but it is currently true
		   and checked by the generator in uc_dcm.awk. */

		if (cc == 1) {
			if (dm >= dn) { *psn = s0; return -1; }
			if (dst) dst[dm] = cd[j];
			dm++;
			if (!count) s0++;
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
		base[order[k]] = dm;
		if unlikely((dm += tmp) < tmp) dm = -1;
	}

	if (dst) {
		size_t i;
		/* starters and class-1 nonstarters are already written out */
		base[0] = base[1] = dn;

		for (i = s0; i < sm; i++) {
			m = decomp(cd, sizeof cd / sizeof cd[0], src[i]);
			for (j = 0; j < m; j++) {
				cc = uc_tcc(cd[j]);
				/* base[cc] < dn <= SIZE_MAX */
				if (base[cc] < dn) dst[base[cc]++] = cd[j];
			}
		}
	}

	if (dm <= dn) {
		*psn = sm; *pdn = dm; return 0;
	} else {
		*psn = s0; return -1;
	}
}

/* FIXME state */
void ucsdec(uint_least32_t *uc_restrict dst,
            size_t *uc_restrict pdn,
            const uint_least32_t *uc_restrict src,
            size_t *uc_restrict psn)
{
	size_t sn = psn ? *psn : -1, dn = pdn ? *pdn : -1;
	size_t sm = 0, dm = 0;

	for (;;) {
		size_t i, k, n;
		unsigned tcc = 0;

		n = sn - sm <= dn - dm ? sn : sm + (dn - dm);
		for (i = k = sm; i < n; i++) {
			uint_least32_t u = src[i], qc = uc_qc(u);
			if likely(qc & UC_STARTER) k = i;
			if ((tcc | UC_DQY) > (qc & (UC_LCC | UC_DQY))) break;
			tcc = qc >> UC_TCC_SHIFT;
			if unlikely(!u) { sn = k = i + 1; break; }
		}

		if (dst) memcpy(dst + dm, src + sm, (k - sm) * sizeof *src);
		dm += k - sm; sm = k;

		if (sm < sn && dm < dn) {
			int r; size_t j = dn - dm; k = sn - sm;
			r = slowpath(dst + dm, &j, src + sm, &k);
			dm += j; sm += k;
			if (r < 0) break;
		}

		if (sm == sn || dm == dn) break;
	}

	if (psn) *psn = sm;
	if (pdn) *pdn = dm;
}
