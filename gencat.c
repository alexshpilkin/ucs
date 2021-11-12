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
#else
#define has_gnu_attribute(X) 0
#endif
#endif

#if defined __has_builtin
#define has_builtin(X) __has_builtin(__builtin_##X)
#else
#define has_builtin(X) has_builtin_##X
#define has_builtin_expect (__GNUC__ >= 3)
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

typedef enum gencat {
	OTH = 000,
	OTHUNA = OTH, OTHCTL, OTHFMT, OTHSUR, OTHPRI,
	LET = 010,
	LETUPR = LET, LETLWR, LETTTL, LETMOD, LETOTH,
	MRK = 020,
	MRKNON = MRK, MRKSPC, MRKENC,
	NUM = 030,
	NUMDEC = NUM, NUMLET, NUMOTH,
	PCT = 040,
	PCTCON = PCT, PCTDSH, PCTOPN, PCTCLO, PCTINI, PCTFIN, PCTOTH,
	SYM = 050,
	SYMMTH = SYM, SYMCUR, SYMMOD, SYMOTH,
	SEP = 060,
	SEPSPC = SEP, SEPLIN, SEPPAR,
	CATGRP = 070
} gencat_t;

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
#include "gencat.g"

#if has_gnu_attribute(const)
__attribute__((__const__))
#endif
gencat_t gencat(uint_least32_t uc) {
	const unsigned g = uc >> GROUP_BIT;
	if unlikely(g >= sizeof uc_gcg / sizeof uc_gcg[0]) {
		return OTHUNA;
	} else {
		const unsigned c = (uc & (1 << GROUP_BIT) - 1) >> CHUNK_BIT,
		               v =  uc & (1 << CHUNK_BIT) - 1;
		return uc_gcv[uc_gcc[uc_gcg[g]][c] + v];
	}
}

#if 1

#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef __GNUC__
__extension__ /* FIXME duplication, C89 and C++ compatibility */
#endif
static const char catnam[][2] = {
	[OTHUNA] = "Cn", [OTHCTL] = "Cc", [OTHFMT] = "Cf", [OTHSUR] = "Cs",
	[OTHPRI] = "Co", [LETUPR] = "Lu", [LETLWR] = "Ll", [LETTTL] = "Lt",
	[LETMOD] = "Lm", [LETOTH] = "Lo", [MRKNON] = "Mn", [MRKSPC] = "Mc",
	[MRKENC] = "Me", [NUMDEC] = "Nd", [NUMLET] = "Nl", [NUMOTH] = "No",
	[PCTCON] = "Pc", [PCTDSH] = "Pd", [PCTOPN] = "Ps", [PCTCLO] = "Pe",
	[PCTINI] = "Pi", [PCTFIN] = "Pf", [PCTOTH] = "Po", [SYMMTH] = "Sm",
	[SYMCUR] = "Sc", [SYMMOD] = "Sk", [SYMOTH] = "So", [SEPSPC] = "Zs",
	[SEPLIN] = "Zl", [SEPPAR] = "Zp",
};

int main(int argc, char **argv) {
	uint_least32_t uc;
	while (scanf("%"SCNxLEAST32, &uc) == 1)
		printf("%.4"PRIXLEAST32"\t%.2s\n", uc, catnam[gencat(uc)]);
	return ferror(stdin) ? (perror(argv[0]), EXIT_FAILURE) : EXIT_SUCCESS;
}

#endif
