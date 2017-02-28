#import <Foundation/Foundation.h>
#include <malloc/malloc.h>
#import <objc/runtime.h>
#import <ObjectiveXML/MPWXmlArchiver.h>
#import <MPWFoundation/CodingAdditions.h>

@interface SampleObject:NSObject
{
  int a;
  float b;
  id c;
}

@end
@implementation SampleObject

-initWithA:(int)newA b:(float)newB c:(id)newC
{
    self=[super init];
    if ( self ) {
      a=newA;
      b=newB;
      c=[newC retain];
    }
    return self;
}

-asPlist
{
  NSMutableDictionary *dict=[NSMutableDictionary dictionary];
  [dict setObject:[NSNumber numberWithInt:a] forKey:@"a"];
  [dict setObject:[NSNumber numberWithFloat:b] forKey:@"b"];
  [dict setObject:c forKey:@"c"];
  return dict;
}

-(void)encodeWithCoder:(NSCoder*)aCoder
{
  encodeVar( aCoder, a );
  encodeVar( aCoder, b );
  encodeVar( aCoder, c );
}


- (id)initWithCoder:(NSCoder *)aCoder {
      self = [super init];
      if (self) {
        decodeVar( aCoder, a );
        decodeVar( aCoder, b );
        decodeVar( aCoder, c );
     }
    return self;
}

-(void)dealloc
{
  [c release];
  [super dealloc];
}
@end

//#define KEYED 1

NSArray *toPlist( NSArray *sampleObjects ) {
  NSMutableArray *p=[NSMutableArray arrayWithCapacity:[sampleObjects count]];
  for ( SampleObject *s in sampleObjects ) {
    [p addObject:[s asPlist]];
  }
  return p;
}

int main(int argc, char *argv[] ) {
    [NSAutoreleasePool new];
    NSMutableArray *objs=[NSMutableArray array];
    int count=argc>1 ? atoi(argv[1]) : 1000;
    id base=@"Hello World!";
    int i;
    int size=class_getInstanceSize ([SampleObject class])+16;  // size of NSString
    
    for ( i=0;i<count;i++) {
//      SampleObject *a=[[[SampleObject alloc] initWithA:i b:(float)i c:[NSString stringWithFormat:@"%d",i]] autorelease];      
      SampleObject *a=[[[SampleObject alloc] initWithA:i b:(float)i c:@"hello world"] autorelease];
      [objs addObject:a];
    }
    struct mstats stats=mstats();
    long used_before=stats.bytes_used;
  //  NSData *archive=[NSPropertyListSerialization dataWithPropertyList:toPlist(objs) format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
//    NSData *archive=[NSPropertyListSerialization dataWithPropertyList:toPlist(objs) format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];
//    NSData *archive=[NSJSONSerialization dataWithJSONObject:toPlist(objs) options:0 error:nil];

    NSData *archive = [MPWXmlArchiver archivedDataWithRootObject:objs];
//  [archive writeToFile:@"archive.xml" atomically:YES];    
/*
#if KEYED
    NSData *archive=[NSKeyedArchiver archivedDataWithRootObject:objs];
#else
    NSData *archive=[NSArchiver archivedDataWithRootObject:objs];
#endif
    for (i=0;i<1000;i++) {
      @autoreleasepool {
#if KEYED        
        NSArray *a=[NSKeyedUnarchiver unarchiveObjectWithData:archive];
#else
        NSArray *a=[NSUnarchiver unarchiveObjectWithData:archive];
#endif
      }
    }
*/
    stats=mstats();
    printf("n=%d instance size: %d archive size: %ld memory used: %ld mem/n*instance size=%g\n",count,size,[archive length], stats.bytes_used-used_before,(stats.bytes_used-used_before)/((double)count * size));

}
