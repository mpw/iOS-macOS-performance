#import <Foundation/Foundation.h>
#include <malloc/malloc.h>
#import <objc/runtime.h>
#import <ObjectiveXML/MPWXmlArchiver.h>
#import <ObjectiveXML/MPWXmlUnarchiver.h>
#import <ObjectiveXML/MPWXmlGeneratorStream.h>
#import <ObjectiveXML/MPWMAXParser.h>
#import <MPWFoundation/CodingAdditions.h>
#import <MPWFoundation/MPWBinaryPListWriter.h>
#import <MPWFoundation/MPWBinaryPlist.h>
#include <libkern/OSAtomic.h>
 

#define UNARCHIVE 0
#define XMLARCHIVE 0
#define XMLARCHIVE_DIRECT 0
#define PLISTONLY 0
#define MPWBPLIST 0
#define MPWBPLIST_VIAPLIST 0
#define PLISTBINARY 0
#define BPLISTCF 0
#define PLISTXML 0
#define PLISTSTREAM 0
#define KEYED 0
#define OLDSTYLE 0
#define JSON  0
#define SUMB  1


#define SAVEARCHIVE 0

@interface NSArray(asPlist)

-(id)asPlist;
@end


@interface SampleObject:NSObject
{
  int retainCount;
  int a;
  float b;
  NSString *name;
  NSArray  *children;
}


@end


@implementation NSOutputStream(appendBytes)

-(void)appendBytes:(void*)bytes length:(unsigned)len
{
  [self write:bytes maxLength:len];
}

@end


@implementation SampleObject


-(NSUInteger)count
{
  int count=2;
    for ( SampleObject *s in children ) {
       count+=[s count];
    }
  return count;
}

-processCArrayFromPlist:someC {
    NSMutableArray *r=[NSMutableArray arrayWithCapacity:[someC count]];
    for ( NSDictionary *d in someC ){
      [r addObject:[[[[self class] alloc] initWithPlist:d] autorelease]];
    }
  return r;
}

-initWithBinaryPlist:(MPWBinaryPlist*)aPlist
{
  self=[super init];
#if 0
  [aPlist parseDictUsingBlock:^(MPWBinaryPlist *plist, long keyIndex,long valueIndex, long anIndex) {
#if 0
      NSString *key=[plist objectAtIndex:keyIndex];
      if ( [key isEqual:@"a"] ) {
         a=[plist currentInt];                                                                                                           
      } else if ( [key isEqual:@"b"] ) {

      } else if ( [key isEqual:@"name"] ) {
            c=[[aPlist currentObject] retain];
      } else if ( [key isEqual:@"children"] ) {
            NSMutableArray *array=[NSMutableArray array];
            [plist parseArrayUsingBlock:^(MPWBinaryPlist *plist, long arrayIndex, long anIndex) {
                     [array addObject:[[[[self class] alloc] initWithBinaryPlist:plist] autorelease]];
            }];
            children=[array retain];
      }
#else
      switch ( anIndex ) {
        case 0:

          a=[plist currentInt];
          break;
        case 1:
          b=[plist readFloat];
          break;
        case 2:
            c=[[aPlist currentObject] retain];
          break;
        case 3:
            NSMutableArray *array=[NSMutableArray array];
            [plist parseArrayUsingBlock:^(MPWBinaryPlist *plist, long arrayIndex, long anIndex) {
                     [array addObject:[[[[self class] alloc] initWithBinaryPlist:plist] autorelease]];
            }];
            c=[array retain];
          break;

      }
#endif
    } ];
#else
//  NSLog(@"parseUsingContentBlock");
  [aPlist parseDictUsingContentBlock:^(MPWBinaryPlist *plist, long keyIndex,long valueIndex, long anIndex) {
    a=[plist readIntegerForKey:@"a"];
    b=[plist readRealForKey:@"b"];
    name=[plist readObjectForKey:@"name"];
    NSMutableArray *array=[NSMutableArray array];
    [plist parseArrayAtKey:@"children" usingBlock:^(MPWBinaryPlist *plist, long arrayIndex, long anIndex) {
         [array addObject:[[[[self class] alloc] initWithBinaryPlist:plist] autorelease]];
       }];
    children=[array retain];
  } ];
#endif

  return self;
}

-initWithBinaryPlistData:(NSData*)aPlist
{
   MPWBinaryPlist *pl=[MPWBinaryPlist bplistWithData:aPlist];
   return [self initWithBinaryPlist:pl];
}

#if !__has_feature(objc_arc)

-(id)retain
{
//   __sync_fetch_and_add(&retainCount,1);
  OSAtomicIncrement32(&retainCount);
//   retainCount++;
   return self;
}

-(oneway void)release
{
//   __sync_fetch_and_add(&retainCount,-1);
  OSAtomicDecrement32(&retainCount);
//   retainCount--;
  if ( retainCount < 0 ) {
    [self dealloc];
  }
}

-(void)dealloc
{
  [name release];
  [children release];
  [super dealloc];
}

#endif

-(float)b { return b; }

-(double)sumB
{
    double result=0;
    for (int i=0;i<10;i++) {
      result+=[self b];
    }
    for ( SampleObject *s in children ) {
      result+=[s sumB];
    }
    return result;
}


static NSString* uniqueString( NSString *aString ) 
{
  static NSMutableSet *strings=nil;
  if ( ! strings ) {
    strings=[NSMutableSet new];
  }
  id result=[strings member:aString];
  if ( !result ) {
    if ( [strings count] > 20 ) {
      [strings removeObject:[strings anyObject]];
    }
    [strings addObject:aString];
    result=aString;
  }
  return result;
}


+parseFromXML:(NSData*)xmlData
{
  static MPWMAXParser *parser=nil;
  if (!parser ) {
    ASSIGN_ID(parser, [MPWMAXParser parser]); 
    [parser setHandler:self forElements:[NSArray arrayWithObject:@"S"]
           inNamespace:nil prefix:@""  map:nil];
    [parser declareAttributes:@[ @"a", @"b" ] inNamespace:nil];
    [parser handleElement:@"S" withBlock:^(id elements,id attributes ,id parser){ 
        id children;
        if ( [elements count] == 1 ) {
          children=uniqueString( [elements lastObject] );
//          children=@"Hello World!";
        } else {
          children=[elements allValues];
        }
        return [[self alloc] initWithA:[[attributes objectForUniqueKey:@"a"] intValue] 
                                     b:[[attributes objectForUniqueKey:@"b"] floatValue]
                                     name:[[attributes objectForUniqueKey:@"name"] stringValue]
                                     children:children];
            }];
  }
  id obj=[parser parsedData:xmlData];
  return obj;
}

-initWithA:(int)newA b:(float)newB name:(id)newC children:(id)newChildren
{
    self=[super init];
    if ( self ) {
      a=newA;
      b=newB;
      name=RETAIN(newC);
      children=RETAIN(newChildren);
    }
    return self;
}

CONVENIENCE( sampleWithA:(int)newA b:(float)newB name:(id)newC children:(id)newChildren, initWithA:newA b:newB name:newC children:newChildren   )

-(void)generateXMLOn:(MPWXmlGeneratorStream*)stream
{
  [stream writeElementName:"S"
          attributeBlock:^(MPWXmlGeneratorStream *s){
            [s writeCStrAttribute:"a" intValue:a]; 
            [s writeCStrAttribute:"b" doubleValue:b]; 
            [s writeCStrAttribute:"name" value:name]; 
          } contentBlock:^(MPWXmlGeneratorStream *s){
             for ( SampleObject *o in children ) {
               [o generateXMLOn:s];
             }
          }];
}

-(void)writeOnPropertyList:aWriter
{
  [aWriter writeDictionaryLikeObject:self withContentBlock:^(id writer,id anObject){
    [writer writeInt:a forKey:@"a"];
    [writer writeFloat:b forKey:@"b"];
    [writer writeObject:name forKey:@"name"];
    [writer writeObject:children forKey:@"children"];
  }];
}

-asXML
{
//  MPWXmlGeneratorStream *s=[MPWXmlGeneratorStream streamWithTarget:[MPWByteStream streamWithTarget:[NSMutableData dataWithCapacity:46 * 1024 * 1024]]];
//     NSOutputStream *stream=[NSOutputStream outputStreamToFileAtPath:@"archive.xmlstream" append:NO];
//     [stream open];
  MPWXmlGeneratorStream *s=[MPWXmlGeneratorStream streamWithTarget:[MPWByteStream streamWithTarget:[NSMutableData dataWithCapacity:50 ]]];
//   MPWXmlGeneratorStream *s=[MPWXmlGeneratorStream streamWithTarget:[MPWByteStream streamWithTarget:stream]];
//  MPWXmlGeneratorStream *s=[MPWXmlGeneratorStream streamWithTarget:[MPWByteStream fileName:@"archive-direct.rawxml"]];
  [self generateXMLOn:s];
  [s close];
//  [stream close];
  return [[s target] target];
//  return nil;
}

-initWithPlist:(NSDictionary*)aPlist
{
  return [self initWithA:[[aPlist objectForKey:@"a"] intValue] b:[[aPlist objectForKey:@"b"] floatValue]
                    name:[aPlist objectForKey:@"name"] children:[self processCArrayFromPlist:[aPlist objectForKey:@"children"]]];
}


-asPlist
{
#if 1
  static id keyset=nil;
#if 1
  if ( !keyset ) {
    keyset=[[NSDictionary sharedKeySetForKeys:@[@"a",@"b",@"name", @"children"]] retain];
  }
  NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithSharedKeySet:keyset];
#else
  NSMutableDictionary *dict=[NSMutableDictionary dictionary];
#endif
  [dict setObject:[NSNumber numberWithInt:a] forKey:@"a"];
  [dict setObject:[NSNumber numberWithFloat:b] forKey:@"b"];
  [dict setObject:name forKey:@"name"];
  [dict setObject:[children asPlist] forKey:@"children"];
  return dict;
#else
  return @{ @"a": @(a), @"b": @(b), @"name": name,  @"children": [children asPlist],  };
  return [NSDictionary dictionaryWithObjectsAndKeys:
          @(a),@"a",
          @(b),@"b",
          name,@"name",nil,
          [children asPlist],@"children",nil];

#endif
}

-(void)encodeWithCoder:(NSCoder*)aCoder
{
#if 1
  encodeVar( aCoder, a );
  encodeVar( aCoder, b );
  encodeVar( aCoder, name );
  encodeVar( aCoder, children );
#else
  [aCoder encodeInt:a forKey:@"a"];
  [aCoder encodeFloat:b forKey:@"b"];
    [aCoder encodeObject:name forKey:@"name"];
    [aCoder encodeObject:children forKey:@"children"];
#endif
}


- (id)initWithCoder:(NSKeyedUnarchiver *)aCoder {
      self = [super init];
      if (self) {
#if 1
        decodeVar( aCoder, a );
        decodeVar( aCoder, b );
        decodeVar( aCoder, name );
        decodeVar( aCoder, children );
#else
        a=[aCoder decodeIntForKey:@"a"];
        b=[aCoder decodeFloatForKey:@"b"];
        name=[[aCoder decodeObjectForKey:@"name"] retain];
        children=[[aCoder decodeObjectForKey:@"children"] retain];
#endif
     }
    return self;
}

-description { return [NSString stringWithFormat:@"<%@:%p: a=%d b=%g name=%@ children=%@>",[self class],self,a,b,name,children]; }

@end


int main(int argc, char *argv[] ) {
    NSData *archive=nil;
    @autoreleasepool {
    [NSUserDefaults standardUserDefaults];
    NSMutableArray *objs=[NSMutableArray array];
    int count=argc>1 ? atoi(argv[1]) : 31;
    int i;
    NSString *s=@"hello world!";
    
    for ( i=0;i<count;i++) {
      @autoreleasepool {
      NSMutableArray *a1=[NSMutableArray array];
      for (int j=0;j<count;j++) {
        @autoreleasepool {
#if 1
         float newB=(float)j/(float)(i+1);
         float newA=j*i;
#else
         float newB=0;
         float newA=0;
#endif
         SampleObject *bottom=[SampleObject sampleWithA:newA b:newB name:s children:[NSArray array]];
         [a1 addObject:bottom]; 
        }
      }
      SampleObject *a=[SampleObject sampleWithA:i b:(float)i name:s children:a1];
      [objs addObject:a];
      }
    }
    SampleObject *top=[SampleObject sampleWithA:100 b:100.12 name:s children:objs] ;
#if 0
    for (int i=0;i<1000;i++ ) {
      [top count];
    }
#endif   
    struct mstats stats=mstats();
    long used_before=stats.bytes_used;
#if XMLARCHIVE
    archive=[top asXML];
#elif XMLARCHIVE_DIRECT
    [top generateXMLOn:[MPWXmlGeneratorStream streamWithTarget:[MPWByteStream fileName:@"archive.rawxml"]]];
#elif PLISTONLY
    id plist=[top asPlist];
#elif MPWBPLIST
    archive=[MPWBinaryPListWriter process:top];
#elif MPWBPLIST_VIAPLIST
    archive=[MPWBinaryPListWriter process:[top asPlist]];
#elif PLISTBINARY
    archive=[NSPropertyListSerialization dataWithPropertyList:[top asPlist] format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
#elif BPLISTCF
    archive=(NSData*)CFPropertyListCreateData ( nil, (CFPropertyListRef)[top asPlist], kCFPropertyListOpenStepFormat , 0, NULL);
#elif PLISTXML
    archive=[NSPropertyListSerialization dataWithPropertyList:[top asPlist] format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];
#elif JSON
    archive=[NSJSONSerialization dataWithJSONObject:[top asPlist] options:0 error:nil];
#elif PLISTSTREAM
//     NSOutputStream *stream=[NSOutputStream outputStreamToFileAtPath:@"archive.someformat" append:NO];
//     [stream open];
//     NSLog(@"stream: %@",stream);
//    [NSPropertyListSerialization writePropertyList:plist toStream:stream format:NSPropertyListXMLFormat_v1_0 options:0 error:nil];
//    [NSPropertyListSerialization writePropertyList:plist toStream:stream format:NSPropertyListBinaryFormat_v1_0 options:0 error:nil];
//    NSLog(@"stream after write");
//    [NSKeyedArchiver archiveRootObject:top toFile:@"keyedarchivedirect.arc"];
//    NSData *archive = [MPWXmlArchiver archivedDataWithRootObject:top];
#elif KEYED
    archive=[NSKeyedArchiver archivedDataWithRootObject:top];
#elif OLDSTYLE
    archive=[NSArchiver archivedDataWithRootObject:top];
#elif SUMB
    NSLog(@"before sum");
    NSLog(@"sum b: %g",[top sumB]);
#endif
//    [stream close];
//    NSLog(@"stream after close");

#if UNARCHIVE
    for (i=0;i<1000;i++) {
      SampleObject *s=nil;
      @autoreleasepool {
#if XMLARCHIVE
       s=[SampleObject parseFromXML:archive];
#elif PLISTONLY
       s =[[[SampleObject alloc] initWithPlist:plist] autorelease];
#elif BPLIST || PLISTBINARY || BPLISTCF || PLISTXML
        s =[[[SampleObject alloc] initWithPlist:[NSPropertyListSerialization propertyListWithData:archive options:0 format:NULL error:nil]] autorelease];
#elif JSON
        s =[[[SampleObject alloc] initWithPlist:[NSJSONSerialization JSONObjectWithData:archive options:0 error:nil]] autorelease];
#elif MPWBPLIST
        s =[[SampleObject alloc] initWithBinaryPlistData:archive];
#elif MPWBPLIST_VIAPLIST
        s= [[[SampleObject alloc] initWithPlist:[[MPWBinaryPlist bplistWithData:archive] rootObject]] autorelease]
#elif KEYED
        s = [NSKeyedUnarchiver unarchiveObjectWithData:archive];
#elif OLDSTYLE
        [NSUnarchiver unarchiveObjectWithData:archive];
#endif

      }
    }
#endif

#if SAVEARCHIVE
   [archive writeToFile:@"archive.rawxml" atomically:YES];
#endif
    stats=mstats();
    printf("n=%d archive size: %ld memory used: %ld \n",count,[archive length], stats.bytes_used-used_before);
      exit(0);
  }
  return 0;
}

@implementation NSString(asPlist) 

-asPlist { return self; }

@end

@implementation NSArray(asPlist)

-asPlist {
   NSMutableArray *plist=[NSMutableArray array];
   for (id a in self ) {
     [plist addObject:[a asPlist]];
   }
   return plist;
}
@end
