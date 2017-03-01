#include <stdio.h>
#include <stdlib.h>

int main( int argc , char *argv[] ) 
{
	long k;
	long i,sum,totalSum,max=1000,numIter=1000;

	if ( argc > 1 ) {
		numIter=atol(argv[1]);
	}
	if ( argc > 2 ) {
		max=atol(argv[2]);
	}
    totalSum=0;
	for (k=0;k<numIter;k++) {
		sum=0;
		for (i=1;i<=max;i++ ) {
			sum+=i;
		}
   	    totalSum+=sum;
	}
	printf("%ld (total: %ld)\n",sum,totalSum);
	return 0;
}
