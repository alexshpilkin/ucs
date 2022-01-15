#include "uccomp.h"

#include <inttypes.h>
#include <stdio.h>

#define UNIMAX UINT32_C(0x10FFFF) /* FIXME */

int main(void) {
	uint_least32_t i;
	for (i = 0; i < 2*(UNIMAX + 1); i++) {
		int x = cmbcls(i); if (!x) continue;
		printf("%.4" PRIXLEAST32 "\t%d\n", i, x);
	}
	return 0;
}
