//
//  SimpleStdioStringDict.m
//  DictTest
//
//  Created by Marcel Weiher on 9/11/13.
//
//

#import "SimpleStdioStringDict.h"

@implementation SimpleStdioStringDict

-(void)_realloc
{
    if ( count+2 >= capacity) {
        capacity=(capacity+10)*2;
        strings=realloc(strings, (capacity+2) * sizeof *strings);
    }
}


-initWithContentsOfFile1:(NSString*)filename
{
    self=[super init];
    const char *fname=[filename UTF8String];
    FILE *f=fopen(fname, "r");
    BOOL done=NO;
    if (f) {
        while (!done) {
            char buffer[8192];
            [self _realloc];
            char *line=fgets(buffer, 8000, f);
            if (line) {
                int len=(int)strlen(line);
                if (len>0) {
                    len--;
                    line[len]=0;
                    strings[count++]=strdup(line);
                    continue;
                }
            }
            done=YES;
        }
        fclose(f);
    }
    return self;
}


-initWithContentsOfFile:(NSString*)filename
{
    self=[super init];
    const char *fname=[filename UTF8String];
    FILE *f=fopen(fname, "r");
    if (f) {
        char *line;
        size_t lineLength;
        while ( (line=fgetln(f, &lineLength))) {
            [self _realloc];
            strings[count++]=strndup(line,lineLength);
        }
        fclose(f);
    }
    return self;
}


-(int)count
{
    return count;
}

-(BOOL)containsString:(NSString*)str
{
    int maxLen=(int)[str length];
    char buffer[ maxLen + 10 ];
    [str getBytes:buffer maxLength:maxLen+1 usedLength:NULL encoding:NSASCIIStringEncoding options:0 range:NSMakeRange(0, maxLen) remainingRange:NULL];
    buffer[maxLen]=0;
    void *result = bsearch_b((const void*)buffer, (const void*)strings, count, sizeof *strings , ^( const void *key, const void *elemptr){
        const char *elem=*(const char**)elemptr;
        return  strcasecmp(key,elem );
    } );
    return result != NULL;
}



@end
