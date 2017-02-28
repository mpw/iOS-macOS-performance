#import <Foundation/Foundation.h>
#include <malloc/malloc.h>

int main(int argc, char *argv[] )
{
    [NSAutoreleasePool new];
    int count=argc>1 ? atoi(argv[1]) : 1000;
    id base=@"Hello World!";
    int i;
    [[NSArray arrayWithObject:base] description];
    for ( i=0;i<count;i++) {
       base=[NSArray arrayWithObject:base];
    }
    struct mstats stats=mstats();
    long used_before=stats.bytes_used;
    NSString *d=[base description];
    stats=mstats();
    printf("n=%d description size: %ld memory used: %ld mem/size=%ld\n",count,[d length], stats.bytes_used-used_before,(stats.bytes_used-used_before)/[d length] );
    return 0;
}

