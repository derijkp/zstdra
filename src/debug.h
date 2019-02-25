/* #define DEBUG 1 */

#ifdef DEBUG
#define DPRINT(...) fprintf(stderr, "-- ");fprintf(stderr, __VA_ARGS__);fprintf(stderr, "  (%s:%d)\n", __func__, __LINE__);fflush(stderr);fflush(stdout);
#define NODPRINT(...) /**/
#else
#define DPRINT(...) /**/
#define NODPRINT(...) /**/
#endif
