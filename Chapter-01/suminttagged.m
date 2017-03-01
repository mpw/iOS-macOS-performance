#import <Foundation/Foundation.h>

#define kCFTaggedObjectID_Integer  ((3 << 1) + 1)
#define kCFNumberSInt32Type  3
#define kCFTaggedIntTypeOffset 6
#define kCFTaggedOffset 2
#define kCFTaggedIntValueOffset (kCFTaggedIntTypeOffset+kCFTaggedOffset)

static inline int getInt( NSNumber *o ) {
	long long n=(long long)o;
	if ( n & 1 ) {
		return  n >> kCFTaggedIntValueOffset;
	} else {
		return [o intValue];
	}
}


static inline NSNumber *makeInt( int i ) {
	long long o=i;
	o=(o << kCFTaggedIntValueOffset) | (kCFTaggedObjectID_Integer | (kCFNumberSInt32Type<<kCFTaggedIntTypeOffset));
	return (NSNumber*)o;
}

int main( int argc , char *argv[] ) 
{
	int i,k;
	NSNumber* sum = nil;
	for (k=0;k<1000000; k++ ) {
		sum =makeInt(0);
		for (i=1;i<=1000;i++) {
			sum =makeInt(getInt(sum)+i);
		}
	}
	NSLog(@"%@/%@ -> '%@'",sum,[sum class],[sum stringValue]);

	return 0;
}
