#import <Foundation/Foundation.h>

int main(int argc, char *argv[] ) {
    [NSAutoreleasePool new];
    id a1=[NSMutableArray array];
    id a2=[NSMutableArray array];
    [a1 addObject:a2];
    [a2 addObject:a1];
    NSLog(@"a1: %@",[a1 description);
}
