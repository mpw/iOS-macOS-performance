#include <stdio.h>
#include <stdlib.h>

int main( int argc , char *argv[] ) 
{
  int i,k,sum;
  int limit=argc > 1 ? atoi(argv[1]) : 1;
  limit *= 1000;
  for (k=0;k<limit; k++ ) {
    sum=0;
    for (i=1;i<= 10000;i++ ) {
      sum+=i;
    }
  }
  printf("%d\n",sum);
  return 0;
}
