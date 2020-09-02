#include <stdlib.h>
#include <stdio.h>
#include <string.h>

int main(int argc, char **argv) {
  FILE * input=stdin;
  FILE * output=stdout;
  int c;
  while(!(feof(input))){
    c=fgetc(input);
    if(c<='z' && c>='a'){
      c=c-32;
    }
    fputc(c,output);
  }
  return 0;
}
