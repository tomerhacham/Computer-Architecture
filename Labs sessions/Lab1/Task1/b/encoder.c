#include <stdlib.h>
#include <stdio.h>
#include <string.h>

int main(int argc, char **argv) {
  char c, modified_char;
  char* encKey=""; //string of the encreption encryption key
  FILE * input=stdin;
  FILE * output=stdout;
  FILE * error = stderr;
  int debug=0; // 1 when -d argument is pass
  int encryption=0;
  int increment_encryption=0; // added key or subsitute key
  int valid_argument=0;
  int counter=0;

  //{parsing the arguments
  for(int i=1;i<argc;i++){
    valid_argument=0;
    if( (strcmp("-D",argv[i])==0) || (strcmp("-d",argv[i])==0)){//debug flag passed as argument
      valid_argument=1;
      debug=1;
      fprintf(error,"%s\n",argv[i]);
    }
    if( strncmp("-e",argv[i],2*sizeof(char))==0 || strncmp("+e",argv[i],2*sizeof(char))==0 ){//ecnoding flag passed as argument
      valid_argument=1;
      encryption=1;
      if(strncmp("+e",argv[i],2*sizeof(char))==0){increment_encryption=1;}//mode of encryption
      encKey=argv[i];
      strcpy(encKey, encKey+2*sizeof(char));//copy the actual values of the key
      //fprintf(output,"encoding key: %s\n",encKey);
    }
    if( strncmp("-o",argv[i],2*sizeof(char))==0){//specific output flag passed as arguments
      valid_argument=1;
      //output = fopen(strcat(argv[i]+2*sizeof(char),".txt"), "w");
      output = fopen(argv[i]+2*sizeof(char),"w");
      if(output==NULL){ // if a file can't be open
          fprintf(error,"Error in openning filename : %s\n", argv[i]);
          return 1; // error in file
    }
  }
  if( strncmp("-i",argv[i],2*sizeof(char))==0){//specific output flag passed as arguments
    valid_argument=1;
    input = fopen(argv[i]+2*sizeof(char), "r");
    if(input==NULL){ // if a file can't be open
        fprintf(error,"Error in reading from the file : %s\n", argv[i]);
        return 1; // error in file
  }
}
    if(!valid_argument){
      fprintf(error, "invalid argument given: %s\n",argv[i]);
      return 1;
    }
  }
  //flow of the program
  while(!(feof(input))){
      c=fgetc(input);
      modified_char=c;
      if(c!=EOF){
        if(encryption){
          char enc_char = encKey[counter%(strlen(encKey))];
          int enc_val = enc_char-48;
          //fprintf(stderr, "enc_char: %c, offset value is: %d\n",enc_char,enc_val );
          if(increment_encryption){modified_char=c+enc_val;}
          else{modified_char=c-enc_val;}
        }
        if(debug){fprintf(error, "%d\t",c );}
        if(!encryption && c<='z' && c>='a'){ modified_char=c-32;}
        if(debug){fprintf(error, "%d\n",modified_char );}
        if(encryption){
          counter++;
          if(c=='\n'){
            modified_char=c;
            counter=0;
          }
        }
        fputc(modified_char,output);
      }
      else{break;}
  }

  fclose(output);
  return 0;
}
