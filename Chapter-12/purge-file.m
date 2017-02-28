#include <stdlib.h>
#include <unistd.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>

void purgeFile( char *filename ) {
    int fd=open( filename, O_RDONLY);
    struct stat st;
    fstat( fd, &st );
    off_t length=st.st_size;
    //  MAP_PRIVATE, MAP_NOCACHE
    const char *result=mmap( NULL,  length, PROT_READ  , MAP_SHARED , fd, 0 );
    madvise( (void*)result, length, MADV_FREE  );
    close(fd);
}


int main(int argc, char *argv[] ) {
     char *filename=argv[1];
     purgeFile( filename );
}
