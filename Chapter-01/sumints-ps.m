#import <Foundation/Foundation.h>
#import <EGOS/MPWPSInterpreter.h>

int main( int argc , char *argv[] ) 
{
	int j;
	int i,max=atoi(argv[1]);
	id pool=[NSAutoreleasePool new];
	MPWPSInterpreter* interpreter=[MPWPSInterpreter stream];
	[interpreter push:[interpreter makeInt:0]];
//	id stack=[interpreter operandStack];
	for (j=0;j<10;j++) {
	for (i=1;i<= max;i++ ) {
//		interpreter->push( stack, 0, interpreter->self_makeInt( interpreter, 0 ,i ));
		[interpreter pushInt:i];
//		[interpreter push:[interpreter makeInt:i]];
		[interpreter add];
	}
	}
	NSLog(@"sum: %@",[interpreter tos]);
	exit(0) ;
	[pool release];
	return 0;
}
