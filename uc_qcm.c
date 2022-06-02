#include "uc_cnf.h"
#include "ucnorm.h"

#define UC_CMBCLS_(C) (UINT32_C(C) << UC_CMBCLS_SHIFT)
#define UC_LCC_(C)    (UINT32_C(C) << UC_LCC_SHIFT)
#define UC_TCC_(C)    (UINT32_C(C) << UC_TCC_SHIFT)
#include "uc_qcm.g"
