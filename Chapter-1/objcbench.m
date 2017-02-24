//  objcbench.m
//
//  Copyright 2009, Marcel Weiher. 
//

#define  __IMAGEIO__ 1


#include <CoreServices/CoreServices.h>
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import <MPWFoundation/MPWFoundation.h>
#import <MPWFoundation/MPWSmallStringTable.h>
#import <MPWFoundation/NSThreadInterThreadMessaging.h>
#import <MPWFoundation/MPWInteger.h>
#import <MPWFoundation/MPWValueAccessor.h>
#import <MPWFoundation/MPWFastInvocation.h>
#import <objc/runtime.h>

#include <sys/time.h>
#include <unistd.h>
#import <mach/mach_time.h>

#include <dispatch/dispatch.h>


void csvTable( NSArray *results );

static int shiftLeft=0;
static int mask=0;

@interface MPWTRusage : NSObject
{
	  NSString  *name;
	  struct rusage usage;
        NSInteger iterations;
}

objectAccessor_h( NSString , name, setName )

-(double)userNS;
-(double)userNSPerIteration;
-(void)setIterations:(NSInteger)newIterations;
+current;
+timeRelativeTo:(MPWTRusage*)start;
-(long)userMicroseconds;
-subtractStartTime:(MPWTRusage*)start;
-(double)userNSPerIteration;
-(void)setNSPer:(double)nsper;


@end

@implementation MPWTRusage

static int itoa( char *buffer, long a ) {
  char tempbuf[40];
  int len=0;
  while ( a > 0 ) {
    tempbuf[len++]=(a%10)+'0';
    a/=10;
  }
  for (int i=0;i<len;i++) {
    buffer[i]=tempbuf[len-i-1];
  }
  buffer[len]=0;
  return len;
}


objectAccessor( NSString , name, setName )

-(void)setIterations:(NSInteger)newIterations {  iterations=newIterations; }
-(NSInteger)iterations { return iterations; }

-(void)setNSPer:(double)nsper
{
	usage.ru_utime.tv_sec=0;
	usage.ru_utime.tv_usec=nsper*1000;
	[self setIterations:1000000];
}

-initWithCurrent
{
        if ((self=[super init])) {
                getrusage( RUSAGE_SELF, &usage );
        }
        return self;
}

+current {
        return [[[self alloc] initWithCurrent] autorelease];
}

+timeRelativeTo:(MPWTRusage*)start
{
        return [[self current] subtractStartTime:start];
}

+timeWithName:(NSString*)newName value:(double)newTime
{
	MPWTRusage* newUsage =[[[self alloc] init] autorelease];
	[newUsage setName:newName];
	[newUsage setNSPer:newTime];
	return newUsage;
}

-(struct rusage*)usage {
        return &usage;
}

-(struct timeval)timevalFrom:(struct timeval)tvstart to:(struct timeval)tvstop
{
        tvstop.tv_sec -= tvstart.tv_sec;
        tvstop.tv_usec -= tvstart.tv_usec;
        if ( tvstop.tv_usec < 0 ) {
                tvstop.tv_sec--;
                tvstop.tv_usec+=1000000;
        }
        return tvstop;
}


-(long)microsecondsForTimeVal:(struct timeval)timeval
{
        return timeval.tv_sec  * 1000000 + timeval.tv_usec;
}

-(long)systemMicroseconds {
        return [self microsecondsForTimeVal:usage.ru_stime];
}

-(long)userMicroseconds {
        return [self microsecondsForTimeVal:usage.ru_utime];
}

-subtractStartTime:(MPWTRusage*)start
{
        struct rusage start_usage;
//      NSAssert( start != nil );
        start_usage=*[start usage];
        usage.ru_utime = [self timevalFrom:start_usage.ru_utime to: usage.ru_utime];
        usage.ru_stime = [self timevalFrom:start_usage.ru_stime to: usage.ru_stime];

#define USAGE_SUBTRACT( member )  usage.member -= start_usage.member

         USAGE_SUBTRACT(  ru_maxrss);          /* integral max resident set size */
         USAGE_SUBTRACT(  ru_ixrss);           /* integral shared text memory size */
         USAGE_SUBTRACT(  ru_idrss);           /* integral unshared data size */
         USAGE_SUBTRACT(  ru_isrss);           /* integral unshared stack size */
         USAGE_SUBTRACT(  ru_minflt);          /* page reclaims */
         USAGE_SUBTRACT(  ru_majflt);          /* page faults */
         USAGE_SUBTRACT(  ru_nswap);           /* swaps */
         USAGE_SUBTRACT(  ru_inblock);         /* block input operations */
         USAGE_SUBTRACT(  ru_oublock);         /* block output operations */
         USAGE_SUBTRACT(  ru_msgsnd);          /* messages sent */
         USAGE_SUBTRACT(  ru_msgrcv);          /* messages received */
         USAGE_SUBTRACT(  ru_nsignals);        /* signals received */
         USAGE_SUBTRACT(  ru_nvcsw);           /* voluntary context switches */
         USAGE_SUBTRACT(  ru_nivcsw);          /* involuntary context switches */
        return self;
}


-(double)systemNSPerIteration {
	return ([self systemMicroseconds] * 1000.0) / iterations;
}

-(double)userNS {
	return ([self userMicroseconds] * 1000.0);
}

-(double)userNSPerIteration {
	return [self userNS]  / iterations;
}

-(double)measuredNSPerIteration
{
    return [self userNSPerIteration];
}

-description {  return [NSString stringWithFormat:@"[ %@:  %d iterations user: %g ns/iteration system: %g ns/iteration ]",[self name],[self iterations],[self userNSPerIteration],[self systemNSPerIteration]]; }

-(NSComparisonResult)compare:otherObject
{
	double otherTime=[otherObject userNSPerIteration];
	double myTime=[self userNSPerIteration];
	if ( myTime > otherTime ) {
		return 1;
	} else if ( otherTime > myTime ) {
		return -1;
	} else {
		return 0;
	}	
}

@end

long a=0;

@interface IncreaseAOperation : NSOperation
@end

@implementation IncreaseAOperation
-(void)start
{
	OSAtomicIncrement32(&a);
}

-(void)notify
{
  a++;
}
@end

@interface DummyClass : NSObject {} 
-dummyMethod:arg andAnother:another;
@end

@implementation DummyClass 
-dummyMethod:arg andAnother:another
{
   return @"";
}
@end

@interface Tester : NSObject {
	id anObject;
	id observedProperty;
	id unobservedProperty;
  id manualKVOObserverdProperty;
	id macroIvar;
	id bindingSource;
	id bindingTarget;
        int ivarA;
	BOOL forwardingAllowed;
	NSMutableDictionary *dict;
	MPWValueAccessor *dictAccessor;
}

@property(retain)  id anObject;
@property(retain, nonatomic)  id observedProperty;
@property(retain, nonatomic)  id unobservedProperty;
@property(retain, nonatomic)  id bindingSource,bindingTarget;
@property(retain, nonatomic) NSMutableDictionary *dict;
@property(retain, nonatomic) id world;

@end

@implementation Tester

@synthesize anObject,observedProperty,unobservedProperty,bindingSource,bindingTarget,dict;
@dynamic world;

idAccessor( macroIvar, setMacroIvar )
intAccessor( ivarA, setIvarA )


-(void)setManualKVOObservedProperty:newValue
{
  [self willChangeValueForKey:@"manualKVOObserverdProperty"];
  [newValue retain];
  [manualKVOObserverdProperty release];
  manualKVOObserverdProperty=newValue;
  [self didChangeValueForKey:@"manualKVOObserverdProperty"];
}

-manualKVOObserverdProperty
{
  return manualKVOObserverdProperty;
}

-(int)dummy { return 4; }

static Class attrStringClass=nil;

#define MICROSECOND_THRESHOLD   (1000 * 100)
#define ITERATION_THRESHOLD   (1000LL * 1000LL * 1000LL  )

#define SIMPLETESTBODY( expr ) \
	long i;\
	for (i=0;i<iterations;i++) { \
		expr; \
	}\


-(void)forwardInvocation:(NSInvocation*)inv
{ 
  if ( YES ) {
      SEL sel=[inv selector];
      NSString *msg=NSStringFromSelector( sel );
      if ( [msg hasPrefix:@"set"] ) {
	NSRange  r      = NSMakeRange(3,1);
	NSString *first = [msg substringWithRange:r];
	NSString *rest  = [msg substringFromIndex:4];
	NSString *key   = nil;
        id arg=nil;
        [inv getArgument:&arg atIndex:2];
	first=[first lowercaseString];
	key=[first stringByAppendingString:rest];
	[dict setObject:arg forKey:key];
      } else {
	id result=[dict objectForKey:msg];
	[inv setReturnValue:&result];
      }
   } else {
      [super forwardInvocation:inv];
   } 
}

-methodSignatureForSelector:(SEL)aSelector
{
    NSString *s=NSStringFromSelector(aSelector);
    if ( [s hasPrefix:@"set"] ) {
	return [super methodSignatureForSelector:@selector(setDict:)];
    } else {
	return [super methodSignatureForSelector:@selector(dict)];
    }
}

-(void)reportTime:(double)time forLabel:(char*)label iterations:(NSInteger)iterations
{
	printf("%s:\t %10.4f ns/iteration using %ld iterations\n",label,time,(long)iterations);
	
}

-initWithLogPath:(char*)logPath useXML:(BOOL)xml config:(char*)configstring
{
	self=[super init];
	if (self) {
		forwardingAllowed=NO;
		dictAccessor=[[MPWValueAccessor valueForName:@"key"] retain];
	}
	return self;
}

-attribute { return self; }

-(void)pthreadLockedAddition:(long)iterations
{
	pthread_mutex_t mutex;
	pthread_mutex_init( &mutex, NULL );

	SIMPLETESTBODY( pthread_mutex_lock( &mutex); a++;      pthread_mutex_unlock(&mutex); );

	pthread_mutex_destroy( &mutex );
}

-(void)dictGetViaForward:(long)iterations
{
    forwardingAllowed=YES;
    [self setDict:[NSMutableDictionary dictionary]];
    [[self dict] setObject:@"hello" forKey:@"world"];
    SIMPLETESTBODY( self.world );
    forwardingAllowed=NO;
    
}



-(void)valueAccessorGetOffsetAccessor:(long)iterations with:(MPWValueAccessor*)a
{
    [a _setOffset:8];
    SIMPLETESTBODY( GETVALUE(a) ); 
}


-(void)valueAccessorGetAccessor:(long)iterations with:(MPWValueAccessor*)a
{
    SIMPLETESTBODY( GETVALUE(a) ); 
}

-(void)valueAccessorGetAccessorBound:(long)iterations with:(MPWValueAccessor*)a
{
    [a bindToTarget:self];
    SIMPLETESTBODY( GETVALUE(a) ); 
}

-(void)sendNSInvocation:(long)iterations
{
  SEL selector=@selector(dummyMethod:andAnother:);
  DummyClass *d=[[DummyClass new] autorelease];
  NSMethodSignature *sig=[d methodSignatureForSelector:selector];
  NSInvocation *inv=[NSInvocation invocationWithMethodSignature:sig];
  [inv setSelector:selector];
  id a=@"a";
  SIMPLETESTBODY( [inv setArgument:&a atIndex:2]; [inv setArgument:&a atIndex:3]; [inv invokeWithTarget:d]  );

}

-(void)sendMacroFastInvocation:(long)iterations 
{
  DummyClass *d=[[DummyClass new] autorelease];
  MPWFastInvocation *invocation=[MPWFastInvocation invocation];
  [invocation setSelector:@selector(dummyMethod:andAnother:)];
  [invocation setTarget:d];
  [invocation setArgument:&a atIndex:2];
  [invocation setArgument:&a atIndex:3];
  [invocation setUseCaching:YES];
  SIMPLETESTBODY( INVOKE( invocation ) );
}

-(void)sendFastInvocation:(long)iterations withCaching:(BOOL)shouldCache
{
  DummyClass *d=[[DummyClass new] autorelease];
  MPWFastInvocation *invocation=[MPWFastInvocation invocation];
  [invocation setSelector:@selector(dummyMethod:andAnother:)];
  [invocation setTarget:d];
  id a=@"a";
  id args[2]={ a,a };
  if ( shouldCache ) {
    [invocation setUseCaching:YES];
   }
  SIMPLETESTBODY( [invocation resultOfInvokingWithArgs:args count:2] );
}

-(void)valueAccessorGetAccessorDict:(long)iterations with:dict
{
//    MPWValueAccessor *a=[MPWValueAccessor valueForName:@"key"];
    MPWValueAccessor *a=dictAccessor;
    [a bindToTarget:dict];
    SIMPLETESTBODY( GETVALUE(a) ); 
}

-(void)nsdatamap:(long)iterations
{
    SIMPLETESTBODY( @autoreleasepool {  [NSData dataWithContentsOfMappedFile:@"objcbench.m"]; } );
}

-(void)nsdataread:(long)iterations
{
    SIMPLETESTBODY( @autoreleasepool {  [NSData dataWithContentsOfFile:@"objcbench.m"]; } );
}

-(void)dictSetViaForward:(long)iterations
{
    forwardingAllowed=YES;
    [self setDict:[NSMutableDictionary dictionary]];
    [[self dict] setObject:@"hello" forKey:@"world"];
    SIMPLETESTBODY( self.world = @"hello"; );
    forwardingAllowed=NO;
    
}

-(void)fork:(long)iterations
{
	int childPid=0;
	SIMPLETESTBODY( switch ( childPid=fork() ) { case 0: exit(1);   case -1: return; default: wait( NULL ); }  );
}


-(void)system:(long)iterations
{
	SIMPLETESTBODY( system("dc </dev/null  >/dev/null"); );
}

-(void)synchronizedAdditionTest:(long)iterations
{
	SIMPLETESTBODY( @synchronized(self) {  a+=i;  } );
}

-(void)additionTest:(long)iterations
{
	int local=0;
	SIMPLETESTBODY( local+=i;  );
	a=local;
}

-(void)additionTestUnrolled:(long)iterations
{
	int local=0;
	iterations/=4;
	SIMPLETESTBODY( local+=i; local+=i; local+=i; local+=i;  );
	a=local;
}

-(void)nonAtomicPropertyTest:(long)iterations
{
	SIMPLETESTBODY( [self unobservedProperty]; );
}

-(void)atomicPropertyTest:(long)iterations
{
	SIMPLETESTBODY( [self anObject]; );
}

-(void)idAccessorWriteTest:(long)iterations
{
	SIMPLETESTBODY( [self setMacroIvar:@"dummy"]; );
}

-(void)idAccessorReadTest:(long)iterations
{
	SIMPLETESTBODY( [self macroIvar]; );
}

-(void)performSelectorTest:(long)iterations
{
	SIMPLETESTBODY( [self performSelector:@selector(macroIvar)]; );
}

-(void)incrementAtomicTest:(long)iterations
{
	a=0;
	SIMPLETESTBODY( OSAtomicIncrement32(&a); );
}

-(void)multiplyTest:(long)iterations
{
	int local=iterations;
	SIMPLETESTBODY( local*=i;  );
	a=local;
}
-(void)divideTest:(long)iterations
{
	int local=iterations;
	SIMPLETESTBODY( local=local/(i+1);  );
	a=local;
}

-snprintfDoubleTest:(long)iterations
{
  char buffer[800];
  double a=3.14159;
  SIMPLETESTBODY( snprintf(buffer,600," attribute=\"%g\" ",a));
}

-snprintfIntegerTest:(long)iterations
{
  char buffer[800];
  SIMPLETESTBODY( snprintf(buffer,600," attribute=\"%d\" ",i));
}

-itoaTest:(long)iterations
{
  char buffer[800];
  SIMPLETESTBODY( itoa( buffer, i ));
}

-(void)emptyTest:(long)iterations
{
	SIMPLETESTBODY(  );
}

-(void)allocReleaseTest:(long)iterations
{
	SIMPLETESTBODY([[[MPWInteger alloc] init] release] );
}


-(void)getObjectSlowTest:(long)iterations with:(MPWObjectCache*)objCache
{
	[objCache setUnsafeFastAlloc:YES];
	SIMPLETESTBODY( id obj= GETOBJECT(  objCache ); [[obj retain] autorelease]; );

}

-(void)getObjectTest:(long)iterations with:(MPWObjectCache*)objCache
{
	[objCache setUnsafeFastAlloc:YES];
	SIMPLETESTBODY( GETOBJECT(  objCache ); );

}

-(void)callocTest:(long)iterations
{
	SIMPLETESTBODY( free(calloc(16,1)) );
}

-(void)mallocTest:(long)iterations
{
	SIMPLETESTBODY( free(malloc(16)) );
}

-(void)autoreleaseDoubleTest:(long)iterations
{
	SIMPLETESTBODY(  id obj=[[[MPWInteger alloc] init] autorelease]; [[obj retain] autorelease];  );
}


-(void)autoreleaseTest:(long)iterations
{
	SIMPLETESTBODY(  [[[MPWInteger alloc] init] autorelease]  );
}

-(void)autoreleaseLanguageTest:(long)iterations
{
	id object=[NSString stringWithUTF8String:"hello world!"];
	SIMPLETESTBODY( @autoreleasepool { [[object retain] autorelease]; } ); 
}


-(void)nestedAutoreleasePoolTest:(long)iterations
{
	id object=[NSString stringWithUTF8String:"hello world!"];
	SIMPLETESTBODY( id pool=[NSAutoreleasePool new]; [[object retain] autorelease]; [pool drain];  ); 
}

-(void)nsIntNumberBitShiftAndIntValue:(long)iterations
{
#define MAKEINT( num )   ((id)((((long long)num) << shiftLeft) | mask ))
	int num=1024;
	if ( !mask ) {
		id nsnum=[NSNumber numberWithInt:num];
		long long tester=(long long)nsnum;
		for ( shiftLeft =0; tester > num ; shiftLeft++, tester >>= 1 ) {
			;
		}
		mask = (long long)nsnum & ((1<<shiftLeft)-1);
	}
	SIMPLETESTBODY( [MAKEINT( num ) intValue] );
}

-(void)nsIntNumberConvenience:(long)iterations
{
	int num=1024;
	id nsno=nil;
	SIMPLETESTBODY( nsno=[NSNumber numberWithInt:num] );
//	NSLog(@"NSNumber: %@/%p",nsno,nsno);
}


-(void)nsArrayAlloc:(long)iterations
{
	SIMPLETESTBODY( [[[NSMutableArray alloc] initWithCapacity:10] release] );
}


-(void)nsFloatNumber:(long)iterations
{
	SIMPLETESTBODY( [[[NSNumber alloc] initWithFloat:(float)i] release] );
}


-(void)nsIntNumber:(long)iterations
{
	int num=1024;
	SIMPLETESTBODY( [[[NSNumber alloc] initWithInt:num] release] );
}

-(void)cfFloatNumber:(long)iterations
{
	
	SIMPLETESTBODY( float f=i; [(id)CFNumberCreate(NULL, kCFNumberFloatType, &f) release] );
}



-(void)reduceAccessingIndividualObjs:(long)iterations with:(MPWRealArray*)array
{
	float sum=0;
	SIMPLETESTBODY( id pool=[NSAutoreleasePool new]; for (int i=0,max=[array count]; i<max; i++ ) 
		{  sum+=[[array objectAtIndex:i] floatValue]; } [pool release];  );
}



-(void)reduceAccessingIndividualReals:(long)iterations with:(MPWRealArray*)array
{
	float sum=0;
	SIMPLETESTBODY( for (int i=0,max=[array count]; i<max; i++ ) 
		{  sum+=[array realAtIndex:i]; }  );
}

-nsArrayFrom:(float)realStart to:(float)realStop
{
    NSMutableArray *result=[NSMutableArray array];
    float i;
    for (i=realStart ; i<=realStop; i++ ) {
	[result addObject:[NSNumber numberWithFloat:i]];
    }
    return result;
}

-mpwRealArrayFrom:(float)realStart to:(float)realStop
{
    MPWRealArray *result=[[[MPWRealArray alloc] initWithCapacity:10] autorelease];
    float i;
    for (i=realStart ; i<=realStop; i++ ) {
        [result addReal:i];
    }
    return result;
}


-(void)reduceOperatorPlus:(long)iterations with:(MPWRealArray*)array
{
  float totalSum=0,sum=0;
	SIMPLETESTBODY( sum=[array vec_reduce_sum]; totalSum+=sum  );
  printf("sum=%g totalSum=%g",sum,totalSum);
}

-(void)vecReduceOperatorPlus:(long)iterations with:(MPWRealArray*)array
{
	SIMPLETESTBODY( [array vec_reduce_sum];  );
}


-(void)mpwRealArray:(long)iterations
{
	SIMPLETESTBODY( [[[MPWRealArray alloc] initWithCapacity:10] release]  );
}

-(void)cfIntNumber:(long)iterations
{
	int num=1002212;
	CFAllocatorRef allocator = CFAllocatorGetDefault();
	SIMPLETESTBODY(  id objnum=(id)CFNumberCreate(allocator, kCFNumberIntType, &num); if ( ((long long)objnum & 1) == 0 )  { [objnum release]; }  );
}


-(void)msgTestDummy:(long)iterations with:someObject
{
	SIMPLETESTBODY( [self dummy] );
}

-(void)msgTestSelf:(long)iterations with:someObject
{
	SIMPLETESTBODY( [someObject self] );
}


-(void)cfNumberGetInt:(long)iterations with:(CFNumberRef)number
{
	int value=0;
	SIMPLETESTBODY( CFNumberGetValue( number,  kCFNumberSInt32Type , &value ) );
}



-(void)impCachedDummy:(long)iterations
{
	[self dummy];
	IMP intValueFn=[self methodForSelector:@selector(dummy)];
	SIMPLETESTBODY( intValueFn( self, @selector(dummy) ));
}


-(void)impCachedIntValue:(long)iterations with:number
{
	[number intValue];
	IMP intValueFn=[number methodForSelector:@selector(intValue)];
	SIMPLETESTBODY( intValueFn( number, @selector(intValue) ));
}


-(void)nsNumberIntValue:(long)iterations with:number
{
//	NSLog(@"number: %@",number);
	SIMPLETESTBODY( [number intValue] );
}

#define LOOKUPKEY  "reallylongkeymorethanafewchars1"
//#define LOOKUPKEY  "key2"

-(void)smallCFDictLookup:(long)iterations with:(CFDictionaryRef)dict
{
	NSString *key=[[[NSString stringWithUTF8String:LOOKUPKEY] stringByAppendingString:@"2"] substringToIndex:[@LOOKUPKEY length]];
	SIMPLETESTBODY( CFDictionaryGetValue( dict, key )); 
}


-(void)smallStringTableLookup:(long)iterations with:(MPWSmallStringTable*)table
{
	SIMPLETESTBODY( OBJECTFORCONSTANTSTRING( table, LOOKUPKEY )   ); 
}

-(void)threadSpecificLookup:(long)iterations with:objkey
{
	pthread_key_t key=-1;
	pthread_key_create( &key, NULL);
	pthread_setspecific( key, (void*)2 );
	SIMPLETESTBODY( a+= (NSUInteger)pthread_getspecific( key ) );
}


-(void)smallDictLookupNotFound:(long)iterations with:dict
{
	id key=[NSString stringWithUTF8String:"key999"];
//	NSLog(@"key: %p",key);
	SIMPLETESTBODY( [dict objectForKey:key] );
}



-(void)smallDictLookupConstKey:(long)iterations with:dict
{
	id key=@LOOKUPKEY;
	SIMPLETESTBODY( [dict objectForKey:key] );
}

-(void)smallDictLookupTaggedKey:(long)iterations with:dict
{
	id key=[[NSMutableString stringWithUTF8String:LOOKUPKEY] copy];
	NSLog(@"copied mutable key: %p",key);
	SIMPLETESTBODY( [dict objectForKey:key] );
}


-(void)smallDictLookupMutableKey:(long)iterations with:dict
{
	id key=[NSMutableString stringWithUTF8String:LOOKUPKEY];
	NSLog(@"key: %p %@",key,[key className]);
	SIMPLETESTBODY( [dict objectForKey:key] );
}

-(void)smallDictSet:(long)iterations with:dict
{
	SIMPLETESTBODY( [dict setObject:@"newValue" forKey:@"key"] );
}

-(void)kvcLookup:(long)iterations with:aTester
{
	SIMPLETESTBODY( [aTester valueForKey:@"attribute"] );
}

static char associated_object_key;

-(void)associatedObjectLookup:(long)iterations with:aTester
{
	objc_setAssociatedObject ( self, &associated_object_key, @"some object", OBJC_ASSOCIATION_RETAIN);
	SIMPLETESTBODY( objc_getAssociatedObject(self, &associated_object_key);  );
}

-(void)kindOfClass:(long)iterations with:testObject
{
	SIMPLETESTBODY( [testObject isKindOfClass:attrStringClass] );
}

-(void)nstringAppend:(long)iterations with:testObject
{
	SIMPLETESTBODY( [testObject appendString:@"s"] );
}

-(void)stringReplaceAtEnd:(long)iterations with:testObject
{
	SIMPLETESTBODY( [testObject  replaceCharactersInRange:NSMakeRange( [testObject length],0) withString:@"s"] );
}



-(void)cStringCompareNoMatch:(long)iterations with:testObject
{
	const char *cString=[testObject UTF8String];
	const char *cString1="bozo";
	SIMPLETESTBODY( a+=(cString1[0]==cString[0]) && !strcmp(cString,cString1) );
}

void* inca( void *b ) {  a++; return NULL; }

-(void)pthreadDetachedIncreaseA:(long)iterations with:testObject
{
	pthread_t thread=0;
	a=0;
	SIMPLETESTBODY(  pthread_create(&thread, NULL, inca, NULL); pthread_detach( thread  ) );
//	NSLog(@"a-iterations = %ld",a-iterations);
}

-(void)pthreadJoinedIncreaseA:(long)iterations with:testObject
{
	pthread_t thread=0;
	a=0;
	SIMPLETESTBODY(  pthread_create(&thread, NULL, inca, NULL); pthread_join( thread , NULL ) );
//	NSLog(@"a-iterations = %ld",a-iterations);
}

typedef void (^voidBlock)(void );


-(void)dispatch:(long)iterations with:testObject
{
        a=0;
	voidBlock block= ^{ [self class];  OSAtomicIncrement32(&a);};
	voidBlock globalBlock = Block_copy( block );	
//        SIMPLETESTBODY(  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) , globalBlock));
        SIMPLETESTBODY(  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) , 
			^{ [self setIvarA:i];  OSAtomicIncrement32(&a);} ));
	while ( a < iterations ) { 
//	    NSLog(@"gcd a-iterations = %ld",a-iterations);
	}
//	NSLog(@"gcd a-iterations = %ld",a-iterations);
}

-(void)dispatch100:(long)iterations with:testObject
{
	SIMPLETESTBODY( [self dispatch:100 with:testObject]; );
}


-(void)nsoperation:(long)iterations with:queue
{
	a=0;
	SIMPLETESTBODY( [queue addOperation:[[[IncreaseAOperation alloc] init] autorelease]]; );
//	[queue waitUntilAllOperationsAreFinished];
	while ( a < iterations ) { 
//	    NSLog(@"nsoperation a-iterations = %ld",a-iterations);
	}
//      NSLog(@"nsoperation a-iterations = %ld",a-iterations);
}

-(id)incA
{
	OSAtomicIncrement32(&a);
	return nil;
}

-(void)asyncOperation:(long)iterations with:queue
{
	a=0;
	SIMPLETESTBODY( [[self asyncOnOperationQueue:queue] incA]; );
//	[queue waitUntilAllOperationsAreFinished];
	while ( a < iterations ) { 
	    NSLog(@"async-nsoperation a-iterations = %ld",a-iterations);
	}
      NSLog(@"async-nsoperation a-iterations = %ld",a-iterations);
}

-(void)nsthreadDetached:(long)iterations with:operation
{
	a=0;
	SIMPLETESTBODY( [NSThread detachNewThreadSelector:@selector(start) toTarget:operation withObject:nil]; );
	while ( a < iterations ) { 
//	    NSLog(@"nsthread-detached a-iterations = %ld",a-iterations);
	}
 //       NSLog(@"nsthread-detached a-iterations = %ld",a-iterations);
}

-(void)asyncHOM:(long)iterations with:operation
{
	a=0;
	SIMPLETESTBODY( [[operation async] start]; );
	while ( a < iterations ) { 
//            NSLog(@"async-hom a-iterations = %ld",a-iterations);
        }
//        NSLog(@"async-hom a-iterations = %ld",a-iterations);

}

static id one=nil;

-(NSNumber*)returnOne
{
//	NSLog(@"return one: %p/%@",one,one);
	return one;
}

-(void)future:(long)iterations with:operation
{
	a=0;
	if ( !one ) {
		one=[[NSNumber numberWithInt:1] retain];
	}
	SIMPLETESTBODY( id result=[[self future] returnOne]; int intResult=[result intValue]; a+=intResult; );
        NSLog(@"future-hom a-iterations = %ld",a-iterations);

}

-(void)nsthreadWaited:(long)iterations with:operation
{
	a=0;
	NSThread *t=nil;
	SIMPLETESTBODY(t=[[[NSThread alloc] initWithTarget:operation selector:@selector(start) object:nil] autorelease]; [t start]; while (![t isFinished]) {};  );
	while ( a < iterations ) { 
//	    NSLog(@"nsthread-waited a-iterations = %ld",a-iterations);
	}
 //       NSLog(@"nsthread-waited a-iterations = %ld",a-iterations);
}

-(void)nsthreadDictionary:(long)iterations
{
	NSThread *c=[NSThread currentThread];
	SIMPLETESTBODY( [c threadDictionary]; );
}

-(void)didChangeValueForKey:aKey
{
    a++;
}


-(void)setBoundProperty:(long)iterations with:newValue
{
    SIMPLETESTBODY( id pool=[NSAutoreleasePool new]; [self setBindingSource:@"newValue"]; [pool release]; );
}

static id array=nil;
-(void)createFilledMPWRealArray:(long)iterations
{
    SIMPLETESTBODY( id pool=[NSAutoreleasePool new]; array=[[[MPWRealArray alloc] initWithStart:1.0 end:10000.0 step:1.0] autorelease]; [pool drain] );
}

-(void)createMsgFilledRealArray:(long)iterations
{
    SIMPLETESTBODY( id pool=[NSAutoreleasePool new]; array=[self mpwRealArrayFrom:1.0 to:10000.0]; [pool drain] );
}

-(void)createVecFilledMPWRealArray:(long)iterations
{
    SIMPLETESTBODY( id pool=[NSAutoreleasePool new]; array=[[[MPWRealArray alloc] initWithVecStart:1.0 end:10000.0 step:1.0] autorelease]; [pool drain] );
}


-(void)createFilledNSRealArray:(long)iterations
{
    SIMPLETESTBODY( id pool=[NSAutoreleasePool new]; array=[self nsArrayFrom:1.0 to:10000.0]; [pool drain] );
}



-(void)nonKvoSetProperty:(long)iterations with:tester
{
    SIMPLETESTBODY( [self setUnobservedProperty:@"newValue"];  );
}


-(void)kvoPreparedButNotActive:(long)iterations
{
  SIMPLETESTBODY( [self setManualKVOObservedProperty:@"hello world"]; );
}

-(void)kvoSetProperty:(long)iterations with:tester
{
     a=0;
    SIMPLETESTBODY( id pool=[NSAutoreleasePool new]; [self setObservedProperty:@"newValue"]; [pool release]; );
    if ( a!= iterations ) {
	NSLog(@"KVO not called enough times!");
    }
}

-(void)sendNotifications:(long)iterations
{
    id observer = [[[IncreaseAOperation alloc] init] autorelease];
    NSNotificationCenter *center=[NSNotificationCenter defaultCenter];
    a=0;
    [center addObserver:observer selector:@selector(notify) name:@"notification" object:nil];

    SIMPLETESTBODY( @autoreleasepool {  [center postNotificationName:@"notification" object:nil]; } );
    if ( a!= iterations ) {
      NSLog(@"notification not called right number of times %ld should be %ld!",a,iterations);
    }
    [center removeObserver:observer];
}

-(void)cStringCompare:(long)iterations with:testObject
{
	NSString *s1=[[testObject copy] autorelease];
	const char *cString=[testObject UTF8String];
	const char *cString1=[s1 UTF8String];
	SIMPLETESTBODY( a+=(cString1[0]==cString[0]) && !strcmp(cString,cString1) );
}


-(void)nsStringCompareNoMatch:(long)iterations with:testObject
{
	NSString *s1=@"this won't match";
	a=0;
	SIMPLETESTBODY( a+=[s1 compare:testObject] );
}


-(void)nsStringCompareSelf:(long)iterations with:testObject
{
	NSString *s1=[[testObject copy] autorelease];
	a=0;
	SIMPLETESTBODY( a+=[s1 compare:testObject] );
}

-(id)runTestMsg:(SEL)msg with:testObject label:(char*)label
{
	id pool=[NSAutoreleasePool new];
	long iterations = 1;
//	NSLog(@"start with %ld iterations of %@",iterations,NSStringFromSelector(msg));
	for ( iterations=1;  iterations <= ITERATION_THRESHOLD ; iterations*=10 ) {
		id inner=[NSAutoreleasePool new];
//		NSLog(@"start with %d iterations of %@",iterations,NSStringFromSelector(msg));
		MPWTRusage *timing = [MPWTRusage current];
		[self performSelector:msg withObject:(id)iterations withObject:testObject];
		timing = [MPWTRusage timeRelativeTo:timing];
		[timing setIterations:iterations];
//		NSLog(@"stop with %d iterations microseconds: %ld nanoseconds: %g per iteration: %g",iterations,[timing userMicroseconds],[timing userNS],[timing userNSPerIteration]);
		if ( [timing userMicroseconds] > MICROSECOND_THRESHOLD ) {
			[timing setName:[NSString stringWithUTF8String:label]];
			return timing;
			break;
		}
		if ( iterations >= ITERATION_THRESHOLD ) {
//			NSLog(@"crossed iteration threshold for %@",NSStringFromSelector(msg));
			[timing setName:[NSString stringWithUTF8String:label]];
//			[timing setTimeUsed:[timing measuredNSPerIteration]];
			return timing;
			break;
		}
		[inner release];
	}
	[pool release];
	return nil;
} 

-(void)closeLog
{
}

-(void)dealloc
{
	[self closeLog];
	[super dealloc];
}



@end




void texTable( NSArray * results  );

int main( int argc, char *argv[] ) {
	id pool=[NSAutoreleasePool new];
	id tester;
	char *logpath=NULL;
	BOOL xml=NO;
	int ch;
	char *config="";
    while ((ch = getopt(argc, argv, "l:ze:")) != -1)
    {
        switch (ch)
        {
            case 'l':
                    logpath = optarg;
                    break;
            case 'z':
                    xml = 1;
                    break;
            case 'e':
                    config = optarg;
                    break;
        }
    }
	
	 
	tester = [[Tester alloc] initWithLogPath:logpath useXML:xml config:config];
	attrStringClass=[NSAttributedString class];
	NSMutableArray *results=[NSMutableArray array];	
	id emptyTest = [tester runTestMsg:@selector(emptyTest:) with:nil label:"empty"];	
//	emptyTest = [tester runTestMsg:@selector(emptyTest:) with:nil label:"empty"];	
//	emptyTest = [tester runTestMsg:@selector(emptyTest:) with:nil label:"empty"];	
//	[results addObject:emptyTest];
	double emptyTime=[emptyTest userNSPerIteration];
#define RUNTESTWITHLABEL( msg, arg, someLabel )   [results addObject:[tester runTestMsg:@selector(msg) with:arg label:someLabel]]
#define RUNTEST( msg, arg )   			RUNTESTWITHLABEL( msg, arg, #msg )

#if 1
	RUNTESTWITHLABEL(  multiplyTest: , nil ,"multiply" ); 
	RUNTESTWITHLABEL(  divideTest: , nil ,"divide" ); 
	RUNTESTWITHLABEL(  additionTest: , nil ,"add" ); 
	RUNTESTWITHLABEL( msgTestDummy:with: , nil ,"message" ); 
	RUNTESTWITHLABEL(  allocReleaseTest: , nil ,"alloc/release" ); 
#endif
#if 0
	RUNTESTWITHLABEL( emptyTest: , nil, "empty" ); 
       RUNTESTWITHLABEL(nsNumberIntValue:with: ,[MPWInteger integer:3] , "mpw intValue");
       RUNTESTWITHLABEL(cfNumberGetInt:with: ,[NSNumber numberWithInt:3] , "CFNumberGetValue");
       RUNTESTWITHLABEL(impCachedIntValue:with: ,[MPWInteger integer:3] , "imp-cached mpw intValue");
       RUNTESTWITHLABEL(cfFloatNumber: ,nil				 , "CF(float)");
	RUNTESTWITHLABEL(  synchronizedAdditionTest: , nil ,"add synchronized" ); 
	RUNTESTWITHLABEL(  pthreadLockedAddition: , nil ,"add pthread_mutex" ); 
       RUNTESTWITHLABEL(nsNumberIntValue:with: ,[NSNumber numberWithInt:3] , "-intVal");
       RUNTESTWITHLABEL(nsIntNumber: ,nil					 , "NS(int)");
       RUNTESTWITHLABEL(nsFloatNumber: ,nil					 , "NS(float)");
       RUNTESTWITHLABEL(nsthreadDictionary: ,nil , "nsthread-dict");
	RUNTESTWITHLABEL(  cStringCompare:with: , @"hello world this is a long string" ,"strcmp(32) " ); 
	RUNTESTWITHLABEL(  cStringCompare:with: , @"key9" ,"strcmp(4) " ); 
       RUNTESTWITHLABEL(impCachedDummy: ,nil , "imp-cached [self dummy]");
#endif
#if 1

	NSArray *singleValue = @[ @"value" ];
	NSArray *singleKey = @[ @LOOKUPKEY ];
	NSArray *singleKeyNoMatch = @[ @"key1" ];
	NSArray *tenKeys = @[ @"akey1",@"key2",@"somekey3",@"anotherkey4",@"morekey5",@LOOKUPKEY,@"mykey7",@"key8",@"key9",@"key10" ];
	NSArray *tenValues = @[ @"v1",@"v2",@"v3",@"v4",@"v5",@"v6",@"v7",@"v8",@"v9",@"v10" ];
	NSArray *threeKeys = @[ @"akey1",@LOOKUPKEY,@"somekey3"];
	NSArray *threeValues = @[ @"v1",@"v2",@"v3" ];

//	NSArray *kvPairs=@ [   @[ singleKey, singleValue], @[singleKeyNoMatch, singleValue], @[ tenKeys, tenValues] , @[ threeKeys, threeValues ] ];
	NSArray *kvPairs=@ [   @[ tenKeys, tenValues] , @[ threeKeys, threeValues ] ];
	NSDictionary  *dictClassesAndMessage=@{
			@"MPWSmallStringTable": @[@"smallStringTableLookup:with:"],
			@"NSDictionary": @[@"smallDictLookupConstKey:with:" ,@"smallDictLookupTaggedKey:with:" ,@"smallDictLookupMutableKey:with:", @"smallCFDictLookup:with:" ],
		 };
	


	for ( NSString *className in dictClassesAndMessage.allKeys ) {
		Class dictClass=NSClassFromString(className);
		for ( NSString *messageName in dictClassesAndMessage[className] ) {	
			for ( NSArray *kvPair in kvPairs ) {
				NSString *msg=[NSString stringWithFormat:@"%@ with %2d element(s) message: %@",className,[kvPair[1] count],messageName];
				NSLog(@"test: %@",msg);
				NSArray *values = kvPair[1];
				NSArray *keys   = kvPair[0];
				id testDict = [[[dictClass alloc] initWithObjects:values forKeys:keys] autorelease];
				[results addObject:[tester runTestMsg:NSSelectorFromString(messageName) with:testDict label:[[msg stringByAppendingString:@" keys const"] UTF8String]]];
				testDict = [[[dictClass alloc] initWithObjects:values forKeys:[[keys collect] mutableCopy]] autorelease];
				[results addObject:[tester runTestMsg:NSSelectorFromString(messageName) with:testDict label:[[msg stringByAppendingString:@" keys tagged (copied)"] UTF8String]]];
			}
		}
	}

	RUNTESTWITHLABEL(  smallDictLookup:with: , [NSDictionary dictionary] ,"nsdict(0)" ); 



       RUNTESTWITHLABEL(smallDictLookupNotFound:with: ,([NSDictionary dictionaryWithObjectsAndKeys:@"v1",@"key1",@"v2",@"key2",@"v3",@"key3",@"v4",@"key4",@"v5",@"key5",@"v6",@"key6",@"v7",@"key7",@"v7",@"key7",@"v8",@"key8",@"v9",@"key9",@"v10",@"key10",nil]) , "key999");
       RUNTESTWITHLABEL(smallDictLookupNotFound:with: ,([NSDictionary dictionaryWithObjectsAndKeys:@"v1",@"key1",@"v2",@"key2",@"v3",@"key3",@"v4",@"key4",@"v5",@"key5",@"v6",@"key6",@"v7",@"key7",@"v7",@"key7",@"v8",@"key8",@"v9",@"key999",@"v10",@"key10",nil]) , "nsdict with 10 elems, key key999 -- found");
       RUNTESTWITHLABEL(snprintfDoubleTest: ,nil , "nsprintf double (with extra string in format)");
       RUNTESTWITHLABEL(snprintfIntegerTest: ,nil , "nsprintf integer (with extra string in format)");
       RUNTESTWITHLABEL(itoaTest: ,nil , "ito");
#endif
#if 1
       RUNTESTWITHLABEL(dictGetViaForward: ,nil, "dictionary read access via msg send and forward" );
       RUNTESTWITHLABEL(dictSetViaForward: ,nil, "dictionary write access via msg send and forward" );
       RUNTESTWITHLABEL(nsdataread: ,nil, "NSData dataWithContentsOfFile" );
       RUNTESTWITHLABEL(nsdatamap: ,nil, "NSData dataWithContentsOfMappedFile" );
      
#endif
#if 0
	RUNTESTWITHLABEL(  performSelectorTest: , nil ,"performSelector:" ); 
  RUNTESTWITHLABEL(  sendNSInvocation: , nil ,"performNSInvocation:" ); 
  RUNTESTWITHLABEL(  sendFastInvocation:withCaching: , NO ,"performFastInvocation: uncached" ); 


       RUNTESTWITHLABEL(smallStringTableLookup:with: ,[[[MPWSmallStringTable alloc] initWithObjects:singleValue forKeys:singleKey] autorelease] , "mpw small string table with 1 element");
b
       RUNTESTWITHLABEL(smallStringTableLookup:with: ,[[[MPWSmallStringTable alloc] initWithObjects:singleValue forKeys:singleKey] autorelease] , "mpw small string table with 1 element -- no match");
       RUNTESTWITHLABEL(smallStringTableLookup:with: ,([[[MPWSmallStringTable alloc] initWithObjects:tenValues forKeys:tenKeys] autorelease]) , "mpw small string table with 10 elements");
       RUNTESTWITHLABEL(smallStringTableLookup:with: ,([[[MPWSmallStringTable alloc] initWithKeys:[NSArray arrayWithObjects:@"ikey1",@"key2",@"somekey3",nil] values:[NSArray arrayWithObjects:@"v1",@"v2",@"v3",nil]] autorelease]) , "mpw small string table with 3 elements");
	RUNTESTWITHLABEL(  smallDictLookup:with: , [NSDictionary dictionary] ,"nsdict(0)" ); 
       RUNTESTWITHLABEL(smallCFDictLookup:with: ,[NSDictionary dictionaryWithObject:@"value" forKey:@"key2"] , "cfdict(1)");
       RUNTESTWITHLABEL(smallDictLookup:with: ,([NSDictionary dictionaryWithObjectsAndKeys:@"v1",@"key1",@"v2",@"key2",nil]) , "nsdict(2)");
       RUNTESTWITHLABEL(smallDictLookup:with: ,([NSDictionary dictionaryWithObjectsAndKeys:@"v1",@"key1",@"v2",@"key2",@"v3",@"key3",@"v4",@"key4",@"v5",@"key5",@"v6",@"key6",@"v7",@"key7",@"v7",@"key7",@"v8",@"key8",@"v9",@"key9",@"v10",@"key10",nil]) , "nsdict(10)");
       RUNTESTWITHLABEL(smallDictLookupNotFound:with: ,([NSDictionary dictionaryWithObjectsAndKeys:@"v1",@"key1",@"v2",@"key2",@"v3",@"key3",@"v4",@"key4",@"v5",@"key5",@"v6",@"key6",@"v7",@"key7",@"v7",@"key7",@"v8",@"key8",@"v9",@"key9",@"v10",@"key10",nil]) , "key999");
       RUNTESTWITHLABEL(smallDictLookup:with: ,[NSDictionary dictionaryWithObject:@"value" forKey:@"key2"] , "nsidct with 1 element");
       RUNTESTWITHLABEL(smallDictLookup:with: ,([NSDictionary dictionaryWithObjectsAndKeys:@"v1",@"key1",@"v2",@"key2",@"v3",@"key3",nil]) , "nsdict with 3 elems");
       RUNTESTWITHLABEL(smallDictLookupNotFound:with: ,([NSDictionary dictionaryWithObjectsAndKeys:@"v1",@"key1",@"v2",@"key2",@"v3",@"key3",@"v4",@"key4",@"v5",@"key5",@"v6",@"key6",@"v7",@"key7",@"v7",@"key7",@"v8",@"key8",@"v9",@"key999",@"v10",@"key10",nil]) , "nsdict with 10 elems, key key999 -- found");
       RUNTESTWITHLABEL(snprintfDoubleTest: ,nil , "nsprintf double (with extra string in format)");
       RUNTESTWITHLABEL(snprintfIntegerTest: ,nil , "nsprintf integer (with extra string in format)");
       RUNTESTWITHLABEL(itoaTest: ,nil , "ito");
#endif
#if 0
       RUNTESTWITHLABEL(dictGetViaForward: ,nil, "dictionary read access via msg send and forward" );
       RUNTESTWITHLABEL(dictSetViaForward: ,nil, "dictionary write access via msg send and forward" );
       RUNTESTWITHLABEL(nsdataread: ,nil, "NSData dataWithContentsOfFile" );
       RUNTESTWITHLABEL(nsdatamap: ,nil, "NSData dataWithContentsOfMappedFile" );
      
#endif
#if 0
	RUNTESTWITHLABEL(  performSelectorTest: , nil ,"performSelector:" ); 
  RUNTESTWITHLABEL(  sendNSInvocation: , nil ,"performNSInvocation:" ); 
  RUNTESTWITHLABEL(  sendFastInvocation:withCaching: , NO ,"performFastInvocation: uncached" ); 
  RUNTESTWITHLABEL(  sendFastInvocation:withCaching: , YES ,"performFastInvocation: cached" ); 
  RUNTESTWITHLABEL(  sendMacroFastInvocation: , nil ,"performFastInvocation: macro" ); 
	RUNTESTWITHLABEL(  atomicPropertyTest: , nil ,"get property (atomic)" ); 
	RUNTESTWITHLABEL(  nonAtomicPropertyTest: , nil ,"nonatomic property" ); 
       RUNTESTWITHLABEL(kvcLookup:with: ,tester , "KVC lookup");
       RUNTESTWITHLABEL(associatedObjectLookup:with: ,tester , "get associated object");
       RUNTESTWITHLABEL(valueAccessorGetOffsetAccessor:with: ,[MPWValueAccessor valueForName:@"dummy"] , "ValueAccessor offset");
       RUNTESTWITHLABEL(valueAccessorGetAccessorDict:with: ,@{ @"key": @"value"} , "ValueAccessor dict");
       RUNTESTWITHLABEL(valueAccessorGetAccessor:with: ,[MPWValueAccessor valueForName:@"dummy"] , "ValueAccessor message");
       RUNTESTWITHLABEL(valueAccessorGetAccessorBound:with: ,[MPWValueAccessor valueForName:@"dummy"] , "ValueAccessor bound");
#endif
#if 0
       RUNTESTWITHLABEL(reduceOperatorPlus:with: ,[[[MPWRealArray alloc] initWithStart:1.0 end:10000.0 step:1.0] autorelease] , "sum");
       RUNTESTWITHLABEL(vecReduceOperatorPlus:with: ,[[[MPWRealArray alloc] initWithStart:1.0 end:10000.0 step:1.0] autorelease] , "vecsum");
       RUNTESTWITHLABEL(reduceAccessingIndividualReals:with: ,[[[MPWRealArray alloc] initWithStart:1.0 end:10000.0 step:1.0] autorelease] , "msgsum");
//       RUNTESTWITHLABEL(reduceAccessingIndividualObjs:with: ,[[[MPWRealArray alloc] initWithStart:1.0 end:10000.0 step:1.0] autorelease] , "sum 10000 element MPWRealArray using -objectAtIndex");
       RUNTESTWITHLABEL(reduceAccessingIndividualObjs:with: ,[tester nsArrayFrom:1.0 to:10000.0] , "nsarray sum");
       RUNTESTWITHLABEL(createVecFilledMPWRealArray: ,nil , "real-vec");
       RUNTESTWITHLABEL(createFilledMPWRealArray: ,nil , "real");
       RUNTESTWITHLABEL(createMsgFilledRealArray: ,nil , "msg-real");
       RUNTESTWITHLABEL(createFilledNSRealArray: ,nil , "nsarray-real");
       RUNTESTWITHLABEL(mpwRealArray: ,nil				 , "create/free MPWRealArray");
#endif
#if 0
	RUNTESTWITHLABEL(  cStringCompareNoMatch:with: , @"hello world" ,"!strcmp(10)" ); 
	RUNTESTWITHLABEL(  nsStringCompareSelf:with: , @"hello world this is a very long string" ,"nscmp(32)" ); 
	RUNTESTWITHLABEL(  nsStringCompareNoMatch:with: , @"hello world" ,"!nscmp(10)" ); 
       RUNTESTWITHLABEL(nstringAppend:with: ,[NSMutableString string] , "ns append");
       RUNTESTWITHLABEL(stringReplaceAtEnd:with: ,[NSMutableString string] , "ns replace");
	RUNTESTWITHLABEL(  additionTestUnrolled: , nil ,"add unrolled" ); 
       RUNTESTWITHLABEL(cfIntNumber: ,nil					 , "CFNumberCreate(int)");
	RUNTESTWITHLABEL( msgTestSelf:with: , [NSObject new] ,"[anObject self]" ); 
	RUNTESTWITHLABEL(  idAccessorWriteTest: , nil ,"set ivar idAccessor" ); 
	RUNTESTWITHLABEL(  idAccessorReadTest: , nil ,"get ivar idAccessor" ); 
	RUNTESTWITHLABEL(  incrementAtomicTest: , nil ,"OSAtomicIncrement32" ); 
	RUNTESTWITHLABEL(  threadSpecificLookup:with: , @"tkey" ,"pthread_getspecific" ); 
       RUNTESTWITHLABEL(kindOfClass:with: ,@"test"		 , "isKindOfClass");
#endif
#if 0
	RUNTESTWITHLABEL(  getObjectTest:with: ,[[MPWObjectCache alloc] initWithCapacity:20 class:[MPWInteger class]]  ,"GETOBJECT" ); 
	RUNTESTWITHLABEL(  getObjectSlowTest:with: ,[[MPWObjectCache alloc] initWithCapacity:20 class:[MPWInteger class]]  ,"GETOBJECT cache miss warmup" ); 
	RUNTESTWITHLABEL(  getObjectSlowTest:with: ,[[MPWObjectCache alloc] initWithCapacity:20 class:[MPWInteger class]]  ,"GETOBJECT cache miss 2nd" ); 
       RUNTESTWITHLABEL(autoreleaseTest: ,nil , "alloc/autorelease");
       RUNTESTWITHLABEL(autoreleaseLanguageTest: ,nil , "@autorelease");
       RUNTESTWITHLABEL(nestedAutoreleasePoolTest: ,nil , "nested pool create/drain");
       RUNTESTWITHLABEL(autoreleaseDoubleTest: ,nil , "alloc/autorelease x 2");
       RUNTESTWITHLABEL(mallocTest: ,nil					 , "malloc/free");
       RUNTESTWITHLABEL(callocTest: ,nil					 , "calloc/free");
       RUNTESTWITHLABEL(smallDictSet:with: ,[NSMutableDictionary dictionaryWithObject:@"value" forKey:@"key"] , "dict setObject:ForKey:");
       RUNTESTWITHLABEL(nsArrayAlloc: ,nil				 , "create/free NSMutableArray");
       RUNTESTWITHLABEL(nsIntNumberBitShiftAndIntValue: ,nil					 , "create NSNumber with bitshifting and send -intValuer");
       RUNTESTWITHLABEL(nsIntNumberConvenience: ,nil					 , "NSNumber numberWithInt:");
#endif
#if 0
       RUNTESTWITHLABEL(asyncOperation:with: ,[[[NSOperationQueue alloc] init] autorelease] , "async NSOperation");
       RUNTESTWITHLABEL(future:with: ,[[[NSOperationQueue alloc] init] autorelease] , "future");
       RUNTESTWITHLABEL(asyncHOM:with: ,[[[IncreaseAOperation alloc] init] autorelease] , "async-hom");
       RUNTESTWITHLABEL(dispatch:with: ,nil , "dispatch");
       RUNTESTWITHLABEL(nsoperation:with: ,[[[NSOperationQueue alloc] init] autorelease] , "NSOperation");

#endif
#if 0
       RUNTESTWITHLABEL(pthreadDetachedIncreaseA:with: ,nil , "pthread_create+detach");
       RUNTESTWITHLABEL(pthreadJoinedIncreaseA:with: ,nil , "pthread_create+join");
       RUNTESTWITHLABEL(nsthreadDetached:with: ,[[[IncreaseAOperation alloc] init] autorelease] , "nsthread-detached");
       RUNTESTWITHLABEL(nsthreadWaited:with: ,[[[IncreaseAOperation alloc] init] autorelease] , "nsthread-waited");
       RUNTESTWITHLABEL(dispatch100:with: ,nil , "dispatch100");
	RUNTESTWITHLABEL(  fork: , nil ,"fork()" ); 
	RUNTESTWITHLABEL(  system: , nil ,"system()" ); 
	[tester addObserver:tester forKeyPath:@"observedProperty" options:0 context:nil];

       RUNTESTWITHLABEL(kvoSetProperty:with: ,tester , "KVO observation");
       RUNTESTWITHLABEL(nonKvoSetProperty:with: ,tester , "set object without KVO");
       RUNTESTWITHLABEL(kvoPreparedButNotActive: ,nil , "will and didChangeKey");

       RUNTESTWITHLABEL(sendNotifications: ,nil , "sendNOtifications");

	[[tester class]  exposeBinding:@"bindingSource"];
       NSObjectController *controller = [[[NSObjectController alloc] init] autorelease];
	[controller bind:@"contentObject" toObject:tester withKeyPath:@"bindingSource" options:nil];

       RUNTESTWITHLABEL(setBoundProperty:with: ,@"new value" , "set object that has a binding");
//	NSLog(@"bindingSource: %@ bindingTargeT: %@",[tester bindingSource],[tester bindingTarget]);
	



#endif
	[tester release];
	for ( id result in results ) {
		[result setNSPer:[result userNSPerIteration]-emptyTime];	
	}

	[results addObject:[MPWTRusage timeWithName:@"1 ns" value:1.00]];
//	[results addObject:[MPWTRusage timeWithName:@"           $u$s" value:1000]];
//	[results addObject:[MPWTRusage timeWithName:@"           ms" value:1000000]];
	[results addObject:[MPWTRusage timeWithName:@"1/10th  s" value:100000000]];
	NSArray *sorted = [results sortedArrayUsingSelector:@selector(compare:)];
	NSLog(@"results with loop overhead subtracted: %@",sorted);
	texTable( sorted );
	csvTable( sorted );
	
	exit(0);
	[pool release];
	return 0;
}


void twodresultsTable( NSArray * results, char *headerCellFormat, char *headerEnd, char *tableLabelFormat, char *tableFormat, char *emptyFormat, char *tableRowEndFormat  ) {

	int i,j;
	printf("Operation ");
	for (i=0;i<[results count];i++) {
		id result=[results objectAtIndex:i];
		printf(headerCellFormat,[[result name] UTF8String]);
	}
	
	printf("%s",headerEnd);
	for (i=0;i<[results count];i++) {
		id resultname=[[results objectAtIndex:i] name];
		printf(tableLabelFormat,[resultname cString]);
		for (j=0;j<[results count];j++) {
			if ( (j >= i) || [resultname isEqual:@"1 ns"] ) {
				double relativeTime=[[results objectAtIndex:j] userNSPerIteration] / [[results objectAtIndex:i] userNSPerIteration];
				printf(tableFormat,relativeTime > 1000 ? 7 : relativeTime >=100 ? 4:2, relativeTime);
			} else {
				printf("%s",emptyFormat);
			}
		}
		printf("%s", tableRowEndFormat );
	}
}

void texTable( NSArray *results )
{
	twodresultsTable( results, " & %s \t", " \\\\\\hline \n" ,
			"%s\t", " & %.*g\t", " & \t "," \\\\\\hline \n");
}
void csvTable( NSArray *results )
{
	twodresultsTable( results, " , %s ", "\n" ,
			"%s,", " %.*g,  ", " , ","\n");
}
