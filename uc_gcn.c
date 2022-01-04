#include "uc_cnf.h"
#include "uctype.h"

#include <stddef.h>

/* FIXME keep in sync with mincat_t */

size_t strfromcat(char *uc_restrict s, size_t n, mincat_t c) {
	static const char name[PCTOTH+1] = {
		'n', 'u', 'n', 'd', 'c', 'm', 's', '\0',
		'c', 'l', 'c', 'l', 'd', 'c', 'l', '\0',
		'f', 't', 'e', 'o', 's', 'k', 'p', '\0',
		's', 'm', '\0','\0','e', 'o', '\0','\0',
		'o', 'o', '\0','\0','i', 'C', 'L', 'M',
		'N', 'P', 'S', 'Z', 'f', '\0','\0','\0',
		'\0','\0','\0','\0','o',
	};

	switch (n) {
	default: s[2] = '\0'; uc_fallthrough;
	case 2:  s[1] = name[c]; uc_fallthrough;
	case 1:  s[0] = (name + PCTINI + 1)[c & MAJCAT]; uc_fallthrough;
	case 0:  return 2;
	}
}
