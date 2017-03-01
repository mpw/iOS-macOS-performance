import Foundation

func fn()
{
   let a1=NSMutableArray()
   let a2=NSMutableArray()
   a1.addObject(a2)
   a2.addObject(a1)
}

autoreleasepool {
	fn()
}
sleep(20);
