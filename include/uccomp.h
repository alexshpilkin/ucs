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
extern const uint_least8_t  uc_dci[0x110000 / 64 / 32];

#define DECOMP_MAX 4 /* FIXME check this in AWK */

int decomp(uint_least32_t *uc_restrict s, size_t n, uint_least32_t uc); /* FIXME inline? */

#ifdef __cplusplus
}
#endif

#endif
