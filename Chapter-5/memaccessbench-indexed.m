#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if 0
#define MBSIZE 2UL
#define KBSIZE (MBSIZE  * 1024UL)
#else
#define KBSIZE 32UL
#endif
#define SIZE   (KBSIZE * 1024UL)
#define MASK (SIZE-1UL)

//#define SIZE 8192 * 32

// #define RANDOMSTRIDE  (9)
#define UNROLL 4

#define COUNT    ( 1000 * 1000)


int main(int argc, char *argv[] ) {
	unsigned long stride=atol(argv[2]);
	char *ptr=malloc( SIZE + 20*stride  );
	memset( ptr, 55, SIZE + 10*stride );
	long curCount=atol(argv[1])* COUNT/UNROLL;
	long result=0;
	long headroom=UNROLL * stride;
	unsigned long offset=0;
	while ( curCount-- > 0 ) {
		result+=ptr[offset&MASK];  offset+=stride;
		result+=ptr[offset&MASK];  offset+=stride;
		result+=ptr[offset&MASK];  offset+=stride;
		result+=ptr[offset&MASK];  offset+=stride;
	}	
	printf("result: %ld\n",result);	
}
