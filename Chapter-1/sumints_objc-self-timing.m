#import <Foundation/Foundation.h>

long long usermicros()
{
    struct rusage usage;
	getrusage( RUSAGE_SELF, &usage );
	return     usage.ru_utime.tv_sec * 1000000 + usage.ru_utime.tv_usec;
}

int main( int argc , char *argv[] ) 
{
  int i,k;
	long long start = usermicros();
    NSNumber* sum = nil;
    for (k=0;k<100000; k++ ) {
      sum =@(0);
      for (i=1;i<= 1000;i++ ) {
        sum =@([sum intValue]+i);    
      }
    }
    NSLog(@"result: %@ user: %lld microseconds",sum,usermicros() - start);
  return 0;
}
