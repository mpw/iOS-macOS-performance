
#import <Foundation/Foundation.h>
#include <malloc/malloc.h>


NSTimeInterval mallocTest( long size  )
{
	long actual=0;
	void *ptr=malloc( size );
	actual=malloc_size(ptr);
	free(ptr);
	return actual;
}

int main() 
{	int increment=1;
	int lastchange=0;
	for (long size=1; size<1024*1024; size+=increment ) {
		long actual =mallocTest( size );
		if ( actual != lastchange ) {
			int diff = actual - lastchange;
			lastchange=actual;
			if ( diff > increment ) {
				increment=diff;
				printf("requested: %7ld actual: %7ld bucket size: %5d\n",size,actual,increment);
			}
		}
	}
}
