#import <Foundation/Foundation.h>


int main( int argc , char *argv[] ) 
{
	int i,max=atoi(argv[1]);
	id pool=[NSAutoreleasePool new];
	NSNumber *sum=[NSNumber numberWithInt:0];
	for (i=1;i<= max;i++ ) {
		NSNumber *cur=[NSNumber numberWithInt:i];	
		sum=[NSNumber numberWithLongLong:[sum longLongValue]+[cur intValue]];
	}
	NSLog(@"sum: %@",sum);
	exit(0) ;
	[pool release];
	return 0;
}
