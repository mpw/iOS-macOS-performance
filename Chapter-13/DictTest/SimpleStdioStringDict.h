//
//  SimpleStdioStringDict.h
//  DictTest
//
//  Created by Marcel Weiher on 9/11/13.
//
//

#import <Foundation/Foundation.h>

@interface SimpleStdioStringDict : NSObject
{
    char **strings;
    int  capacity;
    int  count;
}
-initWithContentsOfFile:(NSString*)filename ;
-(int)count;
-(BOOL)containsString:(NSString*)str;

@end
