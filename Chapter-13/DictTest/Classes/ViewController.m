//
//  ViewController.m
//  DictTest
//
//  Created by Wagner Truppel on 4/14/09.
//  Copyright Wagner Truppel 2009. All rights reserved.
//

#import "ViewController.h"
#import "StringTable.h"
#import "MPWBinaryPlist.h"
#import "SimpleStdioStringDict.h"
#include <sys/mman.h>

typedef enum enFileKind
{
    kFileKindTxt = 0,
    kFileKindXml,
    kFileKindBin

} FileKind;


@interface ViewController (Private)

- (NSString*) pathToFileOfKind: (FileKind) fileKind;

@end


@implementation ViewController

// ========================================================================= //

- (void) dealloc
{
    // NSLog(@"ViewController: -dealloc");

    [txtNumWordsTF release];
    [txtTimeTF release];

    [xmlNumWordsTF release];
    [xmlTimeTF release];

    [binNumWordsTF release];
    [binTimeTF release];

    [reloadBtn release];

    [super dealloc];
}

// ========================================================================= //

- (void) didReceiveMemoryWarning
{
    NSLog(@"ViewController: -didReceiveMemoryWarning");
    [super didReceiveMemoryWarning];
}

// ========================================================================= //



- (IBAction) actionReload: (id) sender
{
    // NSLog(@"ViewController: -actionReload");

    NSArray *strings=@[ @"abacate", @"MarcelWeiher" ];

    NSString* path;
    NSDate* start;
    NSArray* array;
    NSTimeInterval timeElapsed;
//    NSString* result;

    [sender setEnabled: NO];

    // ============== //

    path = [self pathToFileOfKind: kFileKindBin];
    start = [NSDate date];
    NSData *d=[NSData dataWithContentsOfMappedFile:path];
    MPWBinaryPlist *plist=[[[MPWBinaryPlist alloc] initWithData:d] autorelease];
    [plist setLazyArray:YES];
    array = [plist rootObject];
    
    timeElapsed = -[start timeIntervalSinceNow];
   
    lazyTimeTF.text = [NSString stringWithFormat:@"%f",timeElapsed*1000];
    lazyNumWordsTF.text = [NSString stringWithFormat: @"%i", (int)[array count]];
    
    start = [NSDate date];
    array = [[NSArray alloc] initWithContentsOfFile: path];
    timeElapsed = -[start timeIntervalSinceNow];
    
    
    binNumWordsTF.text = [NSString stringWithFormat: @"%lu", (unsigned long)[array count]];

    [array release];

    binTimeTF.text = [NSString stringWithFormat:@"%f",timeElapsed*1000];

    // ============== //

    path = [self pathToFileOfKind: kFileKindXml];

    start = [NSDate date];
    array = [[NSArray alloc] initWithContentsOfFile: path];
    timeElapsed = -[start timeIntervalSinceNow];

    xmlNumWordsTF.text = [NSString stringWithFormat: @"%lu", (unsigned long)[array count]];

    [array release];

    xmlTimeTF.text = [NSString stringWithFormat:@"%f",timeElapsed*1000];

    // ============== //

    path = [self pathToFileOfKind: kFileKindTxt];

    start = [NSDate date];

    NSError* error;
    NSString* stringFromFileAtPath =
        [[NSString alloc] initWithContentsOfFile: path
                                        encoding: NSUTF8StringEncoding
                                           error: &error];
    NSSet *toSearch=nil;
    if (stringFromFileAtPath == nil)
    {
        NSLog(@"Error reading file at %@\n%@",
              path, [error localizedFailureReason]);
    }
    else
    {
        array = [stringFromFileAtPath componentsSeparatedByString: @"\n"];
        timeElapsed = -[start timeIntervalSinceNow];
        [stringFromFileAtPath release];

        txtNumWordsTF.text = [NSString stringWithFormat: @"%lu", (unsigned long)[array count]];

        txtTimeTF.text = [NSString stringWithFormat:@"%f",timeElapsed*1000];
    }
    
    start = [NSDate date];
 
    toSearch=[NSSet setWithArray:array];
	timeElapsed = -[start timeIntervalSinceNow];
    NSLog(@"time to convert NSArray to NSSet: %g",timeElapsed);
#if 1

    start = [NSDate date];
    for ( int i=0; i<50; i++) {
        for ( NSString *s in strings) {
            [array containsObject:s];
        }
    }
	timeElapsed = -[start timeIntervalSinceNow];
    NSLog(@"time to lineaer search  nsarray 100 times: %g",timeElapsed);
	
    
    start = [NSDate date];
    for ( int i=0; i<500000; i++) {
        for ( NSString *s in strings) {
            [toSearch containsObject:s];
        }
    }
	timeElapsed = -[start timeIntervalSinceNow];
    NSLog(@"time to search nsset (from nsarray) 1000000 times: %g",timeElapsed);
	
    start = [NSDate date];
    for ( int i=0; i<500000; i++) {
        for ( NSString *s in strings) {
            [array indexOfObject:s inSortedRange:NSMakeRange(0, [array count]) options:NSBinarySearchingFirstEqual usingComparator:^( NSString* obj1, NSString* obj2){
                return [obj1 compare:obj2 options:0];
            }];
        }
    }
	timeElapsed = -[start timeIntervalSinceNow];
    NSLog(@"time to binary search array 1000000 times: %g",timeElapsed);
#endif
	
	// ============== //
	
    path = [self pathToFileOfKind: kFileKindTxt];
	
    start = [NSDate date];
	
    StringTable* stringDict =
	[[[StringTable alloc] initWithContentsOfFile:path] autorelease];
	
	timeElapsed = -[start timeIntervalSinceNow];
    stringDictNumWordsTF.text = [NSString stringWithFormat: @"%i", [stringDict count]];
    stringDictTimeTF.text = [NSString stringWithFormat:@"%f",timeElapsed*1000];
    
    start = [NSDate date];
	
    SimpleStdioStringDict* stdioDict =
	[[[SimpleStdioStringDict alloc] initWithContentsOfFile:path] autorelease];
	NSLog(@"stdioDict: %@",stdioDict);
	timeElapsed = -[start timeIntervalSinceNow];
	
    stdioDictNumWordsTF.text = [NSString stringWithFormat: @"%i", [stringDict count]];
    stdioDictTimeTF.text = [NSString stringWithFormat:@"%f",timeElapsed*1000];
		

    for ( NSString *s in strings) {
        NSLog(@"strings %@ in dict: %d",s,[stringDict containsString:s]);
    }
	
    start = [NSDate date];
	
	
    for ( int i=0; i<1000; i++) {
        for ( NSString *s in strings) {
            [stringDict containsString:s];
        }
    }
	
	timeElapsed = -[start timeIntervalSinceNow];
    NSLog(@"time to bsearch 1000 times (via SimpleDict containsString:): %g",timeElapsed);
    // ============== //

    [sender setEnabled: YES];
}

// ========================================================================= //
                        #pragma mark private methods
// ========================================================================= //

- (NSString*) pathToFileOfKind: (FileKind) fileKind
{
    // NSLog(@"ViewController: -pathToFileOfKind");

    NSString* fname;
    NSString* path;

    switch (fileKind)
    {
        case kFileKindTxt:
            fname = @"dictionary.txt";
            path = [[NSBundle mainBundle]
                pathForResource: @"dictionary"
                         ofType: @"txt"];
        break;

        case kFileKindXml:
            fname = @"dictionary_xml.plist";
            path = [[NSBundle mainBundle]
                pathForResource: @"dictionary_xml"
                         ofType: @"plist"];
        break;

        case kFileKindBin:
            fname = @"dictionary_bin.plist";
            path = [[NSBundle mainBundle]
                pathForResource: @"dictionary_bin"
                         ofType: @"plist"];
        break;

        default:
            fname = nil;
            path = nil;
        break;
    }

    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath: path];

    if (fileExists)
    {
        return path;
    }
    else
    {
        NSLog(@"*** ERROR *** ERROR *** ERROR *** ERROR ***");
        NSLog(@"*** ERROR! file '%@' not found!", fname);

        return nil;
    }
}

// ========================================================================= //

@end
