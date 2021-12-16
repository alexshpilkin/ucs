#include "uc_cnf.h"

#ifdef UINT64_C
uc_const int uc_p64(uint_least64_t x) {
	x -= (x >> 1) & UINT64_C(0x5555555555555555);
	x  = (x & UINT64_C(0x3333333333333333)) +
	     ((x >> 2) & UINT64_C(0x3333333333333333));
	x  = (x + (x >> 4)) & UINT64_C(0x0F0F0F0F0F0F0F0F);
	return (x * UINT64_C(0x0101010101010101)) >> 56;
}
#endif
