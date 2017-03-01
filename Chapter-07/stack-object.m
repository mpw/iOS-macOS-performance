
#import <MPWFoundation/MPWInteger.h>
#include <stdlib.h>
#include <string.h>
#include <objc/runtime.h>


int main(int argc, char *argv[]) {
	Class mpwint=[MPWInteger class];
	int instance_size=class_getInstanceSize( mpwint );
	id a=alloca( instance_size );
	bzero(a, instance_size );
	object_setClass(a, mpwint);
	[a setIntValue:43];
	NSLog(@"a=%@",a);
	return 0;
}
