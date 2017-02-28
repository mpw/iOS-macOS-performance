#include <stdio.h>
#include <ctype.h>


int main(int argc, char *argv[] ) {
	int first=1;
	int eof=0;
	do {
		char buffer;
		if ( read(0,&buffer,1)==1) {
			if ( first ) {
				buffer=toupper(buffer);
				first=0;
			}
			write(1,&buffer,1);
			if ( buffer=='\n' ) {
				first=1;
			}
		} else {
			eof=1;
		}
	} while (!eof);
	return 0;
}
