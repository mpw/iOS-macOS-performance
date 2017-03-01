

#import <MPWFoundation/MPWFoundation.h>

@interface DescriptionStream : MPWStream {}  @end  @implementation DescriptionStream


-(void)writeObject:anObject
{
  [anObject describeOn:self];
}
-(void)writeDescription:(NSString*)partialDescription
{
  [target writeObject:partialDescription];
}

@end

@implementation NSArray(describe)

-(void)describeOn:(DescriptionStream*)aStream
{
	[aStream writeDescription:@"( "];
	BOOL first=YES;
	for (id obj in self ) {
		if (first) {
		    first=NO;
		} else {
		   [aStream writeDescription:@", "];
		}
		@autoreleasepool {
		    [aStream writeObject:obj];
		}
	}
	[aStream writeDescription:@")"];
}
@end

@implementation NSObject(describe)
-(void)describeOn:aStream
{
   [aStream writeDescription:[self description]];
}
@end

int main( int argc, char *argv[] ) {
   [NSAutoreleasePool new];
   id s=[DescriptionStream streamWithTarget:[MPWByteStream Stdout]];
   [s writeObject:@[ @[ @"a", @"d" ], @"b", @"c" ]];
   return 0; 
}
