#import <Foundation/Foundation.h>
#include <sys/stat.h>

int main( int argc, char *argv[] ) {
  char *filename=argv[1];
  int fd=open( filename, O_RDONLY );
  struct stat statbuf;
  fstat(fd, &statbuf);
  char *buffer=malloc( statbuf.st_size ); 
  read( fd, buffer, statbuf.st_size );
//  while ( size ) {
//    size=read(fd,buffer,size); 
//  }
  close(fd);
}
