
#import <Foundation/Foundation.h>

int main(int argc, char *argv[] ) {
     const unsigned char *bytes,*end,*cur;
     int pageStride=argv[3] ? atoi(argv[3]) : 0;
     int pageOffset=argv[4] ? atoi(argv[4]) : 0;
     int stride = pageStride * 4096 +  pageOffset;
     printf("pageStride: %d pageOffset: %d -> stride: %d\n",pageStride,pageOffset,stride);
     int options = 0;
     [NSAutoreleasePool new];
     printf("start\n");
     if ( argv[2] ) {
	 options=(atoi(argv[2])==1) ? NSDataReadingMappedAlways : atoi(argv[2])==2 ? NSDataReadingUncached : 0;
     }
     NSURL *url=[NSURL fileURLWithPath:[NSString stringWithUTF8String:argv[1]] isDirectory:NO];
     NSData *data=[NSData dataWithContentsOfURL:url options:options error:nil];
     if ( 0 &&  options == NSDataReadingMappedAlways ) {
        madvise( [data bytes],[data length], MADV_SEQUENTIAL | MADV_WILLNEED );
         printf("madvise\n");
     }
     unsigned char result=0;
     for (bytes=[data bytes],end=bytes+[data length],cur=bytes; cur < end-stride; cur+=stride ) {
         result ^= *cur;
     }     
     printf("stride: %d result: %x\n",stride,result);
    [data writeToFile:@"out" atomically:NO];
}
