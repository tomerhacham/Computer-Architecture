#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int main (int argc, char** argv){
  int iarray[] = {1,2,3};
  char carray[] = {'a','b','c'};
  int* iarrayPtr = iarray;
  char* carrayPtr= carray;
  int* p;

  for(int i=0;i<3;i++){
    printf("iarray[%d]: %d\n",i,*(iarrayPtr+i));
    printf("carray[%d]: %c\n",i,*(carrayPtr+i));
  }
  printf("pointer p value: %p\n",p);// located on the stack (high address)

}
