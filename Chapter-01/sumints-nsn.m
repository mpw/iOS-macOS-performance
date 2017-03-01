#import <Foundation/Foundation.h>

@interface Summer : NSObject
{
	NSNumber *sum;
}

-(NSNumber*)sum;
-(void)add:(NSNumber*)newNumber;
@end

@implementation Summer

-(NSNumber*)sum { return sum; }
-(void)add:(NSNumber*)newValue {  sum= [NSNumber numberWithInt:[sum intValue]+[newValue intValue]]; }

@end

int main( int argc , char *argv[] ) 
{
	id pool=[NSAutoreleasePool new];
	id summer=[Summer new];
	char buffer[80];
	while ( fgets( buffer, 70, stdin )) {
		[summer add:[NSNumber numberWithInt:atoi( buffer )]];
	}
	NSLog(@"%@",[summer sum]);
}
