#include "ucnorm.h"

#include <inttypes.h>
#include <stdio.h>

#if 0 /* FIXME */
#define UNIMAX UINT32_C(0x10FFFF)
#else
#define UNIMAX UINT32_C(0xFFFF)
#endif

int main(void) {
	uint_least32_t i, j;
	for (i = 0; i < 2*(UNIMAX + 1); i++)
	for (j = 0; j < 2*(UNIMAX + 1); j++) {
		uint_least32_t u = recomp(i, j);
		if (!u) continue;
		printf("%.4" PRIXLEAST32 "\t"
		       "%.4" PRIXLEAST32 "\t"
		       "%.4" PRIXLEAST32 "\n",
		       i, j, u);
	}
	return 0;
}
