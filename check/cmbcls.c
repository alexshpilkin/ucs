#include "uctype.h"

#include <inttypes.h>
#include <stdio.h>

int main(void) {
	uint_least32_t i;
	for (i = 0; i < 2*(UNIMAX + 1); i++) {
		int x = cmbcls(i); if (!x) continue;
		printf("%.4" PRIXLEAST32 "\t%d\n", i, x);
	}
	return 0;
}
