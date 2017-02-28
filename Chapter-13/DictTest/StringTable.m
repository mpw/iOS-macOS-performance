//
//  StringTable.m
//  DictTest
//
//  Created by Marcel Weiher on 4/15/09.
//  Copyright 2009 Livescribe. All rights reserved.
//

#import "StringTable.h"
#import "MPWIntArray.h"

@implementation StringTable {
	NSData      *stringFileContents;
    MPWIntArray *offsets;
}


-(void)tokenizeWords
{
    const char *bytes =[stringFileContents bytes];
	const char *cur =bytes;
	const char *end=bytes + [stringFileContents length];
    [offsets addInteger:0];
	while ( cur < end ) {
		if ( *cur == '\n' ) {
            [offsets addInteger:(int)(cur-bytes+1)];
		}
		cur++;
	}
    [offsets addInteger:(int)(end-bytes)];
}

-initWithContentsOfFile:(NSString*)filename 
{
	if ( (self=[super init] ) ) {
        offsets=[[MPWIntArray alloc] init];
		stringFileContents=[[NSData alloc] initWithContentsOfMappedFile:filename];
		[self tokenizeWords];
	}
	return self;
}

-(BOOL)containsString:(NSString*)str
{
    const char *bytes =[stringFileContents bytes];
    const char *searchStr=[str UTF8String];
    long maxLen=[str length];
    int *offsetsp=[offsets integers];
    int max=[self count];
    for (int i=0;i<max;i++) {
        int len=offsetsp[i+1] - offsetsp[i]-1;
        if (len==maxLen && !strncasecmp(bytes+offsetsp[i], searchStr,len )) {
            return YES;
        }
    }
    return NO;
}

-(BOOL)containsString_bsearch:(NSString*)str
{
    const char *bytes =[stringFileContents bytes];
    const char *searchStr=[str UTF8String];
    void *result;
    result = bsearch_b((const void*)searchStr,(const void*)[offsets integers],
                       [self count], sizeof(int) ,
                       ^( const void *va, const void *vb){
        const int *offsetptr=((const int *)vb);
        const char *key=(const char*)va;
        const char *elem=bytes + offsetptr[0];
        int elemLen=offsetptr[1]-offsetptr[0]-1;
        int diff = strncasecmp(key,elem , elemLen);
        if ( diff == 0) {   // at least a substring match
            return (int)key[elemLen];
        } else {
            return diff;
        }
    } );
    return result != NULL;
}

-(int)count
{
	return (int)[offsets count]-1;
}

-(void)dealloc
{
	[stringFileContents release];
    [offsets release];
	[super dealloc];
}

@end
