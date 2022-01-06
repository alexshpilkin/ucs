#include "uctype.h"

#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>

int main(void) {
	uint_least32_t i;
	for (i = 0; i < 2*(UNIMAX + 1); i++) {
		char buf[CAT_MAX];
		if (strfromcat(buf, sizeof buf, mincat(i)) >= sizeof buf)
			abort();
		if (buf[0] == 'C' && buf[1] == 'n' && buf[2] == '\0')
			continue;
		printf("%.4" PRIXLEAST32 "\t%s\n", i, &buf[0]);
	}
	return 0;
}
