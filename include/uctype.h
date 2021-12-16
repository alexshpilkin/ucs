#ifndef UC_UCTYPE_H_
#define UC_UCTYPE_H_ 1

#ifndef UC_CNF_H_
#include "uc_cnf.h"
#endif

#include <limits.h>
#include <stddef.h>

#define UNIMAX UINT32_C(0x10FFFF)

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

int strfromcat(char *uc_restrict, size_t, mincat_t); /* FIXME inline */

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

extern const uint_least32_t uc_tyv[];
extern const uint_least8_t  uc_tyr[];
extern const uint_least16_t uc_tyb[];
extern const uc_uint64_t    uc_tym[];
extern const uint_least8_t  uc_tyi[(UNIMAX + 1) / 64 / 64];

uc_const uint_least32_t uc_ty(uint_least32_t); /* FIXME inline */

#endif
