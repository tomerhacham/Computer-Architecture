#include <stdio.h>
#include <stdlib.h>

void PrintHex(char* buffer, int length) {
  for(int i=0;i<length;i++){
    printf("%02hhX ",buffer[i]);
  }
  printf("\n");
}

int main(int argc, char **argv) {
  char c;
  FILE* input;
  char* buffer;
  int buffer_legnth=0;

  input = fopen(argv[1],"r");//setting the input stream the the givven file provided as argument
  if(input==NULL){ // if a file can't be open
    fprintf(stdout,"Error in reading from the file : %s\n", argv[1]);
    return 1; // error in file
  }
  //count the length of the buffer
  while((c = (fgetc(input)))!=EOF){
    buffer_legnth++;
  }
  rewind(input); //setting the file indicator to the beggining of the file
  //alocate memory dynamicly
  buffer = (char*)(malloc(buffer_legnth*sizeof(char)));
  fread(buffer, sizeof(char), buffer_legnth+1,input);
  PrintHex(buffer, buffer_legnth);
  free(buffer);
  fclose(input);
  return 0;
}
