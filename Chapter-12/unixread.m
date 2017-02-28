#include <stdlib.h>
#include <fcntl.h>
#include <unistd.h>

int main( int argc, char *argv[] ) {
  char *filename=argv[1];
  int kbsize = argv[2]? atoi(argv[2]) : 8;
  size_t size=kbsize*1024;
  char *buffer=malloc(size);
  int fd=open( filename, O_RDONLY );
  while ( size ) {
    size=read(fd,buffer,size); 
  }
  close(fd);
}
