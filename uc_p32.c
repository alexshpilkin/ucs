#include "uc_cnf.h"

uc_const int uc_p32(uint_least32_t x) {
	x -= (x >> 1) & UINT32_C(0x55555555);
	x  = (x & UINT32_C(0x33333333)) + ((x >> 2) & UINT32_C(0x33333333));
	x  = (x + (x >> 4)) & UINT32_C(0x0F0F0F0F);
	return (x * UINT32_C(0x01010101)) >> 24;
}
