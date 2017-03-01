#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MBSIZE 4 
#define SIZE (MBSIZE  * 1024 * 1024)

//#define SIZE (256*1024)

//#define SIZE 8192 * 32

// #define RANDOMSTRIDE  (9)
#define UNROLL 4

#define COUNT    ( 1000 * 1000)

int main(int argc, char *argv[] ) {
	long stride=atol(argv[2]);
	stride = stride > 4 ? stride/4: (stride==0 ? 0 :1);
	char *ptr=malloc( SIZE + 20*stride  );
	
	memset( ptr, 55, SIZE + 10*stride );
	int *cur=(int*)ptr;
	long curCount=atol(argv[1])* COUNT/UNROLL;
	long long  result=0;
	long headroom=UNROLL * stride;
	while ( curCount-- > 0 ) {
		result+=*cur; cur+=stride;
		result+=*cur; cur+=stride;
		result+=*cur; cur+=stride;
		result+=*cur; cur+=stride;
		if ( (((char*)cur-(char*)ptr)+headroom) > SIZE ) {
			cur-=((SIZE-headroom)/4);
		}
	}	
	printf("result: %lld",result);	
}
