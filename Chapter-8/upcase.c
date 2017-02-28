#include <stdio.h>
#include <ctype.h>

#define MAXLENGTH 8192

int main(int argc, char *argv[] ) {
	char buf[MAXLENGTH];
	while (fgets(buf,MAXLENGTH,stdin)) {
		buf[0]=toupper(buf[0]);
		fputs(buf,stdout);
	}
	return 0;
}
