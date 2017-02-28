

#import <MPWFoundation/MPWFoundation.h>

@interface DescriptionStream : MPWStream {}  @end  @implementation DescriptionStream


-(void)writeObject:anObject
{
  if ( [anObject isKindOfClass:[NSArray class]] ) {
     BOOL first=YES;
     [target writeObject:@"( "];
     for ( id content in anObject ) {
       if ( !first) {
          [target writeObject:@", "];
       } else {
          first=NO;
       }
       [self writeObject:content];
     }
     [target writeObject:@") "];
  } else {
    [target writeObject:[anObject description]];
  }
}

@end

int main( int argc, char *argv[] ) {
   [NSAutoreleasePool new];
   id s=[DescriptionStream streamWithTarget:[MPWByteStream Stdout]];
   [s writeObject:@[ @[ @"a", @"d" ], @"b", @"c" ]];
   return 0; 
}
