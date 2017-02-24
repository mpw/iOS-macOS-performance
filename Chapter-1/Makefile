
all : objcbench sumintsc


objcbench : objcbench.m
	cc -F/Library/Frameworks/ -Wall -Wnoshadow-ivar -arch x86_64 -Os -o objcbench objcbench.m -framework Cocoa -framework MPWFoundation 

sumintsc : sumintsc.m
	cc -Wall -Wnoshadow-ivar -Os -o sumintsc sumintsc.m -framework Foundation

