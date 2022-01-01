#ifndef UC_UCCOMP_H_
#define UC_UCCOMP_H_ 1

#ifdef __cplusplus
extern "C" {
#endif

#ifndef UC_CNF_H_
#include "uc_cnf.h"
#endif

#include <stddef.h>

extern const uint_least16_t uc_dcs[];
extern const uint_least8_t  uc_dcl[][3];
extern const uint_least16_t uc_dcb[];
extern const uc_uint64_t    uc_dcm[];
extern const uint_least8_t  uc_dci[0x30000 / 64 / 32];

enum { uc_dc_shift1 = 11, uc_dc_mask1 = 63 };
enum { uc_dc_shift2 =  5, uc_dc_mask2 = 31 };

#define UC_BMPTOP  UINT32_C(0xD800)
#define DECOMP_MAX 4

int decomp(uint_least32_t *uc_restrict s, size_t n, uint_least32_t uc); /* FIXME inline? */

#ifdef __cplusplus
}
#endif

#endif
