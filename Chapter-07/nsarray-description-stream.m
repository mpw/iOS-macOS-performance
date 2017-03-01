#import <Foundation/Foundation.h>
#include <malloc/malloc.h>

@interface StdoutTarget:NSObject
{
	int length;
}
@end

@implementation StdoutTarget

-(void)appendString:(NSString*)aTarget
{
    const int maxlen=8192;
    char buffer[ maxlen ];
    NSUInteger used=0;
    NSRange r={0,[aTarget length] };
    BOOL done=NO;
    do {
        NSRange leftover;
	[aTarget getBytes:buffer maxLength:maxlen usedLength:&used encoding:NSUTF8StringEncoding options:0 range:r remainingRange:&leftover];
        if ( used > 0 ) {
//	   write(1, buffer, used );
           length+=used;
           r=leftover;
        } else {
	   done=YES;
        }
    } while (!done);
}
-(int)length { return length; }
@end


@interface MPWDescriptionStream : NSObject
{
	NSMapTable *alreadySeen;
	NSMutableString *target;
}
@property (nonatomic,retain) NSMapTable *alreadySeen;
@property (nonatomic,retain) NSMutableString *target;
-(void)writeObject:anObject;
-(void)describeArray:anArray;
-(void)describeObject:anObject;
@end


@implementation NSObject(describeOn)
-(void)describeOn:aStream {  [aStream describeObject:self]; }
-(NSString*)fastDescription {
	MPWDescriptionStream *s=[[MPWDescriptionStream new] autorelease];
        [s writeObject:self];
        return [s target];    
}
@end
@implementation MPWDescriptionStream

@synthesize alreadySeen,target;

-init
{
   self=[super init];
   [self setTarget:(id)[StdoutTarget new]];
//   [self setAlreadySeen:[NSMapTable mapTableWithKeyOptions:NSPointerFunctionsOpaquePersonality valueOptions:NSPointerFunctionsOpaquePersonality]];	
   return self;
}

-(void)writeObject:anObject
{
    if ( [alreadySeen objectForKey:anObject] ) {
	[target appendString:[NSString stringWithFormat:@"<already saw: %p>",anObject]];
    } else {
        [alreadySeen setObject:anObject forKey:anObject];
	[anObject describeOn:self];
        [alreadySeen removeObjectForKey:anObject];
    }
}
-(void)describeObject:anObject
{
    [target appendString:[anObject description]];
}

-(void)describeArray:(NSArray*)array
{
    BOOL first=YES;
    [target appendString:@"( "];
    for ( id obj in array ) { 
	if (first) {
	   first=NO;
        } else {
           [target appendString:@", "];
        }
	[self writeObject:obj];
    }
    [target appendString:@" )"];
}

@end

@implementation NSArray(describeOn)
-(void)describeOn:aStream {  [aStream describeArray:self]; }
@end


int main(int argc, char *argv[] )
{
    [NSAutoreleasePool new];
    int count=argc>1 ? atoi(argv[1]) : 1000;
    id base=@"Hello World!";
    int i;
    [[NSArray arrayWithObject:base] description];
    for ( i=0;i<count;i++) {
       base=[NSArray arrayWithObject:base];
    }
    struct mstats stats=mstats();
    long used_before=stats.bytes_used;
    NSString *d=[base fastDescription];
    stats=mstats();
    printf("n=%d description size: %ld memory used: %ld mem/size=%ld\n",count,[d length], stats.bytes_used-used_before,(stats.bytes_used-used_before)/[d length] );
    return 0;
}

