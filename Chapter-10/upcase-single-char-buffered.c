#include <stdio.h>
#include <ctype.h>


int main(int argc, char *argv[] ) {
	int first=1;
	int ch;
	while ( (ch=getchar()) != EOF ) {
		if ( first ) {
			ch=toupper(ch);
			first=0;
		}
		putchar(ch);
		if ( ch=='\n' ) {
			first=1;
		}
	}
	return 0;
}
