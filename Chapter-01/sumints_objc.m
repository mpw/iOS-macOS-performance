#import <Foundation/Foundation.h>

NSNumber *increment( NSNumber *value )
{
	return @([value intValue]+1);
}

int main( int argc , char *argv[] ) 
{
  int i,k;
	id pool=[NSAutoreleasePool new];
    NSNumber* sum = nil;
    for (k=0;k<100000; k++ ) {
      sum =@(0);
      for (i=1;i<= 1000;i++ ) {
        sum =@([sum intValue]+i);    
		sum =increment( sum );
      }
    }
    NSLog(@"%@",sum);
  return 0;
}
