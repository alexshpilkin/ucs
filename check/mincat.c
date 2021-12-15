#include "uctype.h"

#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv) {
	uint_least32_t uc; char buf[CAT_MAX];
	while (scanf("%"SCNxLEAST32, &uc) == 1) {
		if (strfromcat(buf, sizeof buf, mincat(uc)) >= sizeof buf)
			abort();
		printf("%.4"PRIXLEAST32"\t%s\n", uc, &buf[0]);
	}
	return ferror(stdin) ? (perror(argv[0]), EXIT_FAILURE) : EXIT_SUCCESS;
}
