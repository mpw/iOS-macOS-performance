#import <Foundation/Foundation.h>
int main(int argc, char *argv[] ) {
    NSURL *url=[NSURL fileURLWithPath:@(argv[1])];
    NSData *d=[NSData dataWithContentsOfURL:url options:0 error:nil];
    char result=0;
    const char *bytes=[d bytes];
    const char *end=bytes+[d length];
    for (const char *cur=bytes; cur < end; cur++ ) {
      result ^= *cur;
    }
    printf("result: \%x\n",result);
}
