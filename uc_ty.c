#include <limits.h>
#include <stddef.h>
#include <stdint.h>

#if defined __clang__ && defined __has_warning
#if __has_warning("-Wshift-op-parentheses")
#pragma clang diagnostic ignored "-Wshift-op-parentheses"
#endif
#elif __GNUC__ * 100 + __GNUC_MINOR__ >= 406
#pragma GCC diagnostic ignored "-Wparentheses"
#endif

#if __STDC_VERSION__ >= 201906L /* N2385 */ && defined __has_c_attribute
#define has_attribute __has_c_attribute
#elif __cplusplus >= 201103L
#if defined __has_cpp_attribute
#define has_attribute __has_cpp_attribute
#else
#define has_attribute(X) has_attribute_##X
#define has_attribute_fallthrough (__cplusplus >= 201603L)
#define has_attribute_unlikely (__cplusplus >= 201803L)
#endif
#else
#define has_attribute(X) 0
#endif

#ifndef has_gnu_attribute
#if defined __has_attribute
#define has_gnu_attribute __has_attribute
#elif __GNUC__ >= 2
#define has_gnu_attribute has_gnu_attribute_##X
#define has_gnu_attribute_const (__GNUC__ * 100 + __GNUC_MINOR__ >= 205)
#define has_gnu_attribute_fallthrough (__GNUC__ >= 7)
#else
#define has_gnu_attribute(X) 0
#endif
#endif

#if defined __has_builtin && defined __is_identifier
#define has_builtin(X) (__has_builtin(__builtin_##X) || \
                        !__is_identifier(__builtin_##X))
#elif defined __has_builtin
#define has_builtin(X) __has_builtin(__builtin_##X)
#else
#define has_builtin(X) has_builtin_##X
#define has_builtin_expect      (__GNUC__ >= 3)
#define has_builtin_popcount    (__GNUC__ * 100 + __GNUC_MINOR__ >= 304)
#define has_builtin_popcountll  (__GNUC__ * 100 + __GNUC_MINOR__ >= 304)
#endif

#if _MSC_VER >= 1500 && defined __AVX__ && !defined _M_CEE_PURE
/* compiler support is actually available since ABM, but no macro */
#include <intrin.h>
#if defined _M_X64 && !defined _M_ARM64EC
#define has_popcnt64 1
#define has_popcnt   1
#define has_popcnt16 1
#elif defined _M_IX86
#define has_popcnt   1
#define has_popcnt16 1
#endif
#endif

#if _MSC_VER >= 1900 && defined _M_ARM64 && !defined _M_ARM64EC
#include <arm64_neon.h>
#define has_neon_cnt 1
#endif

#if __STDC_VERSION__ >= 199605L /* N559 */
#define uc_restrict restrict
#elif __GNUC__ * 100 + __GNUC_MINOR__ >= 295
#define uc_restrict __restrict__
#else
#define uc_restrict
#endif

#ifndef uc_const
#if has_gnu_attribute(const)
#define uc_const __attribute__((__const__))
#else
#define uc_const
#endif
#endif

#ifndef unlikely
#if has_attribute(unlikely)
#define unlikely(E) (!!(E)) [[unlikely]] /* as condition in if, while, etc. */
#elif has_builtin(expect)
#define unlikely(E) (__builtin_expect(!!(E), 0))
#else
#define unlikely(E) (!!(E))
#endif
#endif

#if has_attribute(fallthrough)
#define uc_fallthrough [[__fallthrough__]]
#elif has_gnu_attribute(fallthrough)
#define uc_fallthrough __attribute__((__fallthrough__))
#else
#define uc_fallthrough
#endif

#if has_builtin(popcount)
#define UC_P32 __builtin_popcount
#elif has_popcnt
#define UC_P32 __popcnt
#endif

#if has_builtin(popcountll)
#define UC_P64 __builtin_popcountll
#elif has_popcnt64
#define UC_P64 __popcnt64
#elif has_neon_cnt
#define UC_P64(M) (neon_addv8(neon_cnt(__uint64ToN64_v(M))).n8_i8[0])
#elif defined UC_P32
#define UC_P64(M) (UC_P32((M) >> 32) + UC_P32((M) & UINT32_C(0xFFFFFFFF)))
#endif

/* See, e.g., <http://graphics.stanford.edu/~seander/bithacks.html> */

#if !defined UC_P32
uc_const int uc_p32(uint_least32_t x) {
	x -= (x >> 1) & UINT32_C(0x55555555);
	x  = (x & UINT32_C(0x33333333)) + ((x >> 2) & UINT32_C(0x33333333));
	x  = (x + (x >> 4)) & UINT32_C(0x0F0F0F0F);
	return (x * UINT32_C(0x01010101)) >> 24;
}
#define UC_P32 uc_p32
#endif

#if !defined UC_P64 && defined UINT64_C
uc_const int uc_p64(uint_least64_t x) {
	x -= (x >> 1) & UINT64_C(0x5555555555555555);
	x  = (x & UINT64_C(0x3333333333333333)) +
	     ((x >> 2) & UINT64_C(0x3333333333333333));
	x  = (x + (x >> 4)) & UINT64_C(0x0F0F0F0F0F0F0F0F);
	return (x * UINT64_C(0x0101010101010101)) >> 56;
}
#define UC_P64 uc_p64
#endif

#ifdef UINT64_C
typedef uint_least64_t uc_uint64_t;
#define UC_UINT64_C(H, L) ((UINT64_C(H) << 32) | UINT64_C(L))
#define UC_RANK64(M, B) UC_P64((M) >> (63-(B)))
#else
typedef uint_least32_t uc_uint64_t[2];
#define UC_UINT64_C(H, L) { UINT32_C(H), UINT32_C(L) }
#define UC_RANK64(M, B) (UC_P32((M)[(B) >> 5] >> (31-((B) & 31))) + \
                         (UC_P32((M)[0]) & -((B) >> 5)))
#endif

enum { MAJCAT = 007 };

typedef enum majcat {
	OTH    = 000, LET,    MRK,    NUM,    PCT    = 004, SYM,    SEP
} majcat_t;

typedef enum mincat {
	OTHUNA = 000, LETUPR, MRKNON, NUMDEC, PCTCON = 004, SYMMTH, SEPSPC,
	OTHCTL = 010, LETLWR, MRKSPC, NUMLET, PCTDSH = 014, SYMCUR, SEPLIN,
	OTHFMT = 020, LETTTL, MRKENC, NUMOTH, PCTOPN = 024, SYMMOD, SEPPAR,
	OTHSUR = 030, LETMOD,                 PCTCLO = 034, SYMOTH,
	OTHPRI = 040, LETOTH,                 PCTINI = 044,
	                                      PCTFIN = 054,
	                                      PCTOTH = 064
} mincat_t;

#define strfromcat uc_gcn /* use 6-character names */
#define CAT_MAX 3

int strfromcat(char *uc_restrict s, size_t n, mincat_t c) {
	static const char name[PCTOTH+1] =
		"n"  "u"  "n"  "d"  "c"  "m"  "s"  "\0"
		"c"  "l"  "c"  "l"  "d"  "c"  "l"  "\0"
		"f"  "t"  "e"  "o"  "s"  "k"  "p"  "\0"
		"s"  "m"  "\0" "\0" "e"  "o"  "\0" "\0"
		"o"  "o"  "\0" "\0" "i"  "C"  "L"  "M"
		"N"  "P"  "S"  "Z"  "f"  "\0" "\0" "\0"
		"\0" "\0" "\0" "\0" "o";

	switch (n) {
	default: s[2] = '\0'; uc_fallthrough;
	case 2:  s[1] = name[c]; uc_fallthrough;
	case 1:  s[0] = (name + PCTINI + 1)[c & MAJCAT]; uc_fallthrough;
	case 0:  return 2;
	}
}

#define UC_INT(V, M)  ((M) <= INT_MAX ? (int)((V) & (M)) : !!((V) & (M)))

/* These can't be enum constants because those must fit into an int, and an int
   is only guaranteed to fit 16-bit numbers */

#define majcat(U)     ((majcat_t)(uc_ty(U) & MAJCAT))
#define UC_MINCAT    ((UINT32_C(1) <<  6) - 1)
#define mincat(U)     ((mincat_t)(uc_ty(U) & UC_MINCAT))
#define UC_ALNUM      (UINT32_C(1) <<  6)
#define isualnum(U)   (UC_INT(uc_ty(U), UC_ALNUM))
#define UC_ALPHA      (UINT32_C(1) <<  7)
#define isualpha(U)   (UC_INT(uc_ty(U), UC_ALPHA))
#define isuascii(U)   ((U) <= 127)
#define UC_BLANK      (UINT32_C(1) <<  8)
#define isublank(U)   (UC_INT(uc_ty(U), UC_BLANK))
#define UC_CASED      (UINT32_C(1) <<  9)
#define isucased(U)   (UC_INT(uc_ty(U), UC_CASED))
#define isucntrl(U)   (gencat(U) == OTHCTL)
#define UC_DELIM      (UINT32_C(1) << 10)
#define isudelim(U)   (UC_INT(uc_ty(U), UC_DELIM))
#define isudigit(U)   (gencat(U) == NUMDEC)
#define UC_GRAPH      (UINT32_C(1) << 11)
#define isugraph(U)   (UC_INT(uc_ty(U), UC_GRAPH))
#define UC_IDENT      (UINT32_C(1) << 12)
#define isuident(U)   (UC_INT(uc_ty(U), UC_IDENT))
#define UC_IGNOR      (UINT32_C(1) << 13)
#define isuignor(U)   (UC_INT(uc_ty(U), UC_IGNOR))
#define UC_LOWER      (UINT32_C(1) << 14)
#define isulower(U)   (UC_INT(uc_ty(U), UC_LOWER))
#define UC_NCHAR      (UINT32_C(1) << 15)
#define isunchar(U)   (UC_INT(uc_ty(U), UC_NCHAR))
#define UC_DIGIT_SHIFT                16
#define UC_digit(U)   (((U) - (uc_ty(U) >> UC_DIGIT_SHIFT)) & 0xF) /* FIXME */
#define UC_PALNUM     (UINT32_C(1) << 20)
#define isupalnum(U)  (UC_INT(uc_ty(U), UC_PALNUM))
#define UC_PDIGIT     (UINT32_C(1) << 21)
#define isupdigit(U)  (UC_INT(uc_ty(U), UC_PDIGIT))
#define UC_PPUNCT     (UINT32_C(1) << 22)
#define isuppunct(U)  (UC_INT(uc_ty(U), UC_PPUNCT))
#define UC_PRINT      (UINT32_C(1) << 23)
#define isuprint(U)   (UC_INT(uc_ty(U), UC_PRINT))
#define isupunct(U)   ((gencat(U) & CATGRP) == PCT)
#define UC_PXDIGIT    (UINT32_C(1) << 24)
#define isupxdigit(U) (UC_INT(uc_ty(U), UC_PXDIGIT))
#define UC_SNTAX      (UINT32_C(1) << 25)
#define isusntax(U)   (UC_INT(uc_ty(U), UC_SNTAX))
#define UC_SPACE      (UINT32_C(1) << 26)
#define isuspace(U)   (UC_INT(uc_ty(U), UC_SPACE))
#define UC_START      (UINT32_C(1) << 27)
#define isustart(U)   (UC_INT(uc_ty(U), UC_START))
#define UC_UPPER      (UINT32_C(1) << 28)
#define isuupper(U)   (UC_INT(uc_ty(U), UC_UPPER))
#define UC_XDIGIT     (UINT32_C(1) << 29)
#define isuxdigit(U)  (UC_INT(uc_ty(U), UC_XDIGIT))

enum {
	Cn = OTHUNA, Cc = OTHCTL, Cf = OTHFMT, Cs = OTHSUR, Co = OTHPRI,
	Lu = LETUPR, Ll = LETLWR, Lt = LETTTL, Lm = LETMOD, Lo = LETOTH,
	Mn = MRKNON, Mc = MRKSPC, Me = MRKENC,
	Nd = NUMDEC, Nl = NUMLET, No = NUMOTH,
	Pc = PCTCON, Pd = PCTDSH, Ps = PCTOPN, Pe = PCTCLO, Pi = PCTINI,
	Pf = PCTFIN, Po = PCTOTH,
	Sm = SYMMTH, Sc = SYMCUR, Sk = SYMMOD, So = SYMOTH,
	Zs = SEPSPC, Zl = SEPLIN, Zp = SEPPAR
};
#define UC_XDIGIT_(X) (UC_XDIGIT | (UINT32_C(X) << UC_DIGIT_SHIFT))
#include "uc_ty.g"

uc_const uint_least32_t uc_ty(uint_least32_t uc) {
	const unsigned i =  uc >> 12, /* FIXME */
	               j = (uc >>  6) & 63,
	               k =  uc        & 63;
	if unlikely(i >= sizeof uc_tyi / sizeof uc_tyi[0]) {
		return 0;
	} else {
		unsigned p = uc_tyi[i], q, r, s;
		q = uc_tyb[p] + UC_RANK64(uc_tym[p], j);
		r = uc_tyb[q] + UC_RANK64(uc_tym[q], k);
		s = uc_tyr[r];
		return uc_tyv[(s >> 1) ^ (uc & s & 1)];
	}
}

#if 1

#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv) {
	uint_least32_t uc; char buf[CAT_MAX];
	while (scanf("%"SCNxLEAST32, &uc) == 1) {
		if (strfromcat(buf, sizeof buf, mincat(uc)) >= sizeof buf)
			abort();
		printf("%.4"PRIXLEAST32"\t%s\n", uc, &buf[0]);
	}
	return ferror(stdin) ? (perror(argv[0]), EXIT_FAILURE) : EXIT_SUCCESS;
}

#endif
