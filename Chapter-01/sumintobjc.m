#import <Foundation/Foundation.h>

@interface Summer : NSObject
{
	long long sum;
}

-(void)add:(int)i;
@end

@implementation Summer

-(void)add:(int)newVal {  sum+=newVal; }
-description { return [[NSNumber numberWithLongLong:sum] description]; }

@end

int main( int argc , char *argv[] ) 
{
	id pool=[NSAutoreleasePool new];
	int i;
	int k;	
	id summer=nil;
	summer=[Summer new];
	IMP f_add=[summer methodForSelector:@selector(add:)];
	for (k=0;k<1000000; k++ ){
	for (i=1;i<=1000;i++) {
//		f_add( summer, @selector(add:), i);
		[summer add:i];
	}
	}
	NSLog(@"%@",summer);
}
