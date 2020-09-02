#include "util.h"

#define SYS_EXIT 1
#define SYS_READ 3
#define SYS_WRITE 4
#define SYS_OPEN 5
#define SYS_CLOSE 6
#define SYS_LSEEK 19
#define SEEK_SET 0

#define O_RDONLY 0
#define O_WRONLY 1
#define O_RDRW 2
#define O_CREATE 64


#define STDIN 0
#define STDOUT 1
#define STDERR 2

extern int system_call(int syscall, int arg1, int arg2, int arg3);

void errorHandler(int output,char* errorMessage){
  system_call(SYS_WRITE,output,errorMessage, strlen(errorMessage));
  system_call(SYS_EXIT,0x55,0,0);
}

void printDebug(int sys_call, int return_val){
  char tab = '\t';
  char newline = '\n';
  system_call(SYS_WRITE,STDERR,itoa(sys_call),strlen(itoa(sys_call)));
  system_call(SYS_WRITE,STDERR,&tab,1);
  system_call(SYS_WRITE,STDERR,itoa(return_val),strlen(itoa(return_val)));
  system_call(SYS_WRITE,STDERR,&newline,1);

}

int main (int argc , char* argv[], char* envp[])
{
  int input=STDIN;
  int output= STDOUT;
  int i;
  int active;
  int error_code;
  int valid_argument;
  int debug;
  char c;
  char modified_char;


  debug=0;
  active=1;
  for(i=1;i<argc;i++){
    valid_argument=0;
    if( (strcmp("-D",argv[i])==0)){
      valid_argument=1;
      debug=1;
    }
    if( strncmp("-o",argv[i],2*sizeof(char))==0){
      valid_argument=1;
      int fd_outputfile;
      fd_outputfile=system_call(SYS_OPEN,argv[i]+2*sizeof(char),O_WRONLY | O_CREATE,0777);
      if(fd_outputfile<0){errorHandler(STDOUT,"Cannot open file specified as output\n");}
      else{output=fd_outputfile;}
    }
    if( strncmp("-i",argv[i],2*sizeof(char))==0){
      valid_argument=1;
      int fd_inputfile;
      fd_inputfile=system_call(SYS_OPEN,argv[i]+2*sizeof(char),O_RDONLY,0777);
      if(fd_inputfile<0){errorHandler(STDOUT,"Cannot open file specified as input\n");}
      else{input=fd_inputfile;}

  }
    if(!valid_argument){
      errorHandler(output,"Invalid argument given\n");
    }
  }
  while (active){
    error_code=system_call(SYS_READ,input,&c,1);
    if(c!='\n'){
      modified_char=c;
      if(debug){
        printDebug(SYS_READ,error_code);
      }
      if(error_code<0){errorHandler(output,"Problem in addressing stdin\n");}
      if(c>='a' &&  c<='z'){modified_char=c-32;}
        error_code=system_call(SYS_WRITE,output,&modified_char,1);
      if(debug){
            system_call(SYS_WRITE,STDERR,"\n",1);
            printDebug(SYS_WRITE,error_code);
      }
      /*system_call(SYS_WRITE,output,"\n",1);*/
      if(error_code<0){errorHandler(output,"Problem in addressing stdout\n");}
    }
    else{active=0;system_call(SYS_WRITE,output,"\n",1);}
  }
  system_call(SYS_CLOSE,input,0,0);
  system_call(SYS_CLOSE,output,0,0);
  return 0;
}
