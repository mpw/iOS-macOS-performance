#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MBSIZE 16
#define SIZE (MBSIZE  * 1024 * 1024)

#define UNROLL 4
#define COUNT    ( 1000 * 1000)

int main(int argc, char *argv[] ) {
  if (argc > 2) {
    long stride=atol(argv[2]);
	char *ptr=malloc( SIZE + 20*stride  );
	memset( ptr, 55, SIZE + 10*stride );
	char *cur=ptr;
	long curCount=atol(argv[1])* COUNT/UNROLL;
	long result=0;
	long headroom=UNROLL * stride;
	while ( curCount-- > 0 ) {
	  result+=*cur; cur+=stride;
	  result+=*cur; cur+=stride;
  	  result+=*cur; cur+=stride;
	  result+=*cur; cur+=stride;
	  if ( ((cur-ptr)+headroom) > SIZE ) {
		cur-=(SIZE-headroom);
      }
	} 
	printf("result: %ld\n",result); 
  } else {
    printf("usage: %s <access-count-in-millions> <stride>\n",argv[0]);
  }	
}
