#include "ucnorm.h"

#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "uctype.h"

#define countof(A) (sizeof(A) / sizeof *(A))

static int umemcmp(const uint_least32_t *p, const uint_least32_t *q, size_t n) {
	while (n--) {
		uint_least32_t a = *p++, b = *q++;
		if (a < b) return -1;
		if (a > b) return  1;
	}
	return 0;
}

static void umemmove(uint_least32_t *uc_restrict dst,
                    const uint_least32_t *uc_restrict src,
                    size_t n)
{
	memmove(dst, src, n * sizeof *src);
}

static void die_(const char *file, int line) {
	fprintf(stderr,
	        "%s:%d: $Id$\n",
	        file, line);
	abort();
}

#define die() die_(__FILE__, __LINE__)

static void clear(uint_least32_t *uc_restrict p, size_t n) {
	while (n--) *p++ = -1; /* not a valid Unicode character */
}

static int empty(const uint_least32_t *p, size_t n) {
	while (n--) if (*p++ != -1) return 0;
	return 1;
}

static void line(void) {

	/* help ASan and Valgrind by using a separate buffer for each length */
#define SZ(X) \
	X( 1) X( 2) X( 3) X( 4) X( 5) X( 6) X( 7) X( 8) \
	X( 9) X(10) X(11) X(12) X(13) X(14) X(15) X(16) \
	X(17) X(18) X(19) X(20) X(21) X(22) X(23) X(24) \
	X(25) X(26) X(27) X(28) X(29) X(30) X(31) X(32) \
	/* SZ */
#define DECL(N) uint_least32_t src##N[N], dst##N[N];
	SZ(DECL)
#define ITEM(N) 0, /* to determine the size automatically */
	uint_least32_t *srcs[] = { SZ(ITEM) }, *dsts[] = { SZ(ITEM) };
	uint_least32_t ref[countof(dsts)];
	uint_least32_t *src;
	size_t n = 0, srcn, oldn, refn, i;

#define INIT(N) srcs[N-1] = src##N, dsts[N-1] = dst##N;
	SZ(INIT)

	src = srcs[countof(srcs)-1];
	do {
		if (scanf("%" SCNxLEAST32, &src[n++]) != 1)
			exit(ferror(stdin) ? EXIT_FAILURE : 0);
		if (n >= countof(srcs) - 1) die(); /* too long */
	} while (fgetc(stdin) == ' ');
	(void)!scanf("%*[^\n]"); /* skip reference output */

	for (i = 0; i < n; i++) {
		if (!src[i]) die();
		printf("%s%.4" PRIXLEAST32, i ? " " : "", src[i]);
	}

	src[n++] = 0;

	oldn = countof(dsts);
	for (srcn = n; srcn; srcn--) {
		uint_least32_t *dst; size_t dstn; size_t srcm;

		umemmove(src = srcs[srcn-1], srcs[countof(srcs)-1], srcn);
		clear(dst = dsts[countof(dsts)-1], countof(dsts));
		dstn = countof(dsts); srcm = srcn;
		ucsdec(dst, &dstn, src, &srcm);
		/* must fit into output buffer */
		if (dstn == countof(dsts)) die();
		/* must not touch unused output space */
		if (!empty(dst + dstn, countof(dsts) - dstn)) die();
		/* save reference result on first iteration */
		if (srcn == n) umemmove(ref, dst, refn = dstn);
		/* must reproduce final null */
		if (dstn == refn && dst[dstn-1]) die();
		/* must become shorter with less input */
		if (oldn < dstn) die();
		oldn = dstn;

		if (srcm < n) {
			uint_least32_t t, *shortsrc, *shortdst;
			size_t shortsrcm, shortdstm;

			/* Try appending a null to the consumed part */

			shortsrc = srcs[srcm];
			umemmove(shortsrc, srcs[countof(srcs)-1], srcm + 1);

			/* temporarily null-terminate */
			t = shortsrc[srcm]; shortsrc[srcm] = 0;

			shortdst = dsts[countof(dsts)-1];
			shortsrcm = srcm + 1; shortdstm = countof(dsts);
			ucsdec(shortdst, &shortdstm, shortsrc, &shortsrcm);
			/* must consume all input */
			if (shortsrcm != srcm + 1) die();
			/* must reproduce final null */
			if (!shortdstm || shortdst[shortdstm-1]) die();
			/* must produce at least as much as after
                           truncation as after null-termination */
			if (shortdstm > dstn + 1 /* the null */) die();
			/* and the overlapping part must match */
			if (umemcmp(shortdst, dst, shortdstm)) die();

			/* restore original data */
			shortsrc[srcm] = t;
		}

		if (srcm < srcn && srcn + 2 <= countof(srcs)) {
			uint_least32_t s, t, x, *modsrc, *moddst;
			size_t modsrcm, moddstm;
			int changed = 0;

			if (dstn + 1 > countof(dsts)) die();

			/* Try appending a character and then null */

			modsrc = srcs[srcn + 1];
			umemmove(modsrc, srcs[countof(srcs)-1], srcn + 1);

			/* save original data and null-terminate */
			s = modsrc[srcn];
			t = modsrc[srcn+1]; modsrc[srcn+1] = 0;

			for (x = 1; x <= UNIMAX; x++) {
				/* try appending every possible character */
				if (majcat(x) == OTH) continue;
				modsrc[srcn] = x;

				moddst = dsts[countof(dsts)-1];
				modsrcm = srcn + 2; moddstm = countof(dsts);
				ucsdec(moddst, &moddstm, modsrc, &modsrcm);
				/* must consume all input */
				if (modsrcm != srcn + 2) die();
				/* must produce at least the partial output */
				if (moddstm < dstn + 1 /* the null */) die();
				/* and match it */
				if (umemcmp(moddst, ref, dstn)) die();
				/* but not the rest, for some x at least */
				if (moddst[dstn] != ref[dstn]) changed = 1;
			}

			if (!changed) die();

			/* restore original data */
			modsrc[srcn] = s; modsrc[srcn+1] = t;
		}

		/* Try passing less output space than required */

		for (; dstn; dstn--) {
			size_t dstm = dstn; srcm = srcn;
			ucsdec(dst = dsts[dstm-1], &dstm, src, &srcm);
			/* must fill all available output space */
			if (dstm != dstn) die();
			/* must match the reference result */
			if (umemcmp(dst, ref, dstn)) die();
		}
	}

	for (i = 0; i < refn - 1; i++)
		printf("%c%.4" PRIXLEAST32, i ? ' ' : '\t', ref[i]);
	fputc('\n', stdout);
}

int main(void) {
	for (;;) line(); /* will exit() when done */
}
