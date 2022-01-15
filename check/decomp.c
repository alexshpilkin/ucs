#include "uccomp.h"

#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>

#define UNIMAX UINT32_C(0x10FFFF) /* FIXME */

int main(void) {
	uint_least32_t i;
	for (i = 0; i < 2*(UNIMAX + 1); i++) {
		uint_least32_t buf[DECOMP_MAX];
		unsigned j, n = decomp(buf, sizeof buf / sizeof buf[0], i);
		if (n > sizeof buf / sizeof buf[0])
			abort();
		if (n == 1 && buf[0] == i)
			continue;
		printf("%.4" PRIXLEAST32, i);
		for (j = 0; j < n; j++)
			printf("%c%.4" PRIXLEAST32, j ? ' ' : '\t', buf[j]);
		printf("\n");
	}
	return 0;
}
