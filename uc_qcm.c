#include "uc_cnf.h"
#include "uccomp.h"

#define UC_CMBCLS_(C) (UINT32_C(C) << UC_CMBCLS_SHIFT)
/* FIXME move to separate data file for FCD? */
#define UC_LCC_(C)    (UINT32_C(C) << UC_LCC_SHIFT)
#define UC_TCC_(C)    (UINT32_C(C) << UC_TCC_SHIFT)
#include "uc_qcm.g"
