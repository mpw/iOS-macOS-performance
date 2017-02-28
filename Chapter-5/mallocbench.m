
#import <Foundation/Foundation.h>
#import <mach/mach_vm.h>


NSTimeInterval vm_allocTest( long size, long iterations )
{
	NSTimeInterval start=[NSDate timeIntervalSinceReferenceDate];
	vm_map_t self_task = mach_task_self();
	for (long i=0;i<iterations;i++) {
		mach_vm_address_t ptr=0;
		if ( mach_vm_allocate( self_task, &ptr, size , YES ) == KERN_SUCCESS ) { 
			mach_vm_deallocate( self_task, ptr, size );
		} else {
			NSLog(@"couldn't allocate %ld bytes from kernel",size);
			break;
		}
	}
	return ([NSDate timeIntervalSinceReferenceDate] - start) / iterations * (1000000000.0);
}


NSTimeInterval callocTest( long size, long iterations )
{
	NSTimeInterval start=[NSDate timeIntervalSinceReferenceDate];
	for (long i=0;i<iterations;i++) {
		void *ptr=calloc(  size, 1 );
		if ( ptr ) {
			free(ptr);
		} else {
            NSLog(@"couldn't allocate %ld bytes with calloc ",size);
            break;
        }
	}
	return ([NSDate timeIntervalSinceReferenceDate] - start) / iterations * (1000000000.0);
}


NSTimeInterval mallocTest( long size, long iterations )
{
	NSTimeInterval start=[NSDate timeIntervalSinceReferenceDate];
	for (long i=0;i<iterations;i++) {
		void *ptr=malloc( size );
		free(ptr);
	}
	return ([NSDate timeIntervalSinceReferenceDate] - start) / iterations * (1000000000.0);
}

int main() 
{
	printf("log2size , time (ns) ,  rate (byes/ns)\n");
	for (long log_size=1; log_size <20; log_size++ ) {
		long size = 1<<log_size;
		NSTimeInterval nsPerAlloc=mallocTest( size , 1000000 );
		printf("%10ld , %g ,  %g \n",log_size,nsPerAlloc,size/nsPerAlloc);
	}
}
