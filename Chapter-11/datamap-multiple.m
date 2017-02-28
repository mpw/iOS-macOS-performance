
#import <Foundation/Foundation.h>

int main(int argc, char *argv[] ) {
     [NSAutoreleasePool new];
     int options=0;
     printf("start\n");
     if ( argv[2] ) {
	 options=(atoi(argv[2])==1) ? NSDataReadingMappedAlways : atoi(argv[2])==2 ? NSDataReadingUncached : 0;
     }
     NSString *basePath = [NSString stringWithUTF8String:argv[1]];
     NSFileManager *fm=[NSFileManager defaultManager];
     NSArray *files=[fm contentsOfDirectoryAtPath:basePath  error:nil];
    unsigned char result=0;
    NSLog(@"%ld files option: %d",[files count],options);
     for ( NSString *file in files ) {
       @autoreleasepool {
         NSString *relpath=[basePath stringByAppendingPathComponent: file];
         NSURL *url=[NSURL fileURLWithPath:relpath isDirectory:NO];
         NSData *data=[NSData dataWithContentsOfURL:url options:options error:nil];
         unsigned stride=4096;
         const char *bytes,*cur,*end;
         for (bytes=[data bytes],end=bytes+[data length],cur=bytes; cur < end-stride; cur+=stride ) {
             result ^= *cur;
         }     
      }
    }
    NSLog(@"result: %x",result);
}
