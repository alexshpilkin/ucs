#ifndef UC_UCNORM_H_
#define UC_UCNORM_H_ 1

#ifdef __cplusplus
extern "C" {
#endif

#ifndef UC_CNF_H_
#include "uc_cnf.h"
#endif

#include <stddef.h>

#define UC_CLASSES 55 /* < 255 (sic, also used as a neutral lcc value) */

#define UC_CMBCLS_SHIFT     0
#define UC_CMBCLS   ((1 <<  8) - 1)
#define UC_DQN       (1 <<  8)
#define UC_KDQN      (1 <<  9)
#define UC_CQN       (1 << 10)
#define UC_CQM       (3 << 10)
#define UC_KCQN      (1 << 12)
#define UC_KCQM      (3 << 12)
/* unused             1 << 14 */
/* unused             1 << 15 */
#define UC_LCC_SHIFT       16
#define UC_TCC_SHIFT       24

#define cmbcls(U) ((int)(uc_qc(U) & UC_CMBCLS))
#define uc_tcc(U) ((int)(uc_qc(U) >> UC_TCC_SHIFT & UC_CMBCLS))

#define UC_QC_SHIFT1 12
#define UC_QC_MASK1  63
#define UC_QC_SHIFT2  6
#define UC_QC_MASK2  63

extern const uint_least32_t uc_qcv[];
extern const uint_least8_t  uc_qcr[];
extern const uint_least16_t uc_qcb[];
extern const uc_uint64_t    uc_qcm[];
extern const uint_least8_t  uc_qci[0x30000 / 64 / 64];

uc_const uint_least32_t uc_qc(uint_least32_t); /* FIXME inline */

#define UC_BMPTOP  UINT32_C(0xD800)
#define DECOMP_MAX 4

#define UC_DC_SHIFT1 11
#define UC_DC_MASK1  63
#define UC_DC_SHIFT2  5
#define UC_DC_MASK2  31

extern const uint_least16_t uc_dcs[];
extern const uint_least8_t  uc_dcl[][3];
extern const uint_least16_t uc_dcb[];
extern const uc_uint64_t    uc_dcm[];
extern const uint_least8_t  uc_dci[0x30000 / 64 / 32];

size_t decomp(uint_least32_t *uc_restrict s, size_t n, uint_least32_t uc); /* FIXME inline? */

#define UC_RC_SIZE 367

#define UC_RC_A1 21622
#define UC_RC_B1   255
#define UC_RC_A2 14516
#define UC_RC_B2   511
#define UC_RC_A3  5599
#define UC_RC_B3  1023

extern const uint_least32_t uc_rch[3 * UC_RC_SIZE];

uint_least32_t recomp(uint_least32_t fst, uint_least32_t snd); /* FIXME inline? */

/* FIXME status not error */
typedef enum ucerr { /* FIXME to common header? use -1 for error? */
	UDONE = 0, U2BIG = -1, UMORE = -2
} ucerr_t;

ucerr_t ucsdec(uint_least32_t *uc_restrict, size_t *uc_restrict,
               const uint_least32_t *uc_restrict, size_t *uc_restrict);

#ifdef __cplusplus
}
#endif

#endif
