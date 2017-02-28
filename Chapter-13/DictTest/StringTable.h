//
//  StringTable
//  DictTest
//
//  Created by Marcel Weiher on 4/15/09.
//  Copyright 2009 Livescribe. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface StringTable : NSObject

-initWithContentsOfFile:(NSString*)filename ;
-(int)count;
-(BOOL)containsString:(NSString*)str;

@end
