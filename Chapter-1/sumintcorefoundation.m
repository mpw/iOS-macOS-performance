#import <Foundation/Foundation.h>

// tagged integers:
// http://objectivistc.tumblr.com/post/7872364181/tagged-pointers-and-fast-pathed-cfnumber-integers-in
//
/*
   6         5         4         3         2         1         0
3210987654321098765432109876543210987654321098765432109876543210
........................................................xxxx0011
|                                                       |   |  +-- (1 bit) always 1 for tagged pointers
|                                                       |   +----- (3 bits) 001 is the tagged object class for integers
|                                                       +--------- (4 bits) for integers, xxxx is either:
|                                                                           0000 for 8-bit integers,
|                                                                           0100 for 16-bit integers,
|                                                                           1000 for 32-bit integers,
|                                                                           1100 for 64-bit integers
+------------------------------------------------------------------ (56 bits) payload with the actual integer value

_objc_tagged_isa_table[])


The next 3 bits (from lowest to highest) define the tagged object class. At the moment, there are classes for 
integers, managed objects, and dates;

*/

#define TAGGED_INTS 1


static inline int getInt( NSNumber *o ) {
	long long n=(long long)o;
	if ( n & 1 ) {
		return  n >> 8;
	} else {
		return [o intValue];
	}
}

static inline NSNumber *makeInt( int i ) {

	long long o=i;
	o=(o << 8) | 0x83;
	return (NSNumber*)o;
}

int main( int argc , char *argv[] ) 
{
	int i,k;
	id pool=[NSAutoreleasePool new];
	NSNumber* sum = nil;
#if 0
	for (i=0;i<100;i++) {
		NSNumber *n=[NSNumber numberWithInt:i];
		NSLog(@"%d: %p -> %d",i,n,((long long)n)>>8);
	}
#endif
	for (k=0;k<100000; k++ ) {
		id inner=[NSAutoreleasePool new];
#if TAGGED_INTS
		sum =makeInt(0);
#else
		sum =[NSNumber numberWithInt:0];
#endif
		for (i=1;i<=1000;i++) {
#if TAGGED_INTS
			sum =makeInt(getInt(sum)+i);
#else
			sum =[NSNumber numberWithInt:[sum intValue]+1];
#endif
		}
		[sum retain];
		[inner drain];
		[sum autorelease];
	}
	NSLog(@"%@/%@ -> '%@'",sum,[sum class],[sum stringValue]);

	return 0;
}
