//
//  MPWBinaryPlist.h
//  MPWFoundation
//
//  Created by Marcel Weiher on 9/27/13.
//
//

#import <Foundation/Foundation.h>

@class MPWIntArray;

@interface MPWBinaryPlist : NSObject
{
    NSData              *data;
    const unsigned char *bytes;
    long                dataLen;
    long                rootIndex;
    long                numObjects;
    long                offsetTableLocation;
    long                *offsets;
    id                  *objects;
    int                 offsetIntegerSizeInBytes;
    int                 offsetReferenceSizeInBytes;
    BOOL                lazyArray;
    long                currentObjectNo;
    long                currentKeyNo;
    MPWIntArray         *objectNoStack;
    MPWIntArray         *keyNoStack;
    
    long                currentDictOffset,currentDictLength,currentDictIndex;
}

typedef void (^ArrayElementBlock)(MPWBinaryPlist* plist,long offset,long anIndex);

typedef void (^DictElementBlock)(MPWBinaryPlist* plist,long keyOffset,long valueOffset,long anIndex);



-initWithData:(NSData*)newPlistData;
+bplistWithData:(NSData*)newPlistData;
-(long)parseIntegerAtOffset:(long)offset;
-(long)offsetOfObjectNo:(long)offsetNo;
-(long)_rootOffset;

-(long)parseArrayAtIndex:(long)anIndex usingBlock:(ArrayElementBlock)block;
-(long)currentInt;

-(NSArray*)readArrayAtIndex:(long)anIndex;
-(long)parseDictAtIndex:(long)anIndex usingBlock:(DictElementBlock)block;
-(NSDictionary*)readDictAtIndex:(long)anIndex;
-(BOOL)isArrayAtIndex:(long)anIndex;
-(BOOL)isArray;
-objectAtIndex:(NSUInteger)anIndex;
-(long)rootIndex;
-(float)readFloat;
-(double)readDouble;
-(BOOL)verifyKey:keyToCheck forIndex:(long)keyOffset;

-(long)decodeIntForKey:(NSString*)aKey;
-(double)decodeDoubleForKey:(NSString*)aKey;
-(id)decodeObjectForKey:(NSString*)aKey;
-(BOOL)isArrayAtKey:(NSString*)aKey;

-(long)parseDictAtIndex:(long)anIndex usingContentBlock:(DictElementBlock)block;
-(long)parseDictUsingContentBlock:(DictElementBlock)block;

-(long)parseArrayAtKey:(NSString*)aKey usingBlock:(ArrayElementBlock)block;


@end
