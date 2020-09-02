#include <stdio.h>
#include <stdlib.h>
#include <string.h>


typedef struct virus {
    unsigned short SigSize; //2
    char virusName[16]; //16
    unsigned char* sig; //8
} virus;

void PrintHex(FILE* output, unsigned char* buffer, unsigned short length) {
  for(int i=0;i<length;i++){
    fprintf(output,"%02hhX ",buffer[i]);
  }
  fprintf(output,"\n\n");
}

virus* readVirus(FILE* file){
  virus* virus  = malloc(sizeof(struct virus));
  if(fread(virus,1,18,file)!=0){
    virus->sig=malloc(virus->SigSize);
    fread(virus->sig,1,virus->SigSize,file);

  }
  return virus;
}

void printVirus(virus* virus, FILE* output){
  fprintf(output,"virus name: %s\n", virus->virusName);
  fprintf(output,"virus size: %d\n", virus->SigSize);
  fprintf(output,"signature:\n");
  PrintHex(output,virus->sig, virus->SigSize);
}

int get_file_size(FILE* file){
  fseek(file, 0L, SEEK_END);
  int file_size = ftell(file);
  rewind(file);
  return file_size;
}

void quit (int exit_code){
  exit(exit_code);
}

int main(int argc, char const *argv[]) {
  FILE* input;
  FILE* output = stdout;

  //Arguments parsing
  input = fopen(argv[1],"r");//setting the input stream the the givven file provided as argument
  if(input==NULL){ // if a file can't be open
    fprintf(stderr,"Error in reading from the file : %s\n", argv[1]);
    quit(EXIT_FAILURE);
  }
  for(int i=2;i<argc;i++){
    if( strncmp("-o",argv[i],2*sizeof(char))==0){//specific output flag passed as arguments
      output = fopen(argv[i]+2*sizeof(char),"w");
      if(output==NULL){ // if a file can't be open
          fprintf(stderr,"Error in openning filename : %s\n", argv[i]);
          quit(EXIT_FAILURE);
    }
  }
}

  //getting the size of the file
  int file_size = get_file_size(input);
  int readen_bytes = 0;
  while(readen_bytes<file_size){
    virus* virus = readVirus(input);
    printVirus(virus,output);
    readen_bytes+=18+virus->SigSize;
    free(virus);
  }
  return 0;
}
