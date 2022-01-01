#include "uctype.h"

#include <inttypes.h>
#include <stdio.h>

int main(void) {
	uint_least32_t i; int x;
	for (i = 0; i < 2*(UNIMAX + 1); i++) {
		if ((x = cmbcls(i))) printf("%.4" PRIXLEAST32 "\t%d\n", i, x);
	}
	return 0;
}
