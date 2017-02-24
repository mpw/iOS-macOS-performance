#import <Foundation/Foundation.h>



@interface SumBench : NSObject
{
  long long totalSum;
  long additional;
}
@end

static long intermediate[256];

@implementation SumBench

-(long)sumUpTo:(long)max
{
  long sum=0;
  for (long i=1;i<=max;i++ ) {
        sum+=i;
        intermediate[i&3]=sum;
  }
  return sum;
}


@end

int main( int argc , char *argv[] ) 
{
	long k;
	long i,sum,totalSum,max=10000,numIter=1000;
  SumBench *summer=[SumBench new];

	if ( argc > 1 ) {
		numIter=atol(argv[1]) * 1000;
	}
	if ( argc > 2 ) {
		max=atol(argv[2]);
	}
  totalSum=0;
	for (k=0;k<numIter;k++) {
	sum=0;
#if 1
  sum=[summer sumUpTo:max];
  totalSum+=sum;
#elif 1
	for (i=1;i<=max-4;i+=4 ) {
		sum+=i;
		sum+=i+1;
		sum+=i+2;
		sum+=i+3;
	}
	for (;i<=max;i++ ) {
		sum+=i;
	}
#else
	sum=(max*max+max)/2;
#endif
	}
	printf("%ld (total: %ld)\n",sum,totalSum);
  for (int i=0;i<3;i++) {
    printf("%ld ",intermediate[i]);
  }
	return 0;
}
