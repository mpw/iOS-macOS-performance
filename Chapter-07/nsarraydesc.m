#import <Foundation/Foundation.h>
#include <malloc/malloc.h>

int main(int argc, char *argv[] )
{
    id pool=[NSAutoreleasePool new];
    int count=argc>1 ? atoi(argv[1]) : 1000;
    NSLog(@"%d entries",count);
    id base=@"Hello World!";
    int i;
    for ( i=0;i<count;i++) {
       base=[NSArray arrayWithObject:base];
    }
    NSLog(@"description has %d bytes",[[base description] length]);
    struct mstats stats=mstats();
    NSLog(@"memory in use: %u bytes",stats.bytes_used);
    exit(0);
    [pool release];
    return 0;
}

