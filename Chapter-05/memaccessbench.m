#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#if 1
#define MBSIZE 2048L
#define SIZE (MBSIZE  * 1024L * 1024L)
#else
#define SIZE (256*1024)
#endif

//#define SIZE 8192 * 32

// #define RANDOMSTRIDE  (9)
#define UNROLL 4

#define COUNT    ( 1000 * 1000)

int main(int argc, char *argv[] ) {
	long stride=atol(argv[2]);
	printf("total size: %ld\n",SIZE+20*stride);
	char *ptr=malloc( SIZE + 20L*stride  );
	memset( ptr, 55, SIZE + 10*stride );
	char *cur=ptr;
	long curCount=atol(argv[1])* COUNT/UNROLL;
	long result=0;
	long headroom=UNROLL * stride;
	printf("stride: %ld count = %ld, headroom=%ld\n",stride,curCount,headroom);
	while ( curCount-- > 0 ) {
		result+=*cur; cur+=stride;
#if 1
		result+=*cur; cur+=stride;
		result+=*cur; cur+=stride;
		result+=*cur; cur+=stride;
#endif
		if ( ((cur-ptr)+headroom) > SIZE ) {
			cur-=(SIZE-headroom);
		}
	}	
	printf("result: %ld\n",result);	
}
