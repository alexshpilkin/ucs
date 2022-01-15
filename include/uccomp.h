#ifndef UC_UCCOMP_H_
#define UC_UCCOMP_H_ 1

#ifdef __cplusplus
extern "C" {
#endif

#ifndef UC_CNF_H_
#include "uc_cnf.h"
#endif

#include <stddef.h>

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

extern const uint_least32_t uc_qcv[];
extern const uint_least8_t  uc_qcr[];
extern const uint_least16_t uc_qcb[];
extern const uc_uint64_t    uc_qcm[];
extern const uint_least8_t  uc_qci[0x30000 / 64 / 64];

enum { uc_qc_shift1 = 12, uc_qc_mask1 = 63 };
enum { uc_qc_shift2 =  6, uc_qc_mask2 = 63 };

uc_const uint_least32_t uc_qc(uint_least32_t); /* FIXME inline */

extern const uint_least16_t uc_dcs[];
extern const uint_least8_t  uc_dcl[][3];
extern const uint_least16_t uc_dcb[];
extern const uc_uint64_t    uc_dcm[];
extern const uint_least8_t  uc_dci[0x30000 / 64 / 32];

enum { uc_dc_shift1 = 11, uc_dc_mask1 = 63 };
enum { uc_dc_shift2 =  5, uc_dc_mask2 = 31 };

#define UC_BMPTOP  UINT32_C(0xD800)
#define DECOMP_MAX 4

size_t decomp(uint_least32_t *uc_restrict s, size_t n, uint_least32_t uc); /* FIXME inline? */

enum { uc_rc_size = 367 };
enum { uc_rc_a1 = 21622, uc_rc_b1 =  255 };
enum { uc_rc_a2 = 14516, uc_rc_b2 =  511 };
enum { uc_rc_a3 =  5599, uc_rc_b3 = 1023 };

extern const uint_least32_t uc_rch[3 * uc_rc_size];

uint_least32_t recomp(uint_least32_t fst, uint_least32_t snd); /* FIXME inline? */

#ifdef __cplusplus
}
#endif

#endif
