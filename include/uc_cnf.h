#ifndef UC_CNF_H_
#define UC_CNF_H_ 1
#else
#error "uc_cnf.h included multiple times"
#endif

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>

#ifndef has_attribute
#if __STDC_VERSION__ >= 201906L /* N2385 */ && defined __has_c_attribute
#define has_attribute __has_c_attribute
#elif __cplusplus >= 201103L
#if defined __has_cpp_attribute
#define has_attribute __has_cpp_attribute
#else
#define has_attribute(X) has_attribute_##X
#define has_attribute_fallthrough (__cplusplus >= 201603L)
#define has_attribute_unlikely (__cplusplus >= 201803L)
#endif
#else
#define has_attribute(X) 0
#endif
#endif

#ifndef has_gnu_attribute
#if defined __has_attribute
#define has_gnu_attribute __has_attribute
#elif __GNUC__ >= 2
#define has_gnu_attribute has_gnu_attribute_##X
#define has_gnu_attribute_const (__GNUC__ * 100 + __GNUC_MINOR__ >= 205)
#define has_gnu_attribute_fallthrough (__GNUC__ >= 7)
#else
#define has_gnu_attribute(X) 0
#endif
#endif

#ifndef has_builtin
#if defined __has_builtin && defined __is_identifier
#define has_builtin(X) (__has_builtin(__builtin_##X) || \
                        !__is_identifier(__builtin_##X))
#elif defined __has_builtin
#define has_builtin(X) __has_builtin(__builtin_##X)
#else
#define has_builtin(X) has_builtin_##X
#define has_builtin_expect      (__GNUC__ >= 3)
#define has_builtin_popcount    (__GNUC__ * 100 + __GNUC_MINOR__ >= 304)
#define has_builtin_popcountll  (__GNUC__ * 100 + __GNUC_MINOR__ >= 304)
#define has_builtin_unreachable (__GNUC__ * 100 + __GNUC_MINOR__ >= 405)
#endif
#endif

#ifndef has_popcnt
#if _MSC_VER >= 1500 && defined __AVX__ && !defined _M_CEE_PURE
/* compiler support is actually available since ABM, but no macro */
#include <intrin.h>
#if defined _M_X64 && !defined _M_ARM64EC
#define has_popcnt64 1
#define has_popcnt   1
#define has_popcnt16 1
#elif defined _M_IX86
#define has_popcnt   1
#define has_popcnt16 1
#endif
#endif
#endif

#ifndef has_neon_cnt
#if _MSC_VER >= 1900 && defined _M_ARM64 && !defined _M_ARM64EC
#include <arm64_neon.h>
#define has_neon_cnt 1
#endif
#endif /* has_neon_cnt */

#ifndef uc_restrict
#if __STDC_VERSION__ >= 199605L /* N559 */
#define uc_restrict restrict
#elif __GNUC__ * 100 + __GNUC_MINOR__ >= 295
#define uc_restrict __restrict__
#else
#define uc_restrict
#endif
#endif

#ifndef uc_static_assert
#if __STDC_VERSION__ >= 201811L /* N2310 */
#define uc_static_assert(E) _Static_assert((E))
#elif __cplusplus >= 201411L /* N4296 */
#define uc_static_assert(E) static_assert((E))
#elif __STDC_VERSION__ >= 200904L /* N1362 */
#define uc_static_assert(E) _Static_assert((E), #E)
#elif __cplusplus >= 200504L /* N1804 */
#define uc_static_assert(E) static_assert((E), #E)
#else
#define uc_static_assert(E) extern char uc_err[2*!!(E)-1]
#endif
#endif

#ifndef uc_const
#if has_gnu_attribute(const)
#define uc_const __attribute__((__const__))
#else
#define uc_const
#endif
#endif

#ifndef unlikely
#if has_attribute(unlikely)
#define unlikely(E) (!!(E)) [[unlikely]] /* as condition in if, while, etc. */
#elif has_builtin(expect)
#define unlikely(E) (__builtin_expect(!!(E), 0))
#else
#define unlikely(E) (!!(E))
#endif
#endif

#ifndef uc_fallthrough
#if has_attribute(fallthrough)
#define uc_fallthrough [[__fallthrough__]]
#elif has_gnu_attribute(fallthrough)
#define uc_fallthrough __attribute__((__fallthrough__))
#else
#define uc_fallthrough
#endif
#endif

#if has_builtin(unreachable)
#define uc_unreachable (__builtin_unreachable())
#elif has_assume
#define uc_unreachable (__assume(0))
#else
#define uc_unreachable ((void)0)
#endif

#if has_builtin(popcount)
#define UC_P32 __builtin_popcount
#elif has_popcnt
#define UC_P32 __popcnt
#endif

#if has_builtin(popcountll)
#define UC_P64 __builtin_popcountll
#elif has_popcnt64
#define UC_P64 __popcnt64
#elif has_neon_cnt
#define UC_P64(M) (neon_addv8(neon_cnt(__uint64ToN64_v(M))).n8_i8[0])
#elif defined UC_P32
#define UC_P64(M) (UC_P32((M) >> 32) + UC_P32((M) & 0xFFFFFFFF))
#endif

/* See, e.g., <http://graphics.stanford.edu/~seander/bithacks.html> */

uc_const int uc_p32(uint_least32_t); /* FIXME inline */
#if !defined UC_P32
#define UC_P32 uc_p32
#endif

uc_const int uc_p64(uint_least64_t); /* FIXME inline */
#if !defined UC_P64 && defined UINT64_C
#define UC_P64 uc_p64
#endif

#ifndef UC_RANK32
#define UC_RANK32(M, B) (UC_P32((M) >> (31-(B))))
#endif
#ifndef UC_FLAG32
#define UC_FLAG32(M, B) ((M) >> (31-(B)) & 1)
#endif

#ifndef UC_UINT64_C
#ifdef UINT64_C
typedef uint_least64_t uc_uint64_t;
#define UC_UINT64_C(H, L) ((UINT64_C(H) << 32) | UINT64_C(L))
#define UC_RANK64(M, B) UC_P64((M) >> (63-(B)))
#define UC_HI32(M) ((uint_least32_t)((M) >> 32))
#define UC_LO32(M) ((uint_least32_t)((M) & 0xFFFFFFFF))
#else
typedef uint_least32_t uc_uint64_t[2];
#define UC_UINT64_C(H, L) { (H), (L) }
#define UC_RANK64(M, B) (UC_RANK32((M)[(B) >> 5], (B) & 31) + \
                         (UC_RANK32((M)[0]) & -((B) >> 5)))
#define UC_HI32(M) ((M)[0])
#define UC_LO32(M) ((M)[1])
#endif
#endif

#ifdef __cplusplus
}
#endif
