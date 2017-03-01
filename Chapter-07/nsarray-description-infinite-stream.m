#import <Foundation/Foundation.h>

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
   [self setTarget:[NSMutableString string]];
   [self setAlreadySeen:[NSMapTable mapTableWithKeyOptions:NSPointerFunctionsOpaquePersonality valueOptions:NSPointerFunctionsOpaquePersonality]];	
   return self;
}

-(void)writeObject:anObject
{
    if ( [alreadySeen objectForKey:anObject] ) {
	[target appendFormat:@"<already saw: %p>",anObject];
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

int main(int argc, char *argv[] ) {
    [NSAutoreleasePool new];
    id a1=[NSMutableArray array];
    id a2=[NSMutableArray array];
    [a1 addObject:@"a string"];
    [a1 addObject:a2];
    [a2 addObject:a1];
    [a2 addObject:@"another string"];
    NSLog(@"a1: %@",[a1 fastDescription]);
}
