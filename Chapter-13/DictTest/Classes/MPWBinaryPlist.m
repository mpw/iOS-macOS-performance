//
//  MPWBinaryPlist.m
//  MPWFoundation
//
//  Created by Marcel Weiher on 9/27/13.
//
//

#import "MPWBinaryPlist.h"
#import "AccessorMacros.h"
#import "MPWIntArray.h"

@interface MPWLazyBListArray : NSArray
{
    NSUInteger count;
    MPWBinaryPlist     *plist;
    MPWIntArray        *offsets;
    id  *objs;
    
}
@end

@implementation MPWLazyBListArray


-(NSUInteger)count { return count; }


-initWithPlist:newPlist offsets:(MPWIntArray*)newOffsets
{
    self=[super init];
    if (self ) {
        count=[newOffsets count];
        objs=calloc( count , sizeof *objs);
        offsets=[newOffsets retain];
        plist=[newPlist retain];
    }
    return self;
}


-objectAtIndex:(NSUInteger)anIndex
{
    id obj=nil;
    if ( anIndex < count) {
        obj=objs[anIndex];
        if ( obj == nil)  {
            obj = [plist objectAtIndex:[offsets integerAtIndex:anIndex]];
            objs[anIndex]=[obj retain];
        }
    } else {
        [NSException raise:@"outofbounds" format:@"index %tu out of bounds",anIndex];
    }
    return obj;
}


DEALLOC(
    for (int i=0;i<count;i++) {
        RELEASE(objs[i]);
    }
    free(objs);
    RELEASE(offsets);
    RELEASE(plist);
)


@end


@implementation MPWBinaryPlist

objectAccessor(NSData, data, setData)
objectAccessor(MPWIntArray, objectNoStack, setObjectNoStack)
objectAccessor(MPWIntArray, keyNoStack, setKeyNoStack)
boolAccessor(lazyArray, setLazyArray)

static const char headerString[]="bplist00";

#define TRAILER_SIZE (sizeof( uint8_t ) * 2 + sizeof( uint64_t ) * 3)



+(BOOL)isValidBPlist:(NSData*)plistData
{
    const char *bytes=[plistData bytes];
    long len = [plistData length];
    return (len > sizeof headerString) &&
        !strncmp(bytes, headerString, sizeof headerString-1);
}

-initWithData:(NSData*)newPlistData
{
    self=[super init];
    if ( [[self class] isValidBPlist:newPlistData]) {
        [self setData:newPlistData];
        bytes=[data bytes];
        dataLen=[data length];
        rootIndex=-1;
        numObjects=-1;
        [self _readTrailer];
        [self _readOffsetTable];
        currentObjectNo=rootIndex;
        [self setKeyNoStack:[MPWIntArray array]];
        [self setObjectNoStack:[MPWIntArray array]];
    } else {
        RELEASE(self);
        self=nil;
    }
    return self;
}
SHORTCONVENIENCE(bplist, WithData:(NSData*)newPlistData)

static inline long readIntegerOfSizeAt( const unsigned char *bytes, long offset, int numBytes  ) {
    long result=0;
    for (int i=0;i<numBytes;i++) {
        result=(result<<8) |  bytes[offset+i];
    }
    return result;
}

-(void)pushCurrentObjectNo
{
    [objectNoStack addInteger:currentObjectNo];
}

-(void)popObjectNo
{
    currentObjectNo=[objectNoStack lastInteger];
    [objectNoStack removeLastObject];
}

-(long)readIntegerOfSize:(int)numBytes atOffset:(long)offset
{
    return readIntegerOfSizeAt(bytes, offset, numBytes);
}

-(void)readNumIntegers:(int)numIntegers atOffset:(long)baseOffset numBytes:(int)numBytes into:(long*)offsetPtrs
{
    for (int i=0;i<numObjects;i++) {
        offsetPtrs[i]=readIntegerOfSizeAt(bytes, baseOffset+i*numBytes, numBytes);
    }
}

-(void)_readOffsetTable
{
    offsets=malloc( numObjects * sizeof *offsets  );
    objects=calloc( numObjects , sizeof *objects  );
    [self readNumIntegers:numObjects atOffset:offsetTableLocation numBytes:offsetIntegerSizeInBytes into:offsets];
}

-(long)offsetOfObjectNo:(long)offsetNo
{
    if ( !offsets ) {
        [self _readOffsetTable];
    }
    return offsets[offsetNo];
}

-(long)_rootOffset
{
    return [self offsetOfObjectNo:[self rootIndex]];
}

static inline int lengthForNibbleAtOffset( int length, const unsigned char *bytes, long *offsetPtr )
{
    long offset=*offsetPtr;
    if ( length==0xf ) {
        int nextHeader=bytes[offset++];
        int byteLen=1<<(nextHeader&0xf);
        length = readIntegerOfSizeAt( bytes, offset, byteLen  ) ;
        offset+=byteLen;
        *offsetPtr=offset;
    }
    return length;
}

-(long)parseIntegerAtOffset:(long)offset
{
    int topNibble=(bytes[offset] & 0xf0) >> 4;
    int bottomNibble=bytes[offset] & 0x0f;
    offset++;
    if ( topNibble == 0x1 ){
        return [self readIntegerOfSize:1<<bottomNibble atOffset:offset];
    } else {
        [NSException raise:@"unsupported" format:@"bplist expected integer (0x1), got %x",topNibble];
    }
    return 0;
}


-(long)parseArrayAtIndex:(long)anIndex usingBlock:(ArrayElementBlock)block
{
    long offset=offsets[anIndex];
    int topNibble=(bytes[offset] & 0xf0) >> 4;
    int length=bytes[offset] & 0x0f;
    offset++;
    if ( topNibble == 0xa ){
        [self pushCurrentObjectNo];
        length = lengthForNibbleAtOffset(  length, bytes,  &offset );
        for (long i=0;i<length;i++) {
            long nextIndex = [self readIntegerOfSize:offsetReferenceSizeInBytes atOffset:offset];
            currentObjectNo=nextIndex;
            block( self, nextIndex, i);
            offset+=offsetReferenceSizeInBytes;

        }
        [self popObjectNo];

    } else {
        [NSException raise:@"unsupported" format:@"bplist expected array (0xa), got %x",topNibble];
    }
    return length;
}

-(long)parseArrayUsingBlock:(ArrayElementBlock)block
{
    return [self parseArrayAtIndex:currentObjectNo usingBlock:block];
}

-(NSArray*)readArrayAtIndex:(long)anIndex
{
    NSMutableArray *array=[NSMutableArray array];
    [self parseArrayAtIndex:anIndex usingBlock:^(MPWBinaryPlist *plist, long offset, long anIndex) {
        [array addObject:[plist objectAtIndex:offset]];
    }];
    return array;
}



-(NSArray*)readLazyArrayAtIndex:(long)anIndex
{
    MPWIntArray *arrayOffsets=[MPWIntArray array];
    [self parseArrayAtIndex:anIndex usingBlock:^(MPWBinaryPlist *plist, long arrayIndex, long anIndex) {
        [arrayOffsets addInteger:arrayIndex];
    }];
    return [[[MPWLazyBListArray alloc] initWithPlist:self offsets:arrayOffsets] autorelease];
}

-(int)keyIndexAtCurrentDictIndex:(int)anIndex
{
    return [self readIntegerOfSize:offsetReferenceSizeInBytes atOffset:currentDictOffset+anIndex*offsetReferenceSizeInBytes];
}

-(int)valueIndexAtCurrentDictIndex:(int)anIndex
{
    if ( anIndex >=0 && anIndex < currentDictLength) {
        return [self readIntegerOfSize:offsetReferenceSizeInBytes atOffset:currentDictOffset+(anIndex+currentDictLength)*offsetReferenceSizeInBytes];
    } else {
        [NSException raise:@"rangecheck" format:@"dict index %d out of range: %d",anIndex,(int)currentDictLength];
    }
    return 0;
}

-(long)decodeIntForKey:(NSString*)aKey
{
    if ( [self verifyKey:aKey forIndex:[self keyIndexAtCurrentDictIndex:currentDictIndex]]) {
        return [self parseIntegerAtOffset:offsets[[self valueIndexAtCurrentDictIndex:currentDictIndex++]]];
    } else {
        [NSException raise:@"keycheck" format:@"dict index %d expected key %@ got %@",(int)currentDictIndex,aKey,[self objectAtIndex:currentDictIndex]];
    }
    return 0;
}

-(double)decodeDoubleForKey:(NSString*)aKey
{
    return [self readDoubleAtIndex:[self valueIndexAtCurrentDictIndex:currentDictIndex++]];
}

-(id)decodeObjectForKey:(NSString*)aKey
{
    return [self objectAtIndex:[self valueIndexAtCurrentDictIndex:currentDictIndex++]];
}

-(id)decodeObjectOfClass:(Class)aClass forKey:(NSString*)aKey
{
    long anIndex =[self valueIndexAtCurrentDictIndex:currentDictIndex++];
    id instance=NSAllocateObject(aClass, 0, NULL);
    [self parseDictAtIndex:anIndex usingContentBlock:^(MPWBinaryPlist *plist, long keyOffset, long valueOffset, long anIndex) {
        [instance initWithCoder:(NSCoder*)plist];
    }];
    return instance;
}

-(id)decodeArrayWithElementsOfClass:(Class)aClass forKey:(NSString*)aKey
{
    long anIndex =[self valueIndexAtCurrentDictIndex:currentDictIndex++];
    NSMutableArray *result=[NSMutableArray array];
    [self parseArrayAtIndex:anIndex usingBlock:^(MPWBinaryPlist *plist, long offset, long anIndex) {
        [result addObject:[plist decodeObjectOfClass:aClass forKey:nil]];
    }];
    return result;
}



-(long)parseArrayAtKey:(NSString*)aKey usingBlock:(ArrayElementBlock)block
{
    long anIndex=[self valueIndexAtCurrentDictIndex:currentDictIndex++];
    return [self parseArrayAtIndex:anIndex usingBlock:block];
}

-(BOOL)isArrayAtKey:(NSString*)aKey
{
    long anIndex=[self valueIndexAtCurrentDictIndex:currentDictIndex];
    return [self isArrayAtIndex:anIndex];
}



-(long)parseDictAtIndex:(long)anIndex usingContentBlock:(DictElementBlock)block
{
    long offset=offsets[anIndex];
    int topNibble=(bytes[offset] & 0xf0) >> 4;
    int length=bytes[offset] & 0x0f;
    
    long oldLength=currentDictLength;
    long oldOffset=currentDictOffset;
    long oldIndex=currentDictIndex;
    offset++;
    if ( topNibble == 0xd ){
        [self pushCurrentObjectNo];
        currentDictIndex=0;
        length = lengthForNibbleAtOffset(  length, bytes,  &offset );
        currentDictOffset=offset;
        currentDictLength=length;
        
        block( self,  0,  0, length);

        [self popObjectNo];
    } else {
        [NSException raise:@"unsupported" format:@"bplist expected dict (0xd), got %x",topNibble];
    }
    currentDictLength=oldLength;
    currentDictOffset=oldOffset;
    currentDictIndex=oldIndex;
    
    return length;
}


-(long)parseDictAtIndex:(long)anIndex usingBlock:(DictElementBlock)block
{
    long offset=offsets[anIndex];
    int topNibble=(bytes[offset] & 0xf0) >> 4;
    int length=bytes[offset] & 0x0f;
    offset++;
    if ( topNibble == 0xd ){
        [self pushCurrentObjectNo];
        length = lengthForNibbleAtOffset(  length, bytes,  &offset );
        for (long i=0;i<length;i++) {
            long nextKeyOffset = [self readIntegerOfSize:offsetReferenceSizeInBytes atOffset:offset];
            long nextValueOffset = [self readIntegerOfSize:offsetReferenceSizeInBytes atOffset:offset+length*offsetReferenceSizeInBytes];
            currentObjectNo=nextValueOffset;
            currentKeyNo=nextKeyOffset;
            block( self,  nextKeyOffset,  nextValueOffset, i);
           offset+=offsetReferenceSizeInBytes;
            
        }
        [self popObjectNo];
    } else {
        [NSException raise:@"unsupported" format:@"bplist expected dict (0xd), got %x",topNibble];
    }
    return length;
}

-(long)parseDictUsingBlock:(DictElementBlock)block
{
    return [self parseDictAtIndex:currentObjectNo usingBlock:block];
}

-(long)parseDictUsingContentBlock:(DictElementBlock)block
{
    return [self parseDictAtIndex:currentObjectNo usingContentBlock:block];
}

-(NSDictionary*)readDictAtIndex:(long)anIndex
{
    NSMutableDictionary *dict=nil;
    dict=[NSMutableDictionary dictionary];
    [self parseDictAtIndex:anIndex usingBlock:^(MPWBinaryPlist *plist, long keyOffset,long valueOffset, long anIndex) {
        [dict setObject:[self objectAtIndex:valueOffset] forKey:[self objectAtIndex:keyOffset]];
        }];
    return dict;
}

-(BOOL)isArrayAtIndex:(long)anIndex
{
    long offset=offsets[anIndex];
    return (bytes[offset] & 0xf0) == 0xa0;
}

-(BOOL)isArray
{
    return [self isArrayAtIndex:currentObjectNo];
}

-(BOOL)isDictAtIndex:(long)anIndex
{
    long offset=offsets[anIndex];
    return (bytes[offset] & 0xf0) == 0xd0;
}

-(BOOL)isDict
{
    return [self isDictAtIndex:currentObjectNo];
}

static inline double readRealAtIndex( int anIndex, const unsigned char *bytes, long *offsets )
{
    double result=0;
    long offset=offsets[anIndex];
    int bottomNibble=bytes[offset] & 0x0f;
    char buffer[8];
    int byteSize =1<<bottomNibble;
    for (int i=0;i<byteSize;i++) {
        buffer[i]=bytes[offset+byteSize-i];
    }
    if ( byteSize==4) {
        result = *(float*)buffer;
    } else if ( byteSize==8) {
        result = *(double*)buffer;
    } else {
        [NSException raise:@"invalidformat" format:@"invalid length of real: %d",byteSize];
    }
    return result;
}

-(float)readFloatAtIndex:(long)anIndex
{
    return readRealAtIndex(  anIndex, bytes, offsets );
}

-(double)readDoubleAtIndex:(long)anIndex
{
    return readRealAtIndex(  anIndex, bytes, offsets );
}

-(float)readFloat
{
    return readRealAtIndex(  currentObjectNo, bytes, offsets );
}

-(double)readDouble
{
    return readRealAtIndex(  currentObjectNo, bytes, offsets );
}

-parseObjectAtIndex:(long)anIndex
{
    long offset=offsets[anIndex];
    int topNibble=(bytes[offset] & 0xf0) >> 4;
    int bottomNibble=bytes[offset] & 0x0f;
    id result=nil;
    int length=bottomNibble;
    offset++;
    switch ( topNibble) {
        case 0x1:
            result = [NSNumber numberWithLong:[self readIntegerOfSize:1<<bottomNibble atOffset:offset]];
            break;
        case 0x2:
            result = ((1<<bottomNibble)==4) ? [NSNumber numberWithFloat:[self readFloatAtIndex:anIndex]] : [NSNumber numberWithDouble:[self readDoubleAtIndex:anIndex]];
            break;

        case 0x5:
            length = lengthForNibbleAtOffset(  length, bytes,  &offset );
            result = AUTORELEASE([[NSString alloc]
                                  initWithBytes:bytes+offset  length:length encoding:NSASCIIStringEncoding]);
            break;
        case 0x6:
            length = lengthForNibbleAtOffset(  length, bytes,  &offset );
            result = AUTORELEASE([[NSString alloc]
                                  initWithBytes:bytes+offset  length:length*2 encoding:NSUTF16BigEndianStringEncoding]);
            
            break;
        case 0xa:
            if ( lazyArray) {
                result = [self readLazyArrayAtIndex:anIndex];
            } else {
                result = [self readArrayAtIndex:anIndex];
            }
            break;
        case 0xd:
            result = [self readDictAtIndex:anIndex];
            break;
        default:
            [NSException raise:@"unsupported" format:@"unsupported data in bplist: %x",topNibble];
            break;
    }
    return result;
}

static inline id objectAtIndex( MPWBinaryPlist *self, NSUInteger anIndex )
{
    id result=self->objects[anIndex];
    if ( !result ){
        result=[self parseObjectAtIndex:anIndex];
        self->objects[anIndex]=RETAIN(result);
    }
    return result;
}

-objectAtIndex:(NSUInteger)anIndex
{
    return objectAtIndex(self, anIndex);
}

-(void)replaceObjectAtIndex:(NSUInteger)anIndex withObject:(id)object
{
    RETAIN(object);
    RELEASE(objects[anIndex]);
    objects[anIndex]=object;
}

-(long)currentInt
{
    return [self parseIntegerAtOffset:offsets[currentObjectNo]];
}

-currentObject
{
    return [self objectAtIndex:currentObjectNo];
}

-rootObject
{
    return [self parseObjectAtIndex:rootIndex];
}


-(void)_readTrailer
{
    long trailerOffset=dataLen-TRAILER_SIZE;
    offsetIntegerSizeInBytes=[self readIntegerOfSize:1 atOffset:trailerOffset];
    offsetReferenceSizeInBytes=[self readIntegerOfSize:1 atOffset:trailerOffset+1];
    numObjects=[self readIntegerOfSize:8 atOffset:trailerOffset+2];
    rootIndex=[self readIntegerOfSize:8 atOffset:trailerOffset+10];
    offsetTableLocation=[self readIntegerOfSize:8 atOffset:trailerOffset+18];
}

-(NSUInteger)count { return numObjects; }
-(long)rootIndex  { return rootIndex;  }

-(BOOL)verifyKey:keyToCheck forIndex:(long)keyOffset
{
    id keyInArchive=objectAtIndex(self, keyOffset );
    if ( keyInArchive == keyToCheck) {
        return YES;
    } else {
        if ( [keyInArchive isEqual:keyToCheck] ) {
            [self replaceObjectAtIndex:keyOffset withObject:keyToCheck];
            return YES;
        }
    }
    return NO;
}

DEALLOC(
        RELEASE(data);
        for (long i=0;i<numObjects;i++) {
            RELEASE( objects[i]);
        }
        free(objects);
        free(offsets);
        RELEASE(objectNoStack);
        RELEASE(keyNoStack);
)

@end
