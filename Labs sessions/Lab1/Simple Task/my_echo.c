#include <stdlib.h>
#include <stdio.h>
#include <string.h>

int main(int argc, char **argv) {
  char* text="";
  FILE * output=stdout;
  for(int i=1;i<argc;i++){
    printf("%s%c",argv[i],' ');
  }
  printf("\n",output);
  return 0;
}
