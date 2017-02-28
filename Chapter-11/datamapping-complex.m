
#import <Foundation/Foundation.h>

const char *readFileNSData( char *filename, int shouldMap, int uncached, long *size, int stride ) {
     NSData *data;
     NSURL *url=[NSURL fileURLWithPath:[NSString stringWithUTF8String:filename]];
     int mapping = shouldMap ? NSDataReadingMappedAlways : uncached ? NSDataReadingUncached : 0 ;
//     NSLog(@"file: %@, mapped: %d uncached: %d options:%d",url,shouldMap,uncached,mapping);
     data=[NSData dataWithContentsOfURL:url options:mapping error:nil];
     if ( shouldMap && stride <= 4096 ) {
	madvise( (void*)[data bytes], [data length], MADV_SEQUENTIAL  | MADV_WILLNEED  );
     }
     if ( size ) {
        *size=[data length];
     }
     return [data bytes];
}

const char *readFileUnix( char *filename, int shouldMap, int uncached, long *size ) {
    int fd=open( filename, O_RDONLY);
    off_t length=lseek(fd,0 , SEEK_END);
    char *result=NULL;
    NSLog(@"got fd: %d length: %lld",fd,length);
    if ( size ) {  *size=length; }
    if ( shouldMap ) {
	//  MAP_PRIVATE, MAP_NOCACHE
        result=mmap( NULL,  length, PROT_READ  , MAP_SHARED , fd, 0 );
#if 1
	    madvise( (void*)result, length, MADV_SEQUENTIAL | MADV_WILLNEED  );
#endif
    } else {
	lseek(fd,0 , SEEK_SET);
         result=malloc( length );
         NSLog(@"got result buf: %p",result);
         long long int numRead=read( fd, result, length );
         NSLog(@"read %lld bytes",numRead);
         if ( numRead <0 ) {
            perror("couldn't read");
         }
    }
    close(fd);
    return result;
}


int main(int argc, char *argv[] ) {
     [NSAutoreleasePool new];
     char *filename=argv[1];
     BOOL shouldMap=argv[2] && atoi(argv[2])==1;
     BOOL uncached=argv[2] && atoi(argv[2])==2; 
     int pageStride=argv[3] ? atoi(argv[3]) : 1;
     int stride = pageStride * 4096 + 1;
     char result=0;
     long length=0;
     const char *bytes=readFileNSData( filename, shouldMap, uncached, &length, stride );
//     const char *bytes=readFileUnix( filename, shouldMap, uncached, &length );
     const char *end=bytes+length;
     const char *cur=bytes;
//     NSLog(@"length: %ld stride=%d",length,stride);
     while ( cur >= bytes && cur < end ) {
         result ^= *cur;
	 cur+=stride;
     }     
     NSLog(@"result: %x",result);
}
